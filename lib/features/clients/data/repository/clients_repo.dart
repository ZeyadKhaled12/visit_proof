import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/clients/data/datasource/clients_remote_data_source.dart';
import 'package:visit_proof/features/clients/data/models/client_detail_model/client_detail_model.dart';
import 'package:visit_proof/features/clients/data/models/client_model.dart';
import 'package:visit_proof/features/clients/domain/repository/base_clients_repo.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_client_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_equipment_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_client_detail_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/remove_client_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/remove_equipment_uc.dart';

import '../../../../core/network/error/exception.dart';

class ClientsRepo extends BaseClientsRepo {
  final BaseClientsRemoteDataSource baseClientsRemoteDataSource;

  ClientsRepo(this.baseClientsRemoteDataSource);

  @override
  Future<Either<Failure, List<ClientModel>>> getClients(
      NoParameters parameters) async {
    try {
      final result = await baseClientsRemoteDataSource.getClients(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, void>> addClient(
      AddClientParameters parameters) async {
    try {
      final result = await baseClientsRemoteDataSource.addClient(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, ClientDetailModel>> getClientDetail(
      GetClientDetailParameters parameters) async {
    try {
      final result =
          await baseClientsRemoteDataSource.getClientDetail(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, void>> removeClient(
      RemoveClientParameters parameters) async {
    try {
      final result = await baseClientsRemoteDataSource.removeClient(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, ClientDetailModel>> addEquipment(
      AddEquipmentParameters parameters) async {
    try {
      final result = await baseClientsRemoteDataSource.addEquipment(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, ClientDetailModel>> removeEquipment(
      RemoveEquipmentParameters parameters) async {
    try {
      final result =
          await baseClientsRemoteDataSource.removeEquipment(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
