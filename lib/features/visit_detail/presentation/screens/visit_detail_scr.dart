import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/usecases/get_visit_detail_uc.dart';
import '../controller/visit_detail_bloc.dart';
import '../widgets/visit_detail_body.dart';

class VisitDetailScr extends StatelessWidget {
  const VisitDetailScr({super.key});
  static const route = '/VisitDetailScr';

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    VisitDetailArgu argu = VisitDetailArgu(visitID: '');
    if (data != null) {
      argu = VisitDetailArgu.fromJson(data);
    }

    return BlocProvider(
        create: (context) => sl<VisitDetailBloc>()
          ..add(GetVisitDetailEvent(
              getVisitDetailParameters:
                  GetVisitDetailParameters(visitID: argu.visitID))),
        child: BlocConsumer<VisitDetailBloc, VisitDetailState>(
          listener: (context, state) {
            if (state.deleteVisitRequestState == RequestState.loaded) {
              Navigator.pop(context, true);
            }
          },
          listenWhen: (previous, current) =>
              previous.deleteVisitRequestState !=
              current.deleteVisitRequestState,
          builder: (context, state) {
            return VisitDetailBody(visitID: argu.visitID, state: state);
          },
        ));
  }
}

class VisitDetailArgu {
  final String visitID;
  VisitDetailArgu({required this.visitID});
  Map<String, dynamic> toArgu() => {'visitID': visitID};
  factory VisitDetailArgu.fromJson(Map<String, dynamic> argu) =>
      VisitDetailArgu(visitID: argu['visitID']);
}
