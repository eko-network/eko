// openmls_push_decrypt.h
// C-compatible FFI for decrypting MLS push notifications in iOS
// Notification Service Extensions.
//
// Usage from Swift (via bridging header):
//   let engine = openmls_push_decrypt_create(dbPath, key, 32, nil)
//   ...
//   let rc = openmls_push_decrypt_message(engine, groupId, groupId.count,
//                                         msg, msg.count,
//                                         &plaintext, &plaintextLen,
//                                         &senderIdx, &error)
//   ...
//   openmls_push_decrypt_free(engine)

#ifndef OPENMLS_PUSH_DECRYPT_H
#define OPENMLS_PUSH_DECRYPT_H

#include <stdint.h>
#include <stddef.h>

// ── Return codes ─────────────────────────────────────────────

/// Message was successfully decrypted.
#define OPENMLS_PUSH_OK 0

/// Message is not an application message (proposal/commit).
#define OPENMLS_PUSH_NOT_APPLICATION 1

/// An error occurred. Check the error_out parameter.
#define OPENMLS_PUSH_ERROR -1

// ── Engine lifecycle ─────────────────────────────────────────

/// Create a new push decryption engine.
///
/// Opens the encrypted MLS database and prepares for message decryption.
///
/// @param db_path          Path to the SQLCipher database file
///                         (use App Groups container path)
/// @param encryption_key   32-byte AES-256 key (same as main app)
/// @param key_len          Must be 32
/// @param error_out        If non-null, set to error string on failure
///                         (free with openmls_push_decrypt_free_string)
/// @return                 Opaque engine handle, or NULL on failure
///                         (free with openmls_push_decrypt_free)
void* openmls_push_decrypt_create(
    const char* db_path,
    const uint8_t* encryption_key,
    size_t key_len,
    char** error_out
);

// ── Message decryption ───────────────────────────────────────

/// Decrypt an MLS application message from a push notification.
///
/// Processes the message using the local MLS group state.
/// Only application messages yield plaintext; proposals/commits
/// return OPENMLS_PUSH_NOT_APPLICATION.
///
/// @param engine_ptr        Handle from openmls_push_decrypt_create
/// @param group_id          Group ID bytes
/// @param group_id_len      Length of group_id
/// @param ciphertext        TLS-serialized MLS protocol message
/// @param ciphertext_len    Length of ciphertext
/// @param plaintext_out     On success, set to allocated plaintext buffer
///                          (free with openmls_push_decrypt_free_bytes)
/// @param plaintext_len_out On success, set to plaintext length
/// @param sender_index_out  On success, set to sender's leaf index
/// @param error_out         If non-null, set to error string on failure
///                          (free with openmls_push_decrypt_free_string)
/// @return                  OPENMLS_PUSH_OK (0) on success,
///                          OPENMLS_PUSH_NOT_APPLICATION (1) if not an app msg,
///                          OPENMLS_PUSH_ERROR (-1) on error
int openmls_push_decrypt_message(
    void* engine_ptr,
    const uint8_t* group_id,
    size_t group_id_len,
    const uint8_t* ciphertext,
    size_t ciphertext_len,
    uint8_t** plaintext_out,
    size_t* plaintext_len_out,
    uint32_t* sender_index_out,
    char** error_out
);

// ── Memory management ────────────────────────────────────────

/// Free a push decryption engine created by openmls_push_decrypt_create.
void openmls_push_decrypt_free(void* engine_ptr);

/// Free a string allocated by any openmls_push_decrypt_* function.
void openmls_push_decrypt_free_string(char* s);

/// Free a byte buffer allocated by openmls_push_decrypt_message.
void openmls_push_decrypt_free_bytes(uint8_t* ptr, size_t len);

#endif /* OPENMLS_PUSH_DECRYPT_H */
