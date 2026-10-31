import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_visit_detail_repo.dart';

class DeleteVisitUc extends BaseUseCase<void, DeleteVisitParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  DeleteVisitUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, void>> call(DeleteVisitParameters parameters) async {
    return await baseVisitDetailRepo.deleteVisit(parameters);
  }
}

class DeleteVisitParameters {
  final String visitID;
  const DeleteVisitParameters({required this.visitID});
}
