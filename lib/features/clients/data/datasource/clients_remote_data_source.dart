import 'dart:convert';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_token.dart';
import 'package:visit_proof/core/utils/general_models/g_model_equipment.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';
import 'package:visit_proof/features/clients/data/models/client_detail_model/client_detail_model.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_client_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_equipment_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_client_detail_uc.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../domain/usecases/remove_client_uc.dart';
import '../../domain/usecases/remove_equipment_uc.dart';

abstract class BaseClientsRemoteDataSource {
  Future<List<ClientDetailModel>> getClients(NoParameters parameters);
  Future<ClientDetailModel> addClient(AddClientParameters parameters);
  Future<void> removeClient(RemoveClientParameters parameters);
  Future<ClientDetailModel> getClientDetail(
      GetClientDetailParameters parameters);
  Future<ClientDetailModel> addEquipment(AddEquipmentParameters parameters);
  Future<ClientDetailModel> removeEquipment(
      RemoveEquipmentParameters parameters);
}

class ClientsRemoteDataSource extends BaseClientsRemoteDataSource {
  @override
  Future<List<ClientDetailModel>> getClients(NoParameters parameters) async {
    return await HandleLogicErrors<List<ClientDetailModel>>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list = LocalPref.sharedPreferences.getStringList('clients') ?? [];
      final clients =
          list.map((e) => ClientDetailModel.fromJson(jsonDecode(e))).toList();
      return clients;
    }).checkLogicErrors();
  }

  @override
  Future<ClientDetailModel> addClient(AddClientParameters parameters) async {
    return await HandleLogicErrors<ClientDetailModel>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      List<ClientDetailModel> clients = [];
      ClientDetailModel? client;
      // throw ServerException(ErrorMessageModel(statusMessage: 'statusMessage'));
      if (parameters.id != null) {
        clients = (LocalPref.sharedPreferences.getStringList('clients') ?? [])
            .map((e) => ClientDetailModel.fromJson(jsonDecode(e)))
            .toList();
        int index =
            clients.indexWhere((element) => element.id == parameters.id);
        client = clients[index];
        client = client.copyWith(
          name: parameters.name,
          email: parameters.email,
          phone: parameters.phoneNumber,
          isWhatsAppPhone: parameters.whatsAppNumber,
          site: client.site?.copyWith(
              addressDetail: parameters.addressDetail,
              city: parameters.city,
              latitude: parameters.latitude,
              longitude: parameters.longitude),
          notes: parameters.notes,
        );
        clients[index] = client;
      } else {
        client = ClientDetailModel(
          id: GFunToken.generateRandomId(),
          name: parameters.name,
          email: parameters.email,
          phone: parameters.phoneNumber,
          isWhatsAppPhone: parameters.whatsAppNumber,
          site: GModelSite(
              city: parameters.city,
              addressDetail: parameters.addressDetail,
              latitude: parameters.latitude,
              longitude: parameters.longitude),
          notes: parameters.notes,
          equipments: [],
          visits: [],
          ordersCount: 0,
        );
        clients = (LocalPref.sharedPreferences.getStringList('clients') ?? [])
            .map((e) => ClientDetailModel.fromJson(jsonDecode(e)))
            .toList();
        clients.insert(0, client);
      }

      await LocalPref.sharedPreferences.setStringList(
          'clients', clients.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage(parameters.id != null
          ? 'Client updated successfuly'
          : 'Client added successfuly');
      return client;
    }).checkLogicErrors();
  }

  @override
  Future<ClientDetailModel> getClientDetail(
      GetClientDetailParameters parameters) async {
    return await HandleLogicErrors<ClientDetailModel>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list = LocalPref.sharedPreferences.getStringList('clients') ?? [];
      final clients =
          list.map((e) => ClientDetailModel.fromJson(jsonDecode(e))).toList();
      return clients.firstWhere((element) => element.id == parameters.clientID);
    }).checkLogicErrors();
  }

  @override
  Future<void> removeClient(RemoveClientParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list = LocalPref.sharedPreferences.getStringList('clients') ?? [];
      final clients =
          list.map((e) => ClientDetailModel.fromJson(jsonDecode(e))).toList();
      clients.removeWhere((element) => element.id == parameters.clientID);
      await LocalPref.sharedPreferences.setStringList(
          'clients', clients.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage('Client removed successfuly');
      return;
    }).checkLogicErrors();
  }

  @override
  Future<ClientDetailModel> addEquipment(
      AddEquipmentParameters parameters) async {
    return await HandleLogicErrors<ClientDetailModel>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final clients =
          (LocalPref.sharedPreferences.getStringList('clients') ?? [])
              .map((e) => ClientDetailModel.fromJson(jsonDecode(e)))
              .toList();
      int index =
          clients.indexWhere((element) => element.id == parameters.clientID);
      ClientDetailModel clientModel = clients[index];
      List<GModelEquipment> equipments =
          List.from(clientModel.equipments ?? []);
      GModelEquipment newEquipment =
          parameters.equipment.copyWith(id: GFunToken.generateRandomId());
      equipments.insert(0, newEquipment);
      clientModel = clientModel.copyWith(equipments: equipments);
      clients[index] = clientModel;
      await LocalPref.sharedPreferences.setStringList(
          'clients', clients.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage('Equipment added successfuly');
      return clientModel;
    }).checkLogicErrors();
  }

  @override
  Future<ClientDetailModel> removeEquipment(
      RemoveEquipmentParameters parameters) async {
    return await HandleLogicErrors<ClientDetailModel>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final clients =
          (LocalPref.sharedPreferences.getStringList('clients') ?? [])
              .map((e) => ClientDetailModel.fromJson(jsonDecode(e)))
              .toList();
      int index =
          clients.indexWhere((element) => element.id == parameters.clientID);
      ClientDetailModel clientModel = clients[index];
      List<GModelEquipment> equipments =
          List.from(clientModel.equipments ?? []);

      equipments.removeWhere((element) => element.id == parameters.equipmentID);

      clientModel = clientModel.copyWith(equipments: equipments);
      clients[index] = clientModel;
      await LocalPref.sharedPreferences.setStringList(
          'clients', clients.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage('Equipment removed successfuly');
      return clientModel;
    }).checkLogicErrors();
  }
}
