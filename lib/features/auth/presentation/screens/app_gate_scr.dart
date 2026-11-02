import 'package:flutter/material.dart';

import '../../../../core/session/app_session.dart';
import '../../../main_menu/presentation/screens/main_menu_scr.dart';
import '../../../technician_home/presentation/screens/tech_home_scr.dart';
import 'role_select_scr.dart';

/// The app's home route ('/'). It follows the session: the role selection
/// when nobody is signed in, otherwise the admin or the technician app.
/// Switching roles or logging out only changes the session; this screen
/// swaps itself.
class AppGateScr extends StatelessWidget {
  const AppGateScr({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSessionModel?>(
      valueListenable: AppSession.current,
      builder: (context, session, _) {
        if (AppSession.isTechnician) {
          // Keyed so a different technician starts from a fresh screen.
          return TechHomeScr(key: ValueKey(session?.technicianId));
        }
        if (AppSession.isAdmin) return const MainMenuScr();
        return const RoleSelectScr();
      },
    );
  }
}
