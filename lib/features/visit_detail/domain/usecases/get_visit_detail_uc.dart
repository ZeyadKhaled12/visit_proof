import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class GetVisitDetailUc
    extends BaseUseCase<VisitDetailModel, GetVisitDetailParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  GetVisitDetailUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      GetVisitDetailParameters parameters) async {
    return await baseVisitDetailRepo.getVisitDetail(parameters);
  }
}

class GetVisitDetailParameters {
  final String visitID;
  const GetVisitDetailParameters({required this.visitID});
}
