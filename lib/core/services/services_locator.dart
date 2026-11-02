import 'package:get_it/get_it.dart';
import 'package:visit_proof/features/add_visit/data/datasource/add_visit_remote_data_source.dart';
import 'package:visit_proof/features/add_visit/domain/repository/base_add_visit_repo.dart';
import 'package:visit_proof/features/add_visit/domain/usecases/add_visit_uc.dart';
import 'package:visit_proof/features/add_visit/presentation/controller/add_visit_bloc.dart';
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
import 'package:visit_proof/features/invoices/data/data_sources/invoices_remote_data_source.dart';
import 'package:visit_proof/features/invoices/data/repository/invoices_repo.dart';
import 'package:visit_proof/features/invoices/domain/repository/base_invoices_repo.dart';
import 'package:visit_proof/features/invoices/presentation/controller/invoices_bloc.dart';
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
import 'package:visit_proof/features/visit_detail/domain/usecases/change_visit_status_uc.dart';
import 'package:visit_proof/features/visits/data/datasource/visits_remote_data_source.dart';
import 'package:visit_proof/features/visits/data/repository/visits_repo.dart';
import 'package:visit_proof/features/visits/domain/repository/base_visits_repo.dart';
import 'package:visit_proof/features/visits/presentation/controller/visits_bloc.dart';

import '../../features/add_visit/data/repository/add_visit_repo.dart';
import '../../features/auth/data/datasource/auth_remote_data_source.dart';
import '../../features/auth/data/repository/auth_repo.dart';
import '../../features/auth/domain/repository/base_auth_repo.dart';
import '../../features/auth/domain/usecases/enter_as_admin_uc.dart';
import '../../features/auth/domain/usecases/login_technician_uc.dart';
import '../../features/auth/domain/usecases/logout_uc.dart';
import '../../features/auth/domain/usecases/restore_session_uc.dart';
import '../../features/auth/presentation/controller/auth_bloc.dart';
import '../../features/dashboard/data/datasource/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repository/dashboard_repo.dart';
import '../../features/dashboard/domain/repository/base_dashboard_repo.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_snapshot_uc.dart';
import '../../features/dashboard/presentation/controller/dashboard_bloc.dart';
import '../../features/dispatch/data/datasource/dispatch_remote_data_source.dart';
import '../../features/dispatch/data/repository/dispatch_repo.dart';
import '../../features/dispatch/domain/repository/base_dispatch_repo.dart';
import '../../features/dispatch/domain/usecases/get_dispatch_settings_uc.dart';
import '../../features/dispatch/domain/usecases/get_technician_days_off_uc.dart';
import '../../features/dispatch/domain/usecases/save_dispatch_settings_uc.dart';
import '../../features/dispatch/domain/usecases/set_technician_day_off_uc.dart';
import '../../features/dispatch/presentation/controller/dispatch_bloc.dart';
import '../../features/invoices/domain/usecases/get_create_invoice_uc.dart';
import '../../features/invoices/domain/usecases/get_invoice_detail_uc.dart';
import '../../features/invoices/domain/usecases/get_invoices_uc.dart';
import '../../features/invoices/domain/usecases/get_payments_uc.dart';
import '../../features/invoices/domain/usecases/issue_invoice_uc.dart';
import '../../features/invoices/domain/usecases/record_payment_uc.dart';
import '../../features/invoices/domain/usecases/refund_payment_uc.dart';
import '../../features/invoices/domain/usecases/review_payment_uc.dart';
import '../../features/invoices/domain/usecases/update_draft_invoice_uc.dart';
import '../../features/services/data/repository/services_repo.dart';
import '../../features/visit_detail/data/datasource/visit_detail_remote_data_source.dart';
import '../../features/visit_detail/data/repository/visit_detail_repo.dart';
import '../../features/visit_detail/domain/repository/base_visit_detail_repo.dart';
import '../../features/visit_detail/domain/usecases/add_visit_comment_uc.dart';
import '../../features/visit_detail/domain/usecases/assign_technician_uc.dart';
import '../../features/visit_detail/domain/usecases/change_visit_service_uc.dart';
import '../../features/visit_detail/domain/usecases/change_visit_site_uc.dart';
import '../../features/visit_detail/domain/usecases/delete_visit_uc.dart';
import '../../features/visit_detail/domain/usecases/get_visit_detail_uc.dart';
import '../../features/visit_detail/domain/usecases/reschedule_visit_uc.dart';
import '../../features/visit_detail/domain/usecases/unassign_technician_uc.dart';
import '../../features/visit_detail/domain/usecases/update_visit_info_uc.dart';
import '../../features/visit_detail/presentation/controller/visit_detail_bloc.dart';
import '../../features/visits/domain/usecases/get_visits_uc.dart';

final sl = GetIt.instance;

class ServicesLocator {
  void init() {
    //Bloc
    sl.registerFactory(() => ClientsBloc(sl(), sl(), sl(), sl(), sl(), sl()));
    sl.registerFactory(() => TechBloc(sl(), sl(), sl(), sl(), sl()));
    sl.registerFactory(() => ServicesBloc(sl(), sl(), sl(), sl()));
    sl.registerFactory(() => AddVisitBloc(sl(), sl(), sl(), sl()));
    sl.registerFactory(() => VisitsBloc(sl()));
    sl.registerFactory(
        () => InvoicesBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));
    sl.registerFactory(() => VisitDetailBloc(sl(), sl(), sl(), sl(), sl(), sl(),
        sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));

    sl.registerFactory(() => DispatchBloc(
        sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));

    sl.registerFactory(() => DashboardBloc(sl()));

    sl.registerFactory(() => AuthBloc(sl(), sl(), sl()));

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

    //add visit
    sl.registerLazySingleton(() => AddVisitUc(sl()));

    //visits
    sl.registerLazySingleton(() => GetVisitsUc(sl()));

    //invoices
    sl.registerLazySingleton(() => GetInvoicesUc(sl()));
    sl.registerLazySingleton(() => GetCreateInvoiceUc(sl()));
    sl.registerLazySingleton(() => GetInvoiceDetailUc(sl()));
    sl.registerLazySingleton(() => IssueInvoiceUc(sl()));
    sl.registerLazySingleton(() => RecordPaymentUc(sl()));
    sl.registerLazySingleton(() => RefundPaymentUc(sl()));
    sl.registerLazySingleton(() => UpdateDraftInvoiceUc(sl()));
    sl.registerLazySingleton(() => ReviewPaymentUc(sl()));
    sl.registerLazySingleton(() => GetPaymentsUc(sl()));

    //visit detail usecases
    sl.registerLazySingleton(() => GetVisitDetailUc(sl()));
    sl.registerLazySingleton(() => ChangeVisitStatusUc(sl()));
    sl.registerLazySingleton(() => AssignTechnicianUc(sl()));
    sl.registerLazySingleton(() => UnassignTechnicianUc(sl()));
    sl.registerLazySingleton(() => RescheduleVisitUc(sl()));
    sl.registerLazySingleton(() => UpdateVisitInfoUc(sl()));
    sl.registerLazySingleton(() => ChangeVisitServiceUc(sl()));
    sl.registerLazySingleton(() => ChangeVisitSiteUc(sl()));
    sl.registerLazySingleton(() => AddVisitCommentUc(sl()));
    sl.registerLazySingleton(() => DeleteVisitUc(sl()));

    //dashboard usecases
    sl.registerLazySingleton(() => GetDashboardSnapshotUc(sl()));

    //auth usecases
    sl.registerLazySingleton(() => LoginTechnicianUc(sl()));
    sl.registerLazySingleton(() => EnterAsAdminUc(sl()));
    sl.registerLazySingleton(() => LogoutUc(sl()));
    sl.registerLazySingleton(() => RestoreSessionUc(sl()));

    //dispatch usecases
    sl.registerLazySingleton(() => GetDispatchSettingsUc(sl()));
    sl.registerLazySingleton(() => SaveDispatchSettingsUc(sl()));
    sl.registerLazySingleton(() => GetTechnicianDaysOffUc(sl()));
    sl.registerLazySingleton(() => SetTechnicianDayOffUc(sl()));

    //Repo
    sl.registerLazySingleton<BaseClientsRepo>(() => ClientsRepo(sl()));
    sl.registerLazySingleton<BaseTechniciansRepo>(() => TechniciansRepo(sl()));
    sl.registerLazySingleton<BaseServicesRepo>(() => ServicesRepo(sl()));
    sl.registerLazySingleton<BaseAddVisitRepo>(() => AddVisitRepo(sl()));
    sl.registerLazySingleton<BaseVisitsRepo>(() => VisitsRepo(sl()));
    sl.registerLazySingleton<BaseInvoicesRepo>(() => InvoicesRepo(sl()));
    sl.registerLazySingleton<BaseVisitDetailRepo>(
        () => VisitDetailRepo(sl()));

    sl.registerLazySingleton<BaseDispatchRepo>(() => DispatchRepo(sl()));
    sl.registerLazySingleton<BaseDashboardRepo>(() => DashboardRepo(sl()));
    sl.registerLazySingleton<BaseAuthRepo>(() => AuthRepo(sl()));

    //Data Source
    sl.registerLazySingleton<BaseDispatchRemoteDataSource>(
        () => DispatchRemoteDataSource());
    sl.registerLazySingleton<BaseDashboardRemoteDataSource>(
        () => DashboardRemoteDataSource());
    sl.registerLazySingleton<BaseClientsRemoteDataSource>(
        () => ClientsRemoteDataSource());
    sl.registerLazySingleton<BaseTechniciansRemoteDataSource>(
        () => TechniciansRemoteDataSource());
    sl.registerLazySingleton<BaseServicesRemoteDataSource>(
        () => ServicesRemoteDataSource());
    sl.registerLazySingleton<BaseAddVisitRemoteDataSource>(
        () => AddVisitRemoteDataSource());
    sl.registerLazySingleton<BaseVisitsRemoteDataSource>(
        () => VisitsRemoteDataSource());
    sl.registerLazySingleton<BaseInvoicesRemoteDataSource>(
        () => InvoicesRemoteDataSource());
    sl.registerLazySingleton<BaseVisitDetailRemoteDataSource>(
        () => VisitDetailRemoteDataSource());
    sl.registerLazySingleton<BaseAuthRemoteDataSource>(
        () => AuthRemoteDataSource());
  }
}
