import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:universal_html/js_util.dart';
import 'package:untitled_app/custom_widgets/error_snack_bar.dart';
import 'package:untitled_app/widgets/group_card.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/following_feed_provider.dart';
import 'package:untitled_app/providers/group_list_provider.dart';
import 'package:untitled_app/providers/group_provider.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/providers/new_feed_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/poll_creator.dart';
import 'package:untitled_app/widgets/post_card.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import 'package:untitled_app/widgets/tag_search.dart';
import '../utilities/constants.dart' as c;
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class ComposePage extends ConsumerStatefulWidget {
  final String? groupId;
  const ComposePage({super.key, this.groupId});
  @override
  ConsumerState<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends ConsumerState<ComposePage> {
  final _key = GlobalKey<ExpandableFabState>();
  String? audiance;
  String? gif;
  AsciiImage? image;
  bool isPoll = false;
  List<String> pollOptions = ['', ''];
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final scrollController = ScrollController();
  final bodyFocus = FocusNode();
  final titleFocus = FocusNode();
  int bodyNewLines = 0;
  bool isUploading = false;
  String? partialTag;
  bool showFab = true;

  @override
  void didUpdateWidget(covariant ComposePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      setState(() {
        audiance = widget.groupId;
      });
    }
  }

  @override
  void initState() {
    bodyFocus.addListener(bodyFocusListen);
    super.initState();
  }

  void bodyFocusListen() {
    setState(() {
      showFab = !bodyFocus.hasPrimaryFocus;
    });
  }

  @override
  void dispose() {
    bodyFocus.removeListener(bodyFocusListen);
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

  void _addGifPressed() async {
    String? url = await context.pushNamed('gif');
    if (url != null) {
      setState(() {
        gif = url;
        image = null;
      });
    }
  }

  Future<void> _addImagePressed() async {
    ref.read(navBarProvider.notifier).disable();
    final pickedImage = await context.pushNamed<XFile?>('camera');

    if (pickedImage == null || !mounted) {
      ref.read(navBarProvider.notifier).enable();
      return;
    }

    final asciiImage = await context.pushNamed<AsciiImage?>('edit_picture',
        extra: pickedImage);

    // Removed since it saved even if you uploaded from camera roll
    // if (asciiImage != null) {
    //   GallerySaver.saveImage(pickedImage.path, toDcim: true)
    //       .then((_) => File(pickedImage.path).delete());
    // }

    setState(() {
      image = asciiImage;
    });

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
      isPoll = false;
      pollOptions = ['', ''];
      gif = null;
      image = null;
      bodyNewLines = 0;
      bodyController.clear();
      titleController.clear();
      audiance = null;
    });
  }

  void _removeMedia() {
    setState(() {
      gif = null;
      image = null;
    });
  }

  Future<void> _postPressed() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    final List<String> tags = [audiance ?? 'public'];
    if (title == '' && body == '' && gif == null && image == null && !isPoll) {
      titleFocus.requestFocus();
      showSnackBar(
          text: AppLocalizations.of(context)!.emptyFieldError,
          context: context);
      return;
    }
    if (title.length > c.maxTitleChars) {
      titleFocus.requestFocus();
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar, context: context);
      return;
    }
    if (body.length > c.maxPostChars) {
      bodyFocus.requestFocus();
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar, context: context);
      return;
    }
    if (_countNewLines(body) > c.maxPostLines) {
      bodyFocus.requestFocus();
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyLine, context: context);
      return;
    }
    if (isPoll &&
        pollOptions.where((option) => option.trim().isNotEmpty).length < 2) {
      showSnackBar(
          text: AppLocalizations.of(context)!.needTwoOptions, context: context);
      return;
    }
    if (isPoll && pollOptions.any((option) => option.length > c.maxPollChars)) {
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar, context: context);
      return;
    }

    final post = PostModel(
      uid: ref.watch(currentUserProvider).user.uid,
      id: '',
      tags: tags,
      likes: 0,
      dislikes: 0,
      commentCount: 0,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      pollOptions: isPoll ? pollOptions : null,
      imageString: image,
      gifUrl: gif,
      title: parseTextToTags(title),
      body: parseTextToTags(body),
    );

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.outlineVariant,
          title: Text(
              'Post to ${audiance == null ? AppLocalizations.of(context)!.public : ref.watch(groupProvider(audiance!)).when(data: (group) => group.name, loading: () => '--', error: (_, __) => '--')}?'),
          content: SingleChildScrollView(
            child: PostCardFromPost(post: post, isPreview: true),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.post),
              onPressed: () async {
                if (isUploading) return;
                isUploading = true;
                final postToUpload = post.copyWith(
                    createdAt: DateTime.now().toUtc().toIso8601String());
                final id = await uploadPost(postToUpload, ref);
                if (context.mounted) context.pop();
                _clear();
                if (context.mounted) {
                  if (post.tags.contains('public')) {
                    final completePost = postToUpload.copyWith(
                      id: id,
                    );
                    ref
                        .read(newFeedProvider.notifier)
                        .insertAtIndex(0, completePost);
                    ref
                        .read(followingFeedProvider.notifier)
                        .insertAtIndex(0, completePost);
                    ref.read(postPoolProvider).putAll([completePost]);
                    context.go('/feed');
                  } else {
                    context.go('/groups/sub_group/${post.tags.first}');
                  }
                }
                isUploading = false;
              },
            ),
          ],
        );
      },
    ).then((_) => FocusManager.instance.primaryFocus?.unfocus());
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: Visibility(
          visible: showFab,
          child: ExpandableFab(
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
              FloatingActionButton.small(
                  heroTag: null,
                  child: const Icon(Icons.perm_media),
                  onPressed: () async {
                    final state = _key.currentState;
                    if (state != null) {
                      state.toggle();
                    }
                    _addImagePressed();
                  }),
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
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _clear();
                },
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface),
                child: Text(
                  AppLocalizations.of(context)!.clear,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: () => _postPressed(),
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: ListView(
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              SizedBox(height: height * 0.01),
              Row(
                children: [
                  ProfilePicture(
                      uid: ref.watch(currentUserProvider).user.uid,
                      onlineIndicatorEnabled: false,
                      size: width * 0.115),
                  const SizedBox(width: 9),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.outline,
                      side: BorderSide(
                        width: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        style: BorderStyle.solid,
                      ),
                    ),
                    onPressed: () => _audianceButtonPressed(
                        context,
                        (id) => setState(() {
                              audiance = id;
                            })),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AudianceText(id: audiance),
                        Icon(Icons.expand_more_rounded,
                            color: Theme.of(context).colorScheme.onSurface),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: height * 0.01),
              // ConstrainedBox(
              //   constraints: BoxConstraints(maxHeight: height * 0.5),
              //   child:
              TextField(
                textCapitalization: TextCapitalization.sentences,
                focusNode: titleFocus,
                controller: titleController,
                maxLines: null,
                cursorColor: Theme.of(context).colorScheme.onSurface,
                keyboardType: TextInputType.text,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(height * 0.01),
                  hintText: AppLocalizations.of(context)!.postTitle,
                  hintStyle: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                          animation:
                              Listenable.merge([titleController, titleFocus]),
                          builder: (context, _) {
                            if (titleFocus.hasPrimaryFocus &&
                                titleController.text.isNotEmpty) {
                              return Text(
                                  '${titleController.text.length}/${c.maxTitleChars} ${AppLocalizations.of(context)!.characters}');
                            }
                            return SizedBox();
                          }),
                      if (gif != null || image != null)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.025,
                                    horizontal: height * 0.025),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: image != null
                                      ? Align(child: ImageWidget(ascii: image!))
                                      : Image.network(
                                          // gif!.images!.fixedWidth.url,
                                          gif ?? '',
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              alignment: Alignment.center,
                                              width: 200,
                                              height: 150,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                              IconButton(
                                iconSize: image != null ? 150 : 30,
                                onPressed: () => _removeMedia(),
                                icon: DecoratedBox(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  child: Icon(
                                    Icons.cancel,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (isPoll)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.025,
                                    horizontal: height * 0.025),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: PollCreator(
                                      height: height,
                                      width: width,
                                      pollOptions: pollOptions,
                                    )),
                              ),
                              IconButton(
                                iconSize: 30,
                                onPressed: () => setState(() {
                                  isPoll = false;
                                }),
                                icon: DecoratedBox(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  child: Icon(
                                    Icons.cancel,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ConstrainedBox(
                        constraints: BoxConstraints(),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          focusNode: bodyFocus,
                          controller: bodyController,
                          maxLines: null,
                          cursorColor: Theme.of(context).colorScheme.onSurface,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(height * 0.01),
                            hintText: AppLocalizations.of(context)!.addText,
                            hintStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation:
                            Listenable.merge([bodyController, bodyFocus]),
                        builder: (context, _) {
                          if (bodyFocus.hasPrimaryFocus &&
                              bodyController.text.isNotEmpty) {
                            return Row(
                              children: [
                                Text(
                                    '${bodyController.text.length}/${c.maxPostChars} ${AppLocalizations.of(context)!.characters}'),
                                const Spacer(),
                                if (bodyNewLines != 0 || true)
                                  Text(
                                      '${_countNewLines(bodyController.text.trim())}/${c.maxPostLines} ${AppLocalizations.of(context)!.newLines}'),
                              ],
                            );
                          }
                          return SizedBox();
                        },
                      ),
                      AnimatedBuilder(
                        animation:
                            Listenable.merge([bodyController, bodyFocus]),
                        builder: (context, _) {
                          final text = searchText(bodyController);
                          if (text != null && bodyFocus.hasFocus) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent),
                            );
                            return TagSearch(
                              onCardTap: (username) =>
                                  onCardTap(username, bodyController),
                              searchText: text,
                              height: MediaQuery.sizeOf(context).height * 0.4,
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: Listenable.merge([titleController, titleFocus]),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AudianceText extends ConsumerWidget {
  final String? id;
  const _AudianceText({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return Text(AppLocalizations.of(context)!.public,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
    }
    final asyncGroup = ref.watch(groupProvider(id!));
    return asyncGroup.when(
        data: (group) => Text(group.name,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        error: (_, __) => SizedBox.shrink(),
        loading: () => SizedBox.shrink());
  }
}

class _GroupListHeader extends StatelessWidget {
  final void Function() onPopularPressed;
  const _GroupListHeader({required this.onPopularPressed});

  @override
  Widget build(BuildContext context) {
    final double width = c.widthGetter(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              AppLocalizations.of(context)!.selectAudience,
              style: const TextStyle(fontSize: 24),
            )),
        Divider(
          color: Theme.of(context).colorScheme.outline,
          height: c.dividerWidth,
        ),
        InkWell(
          onTap: () {
            onPopularPressed();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.05,
                ),
                Icon(Icons.public, size: width * 0.18),
                SizedBox(
                  width: width * 0.05,
                ),
                Text(
                  AppLocalizations.of(context)!.public,
                  style: const TextStyle(fontSize: 19),
                )
              ],
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.outline,
          height: c.dividerWidth,
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 7, top: 12, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.myGroups,
            style: const TextStyle(fontSize: 18),
          ),
        )
      ],
    );
  }
}

class _GroupList extends ConsumerWidget {
  final void Function(String?) onItemPressed;
  const _GroupList({required this.onItemPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsData = ref.watch(groupListProvider);
    return InfiniteScrollyShell<String>(
        header: _GroupListHeader(
          onPopularPressed: () {
            onItemPressed(null);
            context.pop();
          },
        ),
        getter: ref.read(groupListProvider.notifier).getter,
        onRefresh: ref.read(groupListProvider.notifier).refresh,
        widget: (id) => GroupCard(
            groupId: id,
            onPressed: (id) {
              onItemPressed(id);
              context.pop();
            }),
        list: groupsData.$1,
        isEnd: groupsData.$2);
  }
}

void _audianceButtonPressed(
    BuildContext context, void Function(String?) onItemPressed) {
  showModalBottomSheet(
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.outlineVariant,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return _GroupList(
        onItemPressed: onItemPressed,
      );
    },
  );
}
