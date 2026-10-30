import 'package:either_dart/either.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

abstract class BaseVisitsRepo {
  Future<Either<Failure, List<VisitDetailModel>>> getVisits(
      NoParameters parameters);
}
