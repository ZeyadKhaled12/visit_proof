import 'package:either_dart/either.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_technicians_repo.dart';

class AddTechUc extends BaseUseCase<void, AddTechParameters> {
  final BaseTechniciansRepo baseTechniciansRepo;

  AddTechUc(this.baseTechniciansRepo);

  @override
  Future<Either<Failure, void>> call(AddTechParameters parameters) async {
    return await baseTechniciansRepo.addTech(parameters);
  }
}

class AddTechParameters {
  final String? id;
  final String name;
  final String phoneNumber;
  final String email;
  final String? password;
  final List<GModelCatg> categories;

  AddTechParameters(
      {this.id,
      required this.name,
      required this.phoneNumber,
      required this.email,
       this.password,
      required this.categories});
}
