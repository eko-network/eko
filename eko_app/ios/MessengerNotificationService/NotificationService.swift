//
//  NotificationService.swift
//  MessengerNotificationService
//
//  If there is a build error cyclical dependency follow this: https://github.com/flutter/flutter/issues/134256
//
//  Created by Christian Knab on 6/13/26.
//

import UserNotifications
import OSLog

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    private let logger = Logger(subsystem: "com.example.untitledApp.NotificationService", category: "PushExtension")
    
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
            let msg = "mls_message missing"
            logger.debug("[didReceive] \(msg)")
            debugBody("DEBUG: \(msg). got: \(userInfo["mls_message"] ?? "nil")")
            return
        }
        guard let groupIdB64 = userInfo["group_id"] as? String else {
            let msg = "group_id missing"
            logger.debug("[didReceive] \(msg)")
            debugBody("DEBUG: \(msg). got: \(userInfo["group_id"] ?? "nil")")
            return
        }
        guard let ciphertext = Data(base64Encoded: ciphertextB64) else {
            let msg = "mls_message b64 decode failed"
            logger.debug("[didReceive] \(msg)")
            debugBody("DEBUG: \(msg): \(String(ciphertextB64.prefix(40)))...")
            return
        }
        guard let groupId = Data(base64Encoded: groupIdB64) else {
            let msg = "group_id b64 decode failed"
            logger.debug("[didReceive] \(msg)")
            debugBody("DEBUG: \(msg): \(String(groupIdB64.prefix(40)))...")
            return
        }
        guard let dbPath = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.untitledApp")?
                .appendingPathComponent("mls.db").path
        else {
            let msg = "no dbPath (App Group container missing?)"
            logger.debug("[didReceive] \(msg)")
            debugBody("DEBUG: \(msg)")
            return
        }
        
        // get the key
        let key = loadEncryptionKey()
        guard key.count == 32 else {
            logger.debug("[didReceive] encryption key not 32 bytes, got \(key.count)")
            return
        }
        
        var err: UnsafeMutablePointer<CChar>?
        let engine = key.withUnsafeBytes { keyBytes in
            openmls_push_decrypt_create(dbPath, keyBytes.baseAddress!, 32, &err)
        }
        
        if let err = err {
            let msg = String(cString: err)
            openmls_push_decrypt_free_string(err)
            logger.debug("[didReceive] engine error: \(msg, privacy: .public)")
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
            logger.debug("[didReceive] decrypted \(ptLen)B plaintext")

            // store decrypted message in ecp.db so the app has when opend
            storeDecryptedMessageInAppDb(groupId: groupId, plaintext: plaintext)

            // try to extract message content from ActivityPub JSON
            if let json = try? JSONSerialization.jsonObject(with: plaintext) as? [String: Any],
               let obj = json["object"] as? [String: Any],
               let content = obj["content"] as? String {
                bestAttemptContent?.body = content
                // use sender's name from actor field if available
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
            logger.debug("[didReceive] non-application msg (rc=1)")
            debugBody("DEBUG: non-application msg (rc=1)")
        } else if let err = err {
            let msg = String(cString: err)
            openmls_push_decrypt_free_string(err)
            logger.debug("[didReceive] decrypt error: \(msg, privacy: .public)")
            debugBody("DEBUG: decrypt error: \(msg)")
        } else {
            logger.debug("[didReceive] unknown failure rc=\(rc)")
            debugBody("DEBUG: unknown failure rc=\(rc)")
        }
        
        openmls_push_decrypt_free(engine)
        logger.debug("[didReceive] engine freed")
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    /// open ecp.db via SQLCipher and insert the decrypted message + mark as processed.
    private func storeDecryptedMessageInAppDb(groupId: Data, plaintext: Data) {
        let tag = "[storeDecryptedMessageInAppDb]"
        guard let appGroup = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.untitledApp")
        else {
            logger.debug("\(tag) App Group container not available")
            return
        }

        let dbPath = appGroup.appendingPathComponent("ecp.db").path
        guard FileManager.default.fileExists(atPath: dbPath) else {
            logger.debug("\(tag) ecp.db does not exist yet at \(dbPath, privacy: .public)")
            return
        }

        guard let dbKey = loadDbEncryptionKey() else {
            let msg = "db_encryption_key not found"
            logger.debug("\(tag) \(msg)")
            debugBody("DEBUG: \(msg)")
            return
        }

        var db: OpaquePointer?
        guard sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK,
              let db = db
        else {
            logger.debug("\(tag) failed to open ecp.db")
            return
        }

        // set SQLCipher key — this always returns OK; real check is deferred
        let keyStmt = "PRAGMA key = '\(dbKey)';"
        sqlite3_exec(db, keyStmt, nil, nil, nil)

        // verify key by querying the schema
        if sqlite3_exec(db, "SELECT count(*) FROM sqlite_master;", nil, nil, nil) != SQLITE_OK {
            let msg = String(cString: sqlite3_errmsg(db))
            logger.debug("\(tag) wrong key or corrupt db — skipping write (app will handle): \(msg, privacy: .public)")
            sqlite3_close(db)
            return
        }

        // parse ActivityPub JSON payload
        let json = try? JSONSerialization.jsonObject(with: plaintext) as? [String: Any]
        let serverActivityId = json?["id"] as? String ?? UUID().uuidString
        let senderId = json?["actor"] as? String ?? ""
        let obj = json?["object"] as? [String: Any]
        let content = obj?["content"] as? String
        let inReplyTo = obj?["inReplyTo"] as? String
        let messageId = obj?["id"] as? String ?? UUID().uuidString
        logger.debug("\(tag) processing msg serverActivityId=\(serverActivityId, privacy: .public)")

        // Drift stores DateTime as seconds since epoch
        let receivedAt = Int64(Date().timeIntervalSince1970)
        logger.debug("\(tag) raw timeIntervalSince1970=\(Date().timeIntervalSince1970) receivedAt=\(receivedAt)")

        // check if the message has already been processed
        let checkSQL = "SELECT COUNT(*) FROM processed_objects WHERE id = ?;"
        var checkStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, checkSQL, -1, &checkStmt, nil) == SQLITE_OK {
            sqlite3_bind_text(checkStmt, 1, (serverActivityId as NSString).utf8String, -1, nil)
            if sqlite3_step(checkStmt) == SQLITE_ROW, sqlite3_column_int(checkStmt, 0) > 0 {
                sqlite3_finalize(checkStmt)
                sqlite3_close(db)
                logger.debug("\(tag) already processed, skipping")
                return
            }
            sqlite3_finalize(checkStmt)
        }

        // insert into stored_messages
        let insertSQL = """
            INSERT OR IGNORE INTO stored_messages
                (server_activity_id, received_at, sender_id, id, content, group_id, in_reply_to, delivered)
            VALUES (?, ?, ?, ?, ?, ?, ?, 0);
        """
        var insertStmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertSQL, -1, &insertStmt, nil) == SQLITE_OK,
              let insertStmt = insertStmt
        else {
            let msg = String(cString: sqlite3_errmsg(db))
            logger.debug("\(tag) prepare insert failed: \(msg, privacy: .public)")
            debugBody("DEBUG: prepare insert failed: \(msg)")
            sqlite3_close(db)
            return
        }

        sqlite3_bind_text(insertStmt, 1, (serverActivityId as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(insertStmt, 2, receivedAt)
        sqlite3_bind_text(insertStmt, 3, (senderId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertStmt, 4, (messageId as NSString).utf8String, -1, nil)
        if let content = content {
            sqlite3_bind_text(insertStmt, 5, (content as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(insertStmt, 5)
        }
        groupId.withUnsafeBytes { buf in
            sqlite3_bind_blob(insertStmt, 6, buf.baseAddress, Int32(buf.count), nil)
        }
        if let inReplyTo = inReplyTo {
            sqlite3_bind_text(insertStmt, 7, (inReplyTo as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(insertStmt, 7)
        }

        if sqlite3_step(insertStmt) != SQLITE_DONE {
            let msg = String(cString: sqlite3_errmsg(db))
            logger.debug("\(tag) insert failed: \(msg, privacy: .public)")
            debugBody("DEBUG: insert failed: \(msg)")
            sqlite3_finalize(insertStmt)
            sqlite3_close(db)
            return
        }
        sqlite3_finalize(insertStmt)
        logger.debug("\(tag) inserted stored_message")

        // mark as processed
        let markSQL = "INSERT OR IGNORE INTO processed_objects (id) VALUES (?);"
        var markStmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, markSQL, -1, &markStmt, nil) == SQLITE_OK,
              let markStmt = markStmt
        else {
            let msg = String(cString: sqlite3_errmsg(db))
            logger.debug("\(tag) prepare mark_processed failed: \(msg, privacy: .public)")
            sqlite3_close(db)
            return
        }

        sqlite3_bind_text(markStmt, 1, (serverActivityId as NSString).utf8String, -1, nil)
        if sqlite3_step(markStmt) == SQLITE_DONE {
            logger.debug("\(tag) marked processed_objects")
        }
        sqlite3_finalize(markStmt)
        sqlite3_close(db)
    }

    /// read the ecp.db encryption key from the shared .ecp_db_key file in the App Group container.
    /// eko flutter writes this file in _writeSharedDbKeyFile().
    private func loadDbEncryptionKey() -> String? {
        guard let appGroup = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.untitledApp")
        else { return nil }
        let fileUrl = appGroup.appendingPathComponent(".ecp_db_key")
        guard let data = try? Data(contentsOf: fileUrl),
              let key = String(data: data, encoding: .utf8), !key.isEmpty
        else { return nil }
        return key
    }

    func loadEncryptionKey() -> Data {
        let query: [String: Any] = [
             kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccount as String: "mls_encryption_key",
             kSecReturnData as String: true,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data {
            if let b64 = String(data: data, encoding: .utf8),
               let key = Data(base64Encoded: b64),
               key.count == 32
            {
                return key
            }
            debugBody("DEBUG: found \(data.count)B not valid key")
            return Data()
        } else {
            debugBody("DEBUG: status=\(status)")
            return Data()
        }
        debugBody("DEBUG: all queries returned errSecItemNotFound")
        return Data()
    }
}


