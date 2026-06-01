import 'package:ecp/ecp.dart' as ecp;
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/message_provider.dart';
import 'package:eko_app/messenger/types/group.dart';
import 'package:eko_app/messenger/widgets/group_card.dart';
import 'package:eko_app/messenger/widgets/message.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klipy_dart/klipy_dart.dart';

enum MessagePosition { middle, bottom, top, single }

extension SafeLookup<T> on List<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

class ChatView extends ConsumerStatefulWidget {
  final GroupWithUsers group;
  final VoidCallback? onBack;

  const ChatView({super.key, this.onBack, required this.group});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final MenuController _menuController = MenuController();
  final FocusNode _focusNode = FocusNode();
  bool _showMediaPicker = false;
  Map<Uri, ecp.Image> _selectedGifs = {};

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showMediaPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onGifSelected(KlipyResultObject gif) {
    final obj = gif.media.tinyGif ?? gif.media.gif;
    if (obj == null) {
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
    final text = _messageController.text.trim();
    final gifs = _selectedGifs.values;
    if (text.isEmpty && gifs.isEmpty) return;
    _messageController.clear();
    setState(() {
      _selectedGifs = {};
    });

    if (text.isEmpty && gifs.length == 1) {
      await _dispatchMessage(gifs.first);
    } else {
      await _dispatchMessage(
        ecp.Note(
          content: text,
          id: ecp.InternalId.gen(),
          attachments: gifs.isEmpty ? null : gifs.toList(),
        ),
      );
    }
  }

  Future<void> _dispatchMessage(ecp.ActivityPubObject object) async {
    await ref
        .read(ecpClientProvider)
        .messages
        .sendMessage(
          ecp.Activity.newCreate(object: object),
          widget.group.group.groupIdBytes,
        );
  }

  Widget _buildInputRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
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
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
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
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white, size: 20),
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

  @override
  Widget build(BuildContext context) {
    final actorId = ref.watch(ecpClientProvider).me.id;
    final messagesAsync = ref.watch(
      messageProvider(widget.group.group.groupIdBytes),
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
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final chronoIndex = messages.length - 1 - index;
                    final message = messages[chronoIndex];
                    final isReceived = message.senderId != actorId;

                    final prevMsg = messages.getOrNull(chronoIndex - 1);
                    final nextMsg = messages.getOrNull(chronoIndex + 1);

                    final DateTime? prevTime =
                        (prevMsg?.senderId == message.senderId)
                        ? prevMsg?.receivedAt
                        : null;
                    final DateTime? nextTime =
                        (nextMsg?.senderId == message.senderId)
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

                    final messageWidget = MessageWidget(
                      isReceived: isReceived,
                      message: message,
                      position: _determinePosition(
                        prevTime,
                        message.receivedAt,
                        nextTime,
                      ),
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
                              // child: MediaPicker(
                              //   textController: _messageController,
                              //   onGifSelected: _onGifSelected,
                              // ),
                            ),
                          ],
                          child: inputRow,
                        )
                      : inputRow,
                ),
                if (platform.isMobile && _showMediaPicker)
                  SizedBox(
                    height: 400,
                    // child: MediaPicker(
                    //   textController: _messageController,
                    //   onGifSelected: _onGifSelected,
                    // ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
