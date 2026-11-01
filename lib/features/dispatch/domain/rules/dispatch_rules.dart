import 'package:visit_proof/configs/app_language.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../data/models/dispatch_settings_model.dart';
import '../../data/models/technician_day_off_model.dart';

/// Blocking rules stop the action. Warnings need a reason to continue.
enum DispatchSeverity { block, warn }

class DispatchViolation {
  final String message;
  final DispatchSeverity severity;

  const DispatchViolation.block(this.message)
      : severity = DispatchSeverity.block;
  const DispatchViolation.warn(this.message) : severity = DispatchSeverity.warn;

  bool get blocks => severity == DispatchSeverity.block;
}

/// A ranked technician for a visit, with the time and why it was ranked.
class TechnicianSuggestion {
  final TechnicianModel technician;
  final DateTime? start;
  final int score;
  final List<String> reasons;
  final List<DispatchViolation> violations;

  const TechnicianSuggestion({
    required this.technician,
    required this.start,
    required this.score,
    required this.reasons,
    required this.violations,
  });

  bool get eligible => start != null && !violations.any((e) => e.blocks);
}

/// One visit of a batch plan: who takes it and when, or why nobody can.
class PlannedAssignment {
  final VisitDetailModel visit;
  final TechnicianModel? technician;
  final DateTime? start;
  final List<DispatchViolation> warnings;
  final String? problem;

  const PlannedAssignment({
    required this.visit,
    this.technician,
    this.start,
    this.warnings = const [],
    this.problem,
  });

  bool get ok => technician != null && start != null;
}

/// Dispatch planning rules. Visit-level rules (status workflow, complete
/// data, double booking) come from [VisitRules] and are enforced again by
/// the visit data source when the change is saved.
class DispatchRules {
  DispatchRules._();

  static const int _slotStepMinutes = 15;
  static final DateFormat _time = DateFormat('hh:mm a');

  // ==========================================================
  // DAY HELPERS
  // ==========================================================

  static DateTime dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Calendar arithmetic: adding 24 hours breaks on daylight-saving days
  /// (a 25-hour day would give the same date twice).
  static DateTime addDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  /// [day] at [minutes] after midnight, on the wall clock.
  static DateTime atMinutes(DateTime day, int minutes) =>
      DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);

  static bool sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime endOf(VisitDetailModel visit) =>
      visit.startDate!.add(Duration(minutes: visit.durationInMin ?? 0));

  static int priorityRank(Priority? priority) {
    switch (priority ?? Priority.normal) {
      case Priority.emergency:
        return 0;
      case Priority.high:
        return 1;
      case Priority.normal:
        return 2;
      case Priority.low:
        return 3;
    }
  }

  // ==========================================================
  // BOARD DATA
  // ==========================================================

  /// Open visits without a technician: most urgent first, then earliest.
  static List<VisitDetailModel> unassigned(List<VisitDetailModel> visits) =>
      visits
          .where((v) => v.technicianModel == null && !VisitRules.isClosed(v))
          .toList()
        ..sort((a, b) {
          final byPriority =
              priorityRank(a.priority).compareTo(priorityRank(b.priority));
          if (byPriority != 0) return byPriority;
          return (a.startDate ?? DateTime(9999))
              .compareTo(b.startDate ?? DateTime(9999));
        });

  /// Everything a technician has on [day], except cancelled visits.
  static List<VisitDetailModel> technicianDay(
    List<VisitDetailModel> visits,
    String? technicianID,
    DateTime day,
  ) =>
      visits
          .where((v) =>
              v.technicianModel?.id == technicianID &&
              v.status != VisitStatus.cancel &&
              sameDay(v.startDate, day))
          .toList()
        ..sort((a, b) => a.startDate!.compareTo(b.startDate!));

  static bool isDayOff(
    List<TechnicianDayOffModel> daysOff,
    String? technicianID,
    DateTime day,
  ) =>
      daysOff.any((e) => e.covers(technicianID, day));

  /// Planned but not started although the start time has passed.
  static bool isLate(VisitDetailModel visit, DateTime now) {
    final status = VisitRules.statusOf(visit);
    return (status == VisitStatus.scheduled ||
            status == VisitStatus.assigned) &&
        visit.startDate != null &&
        visit.startDate!.isBefore(now);
  }

  /// Why [visit] cannot move to [to], using the payment status the visit
  /// keeps in sync with its invoice (the board does not load invoices).
  static String? statusError(VisitDetailModel visit, VisitStatus to) {
    final paid = visit.paymentStatus == PaymentStatus.paid ||
        visit.paymentStatus == PaymentStatus.partiallyPaid;
    if (to == VisitStatus.cancel && paid) {
      return 'Refund all payments from the invoice before cancelling.'.tr;
    }
    return VisitRules.statusChangeError(visit, null, to);
  }

  static int bookedMinutes(List<VisitDetailModel> technicianDay) =>
      technicianDay.fold(0, (sum, v) => sum + (v.durationInMin ?? 0));

  /// Visits on [day] that break a blocking rule, e.g. after a day off was set.
  static List<VisitDetailModel> conflicts({
    required List<VisitDetailModel> visits,
    required List<TechnicianDayOffModel> daysOff,
    required DateTime day,
  }) {
    final planned = visits.where((v) =>
        v.technicianModel != null &&
        VisitRules.occupiesTechnician(v.status) &&
        sameDay(v.startDate, day));

    return planned.where((visit) {
      final technicianID = visit.technicianModel!.id;
      if (isDayOff(daysOff, technicianID, day)) return true;
      return planned.any((other) =>
          other.id != visit.id &&
          other.technicianModel!.id == technicianID &&
          _overlaps(visit.startDate!, endOf(visit), other.startDate!,
              endOf(other)));
    }).toList();
  }

  // ==========================================================
  // SLOTS
  // ==========================================================

  /// Earliest start on [day] that fits [durationInMin] plus the travel
  /// buffer between the technician's busy visits, or null if the day is full.
  static DateTime? firstFreeSlot({
    required List<VisitDetailModel> busy,
    required DateTime day,
    required int durationInMin,
    required DispatchSettingsModel settings,
    required DateTime now,
  }) {
    final workEnd = atMinutes(day, settings.workEnd);
    var candidate = atMinutes(day, settings.workStart);
    if (candidate.isBefore(now)) candidate = _roundUp(now);

    final booked = busy.where((v) => v.startDate != null).toList()
      ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
    final buffer = Duration(minutes: settings.travelBuffer);
    final duration = Duration(minutes: durationInMin);

    for (final visit in booked) {
      final fitsBefore =
          !candidate.add(duration).add(buffer).isAfter(visit.startDate!);
      if (fitsBefore) break;
      final afterVisit = endOf(visit).add(buffer);
      if (afterVisit.isAfter(candidate)) candidate = _roundUp(afterVisit);
    }

    return candidate.add(duration).isAfter(workEnd) ? null : candidate;
  }

  // ==========================================================
  // ASSIGNMENT CHECKS
  // ==========================================================

  /// Every rule [technician] would break by taking [visit] at [start].
  static List<DispatchViolation> evaluate({
    required VisitDetailModel visit,
    required TechnicianModel technician,
    required DateTime start,
    required List<VisitDetailModel> allVisits,
    required DispatchSettingsModel settings,
    required List<TechnicianDayOffModel> daysOff,
    required DateTime now,
  }) {
    final planned = visit.copyWith(startDate: start);
    final end = endOf(planned);
    final day = dayOf(start);
    final name = technician.name ?? 'This technician'.tr;
    final violations = <DispatchViolation>[];

    final visitError = VisitRules.assignError(planned);
    if (visitError != null) violations.add(DispatchViolation.block(visitError));

    if (start.isBefore(now)) {
      violations.add(DispatchViolation.block(
          'The start time has already passed.'.tr));
    }

    if (isDayOff(daysOff, technician.id, day)) {
      violations.add(DispatchViolation.block('{0} is off on this day.'.trArgs([name])));
    }

    final others = technicianDay(allVisits, technician.id, day)
        .where((v) =>
            v.id != visit.id && VisitRules.occupiesTechnician(v.status))
        .toList();

    for (final other in others) {
      final otherEnd = endOf(other);
      if (_overlaps(start, end, other.startDate!, otherEnd)) {
        violations.add(DispatchViolation.block(
            '{0} is busy with {1} ({2} – {3}).'.trArgs([name, other.visitNumber ?? 'another visit'.tr, _time.format(other.startDate!), _time.format(otherEnd)])));
      } else if (_gapMinutes(start, end, other.startDate!, otherEnd) <
          settings.travelBuffer) {
        violations.add(DispatchViolation.warn(
            'Less than {0} min of travel time around {1}.'.trArgs([settings.travelBuffer, other.visitNumber ?? 'another visit'.tr])));
      }
    }

    final minutes = start.hour * 60 + start.minute;
    final endMinutes = minutes + (visit.durationInMin ?? 0);
    if (minutes < settings.workStart || endMinutes > settings.workEnd) {
      violations.add(DispatchViolation.warn(
          'Outside working hours.'.tr));
    }

    if (others.length >= settings.maxVisits) {
      violations.add(DispatchViolation.warn(
          '{0} already has {1} visits on this day (limit {2}).'.trArgs([name, others.length, settings.maxVisits])));
    }

    final skill = _skillMessage(visit, technician);
    if (skill != null) {
      violations.add(settings.strictSkills
          ? DispatchViolation.block(skill)
          : DispatchViolation.warn(skill));
    }

    if (technician.status == TechnicianStatus.offline) {
      violations.add(DispatchViolation.warn('{0} is marked offline.'.trArgs([name])));
    }

    return violations;
  }

  // ==========================================================
  // SMART SUGGESTIONS (rule based)
  // ==========================================================

  /// Ranks technicians for [visit] on [day]: eligible ones first, then by
  /// specialty match, free time, distance to their other visits and status.
  static List<TechnicianSuggestion> suggest({
    required VisitDetailModel visit,
    required List<TechnicianModel> technicians,
    required List<VisitDetailModel> allVisits,
    required DispatchSettingsModel settings,
    required List<TechnicianDayOffModel> daysOff,
    required DateTime day,
    required DateTime now,
  }) {
    final suggestions = technicians
        .where((t) => t.id != visit.technicianModel?.id)
        .map((technician) => rate(
              visit: visit,
              technician: technician,
              allVisits: allVisits,
              settings: settings,
              daysOff: daysOff,
              day: day,
              now: now,
            ))
        .toList();

    suggestions.sort((a, b) {
      if (a.eligible != b.eligible) return a.eligible ? -1 : 1;
      return b.score.compareTo(a.score);
    });
    return suggestions;
  }

  /// How well one [technician] fits [visit] on [day], at the best start.
  static TechnicianSuggestion rate({
    required VisitDetailModel visit,
    required TechnicianModel technician,
    required List<VisitDetailModel> allVisits,
    required DispatchSettingsModel settings,
    required List<TechnicianDayOffModel> daysOff,
    required DateTime day,
    required DateTime now,
  }) {
    final workMinutes = settings.workEnd - settings.workStart;
    final dayVisits = technicianDay(allVisits, technician.id, day)
        .where((v) => v.id != visit.id)
        .toList();
    final dayOff = isDayOff(daysOff, technician.id, day);
    final start = dayOff
        ? null
        : _bestStart(visit, technician, dayVisits, day, settings, now);

    final violations = start == null
        ? [
            DispatchViolation.block(dayOff
                ? '{0} is off on this day.'.trArgs([technician.name ?? 'Technician'.tr])
                : 'No free time left on this day.'.tr)
          ]
        : evaluate(
            visit: visit,
            technician: technician,
            start: start,
            allVisits: allVisits,
            settings: settings,
            daysOff: daysOff,
            now: now);

    var score = 100;
    final reasons = <String>[];

    if (_skillMessage(visit, technician) == null && visit.category != null) {
      score += 20;
      reasons.add('Specialty match'.tr);
    }

    final load =
        workMinutes <= 0 ? 0.0 : bookedMinutes(dayVisits) / workMinutes;
    score -= (load * 30).round();
    reasons.add(dayVisits.isEmpty
        ? 'Free all day'.tr
        : '{0} visit{1} that day'.trArgs([dayVisits.length, dayVisits.length == 1 ? '' : 's']));

    final distance = _nearestDistanceKm(visit, dayVisits);
    if (distance != null) {
      if (distance < 5) {
        score += 15;
        reasons.add('{0} km from another job'.trArgs([distance.toStringAsFixed(1)]));
      } else if (distance < 15) {
        score += 8;
        reasons.add('{0} km from another job'.trArgs([distance.toStringAsFixed(0)]));
      }
    }

    if (technician.status == TechnicianStatus.available) score += 10;
    score -= 25 * violations.where((e) => !e.blocks).length;

    return TechnicianSuggestion(
      technician: technician,
      start: start,
      score: score,
      reasons: reasons,
      violations: violations,
    );
  }

  /// Plans several visits at once. Each planned visit is counted as booked
  /// before the next one is placed, so two visits never share a slot.
  /// With [technician] set, every visit goes to that technician.
  static List<PlannedAssignment> planAssignments({
    required List<VisitDetailModel> visits,
    required List<TechnicianModel> technicians,
    required List<VisitDetailModel> allVisits,
    required DispatchSettingsModel settings,
    required List<TechnicianDayOffModel> daysOff,
    required DateTime day,
    required DateTime now,
    TechnicianModel? technician,
  }) {
    var simulated = [...allVisits];
    final plans = <PlannedAssignment>[];

    for (final visit in visits) {
      final candidates = technician != null
          ? [
              rate(
                  visit: visit,
                  technician: technician,
                  allVisits: simulated,
                  settings: settings,
                  daysOff: daysOff,
                  day: day,
                  now: now)
            ]
          : suggest(
              visit: visit,
              technicians: technicians,
              allVisits: simulated,
              settings: settings,
              daysOff: daysOff,
              day: day,
              now: now);

      final eligible = candidates.where((c) => c.eligible).toList();
      final best = eligible.where((c) => c.violations.isEmpty).firstOrNull ??
          eligible.firstOrNull;

      if (best == null) {
        plans.add(PlannedAssignment(
            visit: visit,
            problem: candidates.firstOrNull?.violations.firstOrNull?.message ??
                'No technician is available.'.tr));
        continue;
      }

      plans.add(PlannedAssignment(
          visit: visit,
          technician: best.technician,
          start: best.start,
          warnings: best.violations));

      final booked = visit.copyWith(
          technicianModel: best.technician,
          startDate: best.start,
          status: VisitStatus.assigned);
      simulated = [for (final v in simulated) v.id == visit.id ? booked : v];
    }

    return plans;
  }

  /// The visit's own time when it is on [day] and free, else the first slot.
  static DateTime? _bestStart(
    VisitDetailModel visit,
    TechnicianModel technician,
    List<VisitDetailModel> dayVisits,
    DateTime day,
    DispatchSettingsModel settings,
    DateTime now,
  ) {
    final busy =
        dayVisits.where((v) => VisitRules.occupiesTechnician(v.status)).toList();
    final own = visit.startDate;
    final duration = visit.durationInMin ?? 0;

    if (own != null && sameDay(own, day) && own.isAfter(now)) {
      final ownEnd = own.add(Duration(minutes: duration));
      final free = busy.every(
          (v) => !_overlaps(own, ownEnd, v.startDate!, endOf(v)));
      if (free) return own;
    }

    return firstFreeSlot(
        busy: busy,
        day: day,
        durationInMin: duration,
        settings: settings,
        now: now);
  }

  // ==========================================================
  // PRIVATE HELPERS
  // ==========================================================

  static String? _skillMessage(
      VisitDetailModel visit, TechnicianModel technician) {
    final category = visit.category;
    if (category == null) return null;
    final skills = technician.categories ?? const [];
    if (skills.contains(category)) return null;
    return '{0} has no "{1}" specialty.'.trArgs([technician.name ?? 'Technician'.tr, category.name ?? 'required'.tr]);
  }

  static bool _overlaps(
          DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) =>
      aStart.isBefore(bEnd) && bStart.isBefore(aEnd);

  static int _gapMinutes(
      DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
    final gap = bStart.isAfter(aEnd)
        ? bStart.difference(aEnd)
        : aStart.difference(bEnd);
    return gap.inMinutes;
  }

  static DateTime _roundUp(DateTime value) {
    final minutes = value.minute % _slotStepMinutes;
    final base = DateTime(value.year, value.month, value.day, value.hour,
        value.minute - minutes);
    return minutes == 0 && value.second == 0
        ? base
        : base.add(const Duration(minutes: _slotStepMinutes));
  }

  static double? _nearestDistanceKm(
      VisitDetailModel visit, List<VisitDetailModel> others) {
    final from = _point(visit);
    if (from == null) return null;
    const distance = Distance();

    double? nearest;
    for (final other in others) {
      final to = _point(other);
      if (to == null) continue;
      final km = distance.as(LengthUnit.Kilometer, from, to).toDouble();
      if (nearest == null || km < nearest) nearest = km;
    }
    return nearest;
  }

  static LatLng? _point(VisitDetailModel visit) {
    final site = visit.site;
    if (site?.latitude == null || site?.longitude == null) return null;
    return LatLng(site!.latitude!, site.longitude!);
  }
}
