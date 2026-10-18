import 'package:either_dart/either.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import '../../../../core/network/error/failure.dart';
import '../../data/models/client_model.dart';
import '../repository/base_clients_repo.dart';

class GetClientsUc extends BaseUseCase<List<ClientModel>, NoParameters> {
  final BaseClientsRepo baseClientsRepo;

  GetClientsUc(this.baseClientsRepo);

  @override
  Future<Either<Failure, List<ClientModel>>> call(
      NoParameters parameters) async {
    return await baseClientsRepo.getClients(parameters);
  }
}
