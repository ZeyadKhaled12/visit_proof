import '../../../../configs/app_brand.dart';
import '../../../../configs/app_language.dart';
import '../../../../configs/app_offer.dart';
import '../../../../configs/app_theme.dart';

/// A visitor's request for their own version of the app: who they are,
/// the design they made in the studio and anything they want changed.
class WebsiteRequestModel {
  const WebsiteRequestModel({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.customChanges,
    required this.comments,
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
    required bool customChanges,
    required String comments,
  }) {
    return WebsiteRequestModel(
      name: name.trim(),
      company: company.trim(),
      phone: phone.trim(),
      email: email.trim(),
      customChanges: customChanges,
      comments: comments.trim(),
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

  /// Asks for changes made only for them, priced separately.
  final bool customChanges;
  final String comments;

  final AppBrandModel design;
  final bool darkMode;
  final bool arabic;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'company': company,
        'phone': phone,
        'email': email.isEmpty ? null : email,
        'customChanges': customChanges,
        'comments': comments.isEmpty ? null : comments,
        'design': {
          ...AppBrand.toJson(design),
          'mode': darkMode ? 'dark' : 'light',
          'language': arabic ? 'ar' : 'en',
        },
        'offer': {
          'freeMonths': AppOffer.freeMonths,
          'pricePerPeriodUsd': AppOffer.pricePerPeriod,
          'periodMonths': AppOffer.periodMonths,
          'maxUsers': AppOffer.maxUsers,
          'photoStorageGb': AppOffer.photoStorageGb,
        },
        'createdAt': createdAt.toIso8601String(),
      };
}
