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
    required Uint8List super.argument,
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
    final argument = this.argument as Uint8List;
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

String _$reactionsHash() => r'6d3d2dc48da3162d33487dd24376337407e98331';

/// The reactions in a group, by the message they react to, oldest first.

final class ReactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<InternalId, List<StoredReaction>>>,
          Uint8List
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

  ReactionsProvider call(Uint8List groupId) =>
      ReactionsProvider._(argument: groupId, from: this);

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
    required Uint8List super.argument,
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
    final argument = this.argument as Uint8List;
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

String _$readCursorsHash() => r'058de0e212b300e1f9d4473118b2d490490d0108';

/// How far each member read a group, by reader.

final class ReadCursorsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<Uri, ReadCursor>>, Uint8List> {
  ReadCursorsFamily._()
    : super(
        retry: null,
        name: r'readCursorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How far each member read a group, by reader.

  ReadCursorsProvider call(Uint8List groupId) =>
      ReadCursorsProvider._(argument: groupId, from: this);

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
    required Uint8List super.argument,
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
    final argument = this.argument as Uint8List;
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

String _$unreadCountHash() => r'8bf3643a82fb64eb8166ae7be26ea88f19cfadea';

/// How many messages of others in a group we have not read.

final class UnreadCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, Uint8List> {
  UnreadCountFamily._()
    : super(
        retry: null,
        name: r'unreadCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many messages of others in a group we have not read.

  UnreadCountProvider call(Uint8List groupId) =>
      UnreadCountProvider._(argument: groupId, from: this);

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

String _$lastMessageHash() => r'25ddefb1f2c7983639393b4905fb32145e7f3a60';

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
