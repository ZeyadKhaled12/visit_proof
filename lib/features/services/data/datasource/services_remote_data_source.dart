import 'dart:convert';

import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/services/domain/usecases/add_service_uc.dart';

import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/general_functions.dart/g_fun_token.dart';
import '../../domain/usecases/remove_service_uc.dart';

abstract class BaseServicesRemoteDataSource {
  Future<List<ServiceModel>> getServices(NoParameters parameters);
  Future<List<GModelCatg>> getCategories(NoParameters parameters);
  Future<void> addService(AddServiceParameters parameters);
  Future<List<ServiceModel>> removeService(RemoveServiceParameters parameters);
}

class ServicesRemoteDataSource extends BaseServicesRemoteDataSource {
  @override
  Future<List<ServiceModel>> getServices(NoParameters parameters) async {
    return await HandleLogicErrors<List<ServiceModel>>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list = LocalPref.sharedPreferences.getStringList('services') ?? [];
      final services =
          list.map((e) => ServiceModel.fromJson(jsonDecode(e))).toList();
      return services;
    }).checkLogicErrors();
  }

  @override
  Future<List<GModelCatg>> getCategories(NoParameters parameters) async {
    final List<GModelCatg> allCategories = [
      GModelCatg(id: GFunToken.generateRandomId(), name: 'Plumbing'),
      GModelCatg(id: GFunToken.generateRandomId(), name: 'Electrical'),
      GModelCatg(id: GFunToken.generateRandomId(), name: 'HVAC'),
      GModelCatg(id: GFunToken.generateRandomId(), name: 'Networking'),
      GModelCatg(id: GFunToken.generateRandomId(), name: 'Carpentry'),
      GModelCatg(id: GFunToken.generateRandomId(), name: 'Smart Home'),
    ];

    return await HandleLogicErrors<List<GModelCatg>>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list =
          LocalPref.sharedPreferences.getStringList('categories') ?? [];
      if (list.isEmpty) {
        await LocalPref.sharedPreferences.setStringList('categories',
            allCategories.map((e) => jsonEncode(e.toJson())).toList());
        return allCategories;
      }
      final categories =
          list.map((e) => GModelCatg.fromJson(jsonDecode(e))).toList();
      return categories;
    }).checkLogicErrors();
  }

  Future<GModelCatg> _addCategory(String categoryName) async {
    final categories =
        (LocalPref.sharedPreferences.getStringList('categories') ?? [])
            .map((e) => GModelCatg.fromJson(jsonDecode(e)))
            .toList();
    final category =
        GModelCatg(id: GFunToken.generateRandomId(), name: categoryName);
    categories.add(category);
    await LocalPref.sharedPreferences.setStringList(
        'categories', categories.map((e) => jsonEncode(e.toJson())).toList());
    return category;
  }

  @override
  Future<void> addService(AddServiceParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      List<ServiceModel> services = [];
      // throw ServerException(ErrorMessageModel(statusMessage: 'statusMessage'));
      GModelCatg? category;
      if (parameters.categoryName != null) {
        category = await _addCategory(parameters.categoryName!);
      }
      if (parameters.id != null) {
        services = (LocalPref.sharedPreferences.getStringList('services') ?? [])
            .map((e) => ServiceModel.fromJson(jsonDecode(e)))
            .toList();
        int index =
            services.indexWhere((element) => element.id == parameters.id);
        ServiceModel service = services[index];
        service = service.copyWith(
            id: parameters.id,
            category: category ?? parameters.category,
            serviceName: parameters.serviceName,
            defaultPrice: parameters.price,
            checkList: parameters.checkList);
        services[index] = service;
      } else {
        ServiceModel serviceModel = ServiceModel(
            id: GFunToken.generateRandomId(),
            category: category ?? parameters.category,
            serviceName: parameters.serviceName,
            defaultPrice: parameters.price,
            checkList: parameters.checkList);
        services = (LocalPref.sharedPreferences.getStringList('services') ?? [])
            .map((e) => ServiceModel.fromJson(jsonDecode(e)))
            .toList();
        services.insert(0, serviceModel);
      }

      await LocalPref.sharedPreferences.setStringList(
          'services', services.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage(parameters.id != null
          ? 'Service updated successfuly'
          : 'Service added successfuly');
    }).checkLogicErrors();
  }

  @override
  Future<List<ServiceModel>> removeService(
      RemoveServiceParameters parameters) async {
    return await HandleLogicErrors<List<ServiceModel>>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list = LocalPref.sharedPreferences.getStringList('services') ?? [];
      final services =
          list.map((e) => ServiceModel.fromJson(jsonDecode(e))).toList();
      services.removeWhere((element) => element.id == parameters.serviceID);
      await LocalPref.sharedPreferences.setStringList(
          'services', services.map((e) => jsonEncode(e.toJson())).toList());

      AppToasts.showMessage('Service removed successfuly');
      return services;
    }).checkLogicErrors();
  }
}
