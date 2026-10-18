import 'package:either_dart/either.dart';
import 'package:visit_proof/core/utils/general_models/g_model_equipment.dart';
import 'package:visit_proof/features/clients/data/models/client_detail_model/client_detail_model.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_clients_repo.dart';

class AddEquipmentUc
    extends BaseUseCase<ClientDetailModel, AddEquipmentParameters> {
  final BaseClientsRepo baseClientsRepo;

  AddEquipmentUc(this.baseClientsRepo);

  @override
  Future<Either<Failure, ClientDetailModel>> call(
      AddEquipmentParameters parameters) async {
    return await baseClientsRepo.addEquipment(parameters);
  }
}

class AddEquipmentParameters {
  final String clientID;
  final GModelEquipment equipment;

  AddEquipmentParameters({required this.clientID, required this.equipment});
}
