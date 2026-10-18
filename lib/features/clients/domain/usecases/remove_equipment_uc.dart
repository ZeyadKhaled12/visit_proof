import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/client_detail_model/client_detail_model.dart';
import '../repository/base_clients_repo.dart';

class RemoveEquipmentUc
    extends BaseUseCase<ClientDetailModel, RemoveEquipmentParameters> {
  final BaseClientsRepo baseClientsRepo;
  RemoveEquipmentUc(this.baseClientsRepo);
  @override
  Future<Either<Failure, ClientDetailModel>> call(
      RemoveEquipmentParameters parameters) async {
    return await baseClientsRepo.removeEquipment(parameters);
  }
}

class RemoveEquipmentParameters {
  final String clientID;
  final String equipmentID;

  RemoveEquipmentParameters(
      {required this.clientID, required this.equipmentID});
}
