// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/providers/message_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The MLS group ID of the group with row id [id], which it keeps for good.
///
/// The providers of a group are by row id, as the bytes of the same group
/// read again are not equal to the ones read before.

@ProviderFor(groupIdBytes)
final groupIdBytesProvider = GroupIdBytesFamily._();

/// The MLS group ID of the group with row id [id], which it keeps for good.
///
/// The providers of a group are by row id, as the bytes of the same group
/// read again are not equal to the ones read before.

final class GroupIdBytesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// The MLS group ID of the group with row id [id], which it keeps for good.
  ///
  /// The providers of a group are by row id, as the bytes of the same group
  /// read again are not equal to the ones read before.
  GroupIdBytesProvider._({
    required GroupIdBytesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'groupIdBytesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupIdBytesHash();

  @override
  String toString() {
    return r'groupIdBytesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as int;
    return groupIdBytes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupIdBytesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupIdBytesHash() => r'0e4312649ee4de595044e0297032fde3abffa38c';

/// The MLS group ID of the group with row id [id], which it keeps for good.
///
/// The providers of a group are by row id, as the bytes of the same group
/// read again are not equal to the ones read before.

final class GroupIdBytesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List>, int> {
  GroupIdBytesFamily._()
    : super(
        retry: null,
        name: r'groupIdBytesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The MLS group ID of the group with row id [id], which it keeps for good.
  ///
  /// The providers of a group are by row id, as the bytes of the same group
  /// read again are not equal to the ones read before.

  GroupIdBytesProvider call(int id) =>
      GroupIdBytesProvider._(argument: id, from: this);

  @override
  String toString() => r'groupIdBytesProvider';
}

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
    required int super.argument,
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
    final argument = this.argument as int;
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

String _$messageHash() => r'6a549baae5610cdc1f4b06db75c61652566076d2';

final class MessageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StoredMessage>>, int> {
  MessageFamily._()
    : super(
        retry: null,
        name: r'messageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessageProvider call(int id) => MessageProvider._(argument: id, from: this);

  @override
  String toString() => r'messageProvider';
}

/// The reactions in a group, by the message they react to, oldest first.

@ProviderFor(reactions)
final reactionsProvider = ReactionsFamily._();

/// The reactions in a group, by the message they react to, oldest first.

final class ReactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<InternalId, List<StoredReaction>>>,
          Map<InternalId, List<StoredReaction>>,
          Stream<Map<InternalId, List<StoredReaction>>>
        >
    with
        $FutureModifier<Map<InternalId, List<StoredReaction>>>,
        $StreamProvider<Map<InternalId, List<StoredReaction>>> {
  /// The reactions in a group, by the message they react to, oldest first.
  ReactionsProvider._({
    required ReactionsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'reactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reactionsHash();

  @override
  String toString() {
    return r'reactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<InternalId, List<StoredReaction>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<InternalId, List<StoredReaction>>> create(Ref ref) {
    final argument = this.argument as int;
    return reactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reactionsHash() => r'14b51cb726c51feca84b67846509b97352c22e09';

/// The reactions in a group, by the message they react to, oldest first.

final class ReactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<InternalId, List<StoredReaction>>>,
          int
        > {
  ReactionsFamily._()
    : super(
        retry: null,
        name: r'reactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The reactions in a group, by the message they react to, oldest first.

  ReactionsProvider call(int id) =>
      ReactionsProvider._(argument: id, from: this);

  @override
  String toString() => r'reactionsProvider';
}

/// How far each member read a group, by reader.

@ProviderFor(readCursors)
final readCursorsProvider = ReadCursorsFamily._();

/// How far each member read a group, by reader.

final class ReadCursorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<Uri, ReadCursor>>,
          Map<Uri, ReadCursor>,
          Stream<Map<Uri, ReadCursor>>
        >
    with
        $FutureModifier<Map<Uri, ReadCursor>>,
        $StreamProvider<Map<Uri, ReadCursor>> {
  /// How far each member read a group, by reader.
  ReadCursorsProvider._({
    required ReadCursorsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'readCursorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readCursorsHash();

  @override
  String toString() {
    return r'readCursorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<Uri, ReadCursor>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<Uri, ReadCursor>> create(Ref ref) {
    final argument = this.argument as int;
    return readCursors(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadCursorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readCursorsHash() => r'6b90ef67aaa23deda42ef12e0f7b862a7ea11c4f';

/// How far each member read a group, by reader.

final class ReadCursorsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<Uri, ReadCursor>>, int> {
  ReadCursorsFamily._()
    : super(
        retry: null,
        name: r'readCursorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How far each member read a group, by reader.

  ReadCursorsProvider call(int id) =>
      ReadCursorsProvider._(argument: id, from: this);

  @override
  String toString() => r'readCursorsProvider';
}

/// How many messages of others in a group we have not read.

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountFamily._();

/// How many messages of others in a group we have not read.

final class UnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// How many messages of others in a group we have not read.
  UnreadCountProvider._({
    required UnreadCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'unreadCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @override
  String toString() {
    return r'unreadCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return unreadCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadCountHash() => r'ae77f4d8934e2022bc3b139abff0dbf500205e63';

/// How many messages of others in a group we have not read.

final class UnreadCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  UnreadCountFamily._()
    : super(
        retry: null,
        name: r'unreadCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many messages of others in a group we have not read.

  UnreadCountProvider call(int id) =>
      UnreadCountProvider._(argument: id, from: this);

  @override
  String toString() => r'unreadCountProvider';
}

/// The earlier contents of an edited message, oldest first.

@ProviderFor(messageRevisions)
final messageRevisionsProvider = MessageRevisionsFamily._();

/// The earlier contents of an edited message, oldest first.

final class MessageRevisionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MessageRevision>>,
          List<MessageRevision>,
          Stream<List<MessageRevision>>
        >
    with
        $FutureModifier<List<MessageRevision>>,
        $StreamProvider<List<MessageRevision>> {
  /// The earlier contents of an edited message, oldest first.
  MessageRevisionsProvider._({
    required MessageRevisionsFamily super.from,
    required Uri super.argument,
  }) : super(
         retry: null,
         name: r'messageRevisionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageRevisionsHash();

  @override
  String toString() {
    return r'messageRevisionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MessageRevision>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MessageRevision>> create(Ref ref) {
    final argument = this.argument as Uri;
    return messageRevisions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageRevisionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageRevisionsHash() => r'3182c8a0dce31c36709c992aa692d55b4d9441b5';

/// The earlier contents of an edited message, oldest first.

final class MessageRevisionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MessageRevision>>, Uri> {
  MessageRevisionsFamily._()
    : super(
        retry: null,
        name: r'messageRevisionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The earlier contents of an edited message, oldest first.

  MessageRevisionsProvider call(Uri serverActivityId) =>
      MessageRevisionsProvider._(argument: serverActivityId, from: this);

  @override
  String toString() => r'messageRevisionsProvider';
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
    required int super.argument,
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
    final argument = this.argument as int;
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

String _$lastMessageHash() => r'95950a3d852425fb61576eb9fb8ed5ba22374d3c';

/// The newest message in a group, for the chat list, or null when the group
/// has none yet.

final class LastMessageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LastMessagePreview?>, int> {
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

  LastMessageProvider call(int id) =>
      LastMessageProvider._(argument: id, from: this);

  @override
  String toString() => r'lastMessageProvider';
}
