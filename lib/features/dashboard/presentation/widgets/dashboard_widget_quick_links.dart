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

/// The main action of the dashboard.
class DashboardWidgetNewVisit extends StatelessWidget {
  const DashboardWidgetNewVisit({super.key});

  Future<void> _newVisit(BuildContext context) async {
    final bloc = context.read<DashboardBloc>();
    await Navigator.pushNamed(context, AddVisitScr.route);
    bloc.add(const GetDashboardEvent(noParameters: NoParameters()));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _newVisit(context),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.onPrimary.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.add_rounded,
                    color: AppTheme.onPrimary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New visit'.tr,
                        style: AppTheme.font(
                            color: AppTheme.onPrimary,
                            fontSize: AppTheme.textSubtitle,
                            fontWeight: FontWeight.w800)),
                    Text('Book a client and send a technician'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                            color: AppTheme.onPrimary.withValues(alpha: .85),
                            fontSize: AppTheme.textSmall,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final links = [
      (Icons.hub_rounded, 'Dispatch'.tr, MainMenuTab.dispatch),
      (Icons.fact_check_rounded, 'Visits'.tr, MainMenuTab.visits),
      (Icons.people_alt_rounded, 'Clients'.tr, MainMenuTab.clients),
      (Icons.engineering_rounded, 'Technicians'.tr, MainMenuTab.technicians),
      (Icons.build_circle_rounded, 'Services'.tr, MainMenuTab.services),
      (Icons.receipt_long_rounded, 'Invoices'.tr, MainMenuTab.invoices),
    ];

    return DashboardSection(
      title: 'Go to'.tr,
      child: LayoutBuilder(builder: (context, constraints) {
        return DashboardGrid(
          columns: constraints.maxWidth >= 520 ? 6 : 3,
          spacing: 8,
          children: [
            for (final (icon, label, tab) in links)
              InkWell(
                onTap: () => _go(context, tab),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: AppTheme.primary, size: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.textSmall,
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
