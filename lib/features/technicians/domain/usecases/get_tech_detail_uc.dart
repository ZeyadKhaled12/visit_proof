import 'package:either_dart/either.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/domain/repository/base_technicians_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

class GetTechDetailUc
    extends BaseUseCase<TechnicianDetailModel, GetTechDetailParameters> {
  final BaseTechniciansRepo baseTechniciansRepo;

  GetTechDetailUc(this.baseTechniciansRepo);

  @override
  Future<Either<Failure, TechnicianDetailModel>> call(
      GetTechDetailParameters parameters) async {
    return await baseTechniciansRepo.getTechDetail(parameters);
  }
}

class GetTechDetailParameters {
  final String techID;
  GetTechDetailParameters({required this.techID});
}
