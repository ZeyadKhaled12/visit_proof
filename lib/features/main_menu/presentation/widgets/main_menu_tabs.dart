import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../clients/presentation/screens/clients_scr.dart';
import '../../../dashboard/presentation/screens/dashboard_scr.dart';
import '../../../dispatch/presentation/screens/dispatch_scr.dart';
import '../../../invoices/presentation/screens/invoices_scr.dart';
import '../../../services/presentation/screens/services_scr.dart';
import '../../../technicians/presentation/screens/technicians_scr.dart';
import '../../../visits/presentation/screens/visits_scr.dart';

/// Drawer groups, in display order.
enum MainMenuGroup {
  operations('Operations'),
  finance('Finance'),
  directory('Directory');

  const MainMenuGroup(this._label);
  final String _label;

  String get label => _label.tr;
}

/// The app's main sections, in menu order: daily operations first,
/// then money, then the reference lists.
enum MainMenuTab {
  dashboard('Dashboard', 'Overview and what needs attention',
      Icons.space_dashboard_outlined, Icons.space_dashboard_rounded,
      MainMenuGroup.operations),
  dispatch('Dispatch', 'Assign and schedule technicians', Icons.hub_outlined,
      Icons.hub_rounded, MainMenuGroup.operations),
  visits('Visits', 'Every visit and its status', Icons.fact_check_outlined,
      Icons.fact_check_rounded, MainMenuGroup.operations),
  invoices('Invoices', 'Billing, payments and refunds',
      Icons.receipt_long_outlined, Icons.receipt_long_rounded,
      MainMenuGroup.finance),
  clients('Clients', 'Customers, sites and equipment',
      Icons.people_alt_outlined, Icons.people_alt_rounded,
      MainMenuGroup.directory),
  technicians('Technicians', 'Your field team',
      Icons.engineering_outlined, Icons.engineering_rounded,
      MainMenuGroup.directory),
  services('Services', 'Prices, durations and checklists',
      Icons.build_circle_outlined, Icons.build_circle_rounded,
      MainMenuGroup.directory);

  const MainMenuTab(
      this._label, this._hint, this.icon, this.selectedIcon, this.group);

  final String _label;
  final String _hint;

  /// Name and description in the current language.
  String get label => _label.tr;
  String get hint => _hint.tr;
  final IconData icon;
  final IconData selectedIcon;
  final MainMenuGroup group;

  Widget buildScreen() {
    switch (this) {
      case MainMenuTab.dashboard:
        return const DashboardScr();
      case MainMenuTab.dispatch:
        return const DispatchScr();
      case MainMenuTab.visits:
        return const VisitsScr();
      case MainMenuTab.invoices:
        return const InvoicesScr();
      case MainMenuTab.clients:
        return const ClientsScr();
      case MainMenuTab.technicians:
        return const TechniciansScr();
      case MainMenuTab.services:
        return const ServicesScr();
    }
  }
}
