import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/custom_widgets/selected_user_groups.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/search.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/search_model.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import 'package:untitled_app/widgets/user_card.dart';
import '../controllers/create_group_page_controller.dart';
import '../custom_widgets/edit_profile_text_field.dart';
import '../utilities/constants.dart' as c;

Widget selectedUserCardBuilder(String uid) {
  // return SelectedUser(
  //   user: createGroupPageController.selectedPeople[index],
  //   index: index,
  //   selected: (index == createGroupPageController.selectedToDelete),
  //   setter: prov.Provider.of<CreateGroupPageController>(context, listen: false)
  //       .setSelectedToDelete,
  // );
  return SizedBox();
}

void _showConfirmExit(BuildContext context) {
  showMyDialog(
      AppLocalizations.of(context)!.exitCreateGroupTitle,
      AppLocalizations.of(context)!.exitCreateGroupBody,
      [
        AppLocalizations.of(context)!.goBack,
        AppLocalizations.of(context)!.stay
      ],
      [
        () {
          context.pop();
        },
        context.pop
      ],
      context);
}

class CreateGroup extends ConsumerStatefulWidget {
  const CreateGroup({super.key});

  @override
  ConsumerState<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends ConsumerState<CreateGroup> {
  String groupIcon = '';
  final slectedPeopleScroll = ScrollController();
  final nameController = TextEditingController();
  final nameFocus = FocusNode();
  final descriptionController = TextEditingController();
  final searchTextController = TextEditingController();
  final PageController pageController = PageController();
  final selectedPeopleScroll = ScrollController();
  List<UserModel> selectedPeople = [];
  List<UserModel> hits = [];
  bool isLoading = false;
  bool showEmojiKeyboard = false;
  int? selectedToDelete;
  bool canSwipe = false;
  final searchModel = SearchModel();
  String query = '';
  // Cache searchedListData = Cache(items: [], end: false);
  bool creatingGroup = false;
  int index = 0;

  @override
  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    descriptionController.dispose();
    searchTextController.dispose();
    selectedPeopleScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _showConfirmExit(context);
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    if (index == 1) {
                      setState(() {
                        index = 0;
                      });
                      return;
                    }
                    _showConfirmExit(context);
                  },
                  icon: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (index == 1) {
                            setState(() {
                              index = 0;
                            });
                            return;
                          }
                          _showConfirmExit(context);
                        },
                        child: index == 0
                            ? Text(AppLocalizations.of(context)!.cancel)
                            : Text(AppLocalizations.of(context)!.previous),
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              index += 1;
                            });
                          },
                          child: Text(AppLocalizations.of(context)!.next)),
                    ],
                  ),
                )),
          ),
          body: Center(
            child: IndexedStack(
              index: index,
              children: <Widget>[
                GetInfo(
                  nameController: nameController,
                  nameFocus: nameFocus,
                  descriptionController: descriptionController,
                  setPage: (target) => setState(() {
                    index = target;
                  }),
                  groupIcon: '',
                ),
                AddPeople(
                  searchTextController: searchTextController,
                  selectedPeople: selectedPeople,
                  selectedPeopleScroll: selectedPeopleScroll,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class CreateGroupPage extends StatelessWidget {
//   const CreateGroupPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return prov.ChangeNotifierProvider(
//       create: (context) => CreateGroupPageController(context: context),
//       builder: (context, child) {
//         return PopScope(
//             canPop: false,
//             onPopInvokedWithResult: (didPop, result) =>
//                 prov.Provider.of<CreateGroupPageController>(context,
//                         listen: false)
//                     .exitPressed(),
//             child: PageView(
//               physics: prov.Provider.of<CreateGroupPageController>(context,
//                           listen: true)
//                       .canSwipe
//                   ? null
//                   : const NeverScrollableScrollPhysics(),
//               controller: prov.Provider.of<CreateGroupPageController>(context,
//                       listen: false)
//                   .pageController,
//               children: const [_GetInfo(), _AddPeople()],
//             ));
//       },
//     );
//   }
// }

class GetInfo extends StatefulWidget {
  final TextEditingController nameController;
  // TODO do something with focus
  final FocusNode nameFocus;
  final TextEditingController descriptionController;
  final String groupIcon;
  final void Function(int) setPage;

  const GetInfo(
      {super.key,
      required this.setPage,
      required this.nameFocus,
      required this.nameController,
      required this.descriptionController,
      required this.groupIcon});

  @override
  State<GetInfo> createState() => _GetInfoState();
}

class _GetInfoState extends State<GetInfo> {
  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: width * 0.05),
      child: ListView(
        children: [
          IconButton(
            onPressed: () =>
                context.pushNamed('pick_emoji', extra: widget.groupIcon),
            icon: (widget.groupIcon == '')
                ? Icon(Icons.add_reaction_outlined, size: width * 0.3)
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        SizedBox(
                          width: width * 0.3,
                          height: width * 0.3,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              widget.groupIcon,
                              //style: TextStyle(fontSize: width * 0.25),
                            ),
                          ),
                        ),
                        IconButton(
                          //iconSize: width * 0.1,
                          onPressed: () => setState(() {
                            // widget.groupIcon = '';
                          }),
                          icon: DecoratedBox(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                            child: Icon(
                              Icons.cancel,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          ProfileInputFeild(
              focus: widget.nameFocus,
              maxLength: c.maxGroupName,
              label: AppLocalizations.of(context)!.name,
              controller: widget.nameController),
          ProfileInputFeild(
              maxLength: c.maxGroupDesc,
              label: AppLocalizations.of(context)!.description,
              controller: widget.descriptionController),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.onSurface,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(height * 0.01),
          prefixIcon: Padding(
            padding: EdgeInsets.all(width * 0.035),
            child: Image.asset(
                (Theme.of(context).brightness == Brightness.dark)
                    ? 'images/algolia_logo_white.png'
                    : 'images/algolia_logo_blue.png',
                width: width * 0.05,
                height: width * 0.05),
          ),
          hintText: AppLocalizations.of(context)!.search,
          filled: true,
          fillColor: Theme.of(context).colorScheme.outlineVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        controller: controller,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

class AddPeople extends ConsumerStatefulWidget {
  final TextEditingController searchTextController;
  final List<UserModel> selectedPeople;
  final ScrollController selectedPeopleScroll;

  const AddPeople(
      {super.key,
      required this.searchTextController,
      required this.selectedPeople,
      required this.selectedPeopleScroll});

  @override
  ConsumerState<AddPeople> createState() => _AddPeopleState();
}

class _AddPeopleState extends ConsumerState<AddPeople> {
  Timer? debounce;
  List<MapEntry<String, int>> data = [];
  bool isEnd = false;
  int? selectedToDelete;

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return GestureDetector(
        // onPanDown: (details) =>
        //     prov.Provider.of<CreateGroupPageController>(context, listen: false)
        //         .hideKeyboard(),
        // onTap: () =>
        //     prov.Provider.of<CreateGroupPageController>(context, listen: false)
        //         .hideKeyboard(),
        child: GestureDetector(
      onPanDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 5),
            height: widget.selectedPeople.isNotEmpty ? height * 0.05 : 0,
            child: ListView.builder(
              controller: widget.selectedPeopleScroll,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.selectedPeople.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SelectedUser(
                    user: widget.selectedPeople[index],
                    index: index,
                    selected: (index == selectedToDelete),
                    setter: (index) {
                      setState(() {
                        if (index == selectedToDelete) {
                          widget.selectedPeople.removeWhere((element) =>
                              element.uid == widget.selectedPeople[index].uid);
                          selectedToDelete = null;
                        } else {
                          selectedToDelete = index;
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: InfiniteScrollyShell<String>(
              onRefresh: () async {
                if (debounce?.isActive ?? false) debounce!.cancel();
                final res = await SearchInterface.getter(
                    [], ref, widget.searchTextController.text);
                setState(() {
                  data = res.$1;
                  isEnd = res.$2;
                });
              },
              list: data.map((item) => item.key).toList(),
              isEnd: isEnd,
              getter: () async {
                final res = await SearchInterface.getter(
                    data, ref, widget.searchTextController.text);
                setState(() {
                  data.addAll(res.$1);
                  isEnd = res.$2;
                });
              },
              initialLoadingWidget: UserLoader(
                length: 12,
              ),
              widget: selectedUserCardBuilder,
              header: _SearchBar(controller: widget.searchTextController),
            ),
          )
        ],
      )),
    ));

    // PaginationPage(
    //      header:
    //          prov.Provider.of<CreateGroupPageController>(context, listen: true)
    //                  .selectedPeople
    //                  .isEmpty
    //              ? SizedBox(height: height * 0.05)
    //              : null,
    //      getter:
    //          prov.Provider.of<CreateGroupPageController>(context, listen: true)
    //              .getter,
    //      card:
    //          prov.Provider.of<CreateGroupPageController>(context, listen: false)
    //              .groupSearchPageBuilder,
    //      startAfterQuery:
    //          prov.Provider.of<CreateGroupPageController>(context, listen: false)
    //              .startAfterQuery,
    //      externalData:
    //          prov.Provider.of<CreateGroupPageController>(context, listen: true)
    //              .searchedListData,
    //      appbar: SliverAppBar(
    //        toolbarHeight: height * 0.1,
    //        floating: true,
    //        pinned: false,
    //        scrolledUnderElevation: 0.0,
    //        centerTitle: true,
    //        backgroundColor: Theme.of(context).colorScheme.surface,
    //        bottom: PreferredSize(
    //          //FIXME this may be arbitrary
    //          preferredSize: Size.fromHeight(height *
    //              (prov.Provider.of<CreateGroupPageController>(context,
    //                          listen: true)
    //                      .selectedPeople
    //                      .isNotEmpty
    //                  ? 0.1
    //                  : 0.05)),
    //          child: Column(
    //            children: [
    //              TextField(
    //                cursorColor: Theme.of(context).colorScheme.onSurface,
    //                decoration: InputDecoration(
    //                  contentPadding: EdgeInsets.all(height * 0.01),
    //                  prefixIcon: Padding(
    //                    padding: EdgeInsets.all(width * 0.035),
    //                    child: Image.asset(
    //                        (Theme.of(context).brightness == Brightness.dark)
    //                            ? 'images/algolia_logo_white.png'
    //                            : 'images/algolia_logo_blue.png',
    //                        width: width * 0.05,
    //                        height: width * 0.05),
    //                  ),
    //                  hintText: AppLocalizations.of(context)!.search,
    //                  filled: true,
    //                  fillColor: Theme.of(context).colorScheme.outlineVariant,
    //                  border: OutlineInputBorder(
    //                    borderRadius: BorderRadius.circular(10.0),
    //                    borderSide: BorderSide.none,
    //                  ),
    //                ),
    //                onChanged: (s) => prov.Provider.of<CreateGroupPageController>(
    //                        context,
    //                        listen: false)
    //                    .onSearchTextChanged(s),
    //                controller: prov.Provider.of<CreateGroupPageController>(
    //                        context,
    //                        listen: false)
    //                    .searchTextController,
    //                keyboardType: TextInputType.text,
    //                style: const TextStyle(fontSize: 20),
    //              ),
    //              prov.Consumer<CreateGroupPageController>(
    //                builder: (context, createGroupPageController, _) {
    //                  return Container(
    //                    padding: const EdgeInsets.only(top: 5),
    //                    height:
    //                        createGroupPageController.selectedPeople.isNotEmpty
    //                            ? height * 0.05
    //                            : 0,
    //                    child: ListView.builder(
    //                      controller: prov.Provider.of<CreateGroupPageController>(
    //                              context,
    //                              listen: false)
    //                          .selectedPeopleScroll,
    //                      shrinkWrap: true,
    //                      scrollDirection: Axis.horizontal,
    //                      itemCount:
    //                          createGroupPageController.selectedPeople.length,
    //                      itemBuilder: (BuildContext context, int index) {
    //                        return Padding(
    //                          padding: const EdgeInsets.only(right: 10),
    //                          child: SelectedUser(
    //                            user: createGroupPageController
    //                                .selectedPeople[index],
    //                            index: index,
    //                            selected: (index ==
    //                                createGroupPageController.selectedToDelete),
    //                            setter:
    //                                prov.Provider.of<CreateGroupPageController>(
    //                                        context,
    //                                        listen: false)
    //                                    .setSelectedToDelete,
    //                          ),
    //                      );
    //                      },
    //                    ),
    //                  );
    //                },
    //              )
    //            ],
    //          ),
    //        ),
    //        leadingWidth: width * 0.4,
    //        leading: Align(
    //            alignment: Alignment.centerLeft,
    //            child: TextButton(
    //              onPressed: () => prov.Provider.of<CreateGroupPageController>(
    //                      context,
    //                      listen: false)
    //                  .goBack(),
    //              child: Text(AppLocalizations.of(context)!.goBack),
    //            )),
    //        actions: [
    //          TextButton(
    //            onPressed: () => prov.Provider.of<CreateGroupPageController>(
    //                    context,
    //                    listen: false)
    //                .createGroup(),
    //            child: Text(prov.Provider.of<CreateGroupPageController>(context,
    //                        listen: true)
    //                    .selectedPeople
    //                    .isEmpty
    //                ? AppLocalizations.of(context)!.skip
    //                : AppLocalizations.of(context)!.done),
    //          )
    //        ],
    //      ),
    //    ),
    //  );
  }
}
