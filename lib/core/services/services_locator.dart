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
import 'package:visit_proof/features/services/data/datasource/services_remote_data_source.dart';
import 'package:visit_proof/features/services/domain/repository/base_services_repo.dart';
import 'package:visit_proof/features/services/domain/usecases/add_service_uc.dart';
import 'package:visit_proof/features/services/domain/usecases/get_categories_uc.dart';
import 'package:visit_proof/features/services/domain/usecases/get_services_uc.dart';
import 'package:visit_proof/features/services/domain/usecases/remove_service_uc.dart';
import 'package:visit_proof/features/services/presentation/controller/services_bloc.dart';
import 'package:visit_proof/features/technicians/data/datasource/technicians_remote_data_source.dart';
import 'package:visit_proof/features/technicians/data/repository/technicians_repo.dart';
import 'package:visit_proof/features/technicians/domain/repository/base_technicians_repo.dart';
import 'package:visit_proof/features/technicians/domain/usecases/add_tech_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_technicians_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/remove_technician_uc.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';

import '../../features/services/data/repository/services_repo.dart';

final sl = GetIt.instance;

class ServicesLocator {
  void init() {
    //Bloc
    sl.registerFactory(() => ClientsBloc(sl(), sl(), sl(), sl(), sl(), sl()));
    sl.registerFactory(() => TechBloc(sl(), sl(), sl(), sl(), sl()));
    sl.registerFactory(() => ServicesBloc(sl(), sl(), sl(), sl()));

    //clients usecases
    sl.registerLazySingleton(() => GetClientsUc(sl()));
    sl.registerLazySingleton(() => AddClientUc(sl()));
    sl.registerLazySingleton(() => GetClientDetailUc(sl()));
    sl.registerLazySingleton(() => RemoveClientUc(sl()));
    sl.registerLazySingleton(() => AddEquipmentUc(sl()));
    sl.registerLazySingleton(() => RemoveEquipmentUc(sl()));

    //technicians usecases
    sl.registerLazySingleton(() => GetTechniciansUc(sl()));
    sl.registerLazySingleton(() => AddTechUc(sl()));
    sl.registerLazySingleton(() => GetTechDetailUc(sl()));
    sl.registerLazySingleton(() => RemoveTechnicianUc(sl()));

    //services usecases
    sl.registerLazySingleton(() => GetServicesUc(sl()));
    sl.registerLazySingleton(() => GetCategoriesUc(sl()));
    sl.registerLazySingleton(() => AddServiceUc(sl()));
    sl.registerLazySingleton(() => RemoveServiceUc(sl()));

    //Repo
    sl.registerLazySingleton<BaseClientsRepo>(() => ClientsRepo(sl()));
    sl.registerLazySingleton<BaseTechniciansRepo>(() => TechniciansRepo(sl()));
    sl.registerLazySingleton<BaseServicesRepo>(() => ServicesRepo(sl()));

    //Data Source
    sl.registerLazySingleton<BaseClientsRemoteDataSource>(
        () => ClientsRemoteDataSource());
    sl.registerLazySingleton<BaseTechniciansRemoteDataSource>(
        () => TechniciansRemoteDataSource());
    sl.registerLazySingleton<BaseServicesRemoteDataSource>(
        () => ServicesRemoteDataSource());
  }
}
