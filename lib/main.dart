import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/features/invoices/presentation/screens/invoices_scr.dart';
import 'package:visit_proof/features/visits/presentation/screens/visits_scr.dart';
import 'core/local/local_pref.dart';
import 'core/services/services_locator.dart';
import 'features/clients/presentation/screens/add_client_scr.dart';
import 'features/clients/presentation/screens/client_detail_scr.dart';
import 'features/clients/presentation/screens/clients_scr.dart';
import 'features/invoices/presentation/screens/invoice_detail_scr.dart';
import 'features/technicians/presentation/screens/add_tech_scr.dart';
import 'features/technicians/presentation/screens/technician_detail_scr.dart';
import 'features/add_visit/presentation/screens/add_visit_scr.dart';

/*
1- add option to move to full screen of picks
2- add option to add more than one location in client detail
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServicesLocator().init();
  LocalPref.sharedPreferences = await SharedPreferences.getInstance();
  // LocalPref.sharedPreferences.clear();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF2F2F2),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Visit Proof',
        navigatorKey: App.navigatorKey,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => InvoicesScr(),
          ClientDetailScr.route: (context) => ClientDetailScr(),
          ClientsScr.route: (context) => ClientsScr(),
          AddClientScr.route: (context) => AddClientScr(),
          AddTechScr.route: (context) => AddTechScr(),
          TechnicianDetailScr.route: (context) => TechnicianDetailScr(),
          AddVisitScr.route: (context) => AddVisitScr(),
          InvoiceDetailScr.route: (context) => InvoiceDetailScr(),

        });
  }
}
