import 'package:either_dart/either.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/domain/repository/base_visits_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

class GetVisitsUc extends BaseUseCase<List<VisitDetailModel>, NoParameters> {
  final BaseVisitsRepo baseVisitsRepo;

  GetVisitsUc(this.baseVisitsRepo);

  @override
  Future<Either<Failure, List<VisitDetailModel>>> call(
      NoParameters parameters) async {
    return await baseVisitsRepo.getVisits(parameters);
  }
}
