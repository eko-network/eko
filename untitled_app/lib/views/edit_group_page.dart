import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/controllers/edit_group_page_controller.dart';
import 'package:untitled_app/controllers/group_members_controller.dart';
import 'package:untitled_app/custom_widgets/selected_user_groups.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/group_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/users.dart';
import '../custom_widgets/pagination.dart';
import '../custom_widgets/searched_user_card.dart';
import '../utilities/constants.dart' as c;

class EditGroupPage extends StatelessWidget {
  Group group;
  EditGroupPage({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          EditGroupPageController(context: context, group: group),
      builder: (context, child) {
        return PopScope(
            canPop: false,
            onPopInvoked: (didPop) =>
                Provider.of<EditGroupPageController>(context, listen: false)
                    .goBack(didPop: didPop),
            child: PageView(
              physics:
                  Provider.of<EditGroupPageController>(context, listen: true)
                          .canSwipe
                      ? null
                      : const NeverScrollableScrollPhysics(),
              controller:
                  Provider.of<EditGroupPageController>(context, listen: false)
                      .pageController,
              children: const [_GroupSettings(), _AddPeople()],
            ));
      },
    );
  }
}

class _GroupSettings extends StatelessWidget {
  const _GroupSettings();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    if (Provider.of<EditGroupPageController>(context, listen: true)
        .membersList
        .isEmpty) {
      return const Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: height * 0.02, right: height * 0.02),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    (Provider.of<EditGroupPageController>(context,
                                    listen: false)
                                .group
                                .icon !=
                            '')
                        ? SizedBox(
                            width: width * 0.4,
                            height: width * 0.4,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                Provider.of<EditGroupPageController>(context,
                                        listen: false)
                                    .group
                                    .icon,
                                style: TextStyle(fontSize: width * 0.15),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                            width: width * 0.3,
                            height: width * 0.3,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                Provider.of<EditGroupPageController>(context,
                                        listen: false)
                                    .group
                                    .name[0],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: width * 0.15,
                                ),
                              ),
                            ),
                          ),
                    //FIXME: how can i get there to be less padding between the emoji and title
                    Text(
                      Provider.of<EditGroupPageController>(context,
                              listen: false)
                          .group
                          .name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add_outlined),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: () {
                        Provider.of<EditGroupPageController>(context,
                                listen: false)
                            .initializeSearch();
                        Provider.of<EditGroupPageController>(context,
                                listen: false)
                            .goForward();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: () {
                        // TODO
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app_rounded),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: () {
                        Provider.of<EditGroupPageController>(context,
                                listen: false)
                            .leaveGroup();
                      },
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return UserCard(
                      user: Provider.of<EditGroupPageController>(context,
                              listen: true)
                          .membersList[index],
                    );
                  },
                  childCount: Provider.of<EditGroupPageController>(context,
                          listen: true)
                      .membersList
                      .length,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _AddPeople extends StatelessWidget {
  const _AddPeople();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onPanDown: (details) =>
          Provider.of<EditGroupPageController>(context, listen: false)
              .hideKeyboard(),
      onTap: () => Provider.of<EditGroupPageController>(context, listen: false)
          .hideKeyboard(),
      child: PaginationPage(
        header: Provider.of<EditGroupPageController>(context, listen: true)
                .selectedPeople
                .isEmpty
            ? SizedBox(height: height * 0.05)
            : null,
        getter:
            Provider.of<EditGroupPageController>(context, listen: true).getter,
        card: Provider.of<EditGroupPageController>(context, listen: false)
            .groupSearchPageBuilder,
        startAfterQuery:
            Provider.of<EditGroupPageController>(context, listen: false)
                .startAfterQuery,
        externalData:
            Provider.of<EditGroupPageController>(context, listen: true)
                .searchedListData,
        appbar: SliverAppBar(
          toolbarHeight: height * 0.1,
          floating: true,
          pinned: false,
          scrolledUnderElevation: 0.0,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottom: PreferredSize(
            //FIXME this may be arbitrary
            preferredSize: Size.fromHeight(height *
                (Provider.of<EditGroupPageController>(context, listen: true)
                        .selectedPeople
                        .isNotEmpty
                    ? 0.1
                    : 0.05)),
            child: Column(
              children: [
                TextField(
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
                  onChanged: (s) => Provider.of<EditGroupPageController>(
                          context,
                          listen: false)
                      .onSearchTextChanged(s),
                  controller: Provider.of<EditGroupPageController>(context,
                          listen: false)
                      .searchTextController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                ),
                Consumer<EditGroupPageController>(
                  builder: (context, createGroupPageController, _) {
                    return Container(
                      padding: const EdgeInsets.only(top: 5),
                      height:
                          createGroupPageController.selectedPeople.isNotEmpty
                              ? height * 0.05
                              : 0,
                      child: ListView.builder(
                        controller: Provider.of<EditGroupPageController>(
                                context,
                                listen: false)
                            .selectedPeopleScroll,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            createGroupPageController.selectedPeople.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SelectedUser(
                              user: createGroupPageController
                                  .selectedPeople[index],
                              index: index,
                              selected: (index ==
                                  createGroupPageController.selectedToDelete),
                              setter: Provider.of<EditGroupPageController>(
                                      context,
                                      listen: false)
                                  .setSelectedToDelete,
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          leadingWidth: width * 0.4,
          leading: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    Provider.of<EditGroupPageController>(context, listen: false)
                        .goBack(),
                child: Text(AppLocalizations.of(context)!.cancel),
              )),
          actions: [
            if (Provider.of<EditGroupPageController>(context, listen: true)
                .selectedPeople
                .isNotEmpty)
              TextButton(
                onPressed: () =>
                    Provider.of<EditGroupPageController>(context, listen: false)
                        .updateGroupMembers(),
                child: Text(AppLocalizations.of(context)!.save),
              )
          ],
        ),
      ),

      // Column(
      //   children: [
      //     Row(
      //       children: [
      //         TextButton(
      //             onPressed: () => {
      //                   Provider.of<EditGroupPageController>(context,
      //                           listen: false)
      //                       .exitPressed(),
      //                 },
      //             child: Text(AppLocalizations.of(context)!.cancel)),
      //         const Spacer(),
      //         if(Provider.of<EditGroupPageController>(context,
      //                           listen: true).selectedPeople.isNotEmpty)TextButton(
      //           onPressed: () =>
      //               Provider.of<EditGroupPageController>(context, listen: false)
      //                   .updateGroupMembers(),
      //           child: Text(AppLocalizations.of(context)!.save)),

      //       ],
      //     ),
      //     TextField(
      //       cursorColor: Theme.of(context).colorScheme.onBackground,
      //       d
      //         ),
      //         hintText: AppLocalizations.of(context)!.search,
      //         filled: true,
      //         fillColor: Theme.of(context).colorScheme.outlineVariant,
      //         border: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(10.0),
      //           borderSide: BorderSide.none,
      //         ),
      //       ),
      //       onChanged: (s) =>
      //           Provider.of<EditGroupPageController>(context, listen: false)
      //               .onSearchTextChanged(s),
      //       controller:
      //           Provider.of<EditGroupPageController>(context, listen: false)
      //               .searchTextController,
      //       keyboardType: TextInputType.text,
      //       style: const TextStyle(fontSize: 20),
      //     ),
      //     Container(
      //       padding: const EdgeInsets.only(top: 5),
      //       height: Provider.of<EditGroupPageController>(context, listen: true)
      //               .selectedPeople
      //               .isNotEmpty
      //           ? height * 0.05
      //           : 0,
      //       child: ListView.builder(
      //         controller:
      //             Provider.of<EditGroupPageController>(context, listen: true)
      //                 .selectedPeopleScroll,
      //         shrinkWrap: true,
      //         scrollDirection: Axis.horizontal,
      //         itemCount:
      //             Provider.of<EditGroupPageController>(context, listen: true)
      //                 .selectedPeople
      //                 .length,
      //         itemBuilder: (BuildContext context, int index) {
      //           return Padding(
      //             padding: const EdgeInsets.only(right: 10),
      //             child: SelectedUser(
      //               user: Provider.of<EditGroupPageController>(context,
      //                       listen: true)
      //                   .selectedPeople[index],
      //               index: index,
      //               selected: (index ==
      //                   Provider.of<EditGroupPageController>(context,
      //                           listen: true)
      //                       .selectedToDelete),
      //               setter: Provider.of<EditGroupPageController>(context,
      //                       listen: false)
      //                   .setSelectedToDelete,
      //             ),
      //           );
      //         },
      //       ),
      //     ),
      //     Expanded(
      //       child: Provider.of<EditGroupPageController>(context, listen: true)
      //               .isLoading
      //           ? const Center(
      //               child: CircularProgressIndicator(),
      //             )
      //           : Provider.of<EditGroupPageController>(context, listen: true)
      //                   .hits
      //                   .isEmpty
      //               ? Center(
      //                   child: Text(
      //                     AppLocalizations.of(context)!.noResultsFound,
      //                     style: TextStyle(
      //                         fontSize: 18,
      //                         color:
      //                             Theme.of(context).colorScheme.onBackground),
      //                   ),
      //                 )
      //               : ListView.builder(
      //                   //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      //                   itemCount: Provider.of<EditGroupPageController>(context,
      //                           listen: true)
      //                       .hits
      //                       .length,
      //                   itemBuilder: (BuildContext context, int index) {
      //                     return UserCard(
      //                       initialBool: Provider.of<EditGroupPageController>(
      //                               context,
      //                               listen: false)
      //                           .isUserSelected(
      //                               Provider.of<EditGroupPageController>(
      //                                       context,
      //                                       listen: true)
      //                                   .hits[index]),
      //                       adder: Provider.of<EditGroupPageController>(context,
      //                               listen: false)
      //                           .addRemovePersonToList,
      //                       groupSearch: true,
      //                       user: Provider.of<EditGroupPageController>(context,
      //                               listen: true)
      //                           .hits[index],
      //                     );
      //                   },
      //                 ),
      //     ),
      //   ],
      // ),
    );
  }
}
