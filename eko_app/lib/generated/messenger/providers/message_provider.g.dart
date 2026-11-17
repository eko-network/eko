// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/providers/message_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(message)
final messageProvider = MessageFamily._();

final class MessageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoredMessage>>,
          List<StoredMessage>,
          Stream<List<StoredMessage>>
        >
    with
        $FutureModifier<List<StoredMessage>>,
        $StreamProvider<List<StoredMessage>> {
  MessageProvider._({
    required MessageFamily super.from,
    required Uint8List super.argument,
  }) : super(
         retry: null,
         name: r'messageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageHash();

  @override
  String toString() {
    return r'messageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<StoredMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StoredMessage>> create(Ref ref) {
    final argument = this.argument as Uint8List;
    return message(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageHash() => r'aa8199afbe5a76e7254cc9ecd71d2ba8d9f22828';

final class MessageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StoredMessage>>, Uint8List> {
  MessageFamily._()
    : super(
        retry: null,
        name: r'messageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessageProvider call(Uint8List groupId) =>
      MessageProvider._(argument: groupId, from: this);

  @override
  String toString() => r'messageProvider';
}

/// The newest message in a group, for the chat list, or null when the group
/// has none yet.

@ProviderFor(lastMessage)
final lastMessageProvider = LastMessageFamily._();

/// The newest message in a group, for the chat list, or null when the group
/// has none yet.

final class LastMessageProvider
    extends
        $FunctionalProvider<
          AsyncValue<LastMessagePreview?>,
          LastMessagePreview?,
          Stream<LastMessagePreview?>
        >
    with
        $FutureModifier<LastMessagePreview?>,
        $StreamProvider<LastMessagePreview?> {
  /// The newest message in a group, for the chat list, or null when the group
  /// has none yet.
  LastMessageProvider._({
    required LastMessageFamily super.from,
    required Uint8List super.argument,
  }) : super(
         retry: null,
         name: r'lastMessageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lastMessageHash();

  @override
  String toString() {
    return r'lastMessageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<LastMessagePreview?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LastMessagePreview?> create(Ref ref) {
    final argument = this.argument as Uint8List;
    return lastMessage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LastMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastMessageHash() => r'a1f1224dea0ea60790f7582f7ea70780ee67db5d';

/// The newest message in a group, for the chat list, or null when the group
/// has none yet.

final class LastMessageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LastMessagePreview?>, Uint8List> {
  LastMessageFamily._()
    : super(
        retry: null,
        name: r'lastMessageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The newest message in a group, for the chat list, or null when the group
  /// has none yet.

  LastMessageProvider call(Uint8List groupId) =>
      LastMessageProvider._(argument: groupId, from: this);

  @override
  String toString() => r'lastMessageProvider';
}
