import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/enums.dart';
import '../controller/auth_bloc.dart';
import '../widgets/auth_widget_account_actions.dart';
import '../widgets/tech_login_widgets/tech_login_body.dart';

/// Technician sign in with the email and password the admin created.
class TechLoginScr extends StatelessWidget {
  const TechLoginScr({super.key});
  static const route = '/TechLoginScr';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.loginRequestState == RequestState.loading &&
              current.loginRequestState == RequestState.loaded,
          // The home route now shows the technician app.
          listener: (context, state) => AuthWidgetAccountActions.backToHome(),
          builder: (context, state) {
            return TechLoginBody(
                loading: state.loginRequestState == RequestState.loading);
          },
        ));
  }
}
