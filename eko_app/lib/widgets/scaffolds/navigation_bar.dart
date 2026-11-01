import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/common/download_button.dart';
import 'package:eko_app/widgets/scaffolds/app_safe_area.dart';
import 'package:eko_app/providers/nav_bar_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;

const List<IconData> _passiveIconList = [
  Icons.home_outlined,
  CupertinoIcons.paperplane,
  Icons.add,
  Icons.search,
  Icons.person_outline,
];
const List<IconData> _activeIconList = [
  Icons.home,
  CupertinoIcons.paperplane_fill,
  Icons.add,
  Icons.search,
  Icons.person,
];

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void goBranch(int index) {
    if (index == navigationShell.currentIndex) {
      return;
    }
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    const navRailWidth = 80.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hasRoomForRail = screenWidth >= c.indealAppWidth + navRailWidth;

    if (hasRoomForRail) {
      return ScaffoldWithNavigationRail(
        body: navigationShell,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: goBranch,
      );
    }

    return ScaffoldWithNavigationBar(
      body: navigationShell,
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: goBranch,
    );
  }
}

class ScaffoldWithNavigationBar extends ConsumerWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSafeArea(
      child: Scaffold(
        floatingActionButton: downloadButtonIfWeb(),
        body: body,
        bottomNavigationBar: ref.watch(navBarProvider)
            ? Container(
                height: c.navBarHeight,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 0.5,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: selectedIndex,
                  elevation: 0.0,
                  selectedFontSize: 0.0,
                  unselectedFontSize: 0.0,
                  showUnselectedLabels: false,
                  showSelectedLabels: false,
                  unselectedItemColor: Theme.of(context).colorScheme.onSurface,
                  selectedItemColor: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  items: [
                    for (int i = 0; i < _passiveIconList.length; i++)
                      BottomNavigationBarItem(
                        icon: Stack(
                          children: [
                            Icon(_passiveIconList[i], size: c.navBarIconSize),
                          ],
                        ),
                        activeIcon: Stack(
                          children: [
                            Icon(
                              _activeIconList[i],
                              size: c.navBarIconSize + c.navBarIconSizeAdder,
                            ),
                          ],
                        ),
                        label: '',
                      ),
                  ],
                  onTap: (index) => onDestinationSelected(index),
                ),
              )
            : null,
      ),
    );
  }
}

class ScaffoldWithNavigationRail extends ConsumerWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSafeArea(
      child: Scaffold(
        floatingActionButton: downloadButtonIfWeb(),
        body: Row(
          children: [
            // Fixed navigation rail on the left (start)
            if (ref.watch(navBarProvider))
              NavigationRail(
                backgroundColor: Theme.of(context).colorScheme.surface,
                useIndicator: false,
                selectedIconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                unselectedIconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedLabelTextStyle: const TextStyle(fontSize: 0),
                unselectedLabelTextStyle: const TextStyle(fontSize: 0),
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.none,
                destinations: [
                  for (int i = 0; i < _passiveIconList.length; i++)
                    NavigationRailDestination(
                      label: const Text(''),
                      icon: Stack(
                        children: [
                          Icon(_passiveIconList[i], size: c.navBarIconSize),
                        ],
                      ),
                      selectedIcon: Stack(
                        children: [
                          Icon(
                            _activeIconList[i],
                            size: c.navBarIconSize + c.navBarIconSizeAdder,
                          ),
                        ],
                      ),
                    ),
                ],
              )
            else
              SizedBox(width: 80),
            //const VerticalDivider(thickness: 1, width: 1),
            // Main content on the right (end)
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
