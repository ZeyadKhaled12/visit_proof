import 'dart:convert';

import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_token.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_history_model.dart';
import 'package:intl/intl.dart';
import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../domain/usecases/add_visit_uc.dart';

abstract class BaseAddVisitRemoteDataSource {
  Future<VisitDetailModel> addVisit(AddVisitParameters parameters);
}

class AddVisitRemoteDataSource extends BaseAddVisitRemoteDataSource {
  @override
  Future<VisitDetailModel> addVisit(AddVisitParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      DateTime startDate = DateTime.now();
      String visitID = GFunToken.generateRandomId();

      await Future.delayed(Duration(seconds: 1));
      List<VisitDetailModel> visits = [];
      VisitDetailModel visit = parameters.visitDetailModel;
      visits = (LocalPref.sharedPreferences.getStringList('visits') ?? [])
          .map((e) => VisitDetailModel.fromJson(jsonDecode(e)))
          .toList();

      visit = visit.copyWith(
        id: visitID,
        visitNumber:
            'VIS-${(visits.isEmpty ? 1 : visits.length).toString().padLeft(6, '0')}',
      );
      List<VisitHistoryModel> history = [
        VisitHistoryModel(
            id: GFunToken.generateRandomId(),
            visitId: visitID,
            recordedAt: startDate,
            actor: VisitHistoryActorModel(
                id: GFunToken.generateRandomId(), role: 'Admin'),
            description:
                'Admin create this visit at ${DateFormat('dd MMM yyy').format(startDate)}')
      ];
      if (visit.status == VisitStatus.scheduled ||
          visit.status == VisitStatus.assigned) {
        history.add(VisitHistoryModel(
            id: GFunToken.generateRandomId(),
            visitId: visitID,
            recordedAt: startDate,
            actor: VisitHistoryActorModel(
                id: GFunToken.generateRandomId(), role: 'Admin'),
            description:
                'Admin change this visit status to ${visit.status.toString()} at ${DateFormat('dd MMM yyy').format(startDate)}'));
      }
      visit = visit.copyWith(history: history);
      visits.insert(0, visit);
      await LocalPref.sharedPreferences.setStringList(
          'visits', visits.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage('Visit added successfuly');
      return visit;
    }).checkLogicErrors();
  }
}
