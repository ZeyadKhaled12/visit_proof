import 'dart:convert';

import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/data/models/invoice_payment_history_model.dart';
import '../../../technicians/data/models/technician_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../models/dashboard_snapshot_model.dart';

abstract class BaseDashboardRemoteDataSource {
  Future<DashboardSnapshotModel> getDashboardSnapshot(NoParameters parameters);
}

class DashboardRemoteDataSource extends BaseDashboardRemoteDataSource {
  static const Duration _latency = Duration(milliseconds: 400);

  @override
  Future<DashboardSnapshotModel> getDashboardSnapshot(
      NoParameters parameters) async {
    return await HandleLogicErrors<DashboardSnapshotModel>(fun: () async {
      await Future.delayed(_latency);
      return DashboardSnapshotModel(
        visits: _read('visits', VisitDetailModel.fromJson),
        invoices: _read('invoices', InvoiceDetailModel.fromJson),
        payments:
            _read('invoice_payments', InvoicePaymentHistoryModel.fromJson),
        technicians: _read('technicians', TechnicianDetailModel.fromJson)
            .map((e) => e.convertToTechnicianModel())
            .toList(),
        loadedAt: DateTime.now(),
      );
    }).checkLogicErrors();
  }

  List<T> _read<T>(String key, T Function(Map<String, dynamic> json) fromJson) =>
      (LocalPref.sharedPreferences.getStringList(key) ?? [])
          .map((e) => fromJson(Map<String, dynamic>.from(jsonDecode(e) as Map)))
          .toList();
}
