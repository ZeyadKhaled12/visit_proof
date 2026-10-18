import 'package:either_dart/either.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/technicians/domain/usecases/add_tech_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/remove_technician_uc.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

abstract class BaseTechniciansRepo {
  Future<Either<Failure, List<TechnicianModel>>> getTechnicians(
      NoParameters parameters);
  Future<Either<Failure, void>> addTech(AddTechParameters parameters);
  Future<Either<Failure, TechnicianDetailModel>> getTechDetail(
      GetTechDetailParameters parameters);
  Future<Either<Failure, void>> removeTechnician(
      RemoveTechnicianParameters parameters);

  // Future<Either<Failure, ClientDetailModel>> addEquipment(
  //     AddEquipmentParameters parameters);
  // Future<Either<Failure, ClientDetailModel>> removeEquipment(
  //     RemoveEquipmentParameters parameters);
}
