import 'package:eko_app/widgets/posts/markdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/posts/gif_widget.dart';
import 'package:eko_app/widgets/posts/image_widget.dart';
import 'package:eko_app/interfaces/post.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/nav_bar_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/providers/post_preview_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/widgets/posts/poll_creator.dart';
import 'package:eko_app/widgets/posts/post_card.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/widgets/posts/repost_card.dart';
import 'package:eko_app/widgets/search/tag_search.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

class _CornerClose extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  const _CornerClose({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: IntrinsicWidth(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
              child: child,
            ),
            Positioned(
              right: -17,
              top: -17,
              child: IconButton(
                iconSize: 25,
                onPressed: onPressed,
                icon: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Icon(
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComposePage extends ConsumerStatefulWidget {
  final int? repostId;
  final String? timestamp;

  const ComposePage({super.key, this.repostId, this.timestamp});
  @override
  ConsumerState<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends ConsumerState<ComposePage> {
  final _key = GlobalKey<ExpandableFabState>();
  int? repostId;
  String? gif;
  String? timestamp;
  AsciiImage? image;
  bool isPoll = false;
  List<String> pollOptions = List.filled(c.minPollOptions, '', growable: true);
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final scrollController = ScrollController();
  final bodyFocus = FocusNode();
  final titleFocus = FocusNode();
  int bodyNewLines = 0;
  bool isUploading = false;
  bool isChecking = false;
  String? partialTag;
  bool showFab = true;
  bool showMarkdownPreview = false;
  bool _markdownUsesTitle = false;

  @override
  void didUpdateWidget(covariant ComposePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repostId != widget.repostId ||
        oldWidget.timestamp != widget.timestamp) {
      setState(() {
        repostId = widget.repostId;
        timestamp = widget.timestamp;
      });
    }
  }

  @override
  void initState() {
    bodyFocus.addListener(bodyFocusListen);
    titleFocus.addListener(_markdownTargetFocusListen);
    bodyFocus.addListener(_markdownTargetFocusListen);
    repostId = widget.repostId;
    timestamp = widget.timestamp;
    super.initState();
  }

  void _markdownTargetFocusListen() {
    if (titleFocus.hasPrimaryFocus) {
      _markdownUsesTitle = true;
    } else if (bodyFocus.hasPrimaryFocus) {
      _markdownUsesTitle = false;
    }
  }

  void bodyFocusListen() {
    setState(() {
      showFab = !bodyFocus.hasPrimaryFocus;
    });
  }

  @override
  void dispose() {
    bodyFocus.removeListener(bodyFocusListen);
    titleFocus.removeListener(_markdownTargetFocusListen);
    bodyFocus.removeListener(_markdownTargetFocusListen);
    scrollController.dispose();
    titleController.dispose();
    bodyController.dispose();
    titleFocus.dispose();
    bodyFocus.dispose();
    super.dispose();
  }

  int _countNewLines(String str) {
    int count = 0;
    for (int i = 0; i < str.length; i++) {
      if (str[i] == '\n') {
        count++;
      }
    }
    return count;
  }

  void _wrapMarkdown(
    TextEditingController controller,
    FocusNode focus,
    String left,
    String right,
  ) {
    focus.requestFocus();
    final text = controller.text;
    var sel = controller.selection;
    if (!sel.isValid) {
      sel = TextSelection.collapsed(offset: text.length);
    }
    final int start = sel.start;
    final int end = sel.end;
    final int lo = start < end ? start : end;
    final int hi = start < end ? end : start;
    final int loC = lo.clamp(0, text.length);
    final int hiC = hi.clamp(0, text.length);
    final String middle = text.substring(loC, hiC);
    final String replacement = '$left$middle$right';
    final String newText = text.replaceRange(loC, hiC, replacement);
    final int newOffset = middle.isEmpty
        ? loC + left.length
        : loC + replacement.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, newText.length),
      ),
    );
  }

  void _wrapActiveFieldMarkdown(String left, String right) {
    _wrapMarkdown(
      _markdownUsesTitle ? titleController : bodyController,
      _markdownUsesTitle ? titleFocus : bodyFocus,
      left,
      right,
    );
  }

  void _addGifPressed() async {
    String? url = await context.pushNamed('gif');
    if (url != null) {
      setState(() {
        gif = url;
        image = null;
        repostId = null;
      });
    }
  }

  Future<void> _addImagePressed() async {
    ref.read(navBarProvider.notifier).disable();
    final result = await context.pushNamed<AsciiImage?>('camera');

    if (result != null && mounted) {
      setState(() {
        image = result;
        gif = null;
        repostId = null;
      });
    }

    ref.read(navBarProvider.notifier).enable();
  }

  void _addPollPressed() {
    ref.read(navBarProvider.notifier).disable();
    setState(() {
      isPoll = true;
    });
    ref.read(navBarProvider.notifier).enable();
  }

  void _clear() {
    setState(() {
      repostId = null;
      isPoll = false;
      pollOptions = List.filled(c.minPollOptions, '', growable: true);
      gif = null;
      image = null;
      bodyNewLines = 0;
      bodyController.clear();
      titleController.clear();
    });
  }

  Future<void> _uploadAndNavigate(
    PostModel post,
    List<String>? pollOptions,
  ) async {
    if (isUploading) return;
    try {
      isUploading = true;
      final postToUpload = post.copyWith(
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );
      final (id, poll) = await uploadPost(postToUpload, pollOptions, ref);
      _clear();
      if (mounted) {
        final completePost = postToUpload.copyWith(id: id, poll: poll);
        ref.read(newFeedProvider.notifier).insertAtIndex(0, completePost);
        ref.read(followingFeedProvider.notifier).insertAtIndex(0, completePost);
        ref.read(postPoolProvider).putAll([completePost]);
        context.go('/feed');
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        showSnackBar(
          text: AppLocalizations.of(context)!.defaultErrorTitle,
          context: context,
          variant: SnackBarVariant.destructive,
        );
      }
    } finally {
      isUploading = false;
    }
  }

  Future<void> _postPressed() async {
    if (isChecking) return;
    try {
      isChecking = true;
      final title = titleController.text.trim();
      final body = bodyController.text.trim();
      const List<String> tags = ['public'];
      if (title == '' &&
          body == '' &&
          gif == null &&
          image == null &&
          !isPoll) {
        titleFocus.requestFocus();
        showSnackBar(
          text: AppLocalizations.of(context)!.allFieldsEmpty,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
      if (title.length > c.maxTitleChars) {
        titleFocus.requestFocus();
        showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
      if (body.length > c.maxPostChars) {
        bodyFocus.requestFocus();
        showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
      if (_countNewLines(body) > c.maxPostLines) {
        bodyFocus.requestFocus();
        showSnackBar(
          text: AppLocalizations.of(context)!.tooManyLine,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
      if (isPoll &&
          pollOptions.where((option) => option.trim().isNotEmpty).length <
              c.minPollOptions) {
        showSnackBar(
          text: AppLocalizations.of(context)!.needTwoOptions,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
      if (isPoll && pollOptions.any((option) => option.trim().isEmpty)) {
        showSnackBar(
          text: AppLocalizations.of(context)!.blankPollOption,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
      if (isPoll && pollOptions.length > c.maxPollOptions) {
        showSnackBar(
          text: AppLocalizations.of(context)!.tooManyPollOptions,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
      if (isPoll &&
          pollOptions.any((option) => option.length > c.maxPollChars)) {
        showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }

      final postPollOptions = !isPoll ? null : pollOptions;
      final post = PostModel(
        uid: ref.read(currentUserProvider).user.uid,
        id: 0,
        tags: tags,
        likes: 0,
        dislikes: 0,
        commentCount: 0,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        imageString: image,
        gifUrl: gif,
        repostId: repostId,
        title: title,
        body: body,
        poll: postPollOptions
            ?.map<PollOptionModel>(
              (v) => PollOptionModel(value: v, optionId: 0, voteCount: 0),
            )
            .toList(),
      );

      if (mounted) {
        if (ref.read(postPreviewProvider)) {
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) {
              final l10n = AppLocalizations.of(context)!;
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                title: Text(l10n.postToPublicConfirmTitle(l10n.public)),
                content: SingleChildScrollView(
                  child: PostCardFromPost(post: post, isPreview: true),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(l10n.cancel),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  TextButton(
                    child: Text(l10n.post),
                    onPressed: () async {
                      if (isUploading) return;
                      if (context.mounted) context.pop();
                      await _uploadAndNavigate(post, postPollOptions);
                    },
                  ),
                ],
              );
            },
          ).then((_) => FocusManager.instance.primaryFocus?.unfocus());
        } else {
          await _uploadAndNavigate(post, postPollOptions);
          FocusManager.instance.primaryFocus?.unfocus();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        showSnackBar(
          text: AppLocalizations.of(context)!.defaultErrorTitle,
          context: context,
          variant: SnackBarVariant.destructive,
        );
      }
    } finally {
      isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fabInset = ((constraints.maxWidth - c.indealAppWidth) / 2)
            .clamp(0.0, double.infinity)
            .toDouble();
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: AppScaffold(
            contrainBody: true,
            floatingActionButtonLocation: ExpandableFab.location,
            floatingActionButton: Visibility(
              visible: showFab,
              child: ExpandableFab(
                margin: EdgeInsets.only(right: fabInset),
                onOpen: () => FocusManager.instance.primaryFocus?.unfocus(),
                key: _key,
                openButtonBuilder: RotateFloatingActionButtonBuilder(
                  fabSize: ExpandableFabSize.regular,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add_photo_alternate_outlined),
                ),
                closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                  child: const Icon(Icons.close),
                  fabSize: ExpandableFabSize.regular,
                  shape: const CircleBorder(),
                ),
                type: ExpandableFabType.fan,
                distance: 70.0,
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () {
                      final state = _key.currentState;
                      if (state != null) {
                        state.toggle();
                      }
                      _addPollPressed();
                    },
                    child: const Icon(Icons.poll),
                  ),
                  if (!kIsWeb)
                    FloatingActionButton.small(
                      heroTag: null,
                      child: const Icon(Icons.perm_media),
                      onPressed: () async {
                        final state = _key.currentState;
                        if (state != null) {
                          state.toggle();
                        }
                        _addImagePressed();
                      },
                    ),
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () {
                      final state = _key.currentState;
                      if (state != null) {
                        state.toggle();
                      }
                      _addGifPressed();
                    },
                    child: const Icon(Icons.gif_box_rounded),
                  ),
                ],
              ),
            ),
            appBar: EkoAppBar(
              showBackButton: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _clear();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.clear,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _postPressed(),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.postButton,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: ListView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SizedBox(height: height * 0.01),
                  Row(
                    children: [
                      ProfilePicture(
                        uid: ref.watch(currentUserProvider).user.uid,
                        onlineIndicatorEnabled: false,
                        size: width * 0.115,
                      ),
                      const SizedBox(width: 9),
                      ToggleButtons(
                        isSelected: [!showMarkdownPreview, showMarkdownPreview],
                        onPressed: (index) {
                          setState(() {
                            showMarkdownPreview = (index == 1);
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.onSurface,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                        borderColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        selectedBorderColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        constraints: BoxConstraints(
                          minHeight: 32,
                          minWidth: 70,
                        ),
                        children: [
                          Text(AppLocalizations.of(context)!.write),
                          Text(AppLocalizations.of(context)!.preview),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: AppLocalizations.of(
                          context,
                        )!.markdownBoldTooltip,
                        onPressed: showMarkdownPreview
                            ? null
                            : () => _wrapActiveFieldMarkdown('**', '**'),
                        icon: const Icon(Icons.format_bold),
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(32, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(
                          context,
                        )!.markdownItalicTooltip,
                        onPressed: showMarkdownPreview
                            ? null
                            : () => _wrapActiveFieldMarkdown('*', '*'),
                        icon: const Icon(Icons.format_italic),
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(32, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  showMarkdownPreview
                      ? MarkdownView(
                          content: titleController.text,
                          type: MarkdownType.title,
                        )
                      : TextField(
                          textCapitalization: TextCapitalization.sentences,
                          focusNode: titleFocus,
                          controller: titleController,
                          maxLines: null,
                          cursorColor: Theme.of(context).colorScheme.onSurface,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(height * 0.01),
                            hintText: AppLocalizations.of(context)!.postTitle,
                            hintStyle: TextStyle(
                              fontSize: 22,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                          ),
                          // ),
                        ),
                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              titleController,
                              titleFocus,
                            ]),
                            builder: (context, _) {
                              if (titleFocus.hasPrimaryFocus &&
                                  titleController.text.isNotEmpty) {
                                return Text(
                                  '${titleController.text.length}/${c.maxTitleChars} ${AppLocalizations.of(context)!.characters}',
                                );
                              }
                              return SizedBox();
                            },
                          ),
                          if (repostId != null)
                            _CornerClose(
                              onPressed: () => setState(() {
                                repostId = null;
                              }),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: width * 0.8,
                                ),
                                child: RepostCard(
                                  postId: repostId!,
                                  isLoggedIn: true,
                                  isPreview: true,
                                ),
                              ),
                            ),
                          if (gif != null)
                            _CornerClose(
                              onPressed: () => setState(() {
                                gif = null;
                              }),
                              child: GifWidget(url: gif!),
                            ),
                          if (image != null)
                            _CornerClose(
                              onPressed: () => setState(() {
                                image = null;
                              }),
                              child: Align(child: ImageWidget(ascii: image!)),
                            ),
                          if (isPoll &&
                              (image != null ||
                                  gif != null ||
                                  repostId != null))
                            SizedBox(height: 5),
                          if (isPoll)
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 10,
                              ),
                              child: _CornerClose(
                                onPressed: () => setState(() {
                                  isPoll = false;
                                }),
                                child: PollCreator(
                                  height: height,
                                  width: width,
                                  pollOptions: pollOptions,
                                ),
                              ),
                            ),
                          showMarkdownPreview
                              ? MarkdownView(content: bodyController.text)
                              : ConstrainedBox(
                                  constraints: BoxConstraints(),
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    focusNode: bodyFocus,
                                    controller: bodyController,
                                    maxLines: null,
                                    cursorColor: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(
                                        height * 0.01,
                                      ),
                                      hintText: AppLocalizations.of(
                                        context,
                                      )!.addText,
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              bodyController,
                              bodyFocus,
                            ]),
                            builder: (context, _) {
                              if (bodyFocus.hasPrimaryFocus &&
                                  bodyController.text.isNotEmpty) {
                                return Row(
                                  children: [
                                    Text(
                                      '${bodyController.text.length}/${c.maxPostChars} ${AppLocalizations.of(context)!.characters}',
                                    ),
                                    const Spacer(),
                                    if (bodyNewLines != 0 || true)
                                      Text(
                                        '${_countNewLines(bodyController.text.trim())}/${c.maxPostLines} ${AppLocalizations.of(context)!.newLines}',
                                      ),
                                  ],
                                );
                              }
                              return SizedBox();
                            },
                          ),
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              bodyController,
                              bodyFocus,
                            ]),
                            builder: (context, _) {
                              final text = searchText(bodyController);
                              if (text != null && bodyFocus.hasFocus) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => scrollController.jumpTo(
                                    scrollController.position.maxScrollExtent,
                                  ),
                                );
                                return TagSearch(
                                  onCardTap: (username) =>
                                      onCardTap(username, bodyController),
                                  searchText: text,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.4,
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ],
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          titleController,
                          titleFocus,
                        ]),
                        builder: (context, _) {
                          final text = searchText(titleController);
                          if (text != null && titleFocus.hasFocus) {
                            return TagSearch(
                              onCardTap: (username) =>
                                  onCardTap(username, titleController),
                              searchText: text,
                              height: MediaQuery.sizeOf(context).height * 0.4,
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
