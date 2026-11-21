import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/l10n_ext.dart';
import '../../core/widgets/app_widgets.dart';
import 'widgets/custom_bottom_navigation.dart';

enum ShellTab { home, practice, analytics }

/// Bottom-navigation shell. Item order must match the branch order in app_router.dart.
/// Uses a NavigationRail on wide screens.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _onTap(int i) =>
      shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      (Icons.edit_outlined, Icons.edit_rounded, l10n.navPractice),
      (Icons.bookmarks_outlined, Icons.bookmarks_rounded, l10n.navSaved),
      (Icons.bar_chart_rounded, Icons.bar_chart_rounded, l10n.navAnalytics),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 840;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _onTap,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: AppLogo(size: 40),
              ),
              destinations: [
                for (final it in items)
                  NavigationRailDestination(
                    icon: Icon(it.$1),
                    selectedIcon: Icon(it.$2),
                    label: Text(it.$3),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: shell.currentIndex,
        onSelected: _onTap,
        items: [
          for (final it in items)
            NavItem(icon: it.$1, selectedIcon: it.$2, label: it.$3),
        ],
      ),
    );
  }
}

/// Tabs whose modules arrive in later phases (practice, analytics).
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.tab});
  final ShellTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, icon) = switch (tab) {
      ShellTab.practice => (l10n.dailyPractice, Icons.menu_book_outlined),
      ShellTab.analytics => (l10n.analytics, Icons.insights_outlined),
      _ => (l10n.appName, Icons.home_outlined),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: StateMessage(
          icon: icon,
          title: l10n.comingSoon,
          body: l10n.comingSoonBody,
        ),
      ),
    );
  }
}
