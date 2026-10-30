import 'package:either_dart/either.dart';
import 'package:visit_proof/features/add_visit/domain/usecases/add_visit_uc.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

import '../../../../core/network/error/failure.dart';

abstract class BaseAddVisitRepo {
  Future<Either<Failure, VisitDetailModel>> addVisit(
      AddVisitParameters parameters);
}
