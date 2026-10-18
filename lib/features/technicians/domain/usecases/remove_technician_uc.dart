import 'package:either_dart/either.dart';
import 'package:visit_proof/features/technicians/domain/repository/base_technicians_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

class RemoveTechnicianUc extends BaseUseCase<void, RemoveTechnicianParameters> {
  final BaseTechniciansRepo baseTechniciansRepo;

  RemoveTechnicianUc(this.baseTechniciansRepo);

  @override
  Future<Either<Failure, void>> call(
      RemoveTechnicianParameters parameters) async {
    return await baseTechniciansRepo.removeTechnician(parameters);
  }
}

class RemoveTechnicianParameters {
  final String techID;
  RemoveTechnicianParameters({required this.techID});
}
