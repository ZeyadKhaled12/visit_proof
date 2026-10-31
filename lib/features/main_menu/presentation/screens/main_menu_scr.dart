import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../widgets/main_menu_tabs.dart';
import '../widgets/main_menu_widget_drawer.dart';

/// The app shell: shows one main section at a time, with the app menu in a
/// drawer opened from the menu button at the top of each section.
class MainMenuScr extends StatefulWidget {
  const MainMenuScr({super.key});
  static const route = '/MainMenuScr';

  /// Switches the shell to [tab]. Returns false when [context] is not
  /// inside the shell, so callers can fall back to pushing a screen.
  static bool open(BuildContext context, MainMenuTab tab) {
    final shell = context.findAncestorStateOfType<_MainMenuScrState>();
    if (shell == null) return false;
    shell._select(tab);
    return true;
  }

  @override
  State<MainMenuScr> createState() => _MainMenuScrState();
}

class _MainMenuScrState extends State<MainMenuScr> {
  MainMenuTab _current = MainMenuTab.dashboard;

  /// Bumped on every selection so the section is rebuilt and reloads its
  /// data; a change made in one section always shows in the next.
  int _visit = 0;

  void _select(MainMenuTab tab) => setState(() {
        _current = tab;
        _visit++;
      });

  @override
  Widget build(BuildContext context) {
    // Back goes to the dashboard first, then leaves the app.
    return PopScope(
      canPop: _current == MainMenuTab.dashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _select(MainMenuTab.dashboard);
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        drawer: MainMenuWidgetDrawer(current: _current, onSelect: _select),
        body: KeyedSubtree(
          key: ValueKey('${_current.name}-$_visit'),
          child: _current.buildScreen(),
        ),
      ),
    );
  }
}
