import 'dart:convert';

import 'package:visit_proof/core/utils/enums/technician_status_enum.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/technicians/domain/usecases/add_tech_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/remove_technician_uc.dart';

import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/general_functions.dart/g_fun_token.dart';

abstract class BaseTechniciansRemoteDataSource {
  Future<List<TechnicianModel>> getTechnicians(NoParameters parameters);
  Future<void> addTech(AddTechParameters parameters);
  Future<void> removeTechnician(RemoveTechnicianParameters parameters);
  Future<TechnicianDetailModel> getTechDetail(
      GetTechDetailParameters parameters);
}

class TechniciansRemoteDataSource extends BaseTechniciansRemoteDataSource {
  @override
  Future<void> addTech(AddTechParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      List<TechnicianDetailModel> technicians = [];
      // throw ServerException(ErrorMessageModel(statusMessage: 'statusMessage'));
      if (parameters.id != null) {
        technicians =
            (LocalPref.sharedPreferences.getStringList('technicians') ?? [])
                .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
                .toList();
        int index =
            technicians.indexWhere((element) => element.id == parameters.id);
        TechnicianDetailModel technician = technicians[index];
        technician = technician.copyWith(
            name: parameters.name,
            email: parameters.email,
            password: parameters.password,
            phone: parameters.phoneNumber,
            categories: parameters.categories);
        technicians[index] = technician;
      } else {
        TechnicianDetailModel technicianDetailModel = TechnicianDetailModel(
          id: GFunToken.generateRandomId(),
          name: parameters.name,
          email: parameters.email,
          phone: parameters.phoneNumber,
          completedJobs: 0,
          completedPaid: 0,
          openJobs: 0,
          password: parameters.password,
          status: TechnicianStatus.offline,
          categories: parameters.categories,
          visits: [],
        );
        technicians =
            (LocalPref.sharedPreferences.getStringList('technicians') ?? [])
                .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
                .toList();
        technicians.insert(0, technicianDetailModel);
      }

      await LocalPref.sharedPreferences.setStringList('technicians',
          technicians.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage(parameters.id != null
          ? 'Technician updated successfuly'
          : 'Technician added successfuly');
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
      return technicians
          .firstWhere((element) => element.id == parameters.techID);
    }).checkLogicErrors();
  }

  @override
  Future<List<TechnicianModel>> getTechnicians(NoParameters parameters) async {
    return await HandleLogicErrors<List<TechnicianModel>>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list =
          LocalPref.sharedPreferences.getStringList('technicians') ?? [];
      final clients = list
          .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
          .toList();
      return clients.map((e) => e.convertToTechnicianModel()).toList();
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
      technicians.removeWhere((element) => element.id == parameters.techID);
      await LocalPref.sharedPreferences.setStringList('technicians',
          technicians.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage('Technician removed successfuly');
      return;
    }).checkLogicErrors();
  }
}
