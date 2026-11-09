import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app.dart';
import '../../../../configs/app_theme.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/demo/demo_seed.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../domain/usecases/login_technician_uc.dart';
import '../controller/auth_bloc.dart';
import '../screens/tech_login_scr.dart';

/// Account actions pinned to the bottom of the admin and technician menus:
/// switch to the other role, or log out back to the role selection.
class AuthWidgetAccountActions extends StatelessWidget {
  const AuthWidgetAccountActions({super.key});

  /// The app's home ('/') follows the session, so after a change every
  /// screen on top of it is closed and the new home shows.
  static void backToHome() =>
      App.navigatorKey.currentState?.popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            (previous.enterAsAdminRequestState == RequestState.loading &&
                current.enterAsAdminRequestState == RequestState.loaded) ||
            (previous.loginRequestState == RequestState.loading &&
                current.loginRequestState == RequestState.loaded) ||
            (previous.logoutRequestState == RequestState.loading &&
                current.logoutRequestState == RequestState.loaded),
        listener: (context, state) => backToHome(),
        builder: (context, state) {
          final technician = AppSession.isTechnician;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ActionTile(
                icon: technician
                    ? Icons.admin_panel_settings_rounded
                    : Icons.engineering_rounded,
                label: technician
                    ? 'Switch to admin'.tr
                    : 'Switch to technician'.tr,
                color: technician ? AppTheme.primary : AppTheme.primary,
                loading:
                    state.enterAsAdminRequestState == RequestState.loading ||
                        state.loginRequestState == RequestState.loading,
                onTap: () => technician
                    ? context.read<AuthBloc>().add(const EnterAsAdminEvent(
                        noParameters: NoParameters()))
                    : _switchToTechnician(context),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.logout_rounded,
                label: 'Log out'.tr,
                color: AppTheme.statOrange,
                loading: state.logoutRequestState == RequestState.loading,
                onTap: () => _confirmLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Test builds go straight in as a technician. A customer's app asks for
  /// the technician's own sign-in.
  void _switchToTechnician(BuildContext context) {
    final person = DemoMode.testData ? DemoSeed.technicianToTry() : null;
    if (person == null) {
      Navigator.pushNamed(context, TechLoginScr.route);
      return;
    }
    context.read<AuthBloc>().add(LoginTechnicianEvent(
        loginTechnicianParameters: LoginTechnicianParameters(
            email: person.email!, password: person.password!)));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(Icons.logout_rounded, color: AppTheme.statOrange, size: 30),
        title: Text('Log out?'.tr,
            textAlign: TextAlign.center,
            style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.textTitleLarge,
                fontWeight: FontWeight.w800)),
        content: Text('You will need to sign in again to use the app.'.tr,
            textAlign: TextAlign.center,
            style: AppTheme.font(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.textBodyLarge,
                height: 1.4)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'.tr,
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.statOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Log out'.tr,
                style: AppTheme.font(
                    color: AppTheme.onPrimary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<AuthBloc>()
          .add(const LogoutEvent(noParameters: NoParameters()));
    }
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: AppTheme.font(
                        color: color,
                        fontSize: AppTheme.textBodyLarge,
                        fontWeight: FontWeight.w800)),
              ),
              if (loading)
                GWidgetLoadingCircle(
                    color: color, width: 18, height: 18, strokeWidth: 2.5),
            ],
          ),
        ),
      ),
    );
  }
}
