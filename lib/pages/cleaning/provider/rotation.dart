import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/extensions/date_extensions.dart';

enum DutyStatus { upcoming, active, done, missed }

/// The rotation described by [overview], or null if it hasn't started.
Rotation? rotationFrom(CleaningOverview overview) {
  final start = overview.startDate;
  if (start == null) return null;
  return Rotation(
    startDate: start,
    versions: overview.versions,
    overrides: {for (final o in overview.overrides) o.period: o.personId},
    donePeriods: overview.donePeriods.toSet(),
  );
}

/// The 2-day duty rotation, computed from what the server stores.
///
/// A period is 2 calendar days. Each [RotationVersion] gives the order from
/// its period on, so `person = order[(period - effective) % order.length]`.
/// The first version has `effective == 0`, and later ones start at the period
/// after a join or leave, which is why the current duty person can't change.
class Rotation {
  Rotation({
    required DateTime startDate,
    required this.versions,
    this.overrides = const {},
    this.donePeriods = const {},
  }) : _start = _dateOnly(startDate);

  final DateTime _start;
  final List<RotationVersion> versions;

  /// Periods whose duty person was changed by an accepted swap.
  final Map<int, String> overrides;
  final Set<int> donePeriods;

  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  int _daysSinceStart(DateTime day) => _dateOnly(day).difference(_start).inDays;

  int periodOf(DateTime day) => (_daysSinceStart(day) / 2).floor();

  /// Calendar days left in the period, counting [day] itself: 2 or 1.
  int daysLeftOn(DateTime day) => 2 - _daysSinceStart(day) % 2;

  DateTime firstDayOf(int period) => _start.add(Duration(days: period * 2));

  DateTime lastDayOf(int period) =>
      firstDayOf(period).add(const Duration(days: 1));

  /// Display range of a period, e.g. `11/9–11/10`.
  String datesOf(int period) =>
      '${firstDayOf(period).mnShort()}–${lastDayOf(period).mnShort()}';

  /// The rotation as seen from [period]: the first entry is on duty in it.
  List<String> sequenceAt(int period) {
    RotationVersion? current;
    for (final version in versions) {
      if (version.effectivePeriod <= period &&
          (current == null ||
              version.effectivePeriod > current.effectivePeriod)) {
        current = version;
      }
    }
    if (current == null || current.memberIds.isEmpty) return const [];
    final members = current.memberIds;
    final offset = (period - current.effectivePeriod) % members.length;
    return [...members.skip(offset), ...members.take(offset)];
  }

  String? personAt(int period) {
    final override = overrides[period];
    if (override != null) return override;
    final sequence = sequenceAt(period);
    return sequence.isEmpty ? null : sequence.first;
  }

  DutyStatus statusOf(int period, {required int current}) {
    if (donePeriods.contains(period)) return DutyStatus.done;
    if (period > current) return DutyStatus.upcoming;
    return period == current ? DutyStatus.active : DutyStatus.missed;
  }

  /// The first period after [after] that [personId] is on duty, if any.
  int? nextTurnOf(String personId, {required int after}) {
    final end = after + 2 * (_longestRotation + overrides.length) + 1;
    for (var period = after + 1; period <= end; period++) {
      if (personAt(period) == personId) return period;
    }
    return null;
  }

  int get _longestRotation => versions.fold(
    1,
    (longest, v) => v.memberIds.length > longest ? v.memberIds.length : longest,
  );
}
