// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../messenger/notification_service_share.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the iOS notification service (MessengerNotificationService) needs to
/// fetch the inbox, send delivered acks and title what it shows, while the
/// app is not running.

@ProviderFor(notificationServiceShare)
final notificationServiceShareProvider = NotificationServiceShareProvider._();

/// What the iOS notification service (MessengerNotificationService) needs to
/// fetch the inbox, send delivered acks and title what it shows, while the
/// app is not running.

final class NotificationServiceShareProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// What the iOS notification service (MessengerNotificationService) needs to
  /// fetch the inbox, send delivered acks and title what it shows, while the
  /// app is not running.
  NotificationServiceShareProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceShareProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceShareHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return notificationServiceShare(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationServiceShareHash() =>
    r'2301e371049d444a0f20691308daa6285013daea';
