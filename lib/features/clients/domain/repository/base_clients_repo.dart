import 'package:either_dart/either.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_equipment_uc.dart';
import '../../../../core/network/error/failure.dart';
import '../../data/models/client_detail_model/client_detail_model.dart';
import '../usecases/add_client_uc.dart';
import '../usecases/get_client_detail_uc.dart';
import '../usecases/remove_client_uc.dart';
import '../usecases/remove_equipment_uc.dart';

abstract class BaseClientsRepo {
  Future<Either<Failure, List<ClientDetailModel>>> getClients(
      NoParameters parameters);
  Future<Either<Failure, ClientDetailModel>> addClient(
      AddClientParameters parameters);
  Future<Either<Failure, void>> removeClient(RemoveClientParameters parameters);
  Future<Either<Failure, ClientDetailModel>> getClientDetail(
      GetClientDetailParameters parameters);
  Future<Either<Failure, ClientDetailModel>> addEquipment(
      AddEquipmentParameters parameters);
  Future<Either<Failure, ClientDetailModel>> removeEquipment(
      RemoveEquipmentParameters parameters);
}
