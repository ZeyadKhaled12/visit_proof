import 'package:visit_proof/configs/app_language.dart';
import 'dart:convert';

import 'package:visit_proof/core/utils/enums/technician_status_enum.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/technicians/domain/usecases/add_tech_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/remove_technician_uc.dart';

import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/error_message_model.dart';
import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_token.dart';
import '../../../clients/data/models/client_detail_model/client_visit_model.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';

abstract class BaseTechniciansRemoteDataSource {
  Future<List<TechnicianModel>> getTechnicians(NoParameters parameters);
  Future<TechnicianDetailModel> addTech(AddTechParameters parameters);
  Future<void> removeTechnician(RemoveTechnicianParameters parameters);
  Future<TechnicianDetailModel> getTechDetail(
      GetTechDetailParameters parameters);
}

class TechniciansRemoteDataSource extends BaseTechniciansRemoteDataSource {
  @override
  Future<TechnicianDetailModel> addTech(AddTechParameters parameters) async {
    return await HandleLogicErrors<TechnicianDetailModel>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      List<TechnicianDetailModel> technicians = [];
      TechnicianDetailModel? technician;
      // throw ServerException(ErrorMessageModel(statusMessage: 'statusMessage'));

      // The email is the technician's sign-in name, so it must be unique.
      final email = parameters.email.trim().toLowerCase();
      final emailTaken =
          (LocalPref.sharedPreferences.getStringList('technicians') ?? [])
              .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
              .any((e) =>
                  e.id != parameters.id &&
                  (e.email ?? '').trim().toLowerCase() == email);
      if (emailTaken) {
        throw ServerException(ErrorMessageModel(
            statusMessage:
                'Another technician already signs in with this email.'.tr));
      }

      if (parameters.id != null) {
        technicians =
            (LocalPref.sharedPreferences.getStringList('technicians') ?? [])
                .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
                .toList();
        int index =
            technicians.indexWhere((element) => element.id == parameters.id);
        technician = technicians[index];
        technician = technician.copyWith(
            name: parameters.name,
            email: parameters.email.trim(),
            password: parameters.password,
            phone: parameters.phoneNumber,
            categories: parameters.categories);
        technicians[index] = technician;
      } else {
        technician = TechnicianDetailModel(
          id: GFunToken.generateRandomId(),
          name: parameters.name,
          email: parameters.email.trim(),
          phone: parameters.phoneNumber,
          completedJobs: 0,
          completedPaid: 0,
          openJobs: 0,
          password: parameters.password,
          status: TechnicianStatus.available,
          categories: parameters.categories,
          visits: [],
        );
        technicians =
            (LocalPref.sharedPreferences.getStringList('technicians') ?? [])
                .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
                .toList();
        technicians.insert(0, technician);
      }

      await LocalPref.sharedPreferences.setStringList('technicians',
          technicians.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage(parameters.id != null
          ? 'Technician updated successfuly'.tr
          : 'Technician added successfuly'.tr);
      return technician;
    }).checkLogicErrors();
  }

  @override
  Future<TechnicianDetailModel> getTechDetail(
      GetTechDetailParameters parameters) async {
    return await HandleLogicErrors<TechnicianDetailModel>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list =
          LocalPref.sharedPreferences.getStringList('technicians') ?? [];
      final technicians = list
          .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
          .toList();
      final technician =
          technicians.firstWhere((element) => element.id == parameters.techID);
      return _withActivity(technician, _readVisits(), _readInvoices());
    }).checkLogicErrors();
  }

  @override
  Future<List<TechnicianModel>> getTechnicians(NoParameters parameters) async {
    return await HandleLogicErrors<List<TechnicianModel>>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list =
          LocalPref.sharedPreferences.getStringList('technicians') ?? [];
      final technicians = list
          .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
          .toList();
      final visits = _readVisits();
      final invoices = _readInvoices();
      return technicians
          .map((e) =>
              _withActivity(e, visits, invoices).convertToTechnicianModel())
          .toList();
    }).checkLogicErrors();
  }

  @override
  Future<void> removeTechnician(RemoveTechnicianParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list =
          LocalPref.sharedPreferences.getStringList('technicians') ?? [];
      final technicians = list
          .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
          .toList();

      // A technician who is still working on visits cannot be removed.
      final activeVisits = _readVisits()
          .where((visit) =>
              visit.technicianModel?.id == parameters.techID &&
              _isActive(visit.status))
          .length;
      if (activeVisits > 0) {
        throw ServerException(ErrorMessageModel(
            statusMessage: 'This technician has {0} active visit{1}. Unassign or finish {2} before deleting.'.trArgs([activeVisits, activeVisits == 1 ? '' : 's', activeVisits == 1 ? 'it' : 'them'])));
      }

      technicians.removeWhere((element) => element.id == parameters.techID);
      await LocalPref.sharedPreferences.setStringList('technicians',
          technicians.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage('Technician removed successfuly'.tr);
      return;
    }).checkLogicErrors();
  }

  List<VisitDetailModel> _readVisits() =>
      (LocalPref.sharedPreferences.getStringList('visits') ?? [])
          .map((e) => VisitDetailModel.fromJson(jsonDecode(e)))
          .toList();

  List<InvoiceDetailModel> _readInvoices() =>
      (LocalPref.sharedPreferences.getStringList('invoices') ?? [])
          .map((e) => InvoiceDetailModel.fromJson(jsonDecode(e)))
          .toList();

  bool _isActive(VisitStatus? status) =>
      status == VisitStatus.assigned ||
      status == VisitStatus.onWay ||
      status == VisitStatus.inProgress;

  /// Job counts and history come from the real visits and invoices,
  /// so they are always up to date instead of being stored.
  TechnicianDetailModel _withActivity(
    TechnicianDetailModel technician,
    List<VisitDetailModel> visits,
    List<InvoiceDetailModel> invoices,
  ) {
    final invoiceOf = {
      for (final invoice in invoices) invoice.visitId: invoice
    };
    final own = visits
        .where((visit) =>
            visit.technicianModel?.id != null &&
            visit.technicianModel?.id == technician.id)
        .toList()
      ..sort((a, b) =>
          (b.startDate ?? DateTime(0)).compareTo(a.startDate ?? DateTime(0)));
    final completed =
        own.where((visit) => visit.status == VisitStatus.completed);

    return technician.copyWith(
      openJobs: own.where((visit) => _isActive(visit.status)).length,
      completedJobs: completed.length,
      completedPaid: completed.fold<num>(
          0, (sum, visit) => sum + (invoiceOf[visit.id]?.paidAmount ?? 0)),
      visits: own
          .map((visit) =>
              ClientVisitModel.fromVisit(visit, invoice: invoiceOf[visit.id]))
          .toList(),
    );
  }
}
