import 'package:visit_proof/configs/app_language.dart';
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
import '../../../../core/network/error/error_message_model.dart';
import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../models/client_detail_model/client_visit_model.dart';
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
      final visits = _readVisits();
      final invoices = _readInvoices();
      return clients
          .map((client) => _withActivity(client, visits, invoices))
          .toList();
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
          ? 'Client updated successfuly'.tr
          : 'Client added successfuly'.tr);
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
      final client =
          clients.firstWhere((element) => element.id == parameters.clientID);
      return _withActivity(client, _readVisits(), _readInvoices());
    }).checkLogicErrors();
  }

  @override
  Future<void> removeClient(RemoveClientParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await Future.delayed(Duration(seconds: 1));
      final list = LocalPref.sharedPreferences.getStringList('clients') ?? [];
      final clients =
          list.map((e) => ClientDetailModel.fromJson(jsonDecode(e))).toList();

      // Open visits still need this client, so they must be closed first.
      final openVisits = _readVisits()
          .where((visit) =>
              visit.client?.id == parameters.clientID &&
              visit.status != VisitStatus.completed &&
              visit.status != VisitStatus.cancel)
          .length;
      if (openVisits > 0) {
        throw ServerException(ErrorMessageModel(
            statusMessage: 'This client has {0} open visit{1}. Complete or cancel {2} before deleting.'.trArgs([openVisits, openVisits == 1 ? '' : 's', openVisits == 1 ? 'it' : 'them'])));
      }

      clients.removeWhere((element) => element.id == parameters.clientID);
      await LocalPref.sharedPreferences.setStringList(
          'clients', clients.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage('Client removed successfuly'.tr);
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
      AppToasts.showMessage('Equipment added successfuly'.tr);
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
      AppToasts.showMessage('Equipment removed successfuly'.tr);
      return clientModel;
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

  /// History and totals come from the real visits and invoices,
  /// so they are always up to date instead of being stored on the client.
  ClientDetailModel _withActivity(
    ClientDetailModel client,
    List<VisitDetailModel> visits,
    List<InvoiceDetailModel> invoices,
  ) {
    final invoiceOf = {for (final invoice in invoices) invoice.visitId: invoice};
    final own = visits
        .where((visit) => visit.client?.id != null && visit.client?.id == client.id)
        .toList()
      ..sort((a, b) => (b.startDate ?? DateTime(0))
          .compareTo(a.startDate ?? DateTime(0)));

    return client.copyWith(
      visits: own
          .map((visit) =>
              ClientVisitModel.fromVisit(visit, invoice: invoiceOf[visit.id]))
          .toList(),
      ordersCount:
          own.where((visit) => visit.status != VisitStatus.cancel).length,
      totalPaid: own.fold<num>(
          0, (sum, visit) => sum + (invoiceOf[visit.id]?.paidAmount ?? 0)),
      lastVisit: own.where((visit) => visit.startDate != null).firstOrNull?.startDate,
    );
  }
}
