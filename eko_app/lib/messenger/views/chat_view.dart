import 'dart:async';
import 'dart:math' show min;

import 'package:cupertino_interactive_keyboard/cupertino_interactive_keyboard.dart'; // FIXME remove when this issue is closed https://github.com/flutter/flutter/issues/57609
import 'package:ecp/ecp.dart' as ecp;
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/storage.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/messenger/providers/message_provider.dart';
import 'package:eko_app/messenger/providers/group_provider.dart';
import 'package:eko_app/messenger/views/device_warning.dart';
import 'package:eko_app/messenger/widgets/group_card.dart';
import 'package:eko_app/messenger/widgets/media_picker.dart';
import 'package:eko_app/messenger/widgets/message.dart';
import 'package:eko_app/messenger/widgets/message_actions.dart';
import 'package:eko_app/messenger/widgets/message_quote.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/services/messenger_notification_service.dart';
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klipy_dart/klipy_dart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum MessagePosition { middle, bottom, top, single }

extension SafeLookup<T> on List<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

class ChatView extends ConsumerStatefulWidget {
  final ecp.MlsGroupRecord group;
  final VoidCallback? onBack;

  const ChatView({super.key, this.onBack, required this.group});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final MenuController _menuController = MenuController();
  final FocusNode _focusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _showMediaPicker = false;
  Map<Uri, ecp.Image> _selectedGifs = {};

  // at most one of them, the input sends a reply or the edit
  ecp.StoredMessage? _replyingTo;
  ecp.StoredMessage? _editing;

  // our messages shown while they are sent, until the stored ones replace
  // them
  final _sending = <ecp.InternalId, ecp.StoredMessage>{};

  // to scroll to the message a reply quotes
  final _messageKeys = <ecp.InternalId, GlobalKey>{};
  ecp.InternalId? _highlighted;
  Timer? _highlightTimer;

  // members whose devices were reset and not accepted yet, messages here
  // don't reach their new devices
  final _changed = <Uri>{};

  // the newest message, read once it is on screen
  ecp.StoredMessage? _newest;
  Timer? _readTimer;

  StreamSubscription<ecp.GroupDeviceWarning>? _warnings;
  StreamSubscription<({Uri person, ecp.MlsGroupRecord? dm})>? _accepted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(asyncEcpClientProvider, (_, next) {
      _warnings?.cancel();
      _accepted?.cancel();
      final groups = next.value?.groups;
      _warnings = groups?.deviceWarnings.listen((warning) {
        if (warning.unverified && _isMember(warning.owner) && mounted) {
          setState(() => _changed.add(warning.owner));
        }
      });
      _accepted = groups?.resetsAccepted.listen(_onResetAccepted);
    }, fireImmediately: true);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showMediaPicker = false;
        });
      }
    });
    _messageController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(_scheduleMarkRead);
    _verifyMembers();
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id) {
      _changed.clear();
      _sending.clear();
      _replyingTo = null;
      if (_editing != null) _messageController.clear();
      _editing = null;
      _newest = null;
      _verifyMembers();
    }
  }

  void _scheduleMarkRead() {
    _readTimer ??= Timer(const Duration(milliseconds: 500), () {
      _readTimer = null;
      _markRead();
    });
  }

  /// Marks the chat read up to the newest message while it is on screen: the
  /// app is in the foreground and the list scrolled to the bottom.
  Future<void> _markRead() async {
    final newest = _newest;
    if (newest == null || !mounted) return;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    // reversed, the newest messages are at the start
    if (_scrollController.hasClients && _scrollController.offset > 48) return;
    final client = ref.read(ecpClientProvider);
    try {
      await client.messages.markRead(newest);
      await MessengerNotificationService.clearIfRead(
        newest.groupId,
        me: client.me.id,
      );
    } on ecp.EcpDevicesChangedException {
      // waits for the reset to be reviewed in the banner, like sending
    } catch (e) {
      debugPrint('[ChatView] markRead failed: $e');
    }
  }

  /// Checks the chat's devices against their users' device chains, problems
  /// show up through DeviceWarningHandler, unaccepted device resets also in
  /// a banner here.
  void _verifyMembers() {
    final group = widget.group;
    ref
        .read(ecpClientProvider)
        .groups
        .verifyGroup(group.groupIdBytes)
        .then<void>((unverified) {
          if (!mounted || widget.group.id != group.id) return;
          setState(
            () => _changed
              ..clear()
              ..addAll(unverified),
          );
        })
        .catchError((Object e) => debugPrint('[ChatView] verifyGroup: $e'));
  }

  bool _isMember(Uri owner) =>
      (ref.read(groupMembersProvider(widget.group.id)).value ?? const [])
          .contains(uidFromActorId(owner));

  // an old DM that is handed over is left by AdaptiveChat
  void _onResetAccepted(({Uri person, ecp.MlsGroupRecord? dm}) e) {
    if (mounted && _changed.contains(e.person)) {
      setState(() => _changed.remove(e.person));
    }
  }

  Future<void> _review(Uri owner, String name) async {
    if (!await confirmDevicesChanged(context, name)) return;
    try {
      await ref
          .read(ecpClientProvider)
          .groups
          .acceptDeviceReset(ecp.Person.fromId(owner));
    } catch (e) {
      debugPrint('[ChatView] acceptDeviceReset: $e');
      if (!mounted) return;
      showSnackBar(
        text: AppLocalizations.of(context)!.defaultErrorTitle,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    }
  }

  Widget _buildChangedBanner(BuildContext context, Uri owner) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final uid = uidFromActorId(owner);
    final name = ref.watch(userProvider(uid)).value?.name ?? uid;
    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.messengerDevicesChangedTitle(name),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  Text(
                    l10n.messengerDevicesChangedBanner,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _review(owner, name),
              child: Text(l10n.messengerDevicesChangedReview),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _warnings?.cancel();
    _accepted?.cancel();
    _highlightTimer?.cancel();
    _readTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(messageProvider(widget.group.id));
      // a contact may have reset their devices meanwhile
      _verifyMembers();
      _scheduleMarkRead();
    }
  }

  void _onGifSelected(KlipyResultObject gif) {
    final obj = gif.media.tinyGif ?? gif.media.gif;
    // only the text of a message can be edited
    if (obj == null || _editing != null) {
      return;
    }
    setState(() {
      final url = Uri.parse(obj.url);
      _selectedGifs[url] = ecp.Image(
        id: ecp.InternalId.gen(),
        url: url,
        height: obj.dimensions.height.round(),
        width: obj.dimensions.width.round(),
        mediaType: 'image/gif',
        name: gif.title,
      );
    });
  }

  Future<void> _sendMessage() async {
    if (_editing != null) return _sendEdit();
    final text = _messageController.text.trim();
    final selected = _selectedGifs;
    final gifs = selected.values;
    final replyingTo = _replyingTo;
    // held back until the reset is reviewed in the banner
    if (_changed.isNotEmpty || (text.isEmpty && gifs.isEmpty)) return;
    _messageController.clear();
    setState(() {
      _selectedGifs = {};
      _replyingTo = null;
    });

    try {
      if (text.isEmpty && gifs.length == 1) {
        await _dispatchMessage(gifs.first.copyWith(inReplyTo: replyingTo?.id));
      } else {
        await _dispatchMessage(
          ecp.Note(
            content: text,
            id: ecp.InternalId.gen(),
            inReplyTo: replyingTo?.id,
            attachments: gifs.isEmpty ? null : gifs.toList(),
          ),
        );
      }
    } on ecp.EcpDevicesChangedException catch (e) {
      // the reset was only noticed now, the message waits in the input
      if (!mounted) return;
      setState(() {
        _changed.addAll(e.owners.where(_isMember));
        if (_messageController.text.isEmpty) _messageController.text = text;
        if (_selectedGifs.isEmpty) _selectedGifs = selected;
        _replyingTo ??= replyingTo;
      });
    }
  }

  Future<void> _sendEdit() async {
    final editing = _editing!;
    final text = _messageController.text.trim();
    if (text == (editing.content ?? '').trim()) return _stopComposing();
    // a caption can go, the text of a text message can't
    if (_changed.isNotEmpty || (text.isEmpty && editing.attachment.isEmpty)) {
      return;
    }
    _stopComposing();
    await _run((messages) => messages.editMessage(editing, text));
  }

  /// Leaves replying or editing.
  void _stopComposing() {
    if (_editing != null) _messageController.clear();
    setState(() {
      _editing = null;
      _replyingTo = null;
    });
  }

  /// Runs an action on a message, which fails like sending one.
  Future<void> _run(
    Future<void> Function(ecp.MessageHandler messages) action,
  ) async {
    try {
      await action(ref.read(ecpClientProvider).messages);
    } on ecp.EcpDevicesChangedException catch (e) {
      if (mounted) setState(() => _changed.addAll(e.owners.where(_isMember)));
    } catch (e) {
      debugPrint('[ChatView] message action failed: $e');
      if (!mounted) return;
      showSnackBar(
        text: AppLocalizations.of(context)!.messageActionFailed,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    }
  }

  Future<void> _react(
    ecp.StoredMessage message,
    String emoji,
    ecp.StoredReaction? mine,
  ) {
    // picking the current reaction again takes it back
    if (mine != null && mine.emoji == emoji) {
      return _run((messages) => messages.removeReaction(mine));
    }
    return _run((messages) => messages.react(message, emoji));
  }

  Future<void> _onActions(
    ecp.StoredMessage message,
    Rect bubbleRect, {
    required ({ecp.StoredMessage? message})? quoted,
    required List<ecp.StoredReaction> reactions,
  }) async {
    final me = ref.read(ecpClientProvider).me.id;
    final isMine = message.senderId == me;
    final isRecent = DateTime.now().difference(message.receivedAt) < editWindow;
    final hasText = message.content?.trim().isNotEmpty ?? false;
    final mine = reactions.where((r) => r.senderId == me).firstOrNull;

    FocusScope.of(context).unfocus();
    final choice = await showMessageActions(
      context,
      bubbleRect: bubbleRect,
      bubble: MessageBubble(
        isReceived: !isMine,
        message: message,
        me: me,
        quoted: quoted,
      ),
      isReceived: !isMine,
      myReaction: mine?.emoji,
      canReact: !message.deleted,
      actions: [
        if (!message.deleted) MessageAction.reply,
        // an image sent on its own has no text to edit
        if (isMine && isRecent && !message.deleted && message.content != null)
          MessageAction.edit,
        if (!message.deleted && hasText) MessageAction.copy,
        MessageAction.delete,
      ],
    );
    if (!mounted) return;

    switch (choice) {
      case ReactChoice(:final emoji):
        await _react(message, emoji, mine);
      case MoreReactionsChoice():
        final emoji = await pickReaction(context);
        if (emoji != null) await _react(message, emoji, mine);
      case ActionChoice(action: MessageAction.reply):
        _reply(message);
      case ActionChoice(action: MessageAction.edit):
        setState(() {
          _editing = message;
          _replyingTo = null;
          _selectedGifs = {};
          _showMediaPicker = false;
        });
        _messageController.text = message.content ?? '';
        _focusNode.requestFocus();
      case ActionChoice(action: MessageAction.copy):
        await Clipboard.setData(ClipboardData(text: message.content!.trim()));
        if (!mounted) return;
        showSnackBar(
          text: AppLocalizations.of(context)!.messageCopied,
          context: context,
        );
      case ActionChoice(action: MessageAction.delete):
        final how = await confirmDelete(
          context,
          forEveryone: isMine && isRecent && !message.deleted,
        );
        if (how == null || !mounted) return;
        if (_editing?.id == message.id || _replyingTo?.id == message.id) {
          _stopComposing();
        }
        switch (how) {
          case DeleteChoice.forMe:
            await db.deleteMessageForMe(message);
          case DeleteChoice.forEveryone:
            await _run((messages) => messages.deleteForEveryone(message));
        }
      case null:
        break;
    }
  }

  void _reply(ecp.StoredMessage message) {
    if (_editing != null) _messageController.clear();
    setState(() {
      _editing = null;
      _replyingTo = message;
    });
    _focusNode.requestFocus();
  }

  /// Scrolls up to [id], building the older messages on the way, and
  /// highlights it.
  Future<void> _scrollToMessage(ecp.InternalId id) async {
    for (var i = 0; i < 200 && mounted; i++) {
      final target = _messageKeys[id]?.currentContext;
      if (target != null && target.mounted) {
        await Scrollable.ensureVisible(
          target,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        if (!mounted) return;
        _highlightTimer?.cancel();
        setState(() => _highlighted = id);
        _highlightTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _highlighted = null);
        });
        return;
      }
      // the list is reversed, older messages are further along
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent) return;
      _scrollController.jumpTo(
        min(
          position.pixels + position.viewportDimension,
          position.maxScrollExtent,
        ),
      );
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  Future<void> _showReactions(List<ecp.StoredReaction> reactions) {
    // or the keyboard comes back when the sheet closes
    FocusScope.of(context).unfocus();
    return showReactions(
      context,
      reactions: reactions,
      me: ref.read(ecpClientProvider).me.id,
      onRemove: (reaction) =>
          _run((messages) => messages.removeReaction(reaction)),
    );
  }

  Widget? _buildComposeBanner(BuildContext context) {
    final me = ref.watch(ecpClientProvider).me.id;
    final editing = _editing;
    final replyingTo = _replyingTo;
    if (editing == null && replyingTo == null) return null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: MessageQuote(
        message: editing ?? replyingTo,
        me: me,
        title: editing != null
            ? AppLocalizations.of(context)!.messageEditing
            : null,
        onClose: _stopComposing,
      ),
    );
  }

  Future<void> _dispatchMessage(ecp.ActivityPubObject object) async {
    final groupId = widget.group.groupIdBytes;
    setState(
      () => _sending[object.id] = ecp.StoredMessage(
        serverActivityId: Uri(scheme: 'pending', path: object.id.toString()),
        receivedAt: DateTime.now(),
        senderId: ref.read(ecpClientProvider).me.id,
        id: object.id,
        content: object is ecp.Note ? object.content : null,
        inReplyTo: switch (object) {
          ecp.Note(:final inReplyTo) ||
          ecp.Image(:final inReplyTo) => inReplyTo,
          _ => null,
        },
        attachment: switch (object) {
          ecp.Note(:final attachments) => attachments ?? [],
          ecp.Image() => [object],
          _ => [],
        },
        groupId: groupId,
      ),
    );
    try {
      await ref
          .read(ecpClientProvider)
          .messages
          .sendMessage(ecp.Activity.newCreate(object: object), groupId);
    } on ecp.EcpDevicesChangedException {
      if (mounted) setState(() => _sending.remove(object.id));
      rethrow;
    } catch (e) {
      debugPrint('[ChatView] send failed: $e');
      if (!mounted) return;
      setState(() => _sending.remove(object.id));
      showSnackBar(
        text: AppLocalizations.of(context)!.messageSendFailed,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    }
  }

  Widget _buildInputRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final editing = _editing;
    final canSend =
        _changed.isEmpty &&
        (_messageController.text.trim().isNotEmpty ||
            _selectedGifs.isNotEmpty ||
            (editing != null && editing.attachment.isNotEmpty));
    final banner = _buildComposeBanner(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ?banner,
                if (_selectedGifs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 4,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _selectedGifs.entries.map((entry) {
                          final url = entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Image.network(
                                      url.toString(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        _selectedGifs.remove(url);
                                      });
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 12 * 24.0),
                  child: CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.enter):
                          _sendMessage,
                      const SingleActivator(LogicalKeyboardKey.escape):
                          _stopComposing,
                    },
                    child: TextField(
                      focusNode: _focusNode,
                      style: emojiTextStyle(const TextStyle()),
                      controller: _messageController,
                      maxLines: null,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(
                            platform.isMobile
                                ? LucideIcons.imagePlay
                                : LucideIcons.smilePlus,
                            size: 24,
                          ),
                          onPressed: () {
                            if (platform.isMobile) {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _showMediaPicker = !_showMediaPicker;
                              });
                            } else if (_menuController.isOpen) {
                              _menuController.close();
                            } else {
                              _menuController.open();
                            }
                          },
                        ),
                        hintText: AppLocalizations.of(context)!.typeAMessage,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (canSend) const SizedBox(width: 8),
        if (canSend)
          CircleAvatar(
            backgroundColor: Color(0xFF115AEF),
            child: IconButton(
              icon: Icon(
                editing != null ? Icons.check : Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
      ],
    );
  }

  MessagePosition _determinePosition(
    DateTime? prev,
    DateTime me,
    DateTime? next,
  ) {
    const tolerance = Duration(minutes: 1);

    final hasPrev = prev != null && me.difference(prev).abs() <= tolerance;
    final hasNext = next != null && next.difference(me).abs() <= tolerance;

    if (hasPrev && hasNext) {
      return MessagePosition.middle;
    } else if (hasPrev) {
      return MessagePosition.bottom;
    } else if (hasNext) {
      return MessagePosition.top;
    } else {
      return MessagePosition.single;
    }
  }

  /// The members, other than us, whose newest read message each message is.
  /// None for DMs, there the read status says it.
  Map<ecp.InternalId, List<String>> _readBy(
    List<ecp.StoredMessage> messages,
    Map<Uri, ecp.ReadCursor> cursors,
    List<String> others,
  ) {
    final readBy = <ecp.InternalId, List<String>>{};
    if (others.length < 2) return readBy;
    for (final uid in others) {
      final cursor = cursors[actorIdFromUid(uid)];
      if (cursor == null) continue;
      final newest = messages.where(cursor.covers).lastOrNull;
      // their own message already says they read up to it
      if (newest == null || uidFromActorId(newest.senderId) == uid) continue;
      readBy.putIfAbsent(newest.id, () => []).add(uid);
    }
    return readBy;
  }

  @override
  Widget build(BuildContext context) {
    final actorId = ref.watch(ecpClientProvider).me.id;
    final groupId = widget.group.id;
    final messagesAsync = ref.watch(messageProvider(groupId));
    final reactions = ref.watch(reactionsProvider(groupId)).value ?? const {};
    final cursors = ref.watch(readCursorsProvider(groupId)).value ?? const {};
    final members = ref.watch(groupMembersProvider(groupId)).value ?? const [];
    final myUid = uidFromActorId(actorId);
    final others = members.where((uid) => uid != myUid).toList();
    bool readByAll(ecp.StoredMessage message) =>
        others.isNotEmpty &&
        others.every(
          (uid) => cursors[actorIdFromUid(uid)]?.covers(message) ?? false,
        );
    final inputRow = _buildInputRow(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: Row(
          children: [
            SizedBox(height: 35, child: GroupIcon(group: widget.group)),
            const SizedBox(width: 12),
            Expanded(child: GroupTitle(group: widget.group)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
      ),
      body: Column(
        children: [
          for (final owner in _changed) _buildChangedBanner(context, owner),
          Expanded(
            child: messagesAsync.when(
              data: (stored) {
                // the stored message replaces the one being sent
                final storedIds = {for (final m in stored) m.id};
                _sending.removeWhere((id, _) => storedIds.contains(id));
                final messages = [...stored, ..._sending.values];
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noMessagesYet,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final newest = stored.lastOrNull;
                if (newest != null && newest.id != _newest?.id) {
                  _newest = newest;
                  _scheduleMarkRead();
                }
                final byId = {for (final m in messages) m.id: m};
                final readBy = _readBy(stored, cursors, others);
                return CupertinoInteractiveKeyboard(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final chronoIndex = messages.length - 1 - index;
                      final message = messages[chronoIndex];
                      final isReceived = message.senderId != actorId;
                      // others don't know its id yet to reply or react to it
                      final sending = _sending.containsKey(message.id);

                      final prevMsg = messages.getOrNull(chronoIndex - 1);
                      final nextMsg = messages.getOrNull(chronoIndex + 1);

                      // reactions sit under a message, so they end its
                      // group of bubbles
                      bool hasReactions(ecp.StoredMessage m) =>
                          reactions[m.id]?.isNotEmpty ?? false;
                      final DateTime? prevTime =
                          prevMsg?.senderId == message.senderId &&
                              !hasReactions(prevMsg!)
                          ? prevMsg.receivedAt
                          : null;
                      final DateTime? nextTime =
                          nextMsg?.senderId == message.senderId &&
                              !hasReactions(message)
                          ? nextMsg?.receivedAt
                          : null;

                      var isFirstOfDate = false;
                      if (prevMsg == null) {
                        isFirstOfDate = true;
                      } else {
                        final d1 = message.receivedAt;
                        final d2 = prevMsg.receivedAt;
                        isFirstOfDate =
                            d1.year != d2.year ||
                            d1.month != d2.month ||
                            d1.day != d2.day;
                      }
                      final inReplyTo = message.inReplyTo;
                      final quoted = inReplyTo == null
                          ? null
                          : (message: byId[inReplyTo]);
                      final messageReactions =
                          reactions[message.id] ?? const [];
                      final messageWidget = MessageWidget(
                        key: _messageKeys.putIfAbsent(
                          message.id,
                          GlobalKey.new,
                        ),
                        isReceived: isReceived,
                        message: message,
                        me: actorId,
                        position: _determinePosition(
                          prevTime,
                          message.receivedAt,
                          nextTime,
                        ),
                        quoted: quoted,
                        reactions: messageReactions,
                        highlighted: _highlighted == message.id,
                        sending: sending,
                        read: !isReceived && readByAll(message),
                        readBy: readBy[message.id] ?? const [],
                        onActions: sending
                            ? null
                            : (rect) => _onActions(
                                message,
                                rect,
                                quoted: quoted,
                                reactions: messageReactions,
                              ),
                        onReply: sending ? null : () => _reply(message),
                        onQuoteTap: inReplyTo == null || byId[inReplyTo] == null
                            ? null
                            : () => _scrollToMessage(inReplyTo),
                        onReactionsTap: () => _showReactions(messageReactions),
                        onEditedTap: () {
                          FocusScope.of(context).unfocus();
                          showEditHistory(context, message: message);
                        },
                      );

                      if (isFirstOfDate) {
                        return Column(
                          children: [
                            DateChip(time: message.receivedAt),
                            messageWidget,
                          ],
                        );
                      }
                      return messageWidget;
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                debugPrint(error.toString());
                return Center(child: Text('Could not load messages: $error'));
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: !platform.isMobile
                      ? MenuAnchor(
                          controller: _menuController,
                          menuChildren: [
                            SizedBox(
                              width: 380,
                              height: 450,
                              child: MediaPicker(
                                textController: _messageController,
                                onGifSelected: _onGifSelected,
                              ),
                            ),
                          ],
                          child: inputRow,
                        )
                      : inputRow,
                ),
                if (platform.isMobile && _showMediaPicker)
                  SizedBox(
                    height: 400,
                    child: MediaPicker(
                      textController: _messageController,
                      onGifSelected: _onGifSelected,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
