import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../services/data/models/service_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class ChangeVisitServiceUc
    extends BaseUseCase<VisitDetailModel, ChangeVisitServiceParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  ChangeVisitServiceUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      ChangeVisitServiceParameters parameters) async {
    return await baseVisitDetailRepo.changeVisitService(parameters);
  }
}

class ChangeVisitServiceParameters {
  final String visitID;
  final ServiceModel service;
  const ChangeVisitServiceParameters(
      {required this.visitID, required this.service});
}
