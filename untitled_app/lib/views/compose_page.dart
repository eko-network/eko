import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../controllers/compose_controller.dart';
import '../custom_widgets/searched_user_card.dart';
import '../utilities/constants.dart' as c;
import '../models/group_handler.dart' show Group;
import '../custom_widgets/profile_avatar.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class ComposePage extends StatefulWidget {
  const ComposePage({super.key, required this.group});
  final Group? group;
  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  final _key = GlobalKey<ExpandableFabState>();
  bool _isLoadingImage = false;

  Widget _buildPollWidget(BuildContext context, double height, double width) {
    final controller = Provider.of<ComposeController>(context, listen: true);

    return Container(
      width: width * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            controller.pollOptions.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText:
                            "${AppLocalizations.of(context)!.option} ${index + 1}",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        errorText: controller.pollOptions[index].length > 50
                            ? AppLocalizations.of(context)!.tooManyChar
                            : null,
                      ),
                      maxLength: 50, // Set maximum lengths
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null, // Hide default counter
                      onChanged: (value) {
                        // Only update if within limits
                        if (value.length <= 50) {
                          controller.updatePollOption(index, value);
                        }
                      },
                    ),
                  ),
                  if (controller.pollOptions.length > 2 &&
                      index == controller.pollOptions.length - 1)
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () => controller.removePollOption(index),
                    ),
                ],
              ),
            ),
          ),
          if (controller.pollOptions.length < 4)
            TextButton.icon(
              onPressed: () => controller.addPollOption(),
              icon: Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addOption),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audiance = AppLocalizations.of(context)!.public;
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return ChangeNotifierProvider(
      create: (context) => ComposeController(
        context: context,
        audience: (widget.group != null) ? widget.group!.name : audiance,
        // groupEndPoint: group,
      ),
      builder: (context, child) {
        Provider.of<ComposeController>(context, listen: false)
            .initGroup(widget.group);
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) =>
              Provider.of<ComposeController>(context, listen: false)
                  .onWillPop(),
          child: GestureDetector(
            onTap: () => Provider.of<ComposeController>(context, listen: false)
                .hideKeyboard(),
            child: Scaffold(
              //
              floatingActionButtonLocation: ExpandableFab.location,
              floatingActionButton: ExpandableFab(
                key: _key,
                openButtonBuilder: RotateFloatingActionButtonBuilder(
                    child: const Icon(Icons.add_photo_alternate_outlined)),
                type: ExpandableFabType.up,
                distance: 70.0,
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () {
                      final state = _key.currentState;
                      if (state != null) {
                        state.toggle();
                      }
                      Provider.of<ComposeController>(context, listen: false)
                          .addPollPressed();
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
                        setState(() {
                          _isLoadingImage = true;
                        });
                        await Provider.of<ComposeController>(context,
                                listen: false)
                            .addImagePressed();
                        setState(() {
                          _isLoadingImage = false;
                        });
                      }),
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () {
                      final state = _key.currentState;
                      if (state != null) {
                        state.toggle();
                      }
                      Provider.of<ComposeController>(context, listen: false)
                          .addGifPressed();
                    },
                    child: const Icon(Icons.gif_box_rounded),
                  ),
                ],
              ),
              appBar: AppBar(
                surfaceTintColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Provider.of<ComposeController>(context, listen: false)
                              .clearPressed(),
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface),
                      child: Text(
                        AppLocalizations.of(context)!.clear,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Provider.of<ComposeController>(context, listen: false)
                              .postPressed(context),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                index: !Provider.of<ComposeController>(context, listen: false)
                        .isAtSymbolTyped
                    ? 0
                    : 1,
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
                            ProfileAvatar(
                                url: locator<CurrentUser>().profilePicture,
                                size: width * 0.115),
                            const SizedBox(width: 9),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.outline,
                                side: BorderSide(
                                  width: 0.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              onPressed: () => Provider.of<ComposeController>(
                                      context,
                                      listen: false)
                                  .audianceButtonPressed(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      Provider.of<ComposeController>(context,
                                              listen: true)
                                          .audience,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                                  Icon(Icons.expand_more_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: height * 0.5),
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            focusNode: Provider.of<ComposeController>(context,
                                    listen: false)
                                .titleFocus,
                            onChanged: (s) {
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .updateCountsTitle(s);
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .checkAtSymbol(s);
                            },
                            controller: Provider.of<ComposeController>(context,
                                    listen: false)
                                .titleController,
                            maxLines: null,
                            cursorColor:
                                Theme.of(context).colorScheme.onSurface,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Consumer<ComposeController>(
                          builder: (context, composeController, _) =>
                              (composeController.showCount0 &&
                                      composeController.titleChars != 0)
                                  ? Text(
                                      "${composeController.titleChars}/${c.maxTitleChars} ${AppLocalizations.of(context)!.characters}")
                                  : Container(),
                        ),
                        if (Provider.of<ComposeController>(context,
                                        listen: true)
                                    .gif !=
                                null ||
                            Provider.of<ComposeController>(context,
                                        listen: true)
                                    .image !=
                                null ||
                            Provider.of<ComposeController>(context,
                                    listen: true)
                                .isPoll ||
                            _isLoadingImage)
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
                                                child:
                                                    CircularProgressIndicator()))
                                        : Provider.of<ComposeController>(
                                                    context,
                                                    listen: true)
                                                .isPoll
                                            ? _buildPollWidget(
                                                context, height, width)
                                            : Provider.of<ComposeController>(
                                                            context,
                                                            listen: true)
                                                        .image !=
                                                    null
                                                ? ImageWidget(
                                                    text: Provider.of<
                                                                ComposeController>(
                                                            context,
                                                            listen: true)
                                                        .image!)
                                                : Image.network(
                                                    Provider.of<ComposeController>(
                                                            context,
                                                            listen: true)
                                                        .gif!
                                                        .images!
                                                        .fixedWidth
                                                        .url,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return Container(
                                                        alignment:
                                                            Alignment.center,
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
                                  iconSize: Provider.of<ComposeController>(
                                                      context,
                                                      listen: true)
                                                  .image !=
                                              null &&
                                          _isLoadingImage == false
                                      ? 150
                                      : 30,
                                  onPressed: () =>
                                      Provider.of<ComposeController>(context,
                                              listen: false)
                                          .removeMediaPressed(),
                                  icon: DecoratedBox(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface),
                                    child: Icon(
                                      Icons.cancel,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: height * 0.5),
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            focusNode: Provider.of<ComposeController>(context,
                                    listen: false)
                                .bodyFocus,
                            onChanged: (s) {
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .updateCountsBody(s);
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .checkAtSymbol(s);
                            },
                            controller: Provider.of<ComposeController>(context,
                                    listen: false)
                                .bodyController,
                            maxLines: null,
                            cursorColor:
                                Theme.of(context).colorScheme.onSurface,
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
                        Consumer<ComposeController>(
                          builder: (context, composeController, _) =>
                              (composeController.showCount1 &&
                                      composeController.bodyChars != 0)
                                  ? Row(
                                      children: [
                                        Text(
                                            "${composeController.bodyChars}/${c.maxPostChars} ${AppLocalizations.of(context)!.characters}"),
                                        const Spacer(),
                                        if (composeController.newLines != 0)
                                          Text(
                                              "${composeController.newLines}/${c.maxPostLines} ${AppLocalizations.of(context)!.newLines}"),
                                      ],
                                    )
                                  : Container(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: Provider.of<ComposeController>(context,
                                  listen: false)
                              .searchFocus,
                          controller: Provider.of<ComposeController>(context,
                                  listen: false)
                              .searchController,
                          onChanged: (s) {
                            Provider.of<ComposeController>(context,
                                    listen: false)
                                .checkAtSymbol(s);
                          },
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                          cursorColor: Theme.of(context).colorScheme.onSurface,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(height * 0.01),
                            hintText: AppLocalizations.of(context)!.addText,
                            hintStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            border: InputBorder.none,
                          ),
                        ),
                        Expanded(
                          child: Provider.of<ComposeController>(context,
                                      listen: true)
                                  .isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Provider.of<ComposeController>(context,
                                          listen: true)
                                      .hits
                                      .isEmpty
                                  ? Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .noResultsFound,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: Provider.of<ComposeController>(
                                              context,
                                              listen: true)
                                          .hits
                                          .length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return UserCard(
                                            tagSearch: true,
                                            onCardTap: (username) {
                                              Provider.of<ComposeController>(
                                                      context,
                                                      listen: false)
                                                  .updateTextField(
                                                      username,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .titleController,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .titleFocus);
                                              Provider.of<ComposeController>(
                                                      context,
                                                      listen: false)
                                                  .updateTextField(
                                                      username,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .bodyController,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .bodyFocus);
                                            },
                                            user:
                                                Provider.of<ComposeController>(
                                                        context,
                                                        listen: true)
                                                    .hits[index]);
                                      },
                                    ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
