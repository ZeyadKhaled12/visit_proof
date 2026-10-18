import 'package:either_dart/either.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/technicians/domain/repository/base_technicians_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

class GetTechniciansUc
    extends BaseUseCase<List<TechnicianModel>, NoParameters> {
  final BaseTechniciansRepo baseTechniciansRepo;

  GetTechniciansUc(this.baseTechniciansRepo);

  @override
  Future<Either<Failure, List<TechnicianModel>>> call(
      NoParameters parameters) async {
    return await baseTechniciansRepo.getTechnicians(parameters);
  }
}
