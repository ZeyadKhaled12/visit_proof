import 'package:visit_proof/configs/app_language.dart';
import 'dart:convert';

import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/error_message_model.dart';
import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../domain/usecases/save_dispatch_settings_uc.dart';
import '../../domain/usecases/set_technician_day_off_uc.dart';
import '../models/dispatch_settings_model.dart';
import '../models/technician_day_off_model.dart';

abstract class BaseDispatchRemoteDataSource {
  Future<DispatchSettingsModel> getDispatchSettings(NoParameters parameters);
  Future<DispatchSettingsModel> saveDispatchSettings(
      SaveDispatchSettingsParameters parameters);
  Future<List<TechnicianDayOffModel>> getTechnicianDaysOff(
      NoParameters parameters);
  Future<List<TechnicianDayOffModel>> setTechnicianDayOff(
      SetTechnicianDayOffParameters parameters);
}

class DispatchRemoteDataSource extends BaseDispatchRemoteDataSource {
  static const String _settingsKey = 'dispatch_settings';
  static const String _daysOffKey = 'technician_days_off';
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<DispatchSettingsModel> getDispatchSettings(
      NoParameters parameters) async {
    return await HandleLogicErrors<DispatchSettingsModel>(fun: () async {
      await Future.delayed(_latency);
      final stored = LocalPref.sharedPreferences.getString(_settingsKey);
      if (stored == null) return DispatchSettingsModel.defaults;
      return DispatchSettingsModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(stored) as Map));
    }).checkLogicErrors();
  }

  @override
  Future<DispatchSettingsModel> saveDispatchSettings(
      SaveDispatchSettingsParameters parameters) async {
    return await HandleLogicErrors<DispatchSettingsModel>(fun: () async {
      await Future.delayed(_latency);
      final settings = parameters.settings;

      if (settings.workEnd <= settings.workStart) {
        _fail('The working day must end after it starts.'.tr);
      }
      if (settings.maxVisits < 1 || settings.maxVisits > 30) {
        _fail('Daily visits must be between 1 and 30.'.tr);
      }
      if (settings.travelBuffer < 0 || settings.travelBuffer > 240) {
        _fail('Travel time must be between 0 and 240 minutes.'.tr);
      }

      await LocalPref.sharedPreferences
          .setString(_settingsKey, jsonEncode(settings.toJson()));
      AppToasts.showMessage('Dispatch rules saved'.tr);
      return settings;
    }).checkLogicErrors();
  }

  @override
  Future<List<TechnicianDayOffModel>> getTechnicianDaysOff(
      NoParameters parameters) async {
    return await HandleLogicErrors<List<TechnicianDayOffModel>>(fun: () async {
      await Future.delayed(_latency);
      return _readDaysOff();
    }).checkLogicErrors();
  }

  @override
  Future<List<TechnicianDayOffModel>> setTechnicianDayOff(
      SetTechnicianDayOffParameters parameters) async {
    return await HandleLogicErrors<List<TechnicianDayOffModel>>(fun: () async {
      await Future.delayed(_latency);
      final day = DateTime(
          parameters.date.year, parameters.date.month, parameters.date.day);

      final daysOff = _readDaysOff()
        ..removeWhere((e) => e.covers(parameters.technicianID, day));
      if (parameters.isOff) {
        daysOff.add(
            TechnicianDayOffModel(technicianId: parameters.technicianID, date: day));
      }

      await LocalPref.sharedPreferences.setStringList(
          _daysOffKey, daysOff.map((e) => jsonEncode(e.toJson())).toList());
      AppToasts.showMessage(parameters.isOff
          ? 'Technician marked as off for this day'.tr
          : 'Technician is available again'.tr);
      return daysOff;
    }).checkLogicErrors();
  }

  List<TechnicianDayOffModel> _readDaysOff() =>
      (LocalPref.sharedPreferences.getStringList(_daysOffKey) ?? [])
          .map((e) => TechnicianDayOffModel.fromJson(
              Map<String, dynamic>.from(jsonDecode(e) as Map)))
          .toList();

  Never _fail(String message) =>
      throw ServerException(ErrorMessageModel(statusMessage: message));
}
