import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/search.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/search_model.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/group_list_provider.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/types/group.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import 'package:untitled_app/widgets/user_card.dart';
import 'package:untitled_app/widgets/user_search_bar.dart';
import '../custom_widgets/edit_profile_text_field.dart';
import '../utilities/constants.dart' as c;
import '../widgets/group_selected_user.dart';

void _showConfirmExit(BuildContext context) {
  showMyDialog(
      AppLocalizations.of(context)!.exitCreateGroupTitle,
      AppLocalizations.of(context)!.exitCreateGroupBody,
      [AppLocalizations.of(context)!.exit, AppLocalizations.of(context)!.stay],
      [
        () {
          context.pop();
          context.pop();
        },
        context.pop
      ],
      context);
}

class ListenableSet<T> extends ChangeNotifier {
  final Set<T> _set;

  Set<T> get set => _set;
  ListenableSet([List<T> list = const []]) : _set = Set<T>.from(list);

  bool add(T item) {
    final res = _set.add(item);
    notifyListeners();
    return res;
  }

  bool remove(T item) {
    final res = _set.remove(item);
    notifyListeners();
    return res;
  }
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
  final PageController pageController = PageController();
  ListenableSet<String> selectedPeople = ListenableSet<String>();
  bool isLoading = false;
  int? selectedToDelete;
  final searchModel = SearchModel();
  String query = '';
  // Cache searchedListData = Cache(items: [], end: false);
  bool creatingGroup = false;
  int index = 0;

  void setGroupIcon(String newIcon) {
    setState(() {
      groupIcon = newIcon;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    descriptionController.dispose();
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                TextButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (index == 0) {
                        if (nameController.text.trim().length <
                            c.minGroupName) {
                          await showMyDialog(
                              'Name too short',
                              'Name must be at least ${c.minGroupName} characters.',
                              [AppLocalizations.of(context)!.ok],
                              [context.pop],
                              context);
                          nameFocus.requestFocus();
                          return;
                        }
                        setState(() {
                          index = 1;
                        });
                      } else {
                        isLoading = true;
                        showDialog(
                          barrierDismissible: false,
                          barrierColor: Theme.of(context).colorScheme.surface,
                          context: context,
                          builder: (context) => PopScope(
                              canPop: false,
                              child: Center(
                                child: LoadingSpinner(),
                              )),
                        );
                        final now = DateTime.now().toUtc().toIso8601String();
                        final group = GroupModel(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            lastActivity: now,
                            createdOn: now,
                            icon: groupIcon,
                            members: List<String>.from([
                              ref.read(currentUserProvider).user.uid,
                              ...selectedPeople.set
                            ]),
                            notSeen: []);
                        final doc = await FirebaseFirestore.instance
                            .collection('groups')
                            .add(group.toJson());
                        final newGroup = group.copyWith(id: doc.id);
                        ref
                            .read(groupListProvider.notifier)
                            .insertAtIndex(0, newGroup);
                        if (context.mounted) {
                          context.pop();
                          context.pop();
                        }
                        isLoading = false;
                      }
                    },
                    child: Text(index == 0
                        ? AppLocalizations.of(context)!.next
                        : AppLocalizations.of(context)!.create)),
              ],
            ),
          ),
          body: Center(
            child: IndexedStack(
              index: index,
              children: <Widget>[
                GetInfo(
                  nameController: nameController,
                  nameFocus: nameFocus,
                  descriptionController: descriptionController,
                  groupIcon: groupIcon,
                  setGroupIcon: setGroupIcon,
                ),
                AddPeople(
                  selectedPeople: selectedPeople,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GetInfo extends ConsumerWidget {
  final TextEditingController nameController;
  final FocusNode nameFocus;
  final TextEditingController descriptionController;
  final String groupIcon;
  final void Function(String) setGroupIcon;

  const GetInfo(
      {super.key,
      required this.nameFocus,
      required this.nameController,
      required this.descriptionController,
      required this.groupIcon,
      required this.setGroupIcon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: width * 0.05),
      child: ListView(
        children: [
          IconButton(
            onPressed: () async {
              ref.read(navBarProvider.notifier).disable();
              final emoji = await context.pushNamed<String?>('pick_emoji');
              if (emoji != null && emoji.isNotEmpty) {
                setGroupIcon(emoji);
              }
              ref.read(navBarProvider.notifier).enable();
            },
            icon: groupIcon.isEmpty
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
                              groupIcon,
                              //style: TextStyle(fontSize: width * 0.25),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setGroupIcon(''),
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
          ProfileInputField(
              focus: nameFocus,
              maxLength: c.maxGroupName,
              label: AppLocalizations.of(context)!.name,
              controller: nameController),
          ProfileInputField(
              maxLength: c.maxGroupDesc,
              label: AppLocalizations.of(context)!.description,
              controller: descriptionController),
        ],
      ),
    );
  }
}

class AddPeople extends ConsumerStatefulWidget {
  final ListenableSet<String> selectedPeople;

  const AddPeople({super.key, required this.selectedPeople});

  @override
  ConsumerState<AddPeople> createState() => _AddPeopleState();
}

class _AddPeopleState extends ConsumerState<AddPeople> {
  Timer? debounce;
  List<MapEntry<String, int>> data = [];
  bool isEnd = false;
  String selectedToDelete = '';
  final searchTextController = TextEditingController();
  final scrollController = ScrollController();
  String lastVal = '';

  void inputListener() {
    if (searchTextController.text == lastVal) return;
    lastVal = searchTextController.text;
    setState(() {
      data.clear();
      isEnd = false;
    });
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce =
        Timer(const Duration(milliseconds: c.searchPageDebounce), () async {
      final res = await SearchInterface.getter(
          [], ref, searchTextController.text,
          excludeCurrent: true);
      setState(() {
        data = res.$1;
        isEnd = res.$2;
      });
    });
  }

  @override
  void initState() {
    searchTextController.addListener(inputListener);
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.removeListener(inputListener);
    searchTextController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: GestureDetector(
        onPanDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: Column(
          children: [
            UserSearchBar(controller: searchTextController),
            ListenableBuilder(
                listenable: widget.selectedPeople,
                builder: (context, _) {
                  final list = widget.selectedPeople.set.toList();
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SizedBox(
                        height: list.isNotEmpty ? 40 : 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SelectedUser(
                                uid: list[index],
                                selected: (list[index] == selectedToDelete),
                                onPressed: (uid) {
                                  if (uid == selectedToDelete) {
                                    widget.selectedPeople.remove(uid);
                                  } else {
                                    setState(() {
                                      selectedToDelete = uid;
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ));
                }),
            Expanded(
              child: InfiniteScrollyShell<String>(
                controller: scrollController,
                onRefresh: () async {
                  if (debounce?.isActive ?? false) debounce!.cancel();
                  final res = await SearchInterface.getter(
                      [], ref, searchTextController.text,
                      excludeCurrent: true);
                  setState(() {
                    data = res.$1;
                    isEnd = res.$2;
                  });
                },
                list: data.map((item) => item.key).toList(),
                isEnd: isEnd,
                getter: () async {
                  final res = await SearchInterface.getter(
                      data, ref, searchTextController.text,
                      excludeCurrent: true);
                  setState(() {
                    data.addAll(res.$1);
                    isEnd = res.$2;
                  });
                },
                initialLoadingWidget: UserLoader(
                  length: 12,
                ),
                widget: (uid) => UserCard(
                  uid: uid,
                  onCardPressed: (user) {
                    if (widget.selectedPeople.set.contains(user.uid)) {
                      widget.selectedPeople.remove(user.uid);
                    } else {
                      widget.selectedPeople.add(user.uid);
                    }
                  },
                  actionWidget: (user) => ListenableBuilder(
                      listenable: widget.selectedPeople,
                      builder: (context, _) =>
                          widget.selectedPeople.set.contains(user.uid)
                              ? Icon(Icons.check_circle)
                              : Icon(Icons.circle_outlined)),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
