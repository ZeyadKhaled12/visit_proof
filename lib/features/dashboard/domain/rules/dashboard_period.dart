import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum DashboardRange { today, last7Days, last30Days, thisMonth, custom }

/// A reporting window: [from] inclusive, [to] exclusive, both at midnight.
/// Days are added on the calendar, never as 24 hours, so daylight-saving
/// days are counted once.
class DashboardPeriod extends Equatable {
  final DashboardRange range;
  final DateTime from;
  final DateTime to;

  const DashboardPeriod._(this.range, this.from, this.to);

  factory DashboardPeriod.of(
    DashboardRange range, {
    required DateTime now,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final today = _day(now);
    final tomorrow = _addDays(today, 1);
    switch (range) {
      case DashboardRange.today:
        return DashboardPeriod._(range, today, tomorrow);
      case DashboardRange.last7Days:
        return DashboardPeriod._(range, _addDays(today, -6), tomorrow);
      case DashboardRange.last30Days:
        return DashboardPeriod._(range, _addDays(today, -29), tomorrow);
      case DashboardRange.thisMonth:
        return DashboardPeriod._(
            range, DateTime(today.year, today.month, 1), tomorrow);
      case DashboardRange.custom:
        final start = _day(customStart ?? today);
        final end = _day(customEnd ?? start);
        return DashboardPeriod._(range, start, _addDays(end, 1));
    }
  }

  /// Number of calendar days in the window.
  int get days => DateTime.utc(to.year, to.month, to.day)
      .difference(DateTime.utc(from.year, from.month, from.day))
      .inDays;

  /// The window of the same length just before this one.
  DashboardPeriod get previous =>
      DashboardPeriod._(range, _addDays(from, -days), from);

  bool contains(DateTime? time) =>
      time != null && !time.isBefore(from) && time.isBefore(to);

  /// The last day inside the window.
  DateTime get lastDay => _addDays(to, -1);

  String get label {
    switch (range) {
      case DashboardRange.today:
        return 'Today';
      case DashboardRange.last7Days:
        return 'Last 7 days';
      case DashboardRange.last30Days:
        return 'Last 30 days';
      case DashboardRange.thisMonth:
        return 'This month';
      case DashboardRange.custom:
        return dateLabel;
    }
  }

  String get dateLabel {
    final format = DateFormat('dd MMM');
    return days == 1
        ? DateFormat('EEE, dd MMM yyyy').format(from)
        : '${format.format(from)} – ${format.format(lastDay)}';
  }

  String get comparisonLabel => days == 1
      ? 'vs previous day'
      : 'vs previous $days days';

  static DateTime addDays(DateTime day, int days) => _addDays(day, days);

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _addDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  @override
  List<Object?> get props => [range, from, to];
}
