import 'package:either_dart/either.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/general_models/g_model_catg.dart';
import '../../data/models/client_detail_model/client_detail_model.dart';
import '../repository/base_clients_repo.dart';

class AddClientUc extends BaseUseCase<ClientDetailModel, AddClientParameters> {
  final BaseClientsRepo baseClientsRepo;

  AddClientUc(this.baseClientsRepo);

  @override
  Future<Either<Failure, ClientDetailModel>> call(AddClientParameters parameters) async {
    return await baseClientsRepo.addClient(parameters);
  }
}

class AddClientParameters {
  final String? id;
  final String name;
  final String? email;
  final String phoneNumber;
  final bool whatsAppNumber;
  final GModelCatg city;
  final double? latitude;
  final double? longitude;
  final String? addressDetail;
  final String? notes;

  AddClientParameters(
      {this.id,
      required this.name,
      this.email,
      required this.phoneNumber,
      required this.whatsAppNumber,
      required this.city,
      this.latitude,
      this.longitude,
      this.addressDetail,
      this.notes});
}
