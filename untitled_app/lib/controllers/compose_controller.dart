import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart' as http;
import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/current_user.dart';
import '../models/search_model.dart';
import '../utilities/constants.dart' as c;
import '../custom_widgets/error_snack_bar.dart';
import 'package:giphy_get/giphy_get.dart';
import '../utilities/locator.dart';
import '../models/post_handler.dart';
import 'bottom_nav_bar_controller.dart';
import '../custom_widgets/post_card.dart';
import "package:go_router/go_router.dart";
import 'package:untitled_app/models/feed_post_cache.dart';
import '../models/users.dart' show AppUser;
import '../models/group_handler.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;
import '../custom_widgets/pagination.dart';
import '../custom_widgets/group_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class ComposeController extends ChangeNotifier {
  final BuildContext context;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final titleFocus = FocusNode();
  final bodyFocus = FocusNode();
  final searchController = TextEditingController();
  final searchFocus = FocusNode();

  Group? groupEndPoint;
  Group? initGroupVar;
  // List<String> tags;
  String audience;
  int newLines = 0;
  int bodyChars = 0;
  int titleChars = 0;
  bool showCount0 = false;
  bool showCount1 = false;
  GiphyGif? gif;
  String? image;
  bool isAtSymbolTyped = false;
  bool isLoading = false;
  List<AppUser> hits = [];
  Timer? _debounce;

  ComposeController({required this.context, required this.audience}) {
    titleFocus.addListener(onTitleFocusChanged);
    bodyFocus.addListener(onBodyFocusChanged);
  }
  initGroup(Group? group) {
    if (group != initGroupVar) {
      groupEndPoint = group;
      audience =
          (group != null) ? group.name : AppLocalizations.of(context)!.public;

      initGroupVar = group;
    }
  }

  @override
  void dispose() {
    titleFocus.removeListener(onTitleFocusChanged);
    bodyFocus.removeListener(onBodyFocusChanged);
    titleController.dispose();
    bodyController.dispose();
    titleFocus.dispose();
    bodyFocus.dispose();
    searchController.dispose();
    searchFocus.dispose();

    super.dispose();
  }

  void onTitleFocusChanged() {
    if (titleFocus.hasFocus) {
      showCount0 = true;
    } else {
      showCount0 = false;
    }
    notifyListeners();
  }

  void onWillPop() {
    locator<NavBarController>().goBranch(0);
  }

  void onBodyFocusChanged() {
    if (bodyFocus.hasFocus) {
      showCount1 = true;
    } else {
      showCount1 = false;
    }
    notifyListeners();
  }

  // changeDisplayCount(bool value, int index) {
  //   if (index == 0) {
  //     showCount0 = value;
  //   } else {
  //     showCount1 = value;
  //   }
  //   notifyListeners();
  // }

  updateCountsBody(String str) {
    bodyChars = str.length;
    newLines = '\n'.allMatches(str).length;
    notifyListeners();
  }

  updateCountsTitle(String str) {
    titleChars = str.length;
    notifyListeners();
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  removeGifPressed() {
    gif = null;
    image = null;
    notifyListeners();
  }

  clearPressed() {
    hideKeyboard();
    gif = null;
    newLines = 0;
    bodyChars = 0;
    titleChars = 0;
    showCount0 = false;
    showCount1 = false;
    titleController.text = "";
    bodyController.text = "";
    searchController.text = "";
    isAtSymbolTyped = false;
    notifyListeners();
  }

  void _onAudienceGroupCardPressed(Group group) {
    // print("test");
    groupEndPoint = group;
    audience = group.name;
    context.pop();
    notifyListeners();
  }

  dynamic _getTimeFromGroup(dynamic group) {
    return (group as Group).lastActivity;
  }

  Future<PaginationGetterReturn> _getGroups(dynamic time) {
    return GroupHandler().getGroups(time);
  }

  Widget _groupCardSearchBuilder(dynamic group) {
    return GroupCard(
      group: group,
      onPressedSearched: _onAudienceGroupCardPressed,
    );
  }

  void audianceButtonPressed() {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        final double width = c.widthGetter(context);
        return SizedBox(
            child: PaginationPage(
                header: Column(
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
                        groupEndPoint = null;
                        audience = AppLocalizations.of(context)!.public;
                        context.pop();
                        notifyListeners();
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
                        padding:
                            const EdgeInsets.only(left: 7, top: 12, bottom: 12),
                        child: Text(
                          AppLocalizations.of(context)!.myGroups,
                          style: const TextStyle(fontSize: 18),
                        ))
                  ],
                ),
                shrinkWrap: true,
                getter: _getGroups,
                card: _groupCardSearchBuilder,
                startAfterQuery: _getTimeFromGroup));
      },
    );
  }

  Future<String?> uploadImage(File imageFile) async {
    var url =
        Uri.parse("https://createimage-146952619766.us-central1.run.app/");
    var request = http.MultipartRequest("POST", url);

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

  Future<void> addImagePressed() async {
    locator<NavBarController>().disable();
    final ImagePicker picker = ImagePicker();
    final XFile? imageLocal =
        await picker.pickImage(source: ImageSource.gallery);

    if (imageLocal != null) {
      File imageFile = File(imageLocal.path);
      String? ascii = await uploadImage(File(imageFile.path));
      if (ascii != null) {
        image = ascii;
        gif = null;
      }
      notifyListeners();
    } else {}
    locator<NavBarController>().enable();
  }

  addGifPressed() async {
    locator<NavBarController>().disable();
    GiphyGif? newGif = await GiphyGet.getGif(
      context: context,
      apiKey: dotenv.env["GIPHY_API_KEY"]!,
      lang: GiphyLanguage.english,
      //randomID: "abcd", // Optional - An ID/proxy for a specific user.
      tabColor: Colors.teal,
      debounceTimeInMilliseconds: 350,
    );
    //only update gif a gif was selected
    if (newGif != null) {
      gif = newGif;
      image = null;
    }
    notifyListeners();
    locator<NavBarController>().enable();
  }

  _goToPage({Group? group}) {
    if (group == null) {
      context.go("/feed", extra: true);
    } else {
      groupEndPoint = null;
      audience = AppLocalizations.of(context)!.public;
      context.go("/groups/sub_group/${group.id}", extra: group);
    }
  }

  postPressed(BuildContext context) {
    final List<String> tags = [
      (groupEndPoint != null) ? groupEndPoint!.id : "public"
    ];

    bodyController.text = bodyController.text.trim();
    titleController.text = titleController.text.trim();
    updateCountsBody(bodyController.text);
    updateCountsTitle(titleController.text);
    if (titleChars > c.maxTitleChars) {
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar, context: context);
    } else if (newLines > c.maxPostLines) {
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyLine, context: context);
    } else if (bodyChars > c.maxPostChars) {
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar, context: context);
    } else if (titleController.text == "" &&
        bodyController.text == "" &&
        gif == null &&
        image == null) {
      titleFocus.requestFocus();
      showSnackBar(
          text: AppLocalizations.of(context)!.emptyFieldError,
          context: context);
    } else {
      Map<String, dynamic> post = {};
      post["tags"] = tags;
      if (titleController.text != '') {
        post["title"] = titleController.text;
      }
      if (bodyController.text != '') {
        post["body"] = bodyController.text;
      }
      if (gif != null) {
        post["gifUrl"] = gif!.images!.fixedWidth.url;
        post["gifSource"] = gif!.url;
      }
      if (image != null) {
        post["image"] = image;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(AppLocalizations.of(context)!.confirmation),
            content: SingleChildScrollView(
              child: PostCard(
                  post: Post(
                      tags: tags,
                      gifSource: post["gifSource"],
                      gifURL: post["gifUrl"],
                      postId: "postId",
                      time: "", //DateTime.now().toUtc().toIso8601String(),
                      title: Post.parseText(post["title"]),
                      author: AppUser.fromCurrent(locator<CurrentUser>()),
                      body: Post.parseText(post["body"]),
                      image: post["image"],
                      likes: 0,
                      dislikes: 0),
                  isPreview: true),
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
                  titleController.text = "";
                  bodyController.text = "";
                  gif = null;
                  image = null;
                  context.pop();

                  final postID =
                      await locator<PostsHandling>().createPost(post);
                  if (tags.contains("public")) {
                    locator<FeedPostCache>().addPost(
                      0,
                      Post(
                        tags: tags,
                        gifSource: post["gifSource"],
                        gifURL: post["gifUrl"],
                        postId: postID,
                        time: DateTime.now().toUtc().toIso8601String(),
                        image: post["image"],
                        title: Post.parseText(post["title"]),
                        author: AppUser.fromCurrent(locator<CurrentUser>()),
                        body: Post.parseText(post["body"]),
                        likes: 0,
                        dislikes: 0,
                      ),
                    );

                    _goToPage();
                  } else {
                    _goToPage(group: groupEndPoint);
                    //refine cases later for more complicated tag system
                  }

                  notifyListeners();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void checkAtSymbol(String text) {
    searchController.text = text;
    bool wasAtSymbolTyped = isAtSymbolTyped;
    int start = text.lastIndexOf('@');
    if (start != -1 && start < text.length - 1) {
      int end = text.indexOf(' ', start);
      if (end == -1) {
        // No space found after '@'
        isAtSymbolTyped = true;
        onSearchTextChanged(text.substring(start + 1));
      } else if (text.substring(end).contains('@')) {
        // Another '@' found after space
        isAtSymbolTyped = true;
        onSearchTextChanged(text.substring(start + 1, end));
      } else {
        // Space found after '@' and no other '@' found
        isAtSymbolTyped = false;
      }
    } else {
      isAtSymbolTyped = false;
    }
    //if it changed
    if (wasAtSymbolTyped != isAtSymbolTyped) {
      if (!isAtSymbolTyped) {
        // copy back to the original controller
        if (titleFocus.hasFocus) {
          titleController.text = searchController.text;
        } else if (bodyFocus.hasFocus) {
          bodyController.text = searchController.text;
        }
      }
      notifyListeners();
    }
  }

  void updateTextField(
      String username, TextEditingController controller, FocusNode focus) {
    if (focus.hasFocus) {
      String currentText = controller.text;
      int atSymbolIndex = currentText.lastIndexOf('@');
      if (atSymbolIndex != -1) {
        String newText =
            '${currentText.substring(0, atSymbolIndex)}@$username ';
        controller.text = newText;
        controller.selection =
            TextSelection.fromPosition(TextPosition(offset: newText.length));
      }
      isAtSymbolTyped = false;
      notifyListeners();
    }
  }

  void onSearchTextChanged(String s) async {
    if (s == '') {
      hits = [];

      isLoading = false;
      notifyListeners();
    } else {
      isLoading = true;
      notifyListeners();
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: c.searchPageDebounce),
      () async {
        if (s != '') {
          hits = await SearchModel().hitsQuery(s);
          isLoading = false;
          notifyListeners();
        }
      },
    );
  }
}
