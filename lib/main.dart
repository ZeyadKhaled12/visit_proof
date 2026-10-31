import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'core/local/local_pref.dart';
import 'core/services/services_locator.dart';
import 'features/clients/presentation/screens/add_client_scr.dart';
import 'features/clients/presentation/screens/client_detail_scr.dart';
import 'features/clients/presentation/screens/clients_scr.dart';
import 'features/invoices/presentation/screens/invoice_detail_scr.dart';
import 'features/technicians/presentation/screens/add_tech_scr.dart';
import 'features/technicians/presentation/screens/technician_detail_scr.dart';
import 'features/add_visit/presentation/screens/add_visit_scr.dart';
import 'features/dashboard/presentation/screens/dashboard_scr.dart';
import 'features/dispatch/presentation/screens/dispatch_scr.dart';
import 'features/main_menu/presentation/screens/main_menu_scr.dart';
import 'features/visit_detail/presentation/screens/visit_detail_scr.dart';

/*
1- add option to move to full screen of picks
2- add option to add more than one location in client detail
3- solve start time in both update visit and create visit
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServicesLocator().init();
  LocalPref.sharedPreferences = await SharedPreferences.getInstance();
  // LocalPref.sharedPreferences.clear();
  AppTheme.darkMode.value = AppTheme.darkModeEnabled &&
      (LocalPref.sharedPreferences.getBool(darkModeKey) ??
          AppTheme.darkModeByDefault);
  runApp(const MyApp());
}

/// Saved dark mode choice.
const String darkModeKey = 'dark_mode';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppTheme.darkMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppTheme.darkMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  /// Saves the choice and restyles every screen in place. Colors are read
  /// while building, so all widgets (const ones too) are rebuilt; screens,
  /// navigation and data stay as they are.
  void _onThemeChanged() {
    LocalPref.sharedPreferences.setBool(darkModeKey, AppTheme.isDark);
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Visit Proof',
        navigatorKey: App.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.materialTheme,
        // Status bar and navigation bar follow the active theme.
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppTheme.systemOverlay,
              child: child!,
            ),
        routes: {
          '/': (context) => const MainMenuScr(),
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
