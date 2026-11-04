import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/configs/app_brand.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'app/visit_proof_app.dart';
import 'core/demo/demo_mode.dart';
import 'core/demo/demo_seed.dart';
import 'core/local/local_pref.dart';
import 'core/pwa/app_install.dart';
import 'core/services/services_locator.dart';
import 'core/usecase/base_use_case.dart';
import 'features/auth/domain/usecases/restore_session_uc.dart';
import 'features/website/presentation/screens/website_scr.dart';

/*
1- add option to move to full screen of picks
2- add option to add more than one location in client detail
3- solve start time in both update visit and create visit
*/

/*
THE STUDIO'S "اطلب" (REQUEST) BUTTON
-------------------------------------
Now: it installs the app the visitor designed as a PWA on their device
(StudioInstall in features/website/presentation/widgets/
studio_widget_install.dart). The installed app opens with only Visit Proof,
in that design, and cannot change it (AppInstall in core/pwa/app_install.dart,
DemoMode.installedApp).

To go back to the old flow (the button opens the request form,
WebsiteRequestScr, so the visitor sends their design and notes):
  in features/website/presentation/screens/website_studio_scr.dart set
      static const bool requestInstallsApp = false;
That is the only change needed: the request form and its code were kept as
they are. The landing page's "Request my version" button always opens the
request form.
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A customer's build carries their design (see AppBrand.fromEnvironment);
  // an app installed from the studio carries it in its link (AppInstall).
  final installed = DemoMode.installedApp ? AppInstall.opened : null;
  AppBrand.update(installed?.brand ?? AppBrand.fromEnvironment());
  ServicesLocator().init();
  // Each installed design keeps its own data, apart from the website demo.
  if (installed != null) SharedPreferences.setPrefix(AppInstall.storagePrefix);
  LocalPref.sharedPreferences = await SharedPreferences.getInstance();
  final prefs = LocalPref.sharedPreferences;

  // The website always opens in Arabic and light mode; the app keeps the
  // user's choices. An installed app keeps the light/dark it was designed in.
  final savedDark = DemoMode.isOn ? null : prefs.getBool(darkModeKey);
  final savedArabic = DemoMode.isOn ? null : prefs.getBool(arabicKey);
  AppTheme.darkMode.value = installed?.dark ??
      (AppTheme.darkModeEnabled && (savedDark ?? AppTheme.darkModeByDefault));
  AppLanguage.arabic.value = AppLanguage.languageSwitchEnabled &&
      (savedArabic ??
          installed?.arabic ??
          (DemoMode.isOn || AppLanguage.arabicByDefault));

  // An installed app loads the test company once and then keeps what the
  // user does in it.
  final seedNow =
      installed == null || !(prefs.getBool(_installedSeededKey) ?? false);
  if (DemoMode.testData && seedNow) {
    // Every start begins again from the large test company (in its
    // language), so there is always plenty to try. A customer's build keeps
    // its data.
    await prefs.clear();
    if (savedDark != null) await prefs.setBool(darkModeKey, savedDark);
    if (savedArabic != null) await prefs.setBool(arabicKey, savedArabic);
    await DemoSeed.run();
    if (installed != null) await prefs.setBool(_installedSeededKey, true);
  }
  await initializeDateFormatting();
  // Arabic month and day names, but the same 0-9 digits as the rest of the app.
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
  Intl.defaultLocale = AppLanguage.locale.languageCode;
  // Reopens as the admin or the technician who used the app last.
  await sl<RestoreSessionUc>().call(const NoParameters());
  runApp(const MyApp());

  // Opened in a browser tab, the installed app's page must offer this
  // design (not Wizpo) for installing. Its icon is drawn with the icon font,
  // so wait until the first screen has loaded it.
  final raw = AppInstall.openedRaw;
  if (installed != null && raw != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
        const Duration(milliseconds: 800), () => AppInstall.publish(raw)));
  }
}

/// The installed app has loaded the test company.
const String _installedSeededKey = 'installed_seeded';

/// Saved dark mode choice.
const String darkModeKey = 'dark_mode';

/// Saved language choice.
const String arabicKey = 'app_arabic';

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
    AppLanguage.arabic.addListener(_onLanguageChanged);
    AppBrand.current.addListener(_rebuildAll);
  }

  @override
  void dispose() {
    AppTheme.darkMode.removeListener(_onThemeChanged);
    AppLanguage.arabic.removeListener(_onLanguageChanged);
    AppBrand.current.removeListener(_rebuildAll);
    super.dispose();
  }

  /// Saves the language, updates dates and redraws every screen in the new
  /// language and direction.
  void _onLanguageChanged() {
    LocalPref.sharedPreferences.setBool(arabicKey, AppLanguage.isArabic);
    Intl.defaultLocale = AppLanguage.locale.languageCode;
    _rebuildAll();
  }

  /// Saves the choice and restyles every screen in place. Colors are read
  /// while building, so all widgets (const ones too) are rebuilt; screens,
  /// navigation and data stay as they are.
  void _onThemeChanged() {
    LocalPref.sharedPreferences.setBool(darkModeKey, AppTheme.isDark);
    _rebuildAll();
  }

  bool _rebuildScheduled = false;

  /// Redraws every widget, at most once per frame: dragging a color in the
  /// design studio sends many changes a frame, and walking the whole tree
  /// for each of them made the motion stutter.
  void _rebuildAll() {
    if (_rebuildScheduled) return;
    _rebuildScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _rebuildScheduled = false;
      if (!mounted) return;
      setState(() {});
      void rebuild(Element element) {
        element.markNeedsBuild();
        element.visitChildren(rebuild);
      }

      (context as Element).visitChildren(rebuild);
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// The browser build is the sales website, with the app inside it as a
  /// live demo; phones and installed apps run the app itself.
  @override
  Widget build(BuildContext context) =>
      DemoMode.isOn ? const WebsiteApp() : const VisitProofApp();
}
