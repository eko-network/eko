import 'package:ecp/ecp.dart' as ecp;
import 'package:eko_app/database/daos/conversations_dao.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_runtime_provider.dart';
import 'package:eko_app/providers/messages_provider.dart';
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/widgets/messenger/media_picker.dart';
import 'package:eko_app/widgets/messenger/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klipy_dart/klipy_dart.dart';
import 'package:uuid/uuid.dart';

extension SafeLookup<T> on List<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

class ChatView extends ConsumerStatefulWidget {
  final ConversationWithContact conversation;
  final VoidCallback? onBack;

  const ChatView({super.key, required this.conversation, this.onBack});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final MenuController _menuController = MenuController();
  final FocusNode _focusNode = FocusNode();
  final _uuid = Uuid();
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
        base: ecp.ObjectBase(id: _uuid.v4obj()),
        url: url,
        height: obj.dimensions.height.round(),
        width: obj.dimensions.width.round(),
        mediaType: 'image/gif',
        name: gif.title,
      );
    });
  }

  Future<void> _sendMessage() async {
    if (ref.read(authProvider).uid == null) return;

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
          base: ecp.ObjectBase(id: _uuid.v4obj()),
          attachments: gifs.isEmpty ? null : gifs.toList(),
        ),
      );
    }
  }

  Future<void> _dispatchMessage(ecp.ActivityPubObject object) async {
    debugPrint('Send message placeholder: ${object.type}');
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
                  constraints: const BoxConstraints(
                    maxHeight: 12 * 24.0,
                  ),
                  child: CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.enter):
                          _sendMessage,
                    },
                    child: TextField(
                      focusNode: _focusNode,
                      enabled: ref.watch(authProvider).uid?.isNotEmpty ?? false,
                      style: emojiTextStyle(const TextStyle()),
                      controller: _messageController,
                      maxLines: null,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined,
                              size: 24),
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
                        hintText: 'Type a message',
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
            onPressed: (ref.watch(authProvider).uid?.isNotEmpty ?? false)
                ? _sendMessage
                : null,
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
    final client = ref.watch(ecpRuntimeProvider).asData?.value;
    final signedIn = ref.watch(authProvider).uid?.isNotEmpty ?? false;
    final actorId = client?.me.id ?? widget.conversation.contact.id;
    final contactId = widget.conversation.contact.id;

    final inputRow = _buildInputRow(context);

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: Row(
          children: [
            SizedBox(), // TODO FIXME
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(),

              // Text(
              //   // widget.conversation.contact.preferredUsername,
              //   overflow: TextOverflow.ellipsis,
              // ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Placeholder(),

// Column(
//         children: [
//           Expanded(
//             child: messagesAsync.when(
//               data: (messages) {
//                 if (messages.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'No messages yet',
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                         fontSize: 16,
//                       ),
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final chronoIndex = messages.length - 1 - index;
//                     final message = messages[chronoIndex].message;
//                     final isReceived = message.from != actorId;
//
//                     final prevMsg =
//                         messages.getOrNull(chronoIndex - 1)?.message;
//                     final nextMsg =
//                         messages.getOrNull(chronoIndex + 1)?.message;
//
//                     final DateTime? prevTime =
//                         (prevMsg?.from == message.from) ? prevMsg?.time : null;
//                     final DateTime? nextTime =
//                         (nextMsg?.from == message.from) ? nextMsg?.time : null;
//
//                     var isFirstOfDate = false;
//                     if (prevMsg == null) {
//                       isFirstOfDate = true;
//                     } else {
//                       final d1 = message.time;
//                       final d2 = prevMsg.time;
//                       isFirstOfDate = d1.year != d2.year ||
//                           d1.month != d2.month ||
//                           d1.day != d2.day;
//                     }
//
//                     final messageWidget = MessageWidget(
//                       isReceived: isReceived,
//                       messageWithAttachments: messages[chronoIndex],
//                       position: _determinePosition(
//                         prevTime,
//                         message.time,
//                         nextTime,
//                       ),
//                     );
//
//                     if (isFirstOfDate) {
//                       return Column(
//                         children: [
//                           DateChip(time: message.time),
//                           messageWidget,
//                         ],
//                       );
//                     }
//                     return messageWidget;
//                   },
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, stack) {
//                 debugPrint(error.toString());
//                 return Center(
//                   child: Text('Could not load messages: $error'),
//                 );
//               },
//             ),
//           ),
//           SafeArea(
//             top: false,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: signedIn && !platform.isMobile
//                       ? MenuAnchor(
//                           controller: _menuController,
//                           menuChildren: [
//                             SizedBox(
//                               width: 380,
//                               height: 450,
//                               child: MediaPicker(
//                                 textController: _messageController,
//                                 onGifSelected: _onGifSelected,
//                               ),
//                             ),
//                           ],
//                           child: inputRow,
//                         )
//                       : inputRow,
//                 ),
//                 if (platform.isMobile && _showMediaPicker)
//                   SizedBox(
//                     height: 400,
//                     child: MediaPicker(
//                       textController: _messageController,
//                       onGifSelected: _onGifSelected,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
    );
  }
}
