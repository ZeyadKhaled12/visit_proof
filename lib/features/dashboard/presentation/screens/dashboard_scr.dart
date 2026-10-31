import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../controller/dashboard_bloc.dart';
import '../widgets/dashboard_body.dart';

class DashboardScr extends StatelessWidget {
  const DashboardScr({super.key});
  static const route = '/DashboardScr';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<DashboardBloc>()
          ..add(const GetDashboardEvent(noParameters: NoParameters())),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) => DashboardBody(state: state),
        ));
  }
}
