import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../configs/app_brand.dart';
import '../configs/app_theme.dart';
import '../features/auth/presentation/screens/app_gate_scr.dart';
import '../features/auth/presentation/screens/role_select_scr.dart';
import '../features/auth/presentation/screens/tech_login_scr.dart';
import '../features/clients/presentation/screens/add_client_scr.dart';
import '../features/clients/presentation/screens/client_detail_scr.dart';
import '../features/clients/presentation/screens/clients_scr.dart';
import '../features/invoices/presentation/screens/invoice_detail_scr.dart';
import '../features/technicians/presentation/screens/add_tech_scr.dart';
import '../features/technicians/presentation/screens/technician_detail_scr.dart';
import '../features/add_visit/presentation/screens/add_visit_scr.dart';
import '../features/dashboard/presentation/screens/dashboard_scr.dart';
import '../features/dispatch/presentation/screens/dispatch_scr.dart';
import '../features/main_menu/presentation/screens/main_menu_scr.dart';
import '../features/technician_home/presentation/screens/tech_home_scr.dart';
import '../features/visit_detail/presentation/screens/visit_detail_scr.dart';
import '../core/utils/general_widgets/g_widget_install_banner.dart';
import 'app.dart';

/// The Visit Proof app. Also shown inside the website's phone preview.
class VisitProofApp extends StatelessWidget {
  const VisitProofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: AppBrand.appName,
        navigatorKey: App.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.materialTheme,
        // Arabic switches Flutter's own widgets and the layout to RTL.
        locale: AppLanguage.locale,
        supportedLocales: AppLanguage.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Status bar and navigation bar follow the active theme. An installed
        // app opened in a browser tab offers to install itself.
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppTheme.systemOverlay,
              child: GWidgetInstallBanner(child: child!),
            ),
        routes: {
          // Role selection, admin app or technician app, by session.
          '/': (context) => const AppGateScr(),
          RoleSelectScr.route: (context) => const RoleSelectScr(),
          TechLoginScr.route: (context) => const TechLoginScr(),
          TechHomeScr.route: (context) => const TechHomeScr(),
          ClientDetailScr.route: (context) => ClientDetailScr(),
          ClientsScr.route: (context) => ClientsScr(),
          AddClientScr.route: (context) => AddClientScr(),
          AddTechScr.route: (context) => AddTechScr(),
          TechnicianDetailScr.route: (context) => TechnicianDetailScr(),
          AddVisitScr.route: (context) => AddVisitScr(),
          InvoiceDetailScr.route: (context) => InvoiceDetailScr(),
          VisitDetailScr.route: (context) => VisitDetailScr(),
          DispatchScr.route: (context) => DispatchScr(),
          DashboardScr.route: (context) => const DashboardScr(),
          MainMenuScr.route: (context) => const MainMenuScr(),
        });
  }
}
