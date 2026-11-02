import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_models/g_model_geo_point.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class ChangeVisitStatusUc
    extends BaseUseCase<VisitDetailModel, ChangeVisitStatusParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  ChangeVisitStatusUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      ChangeVisitStatusParameters parameters) async {
    return await baseVisitDetailRepo.changeVisitStatus(parameters);
  }
}

class ChangeVisitStatusParameters {
  final String visitID;
  final VisitStatus status;
  final String? reason;

  /// The technician's live location; required when a technician acts.
  final GModelGeoPoint? location;

  /// Temporary paths of the proof photos taken for this step.
  final List<String> photoPaths;
  const ChangeVisitStatusParameters(
      {required this.visitID,
      required this.status,
      this.reason,
      this.location,
      this.photoPaths = const []});
}
