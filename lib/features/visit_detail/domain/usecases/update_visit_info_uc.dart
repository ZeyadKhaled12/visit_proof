import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class UpdateVisitInfoUc
    extends BaseUseCase<VisitDetailModel, UpdateVisitInfoParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  UpdateVisitInfoUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      UpdateVisitInfoParameters parameters) async {
    return await baseVisitDetailRepo.updateVisitInfo(parameters);
  }
}

class UpdateVisitInfoParameters {
  final String visitID;
  final Priority priority;
  final String problemDescription;
  final String notes;
  final bool requireBeforeWorkPhotos;
  final bool requireAfterWorkPhotos;
  const UpdateVisitInfoParameters({
    required this.visitID,
    required this.priority,
    required this.problemDescription,
    required this.notes,
    required this.requireBeforeWorkPhotos,
    required this.requireAfterWorkPhotos,
  });
}
