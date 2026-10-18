import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/client_detail_model/client_detail_model.dart';
import '../repository/base_clients_repo.dart';

class GetClientDetailUc
    extends BaseUseCase<ClientDetailModel, GetClientDetailParameters> {
  final BaseClientsRepo baseClientsRepo;

  GetClientDetailUc(this.baseClientsRepo);

  @override
  Future<Either<Failure, ClientDetailModel>> call(
      GetClientDetailParameters parameters) async {
    return await baseClientsRepo.getClientDetail(parameters);
  }
}

class GetClientDetailParameters {
  final String clientID;
  GetClientDetailParameters({required this.clientID});
}
