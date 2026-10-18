import 'package:get_it/get_it.dart';
import 'package:visit_proof/features/clients/data/datasource/clients_remote_data_source.dart';
import 'package:visit_proof/features/clients/data/repository/clients_repo.dart';
import 'package:visit_proof/features/clients/domain/repository/base_clients_repo.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_client_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_equipment_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_client_detail_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_clients_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/remove_client_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/remove_equipment_uc.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';
import 'package:visit_proof/features/technicians/data/datasource/technicians_remote_data_source.dart';
import 'package:visit_proof/features/technicians/data/repository/technicians_repo.dart';
import 'package:visit_proof/features/technicians/domain/repository/base_technicians_repo.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_technicians_uc.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';

final sl = GetIt.instance;

class ServicesLocator {
  void init() {
    //Bloc
    sl.registerFactory(() => ClientsBloc(sl(), sl(), sl(), sl(), sl(), sl()));
    sl.registerFactory(() => TechBloc(sl()));

    //clients usecases
    sl.registerLazySingleton(() => GetClientsUc(sl()));
    sl.registerLazySingleton(() => AddClientUc(sl()));
    sl.registerLazySingleton(() => GetClientDetailUc(sl()));
    sl.registerLazySingleton(() => RemoveClientUc(sl()));
    sl.registerLazySingleton(() => AddEquipmentUc(sl()));
    sl.registerLazySingleton(() => RemoveEquipmentUc(sl()));

    //technicians usecases
    sl.registerLazySingleton(() => GetTechniciansUc(sl()));

    //Repo
    sl.registerLazySingleton<BaseClientsRepo>(() => ClientsRepo(sl()));
    sl.registerLazySingleton<BaseTechniciansRepo>(() => TechniciansRepo(sl()));

    //Data Source
    sl.registerLazySingleton<BaseClientsRemoteDataSource>(
        () => ClientsRemoteDataSource());
    sl.registerLazySingleton<BaseTechniciansRemoteDataSource>(
        () => TechniciansRemoteDataSource());
  }
}
