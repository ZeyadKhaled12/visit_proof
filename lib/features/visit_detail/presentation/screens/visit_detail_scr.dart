import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/services/services_locator.dart';
import 'package:visit_proof/core/utils/enums.dart';
import '../controller/visit_detail_bloc.dart';
import '../widgets/visit_detail_body.dart';

class VisitDetailScr extends StatelessWidget {
  static const route = '/VisitDetailScr';
  const VisitDetailScr({super.key});

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    VisitDetailArgu argu = VisitDetailArgu(visitID: '');
    if (data != null) {
      argu = VisitDetailArgu.fromJson(data);
    }

    return BlocProvider(
      create: (_) => sl<VisitDetailBloc>()
        ..add(LoadVisitDetailEvent(argu.visitID))
        ..add(const LoadVisitEditOptionsEvent()),
      child: BlocConsumer<VisitDetailBloc, VisitDetailState>(
        listenWhen: (a, b) =>
            a.actionSuccessCount != b.actionSuccessCount ||
            (a.actionState != b.actionState &&
                b.actionState == RequestState.error) ||
            (a.getState != b.getState && b.getState == RequestState.error),
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: AppColors.statOrange,
                content: Text(state.error!,
                    style: AppFonts(
                        color: AppColors.surfaceWhite, fontSize: 12))));
          }
        },
        builder: (_, state) =>
            VisitDetailBody(visitID: argu.visitID, state: state),
      ),
    );
  }
}

class VisitDetailArgu {
  final String visitID;
  VisitDetailArgu({required this.visitID});
  Map<String, dynamic> toArgu() => {'visitID': visitID};
  factory VisitDetailArgu.fromJson(Map<String, dynamic> argu) =>
      VisitDetailArgu(visitID: argu['visitID']);
}
