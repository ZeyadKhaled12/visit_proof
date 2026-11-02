import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/general_widgets/g_widget_app_settings.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../controller/auth_bloc.dart';
import '../../screens/tech_login_scr.dart';

class RoleSelectBody extends StatelessWidget {
  const RoleSelectBody({super.key, required this.enteringAsAdmin});
  final bool enteringAsAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const _Brand(),
            const SizedBox(height: 36),
            Text('How do you want to continue?'.tr,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textTitleLarge,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('You can switch roles later from the app menu.'.tr,
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.textBody)),
            const SizedBox(height: 18),
            _RoleCard(
              icon: Icons.admin_panel_settings_rounded,
              color: AppTheme.primary,
              title: 'Admin'.tr,
              subtitle:
                  'Plan visits, dispatch technicians and follow invoices.'.tr,
              loading: enteringAsAdmin,
              onTap: () => context.read<AuthBloc>().add(
                  const EnterAsAdminEvent(noParameters: NoParameters())),
            ),
            const SizedBox(height: 14),
            _RoleCard(
              icon: Icons.engineering_rounded,
              color: AppTheme.secondary,
              title: 'Technician'.tr,
              subtitle:
                  'See your visits, check in on site and add proof photos.'.tr,
              loading: false,
              onTap: () => Navigator.pushNamed(context, TechLoginScr.route),
            ),
            if (GWidgetAppSettings.hasAny) ...[
              const SizedBox(height: 32),
              const GWidgetAppSettings(),
            ],
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primary.withValues(alpha: .3),
                  blurRadius: 20,
                  offset: const Offset(0, 8)),
            ],
          ),
          child:
              Icon(Icons.verified_rounded, color: AppTheme.onPrimary, size: 44),
        ),
        const SizedBox(height: 16),
        Text('Visit Proof'.tr,
            style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.textHeadline,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Field visits with proof of work'.tr,
            textAlign: TextAlign.center,
            style: AppTheme.font(
                color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .35)),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.cardShadowColor.withValues(alpha: .05),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textTitle,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: AppTheme.font(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.textSmall,
                            height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              loading
                  ? GWidgetLoadingCircle(
                      color: color, width: 20, height: 20, strokeWidth: 2.5)
                  : Icon(Icons.arrow_forward_ios_rounded,
                      color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
