import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:untitled_app/custom_widgets/error_snack_bar.dart';
import 'package:untitled_app/custom_widgets/group_card.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/following_feed_provider.dart';
import 'package:untitled_app/providers/group_list_provider.dart';
import 'package:untitled_app/providers/group_provider.dart';
// import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/providers/new_feed_provider.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/poll_creator.dart';
import 'package:untitled_app/widgets/post_card.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
// import '../custom_widgets/searched_user_card.dart';
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
  bool _isLoadingImage = false;
  String? audiance;
  GiphyGif? gif;
  String? image;
  bool isPoll = false;
  List<String> pollOptions = ['', ''];
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final bodyFocus = FocusNode();
  final titleFocus = FocusNode();
  int bodyNewLines = 0;
  bool isPosting = false;

  void _setState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    audiance = widget.groupId;
    bodyController.addListener(_onBodyChanged);
    titleController.addListener(_setState);
    titleFocus.addListener(_setState);
    bodyFocus.addListener(_setState);
  }

  @override
  void dispose() {
    bodyController.removeListener(_onBodyChanged);
    titleController.removeListener(_setState);
    titleFocus.removeListener(_setState);
    bodyFocus.removeListener(_setState);
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

  void _onBodyChanged() {
    final count = _countNewLines(bodyController.text.trim());
    setState(() {
      bodyNewLines = count;
    });
  }

  Future<void> _addGifPressed() async {
    ref.read(navBarProvider.notifier).disable();
    GiphyGif? newGif = await GiphyGet.getGif(
      context: context,
      apiKey: dotenv.env['GIPHY_API_KEY']!,
      lang: GiphyLanguage.english,
      tabColor: Colors.teal,
      debounceTimeInMilliseconds: 350,
    );
    //only update gif a gif was selected
    if (newGif != null) {
      setState(() {
        gif = newGif;
        gif = newGif;
        image = null;
        isPoll = false;
      });
    }

    ref.read(navBarProvider.notifier).enable();
  }

  Future<void> _addImagePressed() async {
    final asciiArt = await context.push('/compose/camera');

    if (asciiArt != null && asciiArt is String) {
      setState(() {
        image = asciiArt;
        gif = null;
        isPoll = false;
      });
    }
  }

  void _addPollPressed() {
    ref.read(navBarProvider.notifier).disable();
    setState(() {
      isPoll = true;
      gif = null;
      image = null;
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
      isPoll = false;
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

    if (isPosting) {
      return;
    }

    setState(() {
      isPosting = true;
    });

    final post = PostModel(
      uid: ref.watch(currentUserProvider).user.uid,
      id: '',
      tags: tags,
      likes: 0,
      dislikes: 0,
      commentCount: 0,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      isPoll: isPoll,
      pollOptions: isPoll ? pollOptions : null,
      imageString: image,
      gifUrl: gif?.images?.fixedWidth.url,
      title: parseTextToTags(title),
      body: parseTextToTags(body),
    );

    showDialog(
      barrierDismissible: !isPosting,
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
                if (!isPosting) {
                  context.pop();
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.post),
              onPressed: () async {
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
              },
            ),
          ],
        );
      },
    ).then((_) => FocusManager.instance.primaryFocus?.unfocus());

    setState(() {
      isPosting = false;
    });
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
          visible: !bodyFocus.hasPrimaryFocus,
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
        body: IndexedStack(
          index: 0,
          // !prov.Provider.of<ComposeController>(context, listen: false)
          //         .isAtSymbolTyped
          //     ? 0
          //     : 1,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SizedBox(height: height * 0.01),
                  Row(
                    children: [
                      ProfilePicture(
                          uid: ref.watch(currentUserProvider).user.uid,
                          size: width * 0.115),
                      const SizedBox(width: 9),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.outline,
                          side: BorderSide(
                            width: 0.5,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      border: InputBorder.none,
                    ),
                    // ),
                  ),
                  (titleFocus.hasPrimaryFocus &&
                          titleController.text.isNotEmpty)
                      ? Text(
                          '${titleController.text.length}/${c.maxTitleChars} ${AppLocalizations.of(context)!.characters}')
                      : Container(),
                  if (gif != null || image != null || isPoll || _isLoadingImage)
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
                              child: _isLoadingImage
                                  ? SizedBox(
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: CircularProgressIndicator()))
                                  : isPoll
                                      ? PollCreator(
                                          height: height,
                                          width: width,
                                          pollOptions: pollOptions,
                                        )
                                      : image != null
                                          ? ImageWidget(text: image!)
                                          : Image.network(
                                              gif!.images!.fixedWidth.url,
                                              loadingBuilder:
                                                  (BuildContext context,
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
                                                  child:
                                                      CircularProgressIndicator(
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
                            iconSize: image != null && _isLoadingImage == false
                                ? 150
                                : 30,
                            onPressed: () => _removeMedia(),
                            icon: DecoratedBox(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.surface),
                              child: Icon(
                                Icons.cancel,
                                color: Theme.of(context).colorScheme.onSurface,
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  (bodyFocus.hasPrimaryFocus && bodyController.text.isNotEmpty)
                      ? Row(
                          children: [
                            Text(
                                '${bodyController.text.length}/${c.maxPostChars} ${AppLocalizations.of(context)!.characters}'),
                            const Spacer(),
                            if (bodyNewLines != 0 || true)
                              Text(
                                  '$bodyNewLines/${c.maxPostLines} ${AppLocalizations.of(context)!.newLines}'),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            //   child: Column(
            //     children: [
            //       TextField(
            //         focusNode: prov.Provider.of<ComposeController>(context,
            //                 listen: false)
            //             .searchFocus,
            //         controller: prov.Provider.of<ComposeController>(context,
            //                 listen: false)
            //             .searchController,
            //         onChanged: (s) {
            //           prov.Provider.of<ComposeController>(context,
            //                   listen: false)
            //               .checkAtSymbol(s);
            //         },
            //         textCapitalization: TextCapitalization.sentences,
            //         maxLines: null,
            //         cursorColor: Theme.of(context).colorScheme.onSurface,
            //         keyboardType: TextInputType.text,
            //         style: TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.normal,
            //             color: Theme.of(context).colorScheme.onSurface),
            //         decoration: InputDecoration(
            //           contentPadding: EdgeInsets.all(height * 0.01),
            //           hintText: AppLocalizations.of(context)!.addText,
            //           hintStyle: TextStyle(
            //               fontSize: 20,
            //               fontWeight: FontWeight.normal,
            //               color: Theme.of(context)
            //                   .colorScheme
            //                   .onSurfaceVariant),
            //           border: InputBorder.none,
            //         ),
            //       ),
            //       Expanded(
            //         child: prov.Provider.of<ComposeController>(context,
            //                     listen: true)
            //                 .isLoading
            //             ? const Center(
            //                 child: CircularProgressIndicator(),
            //               )
            //             : prov.Provider.of<ComposeController>(context,
            //                         listen: true)
            //                     .hits
            //                     .isEmpty
            //                 ? Center(
            //                     child: Text(
            //                       AppLocalizations.of(context)!
            //                           .noResultsFound,
            //                       style: TextStyle(
            //                           fontSize: 18,
            //                           color: Theme.of(context)
            //                               .colorScheme
            //                               .onSurface),
            //                     ),
            //                   )
            //                 : ListView.builder(
            //                     shrinkWrap: true,
            //                     itemCount:
            //                         prov.Provider.of<ComposeController>(
            //                                 context,
            //                                 listen: true)
            //                             .hits
            //                             .length,
            //                     itemBuilder:
            //                         (BuildContext context, int index) {
            //                       return UserCard(
            //                           tagSearch: true,
            //                           onCardTap: (username) {
            //                             prov.Provider.of<ComposeController>(
            //                                     context,
            //                                     listen: false)
            //                                 .updateTextField(
            //                                     username,
            //                                     prov.Provider.of<
            //                                                 ComposeController>(
            //                                             context,
            //                                             listen: false)
            //                                         .titleController,
            //                                     prov.Provider.of<
            //                                                 ComposeController>(
            //                                             context,
            //                                             listen: false)
            //                                         .titleFocus);
            //                             prov.Provider.of<ComposeController>(
            //                                     context,
            //                                     listen: false)
            //                                 .updateTextField(
            //                                     username,
            //                                     prov.Provider.of<
            //                                                 ComposeController>(
            //                                             context,
            //                                             listen: false)
            //                                         .bodyController,
            //                                     prov.Provider.of<
            //                                                 ComposeController>(
            //                                             context,
            //                                             listen: false)
            //                                         .bodyFocus);
            //                           },
            //                           uid: prov.Provider.of<
            //                                       ComposeController>(
            //                                   context,
            //                                   listen: true)
            //                               .hits[index]
            //                               .uid);
            //                     },
            //                   ),
            //       )
            //     ],
            //   ),
            // )
          ],
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
