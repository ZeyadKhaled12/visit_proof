import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/app.dart';
import '../../../../configs/app_toasts.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../domain/rules/visit_rules.dart';

/// Formatting, labels and form validation shared by the visit detail UI.
class VisitDetailHelpers {
  VisitDetailHelpers._();

  // ==========================================================
  // FORMAT
  // ==========================================================

  static String money(num? amount, [String? currency]) =>
      '${(amount ?? 0).toStringAsFixed(2)} ${currency ?? App.currency}';

  static String date(DateTime? value) =>
      value == null ? '—' : DateFormat('dd MMM yyyy').format(value);

  static String time(DateTime? value) =>
      value == null ? '—' : DateFormat('hh:mm a').format(value);

  static String dateTime(DateTime? value) =>
      value == null ? '—' : DateFormat('dd MMM yyyy · hh:mm a').format(value);

  static String duration(int? minutes) {
    if (minutes == null || minutes <= 0) return '—';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return '{0} min'.trArgs([rest]);
    return rest == 0 ? '$hours h' : '{0} h {1} min'.trArgs([hours, rest]);
  }

  static String site(GModelSite? site) {
    final parts = [site?.city?.name, site?.addressDetail]
        .where((e) => (e ?? '').trim().isNotEmpty);
    return parts.isEmpty ? 'No site'.tr : parts.join(' - ');
  }

  static String initial(String? name) =>
      (name ?? '').trim().isEmpty ? '?' : name!.trim()[0].toUpperCase();

  static String capitalize(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

  // ==========================================================
  // STATUS & PRIORITY
  // ==========================================================

  static String statusText(VisitStatus? status) =>
      capitalize(VisitStatusSwitch(visitStatusEnum: status).getText());

  static Color statusColor(VisitStatus? status) =>
      VisitStatusSwitch(visitStatusEnum: status).getColor();

  static Color priorityColor(Priority? priority) =>
      PrioritySwitch(priorityEnum: priority ?? Priority.normal).getColor();

  static String priorityText(Priority? priority) => capitalize(
      PrioritySwitch(priorityEnum: priority ?? Priority.normal).getText());

  static String statusActionLabel(VisitStatus from, VisitStatus to) {
    switch (to) {
      case VisitStatus.draft:
        return from == VisitStatus.cancel ? 'Reopen as draft'.tr : 'Back to draft'.tr;
      case VisitStatus.scheduled:
        return 'Schedule visit'.tr;
      case VisitStatus.assigned:
        return 'Back to assigned'.tr;
      case VisitStatus.onWay:
        return 'Start trip'.tr;
      case VisitStatus.inProgress:
        return 'Start work'.tr;
      case VisitStatus.completed:
        return 'Complete visit'.tr;
      case VisitStatus.cancel:
        return 'Cancel visit'.tr;
    }
  }

  static IconData statusIcon(VisitStatus status) {
    switch (status) {
      case VisitStatus.draft:
        return Icons.edit_note_rounded;
      case VisitStatus.scheduled:
        return Icons.event_available_rounded;
      case VisitStatus.assigned:
        return Icons.engineering_rounded;
      case VisitStatus.onWay:
        return Icons.directions_car_rounded;
      case VisitStatus.inProgress:
        return Icons.handyman_rounded;
      case VisitStatus.completed:
        return Icons.verified_rounded;
      case VisitStatus.cancel:
        return Icons.cancel_rounded;
    }
  }

  static String statusHint(VisitStatus status) {
    switch (status) {
      case VisitStatus.draft:
        return 'Complete the visit info, then schedule it.'.tr;
      case VisitStatus.scheduled:
        return 'Assign a technician to dispatch this visit.'.tr;
      case VisitStatus.assigned:
        return 'Waiting for the technician to start the trip.'.tr;
      case VisitStatus.onWay:
        return 'The technician is heading to the site.'.tr;
      case VisitStatus.inProgress:
        return 'Work is in progress at the site.'.tr;
      case VisitStatus.completed:
        return 'Visit done. Issue the invoice and collect the payment.'.tr;
      case VisitStatus.cancel:
        return 'This visit is cancelled. Reopen it to plan it again.'.tr;
    }
  }

  // ==========================================================
  // VALIDATION
  // ==========================================================

  static String? moneyError(String? text,
      {required num max, bool allowZero = false}) {
    final value = (text ?? '').trim();

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      return 'Enter a valid amount (up to 2 decimals)'.tr;
    }

    final number = double.parse(value);
    if (allowZero ? number < 0 : number <= 0) {
      return allowZero ? 'Amount cannot be negative'.tr : 'Amount must be above zero'.tr;
    }
    if (number > max + 0.001) return 'Maximum allowed: {0}'.trArgs([money(max)]);

    return null;
  }

  static String? reasonError(String? text, {required bool required}) {
    final length = (text ?? '').trim().length;
    if (required && length < VisitRules.minReasonLength) {
      return 'Enter at least {0} characters'.trArgs([VisitRules.minReasonLength]);
    }
    if (length > VisitRules.maxReasonLength) {
      return 'Keep it under {0} characters'.trArgs([VisitRules.maxReasonLength]);
    }
    return null;
  }

  // ==========================================================
  // EXTERNAL APPS
  // ==========================================================

  static Future<void> openDirections(GModelSite site) async {
    try {
      await GFunLaunch.navigateToGoogleMaps(
          latitude: site.latitude!, longitude: site.longitude!);
    } catch (_) {
      AppToasts.showMessage('Could not open Google Maps'.tr, isError: true);
    }
  }
}
