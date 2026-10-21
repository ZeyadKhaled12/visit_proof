import 'package:either_dart/either.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/services/domain/repository/base_services_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

class GetServicesUc extends BaseUseCase<List<ServiceModel>, NoParameters> {
  final BaseServicesRepo baseServicesRepo;

  GetServicesUc(this.baseServicesRepo);

  @override
  Future<Either<Failure, List<ServiceModel>>> call(
      NoParameters parameters) async {
    return await baseServicesRepo.getServices(parameters);
  }
}
