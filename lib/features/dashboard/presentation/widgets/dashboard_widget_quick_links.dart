import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../add_visit/presentation/screens/add_visit_scr.dart';
import '../../../main_menu/presentation/screens/main_menu_scr.dart';
import '../../../main_menu/presentation/widgets/main_menu_tabs.dart';
import '../controller/dashboard_bloc.dart';
import 'dashboard_widget_parts.dart';

/// Shortcuts to every module, so the dashboard is the app's home.
class DashboardWidgetQuickLinks extends StatelessWidget {
  const DashboardWidgetQuickLinks({super.key});

  /// Switches the menu section when inside the app shell; otherwise
  /// (e.g. the dashboard opened on its own) pushes the screen.
  Future<void> _go(BuildContext context, MainMenuTab tab) async {
    if (MainMenuScr.open(context, tab)) return;
    final bloc = context.read<DashboardBloc>();
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => tab.buildScreen()));
    bloc.add(const GetDashboardEvent(noParameters: NoParameters()));
  }

  Future<void> _newVisit(BuildContext context) async {
    final bloc = context.read<DashboardBloc>();
    await Navigator.pushNamed(context, AddVisitScr.route);
    bloc.add(const GetDashboardEvent(noParameters: NoParameters()));
  }

  @override
  Widget build(BuildContext context) {
    final links = [
      (Icons.add_circle_rounded, 'New visit'.tr, AppTheme.primary,
          () => _newVisit(context)),
      (Icons.hub_rounded, 'Dispatch'.tr, AppTheme.secondary,
          () => _go(context, MainMenuTab.dispatch)),
      (Icons.fact_check_rounded, 'Visits'.tr, AppTheme.primary,
          () => _go(context, MainMenuTab.visits)),
      (Icons.people_alt_rounded, 'Clients'.tr, AppTheme.statGreen,
          () => _go(context, MainMenuTab.clients)),
      (Icons.engineering_rounded, 'Technicians'.tr, AppTheme.pending,
          () => _go(context, MainMenuTab.technicians)),
      (Icons.build_circle_rounded, 'Services'.tr, AppTheme.cardAccent,
          () => _go(context, MainMenuTab.services)),
      (Icons.receipt_long_rounded, 'Invoices'.tr, AppTheme.statOrange,
          () => _go(context, MainMenuTab.invoices)),
    ];

    return DashboardSection(
      title: 'Go to'.tr,
      child: LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 7 : 4;
        return DashboardGrid(
          columns: columns,
          spacing: 8,
          children: [
            for (final (icon, label, color, onTap) in links)
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.textCaption,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
