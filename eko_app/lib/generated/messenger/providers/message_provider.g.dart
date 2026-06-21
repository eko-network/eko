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

String _$messageHash() => r'e19ef42a7fdea8653862ee6f8ae7d9df0fd1e4c0';

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
