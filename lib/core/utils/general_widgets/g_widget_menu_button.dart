import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

/// Opens the app drawer from a screen's top bar. Screens have their own
/// Scaffold, so this looks up past it for the nearest Scaffold that has a
/// drawer. Outside the app menu (e.g. a pushed screen) it shows nothing.
class GWidgetMenuButton extends StatelessWidget {
  const GWidgetMenuButton({super.key});

  static ScaffoldState? _drawerScaffold(BuildContext context) {
    var scaffold = context.findAncestorStateOfType<ScaffoldState>();
    while (scaffold != null) {
      if (scaffold.hasDrawer) return scaffold;
      scaffold = scaffold.context.findAncestorStateOfType<ScaffoldState>();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = _drawerScaffold(context);
    if (scaffold == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: scaffold.openDrawer,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.iconLightGrey.withValues(alpha: .4)),
            ),
            child: Icon(Icons.menu_rounded,
                color: AppTheme.textPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}
