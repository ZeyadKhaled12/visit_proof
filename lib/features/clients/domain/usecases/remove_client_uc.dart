import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_clients_repo.dart';

class RemoveClientUc extends BaseUseCase<void, RemoveClientParameters> {
  final BaseClientsRepo baseClientsRepo;

  RemoveClientUc(this.baseClientsRepo);

  @override
  Future<Either<Failure, void>> call(RemoveClientParameters parameters) async {
    return await baseClientsRepo.removeClient(parameters);
  }
}

class RemoveClientParameters {
  final String clientID;
  RemoveClientParameters({required this.clientID});
}
