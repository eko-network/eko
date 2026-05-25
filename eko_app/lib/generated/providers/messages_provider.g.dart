// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageStreamHash() => r'dfc0b10c784f65c1927f14b541c3b443e3d556fb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [messageStream].
@ProviderFor(messageStream)
const messageStreamProvider = MessageStreamFamily();

/// See also [messageStream].
class MessageStreamFamily
    extends Family<AsyncValue<List<MessageWithAttachments>>> {
  /// See also [messageStream].
  const MessageStreamFamily();

  /// See also [messageStream].
  MessageStreamProvider call(
    Uri contactId,
    Uri actorId,
  ) {
    return MessageStreamProvider(
      contactId,
      actorId,
    );
  }

  @override
  MessageStreamProvider getProviderOverride(
    covariant MessageStreamProvider provider,
  ) {
    return call(
      provider.contactId,
      provider.actorId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageStreamProvider';
}

/// See also [messageStream].
class MessageStreamProvider
    extends AutoDisposeStreamProvider<List<MessageWithAttachments>> {
  /// See also [messageStream].
  MessageStreamProvider(
    Uri contactId,
    Uri actorId,
  ) : this._internal(
          (ref) => messageStream(
            ref as MessageStreamRef,
            contactId,
            actorId,
          ),
          from: messageStreamProvider,
          name: r'messageStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageStreamHash,
          dependencies: MessageStreamFamily._dependencies,
          allTransitiveDependencies:
              MessageStreamFamily._allTransitiveDependencies,
          contactId: contactId,
          actorId: actorId,
        );

  MessageStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.actorId,
  }) : super.internal();

  final Uri contactId;
  final Uri actorId;

  @override
  Override overrideWith(
    Stream<List<MessageWithAttachments>> Function(MessageStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageStreamProvider._internal(
        (ref) => create(ref as MessageStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        actorId: actorId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MessageWithAttachments>>
      createElement() {
    return _MessageStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageStreamProvider &&
        other.contactId == contactId &&
        other.actorId == actorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, actorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageStreamRef
    on AutoDisposeStreamProviderRef<List<MessageWithAttachments>> {
  /// The parameter `contactId` of this provider.
  Uri get contactId;

  /// The parameter `actorId` of this provider.
  Uri get actorId;
}

class _MessageStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<MessageWithAttachments>>
    with MessageStreamRef {
  _MessageStreamProviderElement(super.provider);

  @override
  Uri get contactId => (origin as MessageStreamProvider).contactId;
  @override
  Uri get actorId => (origin as MessageStreamProvider).actorId;
}

String _$messagePollingHash() => r'134d36962c7451e1751a951a9845d87b8dc39eaf';

/// See also [MessagePolling].
@ProviderFor(MessagePolling)
final messagePollingProvider = NotifierProvider<MessagePolling, void>.internal(
  MessagePolling.new,
  name: r'messagePollingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messagePollingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MessagePolling = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
