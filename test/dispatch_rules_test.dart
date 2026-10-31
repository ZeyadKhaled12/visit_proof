import 'package:flutter_test/flutter_test.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/technician_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';
import 'package:visit_proof/features/dispatch/data/models/dispatch_settings_model.dart';
import 'package:visit_proof/features/dispatch/data/models/technician_day_off_model.dart';
import 'package:visit_proof/features/dispatch/domain/rules/dispatch_rules.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_client_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

// A fixed future day so tests never depend on the current time.
final day = DateTime(2099, 3, 10);
final now = DateTime(2099, 3, 9, 12);
const settings = DispatchSettingsModel.defaults; // 08:00–18:00, 30 min travel

const hvac = GModelCatg(id: 'hvac', name: 'HVAC');

TechnicianModel technician(String id, {List<GModelCatg>? skills}) =>
    TechnicianModel(
        id: id,
        name: 'Tech $id',
        status: TechnicianStatus.available,
        categories: skills ?? const [hvac]);

VisitDetailModel visit(String id,
        {DateTime? start,
        TechnicianModel? tech,
        VisitStatus status = VisitStatus.scheduled,
        int duration = 60}) =>
    VisitDetailModel(
      id: id,
      visitNumber: 'VIS-$id',
      status: tech == null ? status : VisitStatus.assigned,
      client: const VisitClientModel(id: 'client', name: 'Client'),
      site: GModelSite(addressDetail: 'Street 1'),
      serviceName: 'AC',
      category: hvac,
      price: 100,
      durationInMin: duration,
      startDate: start ?? day.add(const Duration(hours: 10)),
      technicianModel: tech,
    );

DateTime at(int hour, [int minute = 0]) =>
    DateTime(day.year, day.month, day.day, hour, minute);

List<DispatchViolation> check(VisitDetailModel v, TechnicianModel t,
        DateTime start, List<VisitDetailModel> all,
        {List<TechnicianDayOffModel> daysOff = const []}) =>
    DispatchRules.evaluate(
        visit: v,
        technician: t,
        start: start,
        allVisits: all,
        settings: settings,
        daysOff: daysOff,
        now: now);

void main() {
  final ali = technician('ali');

  group('evaluate', () {
    test('a free technician in working hours passes every rule', () {
      expect(check(visit('1'), ali, at(10), [visit('1')]), isEmpty);
    });

    test('double booking blocks the assignment', () {
      final busy = visit('2', start: at(10), tech: ali);
      final result = check(visit('1'), ali, at(10, 30), [busy]);
      expect(result.any((v) => v.blocks), isTrue);
    });

    test('too little travel time is only a warning', () {
      final busy = visit('2', start: at(9), tech: ali); // ends 10:00
      final result = check(visit('1'), ali, at(10, 10), [busy]);
      expect(result.any((v) => v.blocks), isFalse);
      expect(result, isNotEmpty);
    });

    test('a day off blocks the assignment', () {
      final result = check(visit('1'), ali, at(10), [],
          daysOff: [TechnicianDayOffModel(technicianId: 'ali', date: day)]);
      expect(result.any((v) => v.blocks), isTrue);
    });

    test('outside working hours is a warning', () {
      final result = check(visit('1'), ali, at(19), []);
      expect(result.single.blocks, isFalse);
    });

    test('a specialty mismatch blocks only in strict mode', () {
      final plumber = technician('bob', skills: const []);
      final relaxed = check(visit('1'), plumber, at(10), []);
      expect(relaxed.any((v) => v.blocks), isFalse);

      final strict = DispatchRules.evaluate(
          visit: visit('1'),
          technician: plumber,
          start: at(10),
          allVisits: const [],
          settings: settings.copyWith(strictSkillMatch: true),
          daysOff: const [],
          now: now);
      expect(strict.any((v) => v.blocks), isTrue);
    });
  });

  group('firstFreeSlot', () {
    test('an empty day starts when work starts', () {
      expect(
          DispatchRules.firstFreeSlot(
              busy: const [],
              day: day,
              durationInMin: 60,
              settings: settings,
              now: now),
          at(8));
    });

    test('the slot comes after busy visits plus travel time', () {
      final busy = [visit('2', start: at(8), tech: ali, duration: 90)];
      expect(
          DispatchRules.firstFreeSlot(
              busy: busy,
              day: day,
              durationInMin: 60,
              settings: settings,
              now: now),
          at(10)); // 09:30 end + 30 min travel
    });

    test('a full day has no slot', () {
      final busy = [visit('2', start: at(8), tech: ali, duration: 600)];
      expect(
          DispatchRules.firstFreeSlot(
              busy: busy,
              day: day,
              durationInMin: 60,
              settings: settings,
              now: now),
          isNull);
    });
  });

  group('suggestions and planning', () {
    test('a technician on a day off is not suggested first', () {
      final bob = technician('bob');
      final result = DispatchRules.suggest(
          visit: visit('1'),
          technicians: [ali, bob],
          allVisits: const [],
          settings: settings,
          daysOff: [TechnicianDayOffModel(technicianId: 'ali', date: day)],
          day: day,
          now: now);
      expect(result.first.technician.id, 'bob');
      expect(result.last.eligible, isFalse);
    });

    test('a batch never puts two visits in the same slot', () {
      final plans = DispatchRules.planAssignments(
          visits: [visit('1'), visit('2')],
          technicians: [ali],
          allVisits: [visit('1'), visit('2')],
          settings: settings,
          daysOff: const [],
          day: day,
          now: now,
          technician: ali);
      expect(plans.every((p) => p.ok), isTrue);
      expect(plans[0].start, isNot(plans[1].start));
    });
  });

  test('a week has 7 different days, even across daylight saving', () {
    // Egypt moves its clocks back on Thursday 29 October 2026.
    final monday = DateTime(2026, 10, 26);
    final week = List.generate(7, (i) => DispatchRules.addDays(monday, i));
    expect(week.map((d) => d.day).toList(), [26, 27, 28, 29, 30, 31, 1]);
  });

  test('a paid visit cannot be cancelled from the board', () {
    final paid = visit('1', tech: ali)
        .copyWith(paymentStatus: PaymentStatus.partiallyPaid);
    expect(DispatchRules.statusError(paid, VisitStatus.cancel), isNotNull);
  });
}
