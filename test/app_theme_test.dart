import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visit_proof/configs/app_theme.dart';

void main() {
  tearDown(() => AppTheme.darkMode.value = false);

  test('colors come from the light palette by default', () {
    AppTheme.darkMode.value = false;
    expect(AppTheme.primary, AppTheme.light.primary);
    expect(AppTheme.scaffoldBackground, AppTheme.light.scaffoldBackground);
    expect(AppTheme.systemOverlay.statusBarIconBrightness, Brightness.dark);
  });

  test('switching dark mode swaps every color and the status bar', () {
    AppTheme.darkMode.value = true;
    expect(AppTheme.primary, AppTheme.dark.primary);
    expect(AppTheme.textPrimary, AppTheme.dark.textPrimary);
    expect(AppTheme.surface, AppTheme.dark.surface);
    expect(AppTheme.systemOverlay.statusBarIconBrightness, Brightness.light);
    expect(AppTheme.systemOverlay.systemNavigationBarColor,
        AppTheme.dark.scaffoldBackground);
  });

  test('brand headers always get light status icons', () {
    expect(AppTheme.systemOverlayOnPrimary.statusBarIconBrightness,
        Brightness.light);
  });
}
