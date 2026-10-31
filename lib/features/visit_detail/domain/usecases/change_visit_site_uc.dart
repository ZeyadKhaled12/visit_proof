import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class ChangeVisitSiteUc
    extends BaseUseCase<VisitDetailModel, ChangeVisitSiteParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  ChangeVisitSiteUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      ChangeVisitSiteParameters parameters) async {
    return await baseVisitDetailRepo.changeVisitSite(parameters);
  }
}

class ChangeVisitSiteParameters {
  final String visitID;
  final GModelSite site;
  const ChangeVisitSiteParameters({required this.visitID, required this.site});
}
