import 'dart:convert';

import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/session/app_session.dart';

abstract class BaseVisitsRemoteDataSource {
  Future<List<VisitDetailModel>> getVisits(NoParameters parameters);
}

class VisitsRemoteDataSource extends BaseVisitsRemoteDataSource {
  @override
  Future<List<VisitDetailModel>> getVisits(NoParameters parameters) async {
    return await HandleLogicErrors<List<VisitDetailModel>>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      List<VisitDetailModel> visits = [];
      visits = (LocalPref.sharedPreferences.getStringList('visits') ?? [])
          .map((e) => VisitDetailModel.fromJson(jsonDecode(e)))
          .toList();

      // A technician only ever receives their own visits.
      final technicianId = AppSession.technicianId;
      if (technicianId != null) {
        visits = visits
            .where((visit) => visit.technicianModel?.id == technicianId)
            .toList();
      }
      return visits;
    }).checkLogicErrors();
  }
}
