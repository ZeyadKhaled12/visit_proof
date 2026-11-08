import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/utils/general_widgets/g_widget_app_settings.dart';
import '../../../auth/presentation/widgets/auth_widget_account_actions.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';

/// The technician's menu: who is signed in, preferences, switch to the admin
/// app or log out.
class TechHomeWidgetDrawer extends StatelessWidget {
  const TechHomeWidgetDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.current.value;

    return Drawer(
      backgroundColor: AppTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadiusDirectional.horizontal(end: Radius.circular(28))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.paddingOf(context).top + 22, 20, 22),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(28)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.onPrimary.withValues(alpha: .2),
                  child: Text(
                      VisitDetailHelpers.initial(session?.technicianName),
                      style: AppTheme.font(
                          color: AppTheme.onPrimary,
                          fontSize: AppTheme.textTitleLarge,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session?.technicianName ?? 'Technician'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: AppTheme.onPrimary,
                              fontSize: AppTheme.textTitle,
                              fontWeight: FontWeight.w800)),
                      Text(session?.technicianEmail ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: AppTheme.onPrimary.withValues(alpha: .85),
                              fontSize: AppTheme.textSmall,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              children: [
                _Tip(
                  icon: Icons.my_location_rounded,
                  text:
                      'Every action you take records your current location for the admin.'
                          .tr,
                ),
                const SizedBox(height: 10),
                _Tip(
                  icon: Icons.photo_camera_rounded,
                  text:
                      'Take before and after photos when the visit asks for them.'
                          .tr,
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (GWidgetAppSettings.hasAny) ...[
                    const GWidgetAppSettings(),
                    const SizedBox(height: 8),
                  ],
                  const AuthWidgetAccountActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.iconLightGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.textSmall,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
