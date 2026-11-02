import 'package:visit_proof/configs/app_language.dart';
import 'dart:convert';

import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/error_message_model.dart';
import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/app_role_enum.dart';
import '../../../technicians/data/models/technician_detail_model.dart';
import '../../domain/usecases/login_technician_uc.dart';

abstract class BaseAuthRemoteDataSource {
  Future<AppSessionModel> loginTechnician(
      LoginTechnicianParameters parameters);
  Future<AppSessionModel> enterAsAdmin(NoParameters parameters);
  Future<void> logout(NoParameters parameters);
  Future<AppSessionModel?> restoreSession(NoParameters parameters);
}

/// Local prototype: technicians sign in with the email and password the
/// admin gave them; the admin needs no account. The session is saved under
/// [AppSession.storageKey] so the app reopens as the same user.
class AuthRemoteDataSource extends BaseAuthRemoteDataSource {
  static const Duration _latency = Duration(milliseconds: 600);

  @override
  Future<AppSessionModel> loginTechnician(
      LoginTechnicianParameters parameters) async {
    return await HandleLogicErrors<AppSessionModel>(fun: () async {
      await Future.delayed(_latency);

      final email = parameters.email.trim().toLowerCase();
      final technician = _readTechnicians()
          .where((e) => (e.email ?? '').trim().toLowerCase() == email)
          .firstOrNull;

      if (technician == null || technician.password != parameters.password) {
        _fail('Wrong email or password.'.tr);
      }

      final session = AppSessionModel(
        role: AppRole.technician,
        technicianId: technician.id,
        technicianName: technician.name,
        technicianEmail: technician.email,
      );
      await _start(session);
      AppToasts.showMessage('Welcome, {0}'.trArgs([technician.name ?? '']));
      return session;
    }).checkLogicErrors();
  }

  @override
  Future<AppSessionModel> enterAsAdmin(NoParameters parameters) async {
    return await HandleLogicErrors<AppSessionModel>(fun: () async {
      const session = AppSessionModel(role: AppRole.admin);
      await _start(session);
      return session;
    }).checkLogicErrors();
  }

  @override
  Future<void> logout(NoParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await LocalPref.sharedPreferences.remove(AppSession.storageKey);
      AppSession.current.value = null;
    }).checkLogicErrors();
  }

  /// Reopens the saved session. A technician who was removed meanwhile is
  /// signed out; name and email are refreshed in case the admin changed them.
  @override
  Future<AppSessionModel?> restoreSession(NoParameters parameters) async {
    return await HandleLogicErrors<AppSessionModel?>(fun: () async {
      final saved =
          LocalPref.sharedPreferences.getString(AppSession.storageKey);
      AppSessionModel? session = saved == null
          ? null
          : AppSessionModel.fromJson(
              Map<String, dynamic>.from(jsonDecode(saved) as Map));

      if (session?.role == AppRole.technician) {
        final technician = _readTechnicians()
            .where((e) => e.id != null && e.id == session!.technicianId)
            .firstOrNull;
        session = technician == null
            ? null
            : AppSessionModel(
                role: AppRole.technician,
                technicianId: technician.id,
                technicianName: technician.name,
                technicianEmail: technician.email,
              );
      }

      if (session?.role == null) {
        await LocalPref.sharedPreferences.remove(AppSession.storageKey);
        AppSession.current.value = null;
        return null;
      }

      await _start(session!);
      return session;
    }).checkLogicErrors();
  }

  Future<void> _start(AppSessionModel session) async {
    final saved = await LocalPref.sharedPreferences
        .setString(AppSession.storageKey, jsonEncode(session.toJson()));
    if (!saved) _fail('Could not save the session on this device.'.tr);
    AppSession.current.value = session;
  }

  List<TechnicianDetailModel> _readTechnicians() =>
      (LocalPref.sharedPreferences.getStringList('technicians') ?? [])
          .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
          .toList();

  Never _fail(String message) =>
      throw ServerException(ErrorMessageModel(statusMessage: message));
}
