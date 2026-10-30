import 'package:either_dart/either.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/services/domain/usecases/remove_service_uc.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../usecases/add_service_uc.dart';

abstract class BaseServicesRepo {
  Future<Either<Failure, List<ServiceModel>>> getServices(
      NoParameters parameters);
  Future<Either<Failure, List<GModelCatg>>> getCategories(
      NoParameters parameters);
  Future<Either<Failure, ServiceModel>> addService(AddServiceParameters parameters);
  Future<Either<Failure, List<ServiceModel>>> removeService(
      RemoveServiceParameters parameters);
  // Future<Either<Failure, void>> addClient(AddClientParameters parameters);
  // Future<Either<Failure, void>> removeClient(RemoveClientParameters parameters);
  // Future<Either<Failure, ClientDetailModel>> getClientDetail(
  //     GetClientDetailParameters parameters);
  // Future<Either<Failure, ClientDetailModel>> addEquipment(
  //     AddEquipmentParameters parameters);
  // Future<Either<Failure, ClientDetailModel>> removeEquipment(
  //     RemoveEquipmentParameters parameters);
}
