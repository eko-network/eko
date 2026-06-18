# iOS: openmls Push Decryption Extension

## Building the openmls Rust Library for iOS

The `openmls_push_decrypt.xcframework` contains the Rust static library (`libopenmls_frb.a`) used by the `MessengerNotificationService` extension. To rebuild it from source:

### Prerequisites

```bash
# Install Rust
# Add iOS targets
rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
```

### Build

```bash
# Navigate to the openmls_dart package
cd /path/to/openmls_dart

# Build static libraries for device + sim
make build-ios-static

# Create the XCFramework (overwrites ios/openmls_push_decrypt.xcframework)
make xcframework
```

This produces:
- `rust/target/aarch64-apple-ios/release/libopenmls_frb.a` — device (arm64)
- `rust/target/aarch64-apple-ios-sim/release/libopenmls_frb.a` — simulator (arm64)
- `rust/target/x86_64-apple-ios/release/libopenmls_frb.a` — simulator (x86_64)

The `xcframework` target merges these into `ios/openmls_push_decrypt.xcframework`.
Copy the resulting `.xcframework` and `openmls_push_decrypt.h` header into the app's `ios/` directory.

