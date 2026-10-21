import 'package:either_dart/either.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_services_repo.dart';

class GetCategoriesUc extends BaseUseCase<List<GModelCatg>, NoParameters> {
  final BaseServicesRepo baseServicesRepo;

  GetCategoriesUc(this.baseServicesRepo);

  @override
  Future<Either<Failure, List<GModelCatg>>> call(
      NoParameters parameters) async {
    return await baseServicesRepo.getCategories(parameters);
  }
}
