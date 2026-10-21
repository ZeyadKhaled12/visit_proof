import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/features/technicians/presentation/screens/technicians_scr.dart';
import 'core/local/local_pref.dart';
import 'core/services/services_locator.dart';

import 'features/clients/presentation/screens/add_client_scr.dart';
import 'features/clients/presentation/screens/client_detail_scr.dart';
import 'features/clients/presentation/screens/clients_scr.dart';
import 'features/services/presentation/screens/services_scr.dart';
import 'features/technicians/presentation/screens/add_tech_scr.dart';
import 'features/technicians/presentation/screens/technician_detail_scr.dart';


/*
1- make sure that all required fields has filled
2- make sure that every single required filled has her max and min
3- make sure that fileds need special format like email, phone number and password

---check categories in add tech
---check SAR in all price fields

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
  runApp(const MyApp());
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
          '/': (context) => TechniciansScr(),
          ClientDetailScr.route: (context) => ClientDetailScr(),
          ClientsScr.route: (context) => ClientsScr(),
          AddClientScr.route: (context) => AddClientScr(),
          AddTechScr.route: (context) => AddTechScr(),
          TechnicianDetailScr.route: (context) => TechnicianDetailScr(),
        });
  }
}