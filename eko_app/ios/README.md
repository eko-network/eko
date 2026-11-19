# iOS: Messenger Notification Service

Messenger pushes only say that a message arrived. The `MessengerNotificationService`
extension fetches the inbox, applies its messages to `mls.db` in the App Group,
acks them, and shows one notification per message. The app stores what it
applied when it next runs (the openmls stash, see `processMessageStashed`).

It shares with the app:

- `mls_encryption_key` in the keychain, the key of `mls.db`
- `messenger_notification_service` in the keychain: the inbox, outbox and a
  notification token the messenger mints for the device, which only reads the
  inbox and sends `Delivered` acks
- `notification_names.json` in the App Group: the active groups and usernames
  it titles notifications with

## Building OpenmlsPush.xcframework

The extension links `OpenmlsPush.xcframework`, the C API in `push_ffi/` of
the openmls package (`openmls_push.h`). It is built from the copy of the
package `flutter pub get` resolved, so the extension and the app use the same
engine:

```bash
rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
flutter pub get
ios/build_openmls_push.sh
```

Codemagic does the same before `pod install`. Rebuild it whenever the openmls
dependency changes.

If you are in a direnv, you will need to make sure you can find the iphoneos sdk. Nix overrides SDKROOT which does not contain the SDK, the script unsets it. It should be the following:
```
xcrun --show-sdk-path --sdk iphoneos
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk
```

You can try overriding with:
```
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

But you will need to probably `direnv disallow`.

## Hiding notifications

Without the `com.apple.developer.usernotifications.filtering` entitlement every
push shows a notification, so a push whose message was already shown shows it
again. Once Apple grants it, add it to
`MessengerNotificationService.entitlements` and set `EkoFiltersNotifications`
in its `Info.plist`, and those pushes show nothing.
