import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class AddVisitCommentUc
    extends BaseUseCase<VisitDetailModel, AddVisitCommentParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  AddVisitCommentUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      AddVisitCommentParameters parameters) async {
    return await baseVisitDetailRepo.addVisitComment(parameters);
  }
}

class AddVisitCommentParameters {
  final String visitID;
  final String comment;
  const AddVisitCommentParameters(
      {required this.visitID, required this.comment});
}
