import 'package:either_dart/either.dart';
import 'package:visit_proof/features/services/domain/repository/base_services_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/service_model.dart';

class RemoveServiceUc
    extends BaseUseCase<List<ServiceModel>, RemoveServiceParameters> {
  final BaseServicesRepo baseServicesRepo;

  RemoveServiceUc(this.baseServicesRepo);

  @override
  Future<Either<Failure, List<ServiceModel>>> call(
      RemoveServiceParameters parameters) async {
    return await baseServicesRepo.removeService(parameters);
  }
}

class RemoveServiceParameters {
  final String serviceID;
  RemoveServiceParameters({required this.serviceID});
}
