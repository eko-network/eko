import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/custom_widgets/selected_user_groups.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../controllers/create_group_page_controller.dart';
import '../custom_widgets/edit_profile_text_field.dart';
import '../utilities/constants.dart' as c;

import '../custom_widgets/pagination.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateGroupPageController(context: context),
      builder: (context, child) {
        return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) =>
              Provider.of<CreateGroupPageController>(context, listen: false)
                .exitPressed(),
            child: PageView(
              physics:
                  Provider.of<CreateGroupPageController>(context, listen: true)
                          .canSwipe
                      ? null
                      : const NeverScrollableScrollPhysics(),
              controller:
                  Provider.of<CreateGroupPageController>(context, listen: false)
                      .pageController,
              children: const [_GetInfo(), _AddPeople()],
            ));
      },
    );
  }
}

class _GetInfo extends StatelessWidget {
  const _GetInfo();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () => Provider.of<CreateGroupPageController>(
                          context,
                          listen: false)
                      .exitPressed(),
                  child: Text(AppLocalizations.of(context)!.cancel)),
              const Spacer(),
              TextButton(
                  onPressed: () => Provider.of<CreateGroupPageController>(
                          context,
                          listen: false)
                      .goForward(),
                  child: Text(AppLocalizations.of(context)!.next))
            ],
          ),
          IconButton(
            //iconSize: width * 0.2,
            onPressed: () =>
                Provider.of<CreateGroupPageController>(context, listen: false)
                    .pickEmoji(),
            icon: (Provider.of<CreateGroupPageController>(context, listen: true)
                        .icon ==
                    "")
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
                              Provider.of<CreateGroupPageController>(context,
                                      listen: true)
                                  .icon,
                              //style: TextStyle(fontSize: width * 0.25),
                            ),
                          ),
                        ),
                        IconButton(
                          //iconSize: width * 0.1,
                          onPressed: () =>
                              Provider.of<CreateGroupPageController>(context,
                                      listen: false)
                                  .clearIcon(),
                          icon: DecoratedBox(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Theme.of(context).colorScheme.outlineVariant),
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
              onChanged: (s) =>
                  Provider.of<CreateGroupPageController>(context, listen: false)
                      .updateCanSwipe(),
              focus:
                  Provider.of<CreateGroupPageController>(context, listen: false)
                      .nameFocus,
              maxLength: c.maxGroupName,
              width: width * 0.9,
              label: AppLocalizations.of(context)!.name,
              controller:
                  Provider.of<CreateGroupPageController>(context, listen: false)
                      .nameController),
          ProfileInputFeild(
              maxLength: c.maxGroupDesc,
              width: width * 0.9,
              label: AppLocalizations.of(context)!.description,
              controller:
                  Provider.of<CreateGroupPageController>(context, listen: false)
                      .descriptionController),
        ],
      ),
    );
  }
}

class _AddPeople extends StatelessWidget {
  const _AddPeople();

  @override
  Widget build(BuildContext context) {
    //print(Provider.of<CreateGroupPageController>(context, listen: true).searchedList);
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return GestureDetector( 
      onPanDown: (details) =>
          Provider.of<CreateGroupPageController>(context, listen: false)
              .hideKeyboard(),
      onTap: () =>
          Provider.of<CreateGroupPageController>(context, listen: false)
              .hideKeyboard(),
      child: PaginationPage(
        header: Provider.of<CreateGroupPageController>(context,
                          listen: true).selectedPeople.isEmpty ? SizedBox(height: height * 0.05):null,
        getter: Provider.of<CreateGroupPageController>(context, listen: true)
            .getter,
        card: Provider.of<CreateGroupPageController>(context, listen: false)
            .groupSearchPageBuilder,
        startAfterQuery:
            Provider.of<CreateGroupPageController>(context, listen: false)
                .startAfterQuery,
        externalData:
            Provider.of<CreateGroupPageController>(context, listen: true)
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
                (Provider.of<CreateGroupPageController>(context, listen: true)
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
                      child:  Image.asset((Theme.of(context).brightness == Brightness.dark)? 'images/algolia_logo_white.png':'images/algolia_logo_blue.png',
                          width: width * 0.05, height: width * 0.05),
                    ),
                    hintText: AppLocalizations.of(context)!.search,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.outlineVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (s) => Provider.of<CreateGroupPageController>(
                          context,
                          listen: false)
                      .onSearchTextChanged(s),
                  controller: Provider.of<CreateGroupPageController>(context,
                          listen: false)
                      .searchTextController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                ),
                Consumer<CreateGroupPageController>(
                  builder: (context, createGroupPageController, _) {
                    return Container(
                      padding: const EdgeInsets.only(top: 5),
                      height:
                          createGroupPageController.selectedPeople.isNotEmpty
                              ? height * 0.05
                              : 0,
                      child: ListView.builder(
                        controller: Provider.of<CreateGroupPageController>(
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
                              setter: Provider.of<CreateGroupPageController>(
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
                onPressed: () => Provider.of<CreateGroupPageController>(context,
                        listen: false)
                    .goBack(),
                child: Text(AppLocalizations.of(context)!.goBack),
              )),
          actions: [
            TextButton(
              onPressed: () =>
                  Provider.of<CreateGroupPageController>(context, listen: false)
                      .createGroup(),
              child: Text(
                  Provider.of<CreateGroupPageController>(context, listen: true)
                          .selectedPeople
                          .isEmpty
                      ? AppLocalizations.of(context)!.skip
                      : AppLocalizations.of(context)!.done),
            )
          ],
        ),
        
      ),
    );
  }
}
