import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_add_visit_repo.dart';

class AddVisitUc extends BaseUseCase<VisitDetailModel, AddVisitParameters> {
  final BaseAddVisitRepo baseAddVisitRepo;

  AddVisitUc(this.baseAddVisitRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      AddVisitParameters parameters) async {
    return await baseAddVisitRepo.addVisit(parameters);
  }
}

class AddVisitParameters {
  final VisitDetailModel visitDetailModel;
  AddVisitParameters({required this.visitDetailModel});
}
