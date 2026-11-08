import '../../../../configs/app_brand.dart';
import '../../../../configs/app_language.dart';
import '../../../../configs/app_offer.dart';
import '../../../../configs/app_theme.dart';

/// A visitor's request for their own version of the app: who they are,
/// the design they made in the studio and anything they want changed.
/// Built to be sent as [toJson] once a backend exists.
class WebsiteRequestModel {
  const WebsiteRequestModel({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.requestedChanges,
    required this.design,
    required this.darkMode,
    required this.arabic,
    required this.createdAt,
  });

  /// Takes the design that is on screen right now.
  factory WebsiteRequestModel.fromStudio({
    required String name,
    required String company,
    required String phone,
    required String email,
    required String requestedChanges,
  }) {
    return WebsiteRequestModel(
      name: name.trim(),
      company: company.trim(),
      phone: phone.trim(),
      email: email.trim(),
      requestedChanges: requestedChanges.trim(),
      design: AppBrand.value,
      darkMode: AppTheme.isDark,
      arabic: AppLanguage.isArabic,
      createdAt: DateTime.now(),
    );
  }

  final String name;
  final String company;
  final String phone;
  final String email;

  /// What they want changed in their version: free within a limit, a paid
  /// feature beyond it. Empty when they want it as it is.
  final String requestedChanges;

  final AppBrandModel design;
  final bool darkMode;
  final bool arabic;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'company': company,
        'phone': phone,
        'email': email.isEmpty ? null : email,
        'requestedChanges': requestedChanges.isEmpty ? null : requestedChanges,
        'design': {
          ...AppBrand.toJson(design),
          'mode': darkMode ? 'dark' : 'light',
          'language': arabic ? 'ar' : 'en',
        },
        'offer': {
          'freeMonths': AppOffer.freeMonths,
          'pricePerPeriod': AppOffer.pricePerPeriod,
          'currency': 'SAR',
          'periodMonths': AppOffer.periodMonths,
          'maxUsers': AppOffer.maxUsers,
          'photoStorageGb': AppOffer.photoStorageGb,
        },
        'createdAt': createdAt.toIso8601String(),
      };
}
