import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/enums.dart';
import '../controller/auth_bloc.dart';
import '../widgets/role_select_widgets/role_select_body.dart';

/// First screen when nobody is signed in: continue as the admin (no account
/// needed) or sign in as a technician.
class RoleSelectScr extends StatelessWidget {
  const RoleSelectScr({super.key});
  static const route = '/RoleSelectScr';

  @override
  Widget build(BuildContext context) {
    return GWidgetTourFlag(tour: AppTours.roleSelect, child: BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return RoleSelectBody(
                enteringAsAdmin:
                    state.enterAsAdminRequestState == RequestState.loading);
          },
        )));
  }
}
