import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
// import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/poll_creator.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import '../custom_widgets/searched_user_card.dart';
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
  GiphyGif? gif;
  String? image;
  bool isPoll = false;
  List<String> pollOptions = ['', ''];
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final bodyFocus = FocusNode();
  final titleFocus = FocusNode();
  int titleChars = 0;
  int bodyChars = 0;
  int bodyNewLines = 0;
  bool showBodyCount = false;
  bool showTitleCount = false;
  bool hideFAB = false;

  @override
  void initState() {
    super.initState();
    titleController.addListener(_onTitleChanged);
    bodyController.addListener(_onBodyChanged);
    bodyFocus.addListener(_onBodyFocusChanged);
    titleFocus.addListener(_onTitleFocusChanged);
  }

  @override
  void dispose() {
    titleController.removeListener(_onTitleChanged);
    bodyController.removeListener(_onBodyChanged);
    bodyFocus.removeListener(_onBodyFocusChanged);
    titleFocus.removeListener(_onTitleFocusChanged);
    titleController.dispose();
    bodyController.dispose();
    titleFocus.dispose();
    bodyFocus.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    setState(() {
      titleChars = titleController.text.length;
      showBodyCount = false;
      showTitleCount = true;
    });
  }

  void _onBodyChanged() {
    int count = 0;
    for (int i = 0; i < bodyController.text.length; i++) {
      if (bodyController.text[i] == '\n') {
        count++;
      }
    }
    setState(() {
      bodyChars = bodyController.text.length;
      bodyNewLines = count;
      showBodyCount = true;
      showTitleCount = false;
    });
  }

  void _onTitleFocusChanged() {
    setState(() {
      if (titleFocus.hasPrimaryFocus) {
        showTitleCount = true;
      } else {
        showTitleCount = false;
      }
    });
  }

  void _onBodyFocusChanged() {
    setState(() {
      if (bodyFocus.hasPrimaryFocus) {
        showBodyCount = true;
        hideFAB = true;
      } else {
        showBodyCount = false;
        hideFAB = false;
      }
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
    Future<String?> uploadImage(File imageFile) async {
      var url =
          Uri.parse('https://createimage-146952619766.us-central1.run.app/');
      var request = http.MultipartRequest('POST', url);

      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseText = await response.stream.bytesToString();
        return responseText;
      } else {
        return null;
      }
    }

    // ref.read(navBarProvider.notifier).disable();
    setState(() {
      _isLoadingImage = true;
    });
    final ImagePicker picker = ImagePicker();
    final XFile? imageLocal =
        await picker.pickImage(source: ImageSource.gallery);

    if (imageLocal != null) {
      File imageFile = File(imageLocal.path);
      String? ascii = await uploadImage(File(imageFile.path));
      if (ascii != null) {
        setState(() {
          image = ascii;
          gif = null;
          isPoll = false;
        });
      }
    } else {}
    setState(() {
      _isLoadingImage = false;
    });
    // ref.read(navBarProvider.notifier).enable();
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
      bodyChars = 0;
      titleChars = 0;
      showBodyCount = false;
      showTitleCount = false;
      bodyController.clear();
      titleController.clear();
    });
  }

  void _removeMedia() {
    setState(() {
      isPoll = false;
      gif = null;
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audiance = AppLocalizations.of(context)!.public;
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        //
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: Visibility(
          visible: !hideFAB,
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
                onPressed: () => _clear(),
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
                onPressed: () {},
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
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(audiance,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
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
                  (showTitleCount && titleChars != 0)
                      ? Text(
                          '$titleChars/${c.maxTitleChars} ${AppLocalizations.of(context)!.characters}')
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
                  (showBodyCount && bodyChars != 0)
                      ? Row(
                          children: [
                            Text(
                                '$bodyChars/${c.maxPostChars} ${AppLocalizations.of(context)!.characters}'),
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

// void _audianceButtonPressed(BuildContext context) {
//   showModalBottomSheet(
//     showDragHandle: true,
//     backgroundColor: Theme.of(context).colorScheme.outlineVariant,
//     isScrollControlled: true,
//     context: context,
//     builder: (BuildContext context) {
//       final double width = c.widthGetter(context);
//       return SizedBox(
//           child: InfiniteScrolly<String, String>(
//               header: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                       padding: const EdgeInsets.only(bottom: 5),
//                       child: Text(
//                         AppLocalizations.of(context)!.selectAudience,
//                         style: const TextStyle(fontSize: 24),
//                       )),
//                   Divider(
//                     color: Theme.of(context).colorScheme.outline,
//                     height: c.dividerWidth,
//                   ),
//                   InkWell(
//                     onTap: () {
//                       groupEndPoint = null;
//                       audience = AppLocalizations.of(context)!.public;
//                       context.pop();
//                       notifyListeners();
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: width * 0.05,
//                           ),
//                           Icon(Icons.public, size: width * 0.18),
//                           SizedBox(
//                             width: width * 0.05,
//                           ),
//                           Text(
//                             AppLocalizations.of(context)!.public,
//                             style: const TextStyle(fontSize: 19),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   Divider(
//                     color: Theme.of(context).colorScheme.outline,
//                     height: c.dividerWidth,
//                   ),
//                   Container(
//                       alignment: Alignment.centerLeft,
//                       padding:
//                           const EdgeInsets.only(left: 7, top: 12, bottom: 12),
//                       child: Text(
//                         AppLocalizations.of(context)!.myGroups,
//                         style: const TextStyle(fontSize: 18),
//                       ))
//                 ],
//               ),
//               getter: _getGroups,
//               widget: _groupCardSearchBuilder,
//               startAfterQuery: _getTimeFromGroup));
//     },
//   );
// }
