import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/core/theme/app_pallete.dart';

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [navigationShell] is placed
/// in the body of the Scaffold.
class AppShell extends StatelessWidget {
  /// Creates a [AppShell].
  const AppShell({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The StatefulNavigationShell from the associated StatefulShellRoute is
      // directly passed as the body of the Scaffold.
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppPallete.secondaryBackgroundColor,
              width: 0.3,
            ),
          ),
        ),
        child: BottomNavigationBar(
          selectedLabelStyle: Theme.of(context).textTheme.titleSmall,
          unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
          backgroundColor: AppPallete.primaryBackgroundColor,

          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_filled),
              activeIcon: _buildActiveNavIcon(Icons.home_filled),
              label: 'Posts',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.chat),
              activeIcon: _buildActiveNavIcon(Icons.chat),
              label: 'Chats',
            ),
          ],
          currentIndex: navigationShell.currentIndex,
          // Navigate to the current location of the branch at the provided
          // index when tapping an item in the BottomNavigationBar.
          onTap: (index) => _onTap(context, index),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildNavIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Icon(icon),
    );
  }

  Widget _buildActiveNavIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: const BoxDecoration(
          color: AppPallete.primaryGreenMuted,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Icon(
          icon,
          color: AppPallete.textPrimary,
        ),
      ),
    );
  }
}
