//
//  NotificationService.swift
//  MessengerNotificationService
//
//  If there is a build error cyclical dependency follow this: https://github.com/flutter/flutter/issues/134256
//
//  Created by Christian Knab on 6/13/26.
//

import UserNotifications

// class NotificationService: UNNotificationServiceExtension {
//
//     var contentHandler: ((UNNotificationContent) -> Void)?
//     var bestAttemptContent: UNMutableNotificationContent?
//
//     override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//         self.contentHandler = contentHandler
//         bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//         if let bestAttemptContent = bestAttemptContent {
//             // Modify the notification content here...
//             bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//
//             contentHandler(bestAttemptContent)
//         }
//     }
//
//     override func serviceExtensionTimeWillExpire() {
//         // Called just before the extension will be terminated by the system.
//         // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//         if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//             contentHandler(bestAttemptContent)
//         }
//     }
//
// }

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    func debugBody(_ msg: String) {
        bestAttemptContent?.body = msg
        if let content = bestAttemptContent {
            self.contentHandler?(content)
        }
    }
    
    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
        
        let userInfo = request.content.userInfo
        
        guard let ciphertextB64 = userInfo["mls_message"] as? String else {
            debugBody("DEBUG: mls_message missing. got: \(userInfo["mls_message"] ?? "nil")")
            return
        }
        guard let groupIdB64 = userInfo["group_id"] as? String else {
            debugBody("DEBUG: group_id missing. got: \(userInfo["group_id"] ?? "nil")")
            return
        }
        guard let ciphertext = Data(base64Encoded: ciphertextB64) else {
            debugBody("DEBUG: mls_message b64 decode failed: \(String(ciphertextB64.prefix(40)))...")
            return
        }
        guard let groupId = Data(base64Encoded: groupIdB64) else {
            debugBody("DEBUG: group_id b64 decode failed: \(String(groupIdB64.prefix(40)))...")
            return
        }
        guard let dbPath = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.untitledApp")?
                .appendingPathComponent("mls.db").path
        else {
            debugBody("DEBUG: no dbPath (App Group container missing?)")
            return
        }
        
        let key = loadEncryptionKey()
        guard key.count == 32 else {
            // debugBody("DEBUG: key not 32 bytes, got \(key.count)")
            return
        }
        
        var err: UnsafeMutablePointer<CChar>?
        let engine = key.withUnsafeBytes { keyBytes in
            openmls_push_decrypt_create(dbPath, keyBytes.baseAddress!, 32, &err)
        }
        
        if let err = err {
            let msg = String(cString: err)
            openmls_push_decrypt_free_string(err)
            debugBody("DEBUG: engine error: \(msg)")
            return
        }
        
        var pt: UnsafeMutablePointer<UInt8>?
        var ptLen: Int = 0
        
        let rc = groupId.withUnsafeBytes { gid in
            ciphertext.withUnsafeBytes { msg in
                openmls_push_decrypt_message(
                    engine,
                    gid.baseAddress!, gid.count,
                    msg.baseAddress!, msg.count,
                    &pt, &ptLen, nil, &err
                )
            }
        }
        
        if rc == 0, let pt = pt {
            let plaintext = Data(bytes: pt, count: ptLen)
            let body = String(data: plaintext, encoding: .utf8) ?? "New message"
            openmls_push_decrypt_free_bytes(pt, ptLen)
            // Try to extract message content from ActivityPub JSON
            if let json = try? JSONSerialization.jsonObject(with: plaintext) as? [String: Any],
               let obj = json["object"] as? [String: Any],
               let content = obj["content"] as? String {
                bestAttemptContent?.body = content
                // Use sender's name from actor field if available
                if let actor = json["actor"] as? String,
                   let actorUrl = URL(string: actor) {
                    bestAttemptContent?.title = actorUrl.lastPathComponent
                }
            } else {
                bestAttemptContent?.body = body
            }
            if let content = bestAttemptContent {
                contentHandler(content)
            }
        } else if rc == 1 {
            debugBody("DEBUG: non-application msg (rc=1)")
        } else if let err = err {
            let msg = String(cString: err)
            openmls_push_decrypt_free_string(err)
            debugBody("DEBUG: decrypt error: \(msg)")
        } else {
            debugBody("DEBUG: unknown failure rc=\(rc)")
        }
        
        openmls_push_decrypt_free(engine)
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func loadEncryptionKey() -> Data {
        // Try multiple query variants to find the key stored by FlutterSecureStorage
        let queries: [[String: Any]] = [
            // 1. Service + account + access group with Team ID prefix
            [kSecClass as String: kSecClassGenericPassword,
             kSecAttrService as String: "FlutterSecureStorage",
             kSecAttrAccount as String: "mls_encryption_key",
             kSecAttrAccessGroup as String: "7ZD8Y5HH26.group.com.example.untitledApp",
             kSecReturnData as String: true],
            // 2. Service + account only
            [kSecClass as String: kSecClassGenericPassword,
             kSecAttrService as String: "FlutterSecureStorage",
             kSecAttrAccount as String: "mls_encryption_key",
             kSecReturnData as String: true],
            // 3. Account only
            [kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccount as String: "mls_encryption_key",
             kSecReturnData as String: true],
        ]
        for (i, query) in queries.enumerated() {
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecSuccess, let data = item as? Data {
                if let b64 = String(data: data, encoding: .utf8),
                   let key = Data(base64Encoded: b64),
                   key.count == 32
                {
                    return key
                }
                debugBody("DEBUG: query \(i) found \(data.count)B not valid key")
                return Data()
            } else if status == errSecItemNotFound {
                continue
            } else {
                debugBody("DEBUG: query \(i) status=\(status)")
                return Data()
            }
        }
        debugBody("DEBUG: all queries returned errSecItemNotFound")
        return Data()
    }
}
