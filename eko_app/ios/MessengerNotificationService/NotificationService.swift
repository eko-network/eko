//
//  NotificationService.swift
//  MessengerNotificationService
//
//  If there is a build error cyclical dependency follow this: https://github.com/flutter/flutter/issues/134256
//
//  Created by Christian Knab on 6/13/26.
//

import CryptoKit
import Foundation
import OSLog
import Security
import UserNotifications

/// Pushes only say that a message arrived. This fetches the inbox and applies
/// its messages to the MLS state it shares with the app (openmls_push.h),
/// which keeps each one's plaintext for the app to store, acks them, and
/// shows one notification per message.
///
/// Messages are applied in inbox order, and a group's commits only by the app:
/// once one turns up, the rest of that group is left for the app. Anything
/// that was not applied stays in the inbox, unacked, and a push whose message
/// was not applied shows what the server sent.
class NotificationService: UNNotificationServiceExtension {

    // each run holds the MLS database while it applies, so one at a time
    private static let queue = DispatchQueue(label: "com.example.untitledApp.NotificationService")

    private let lock = NSLock()
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var fallback: UNNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        fallback = request.content
        let data = request.content.userInfo["data"] as? [String: Any]
        let run = Run(
            pushedObjectId: data?["object_id"] as? String,
            // the system gives 30 seconds, this leaves room to show what was found
            deadline: Date().addingTimeInterval(20))
        Self.queue.async {
            self.deliver(run.content() ?? request.content)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let fallback = fallback {
            deliver(fallback)
        }
    }

    private func deliver(_ content: UNNotificationContent) {
        lock.lock()
        let handler = contentHandler
        contentHandler = nil
        lock.unlock()
        handler?(content)
    }
}

private let appGroup = "group.com.example.untitledApp"
private let logger = Logger(subsystem: "com.example.untitledApp.NotificationService", category: "PushExtension")

/// Set once the target has the com.apple.developer.usernotifications.filtering
/// entitlement, which lets a push whose message was already shown show nothing.
private let filtersNotifications =
    Bundle.main.object(forInfoDictionaryKey: "EkoFiltersNotifications") as? Bool ?? false

/// The id of the notification for a message, which the server also sends its
/// push as apns-collapse-id, so the push replaces what this showed for it
/// instead of showing it twice. See apns_collapse_id in eko-messenger.
private func notificationId(objectId: String) -> String {
    base64Url(Data(SHA256.hash(data: Data(objectId.utf8))))
}

private func base64Url(_ data: Data) -> String {
    data.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

/// A message this run applied, or an earlier one did.
private struct Applied {
    let objectId: String
    /// Who the server says sent it, whom the ack goes to.
    let actor: String
    let groupId: Data
    /// Who MLS says sent it.
    let sender: String
    let plaintext: Data
    let earlier: Bool
}

private struct Run {
    let pushedObjectId: String?
    let deadline: Date

    func content() -> UNNotificationContent? {
        guard let config = SharedConfig.load() else {
            logger.error("no config shared by the app")
            return nil
        }
        let session = URLSession(configuration: {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 5
            configuration.timeoutIntervalForResource = 8
            return configuration
        }())
        guard let inbox = fetchInbox(config, session) else { return nil }

        let applied = apply(inbox)
        for message in applied where Date() < deadline {
            ack(message, config, session)
        }

        let names = Names.load()
        var pushedApplied = false
        var pushed: UNNotificationContent?
        var shown: [String] = []
        for message in applied {
            if message.objectId == pushedObjectId {
                pushedApplied = true
                if message.sender != config.actor {
                    pushed = notification(for: message, names)
                }
                continue
            }
            guard !message.earlier, message.sender != config.actor,
                  let content = notification(for: message, names)
            else { continue }
            // e.g. its push was dropped while the device was offline, APNs
            // only keeps the last one
            let id = notificationId(objectId: message.objectId)
            show(UNNotificationRequest(identifier: id, content: content, trigger: nil))
            shown.append(id)
        }
        Shown.add(shown)

        if let pushed = pushed {
            return pushed
        }
        if pushedApplied {
            // nothing the app shows either, e.g. a message from this user
            return filtersNotifications ? UNNotificationContent() : nil
        }
        // an earlier run found the message in the inbox and showed it
        guard let objectId = pushedObjectId else { return nil }
        let id = notificationId(objectId: objectId)
        guard Shown.contains(id) else { return nil }
        return Shown.delivered(id) ?? (filtersNotifications ? UNNotificationContent() : nil)
    }

    private func fetchInbox(_ config: SharedConfig, _ session: URLSession) -> [[String: Any]]? {
        var request = URLRequest(url: config.inbox)
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        guard let result = session.load(request),
              (result.1 as? HTTPURLResponse)?.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: result.0) as? [String: Any]
        else {
            logger.error("fetching the inbox failed")
            return nil
        }
        return json["orderedItems"] as? [[String: Any]] ?? []
    }

    private func apply(_ inbox: [[String: Any]]) -> [Applied] {
        guard let key = SharedConfig.mlsKey(),
              let dbPath = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
                .appendingPathComponent("mls.db").path
        else {
            logger.error("no MLS key or database")
            return []
        }
        var err: UnsafeMutablePointer<CChar>?
        // waits up to five seconds while the app holds the database
        let opened = key.withUnsafeBytes { bytes in
            openmls_push_open(dbPath, bytes.bindMemory(to: UInt8.self).baseAddress, key.count, &err)
        }
        guard let push = opened else {
            logger.error("opening the MLS database failed: \(takeString(err), privacy: .public)")
            return []
        }
        // closed before anything is shown: iOS ends a suspended process that
        // holds a lock on a file in the app group
        defer { openmls_push_close(push) }

        var applied: [Applied] = []
        var waiting = Set<Data>()
        for item in inbox {
            guard Date() < deadline else { break }
            guard item["type"] as? String == "Create",
                  let actor = item["actor"] as? String,
                  let object = item["object"] as? [String: Any],
                  object["type"] as? String == "PrivateMessage",
                  let objectId = object["id"] as? String,
                  let content = object["content"] as? String,
                  let message = Data(base64Encoded: content),
                  let groupId = groupId(of: message),
                  !waiting.contains(groupId)
            else { continue }
            switch receive(push, message, objectId: objectId, actor: actor) {
            case .applied(let message):
                applied.append(message)
            case .notApplication:
                // the app applies it, and then what follows it
                waiting.insert(groupId)
            case .failed(let error):
                // e.g. a group this device has not joined yet
                logger.error("\(objectId, privacy: .public) not applied: \(error, privacy: .public)")
                waiting.insert(groupId)
            }
        }
        return applied
    }

    private func groupId(of message: Data) -> Data? {
        var group: UnsafeMutablePointer<UInt8>?
        var groupLen = 0
        let rc = message.withUnsafeBytes { bytes in
            openmls_push_group_id(bytes.bindMemory(to: UInt8.self).baseAddress, message.count,
                                  &group, &groupLen, nil)
        }
        return rc == 0 ? takeBytes(group, groupLen) : nil
    }

    private enum Received {
        case applied(Applied)
        case notApplication
        case failed(String)
    }

    private func receive(_ push: OpaquePointer, _ message: Data, objectId: String, actor: String) -> Received {
        var plaintext: UnsafeMutablePointer<UInt8>?
        var plaintextLen = 0
        var sender: UnsafeMutablePointer<UInt8>?
        var senderLen = 0
        var group: UnsafeMutablePointer<UInt8>?
        var groupLen = 0
        var err: UnsafeMutablePointer<CChar>?
        let rc = message.withUnsafeBytes { bytes in
            openmls_push_receive(push, bytes.bindMemory(to: UInt8.self).baseAddress, message.count,
                                 objectId, &plaintext, &plaintextLen, &sender, &senderLen,
                                 &group, &groupLen, &err)
        }
        let groupId = takeBytes(group, groupLen)
        switch rc {
        case OPENMLS_PUSH_STASHED, OPENMLS_PUSH_ALREADY_STASHED:
            return .applied(Applied(
                objectId: objectId,
                actor: actor,
                groupId: groupId,
                sender: String(decoding: takeBytes(sender, senderLen), as: UTF8.self),
                plaintext: takeBytes(plaintext, plaintextLen),
                earlier: rc == OPENMLS_PUSH_ALREADY_STASHED))
        case OPENMLS_PUSH_NOT_APPLICATION:
            return .notApplication
        default:
            return .failed(takeString(err))
        }
    }

    /// Mirrors the app's ack. The message was applied, so a failed ack only
    /// leaves its inbox entry, which is acked again from there.
    private func ack(_ message: Applied, _ config: SharedConfig, _ session: URLSession) {
        let delivered: [String: Any] = [
            "@context": ["https://www.w3.org/ns/activitystreams",
                         ["ecp": "https://www.w3.org/ns/activitystreams"]],
            "type": "Delivered",
            "actor": config.actor,
            "to": [message.actor],
            "object": message.objectId,
        ]
        var request = URLRequest(url: config.outbox)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: delivered)
        let status = (session.load(request)?.1 as? HTTPURLResponse)?.statusCode ?? 0
        if status != 201 {
            logger.error("ack of \(message.objectId, privacy: .public) failed: \(status)")
        }
    }

    /// What MessengerNotificationService shows on Android: the sender and the
    /// text. Nothing for what the app does not show as a message, and no
    /// content for a group it hides.
    private func notification(for message: Applied, _ names: Names) -> UNNotificationContent? {
        guard let activity = try? JSONSerialization.jsonObject(with: message.plaintext) as? [String: Any],
              activity["type"] as? String == "Create",
              let object = activity["object"] as? [String: Any],
              let type = object["type"] as? String, type == "Note" || type == "Image"
        else { return nil }

        let content = UNMutableNotificationContent()
        content.sound = .default
        let group = base64Url(message.groupId)
        content.threadIdentifier = group
        guard let path = names.groups[group] else {
            content.title = "New message"
            return content
        }
        let uid = URL(string: message.sender)?.lastPathComponent ?? ""
        content.title = names.users[uid].map { "@\($0)" } ?? "New message"
        let text = (object["content"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let attachments = object["attachments"] as? [Any] ?? []
        if !text.isEmpty {
            content.body = text
        } else if type == "Image" || !attachments.isEmpty {
            content.body = "Sent an attachment"
        } else {
            content.body = "New message"
        }
        // what the app's tap handler opens
        content.userInfo = ["data": ["type": "message", "path": path]]
        return content
    }

    private func show(_ request: UNNotificationRequest) {
        let done = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                logger.error("showing failed: \(error.localizedDescription, privacy: .public)")
            }
            done.signal()
        }
        _ = done.wait(timeout: .now() + 2)
    }
}

/// What the app shares in the keychain, see notification_service_share.dart.
private struct SharedConfig {
    let actor: String
    let inbox: URL
    let outbox: URL
    let token: String

    static func load() -> SharedConfig? {
        guard let data = keychainItem("messenger_notification_service"),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
              let actor = json["actor"],
              let inbox = json["inbox"].flatMap({ URL(string: $0) }),
              let outbox = json["outbox"].flatMap({ URL(string: $0) }),
              let token = json["token"]
        else { return nil }
        return SharedConfig(actor: actor, inbox: inbox, outbox: outbox, token: token)
    }

    static func mlsKey() -> Data? {
        guard let data = keychainItem("mls_encryption_key"),
              let b64 = String(data: data, encoding: .utf8),
              let key = Data(base64Encoded: b64), key.count == 32
        else { return nil }
        return key
    }

    private static func keychainItem(_ account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            logger.error("keychain \(account, privacy: .public): \(status)")
            return nil
        }
        return item as? Data
    }
}

/// The active groups by base64url group id, with the path the app opens for
/// each, and usernames by uid. Written by the app.
private struct Names {
    var groups: [String: String] = [:]
    var users: [String: String] = [:]

    static func load() -> Names {
        guard let url = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
                .appendingPathComponent("notification_names.json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return Names() }
        return Names(groups: json["groups"] as? [String: String] ?? [:],
                     users: json["users"] as? [String: String] ?? [:])
    }
}

/// The ids of the last notifications shown for messages other than their
/// push's, which their own push then replaces.
private enum Shown {
    private static let limit = 200
    private static var url: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("notification_shown.json")
    }

    private static func load() -> [String] {
        guard let url = url, let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONSerialization.jsonObject(with: data) as? [String]) ?? []
    }

    static func contains(_ id: String) -> Bool {
        load().contains(id)
    }

    static func add(_ ids: [String]) {
        guard !ids.isEmpty, let url = url,
              let data = try? JSONSerialization.data(withJSONObject: Array((load() + ids).suffix(limit)))
        else { return }
        try? data.write(to: url, options: .atomic)
    }

    /// What is shown under `id`, while it is in Notification Center.
    static func delivered(_ id: String) -> UNNotificationContent? {
        let done = DispatchSemaphore(value: 0)
        let content = Box<UNNotificationContent>()
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            content.value = notifications.first { $0.request.identifier == id }?.request.content
            done.signal()
        }
        _ = done.wait(timeout: .now() + 2)
        return content.value
    }
}

/// What a completion handler hands back to a caller that waits for it.
private final class Box<Value>: @unchecked Sendable {
    var value: Value?
}

private func takeBytes(_ pointer: UnsafeMutablePointer<UInt8>?, _ count: Int) -> Data {
    guard let pointer = pointer else { return Data() }
    defer { openmls_push_free_bytes(pointer, count) }
    return Data(bytes: pointer, count: count)
}

private func takeString(_ pointer: UnsafeMutablePointer<CChar>?) -> String {
    guard let pointer = pointer else { return "unknown error" }
    defer { openmls_push_free_string(pointer) }
    return String(cString: pointer)
}

private extension URLSession {
    /// Blocks, runs are on their own queue.
    func load(_ request: URLRequest) -> (Data, URLResponse)? {
        let done = DispatchSemaphore(value: 0)
        let result = Box<(Data, URLResponse)>()
        dataTask(with: request) { data, response, _ in
            if let data = data, let response = response {
                result.value = (data, response)
            }
            done.signal()
        }.resume()
        done.wait()
        return result.value
    }
}
