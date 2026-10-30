import 'package:either_dart/either.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/domain/repository/base_services_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/service_model.dart';

class AddServiceUc extends BaseUseCase<ServiceModel, AddServiceParameters> {
  final BaseServicesRepo baseServicesRepo;

  AddServiceUc(this.baseServicesRepo);

  @override
  Future<Either<Failure, ServiceModel>> call(
      AddServiceParameters parameters) async {
    return await baseServicesRepo.addService(parameters);
  }
}

class AddServiceParameters {
  final String? id;
  final GModelCatg? category;
  final String? categoryName;
  final String serviceName;
  final num price;
  final int duration;
  final List<String> checkList;
  final bool blockSetLocal;

  AddServiceParameters({
    this.id,
    this.category,
    this.categoryName,
    this.blockSetLocal = false,
    required this.serviceName,
    required this.price,
    required this.duration,
    required this.checkList,
  });
}
