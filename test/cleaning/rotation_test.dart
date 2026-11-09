import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';

RotationVersion version(int effective, List<String> ids) =>
    RotationVersion(effectivePeriod: effective, memberIds: ids);

final start = DateTime.utc(2026, 11, 9);

Rotation rotation(
  List<RotationVersion> versions, {
  Map<int, String> overrides = const {},
  Set<int> done = const {},
}) => Rotation(
  startDate: start,
  versions: versions,
  overrides: overrides,
  donePeriods: done,
);

List<String?> people(Rotation r, int count) => [
  for (var p = 0; p < count; p++) r.personAt(p),
];

void main() {
  group('periods', () {
    final r = rotation([
      version(0, ['a', 'b']),
    ]);

    test('last 2 days and start on the first day', () {
      expect(r.periodOf(DateTime.utc(2026, 11, 9)), 0);
      expect(r.periodOf(DateTime.utc(2026, 11, 10)), 0);
      expect(r.periodOf(DateTime.utc(2026, 11, 11)), 1);
      expect(r.periodOf(DateTime.utc(2026, 11, 12)), 1);
      expect(r.periodOf(DateTime.utc(2026, 11, 13)), 2);
    });

    test('count the days left, including today', () {
      expect(r.daysLeftOn(DateTime.utc(2026, 11, 9)), 2);
      expect(r.daysLeftOn(DateTime.utc(2026, 11, 10)), 1);
      expect(r.daysLeftOn(DateTime.utc(2026, 11, 11)), 2);
    });

    test('span month ends', () {
      final december = Rotation(
        startDate: DateTime.utc(2026, 11, 29),
        versions: [
          version(0, ['a']),
        ],
      );
      expect(december.datesOf(0), '11/29–11/30');
      expect(december.datesOf(1), '12/1–12/2');
    });

    test('ignore the time of day and device time zone', () {
      expect(r.periodOf(DateTime(2026, 11, 10, 23, 59)), 0);
      expect(r.periodOf(DateTime(2026, 11, 11, 0, 1)), 1);
    });
  });

  group('rotation', () {
    test('follows order[period % length]', () {
      final r = rotation([
        version(0, ['a', 'b', 'c']),
      ]);
      expect(people(r, 7), ['a', 'b', 'c', 'a', 'b', 'c', 'a']);
    });

    test('has nobody on duty when empty', () {
      expect(rotation([]).personAt(0), isNull);
      expect(rotation([version(0, [])]).personAt(0), isNull);
    });

    test('sequenceAt starts with the person on duty', () {
      final r = rotation([
        version(0, ['a', 'b', 'c']),
      ]);
      expect(r.sequenceAt(4), ['b', 'c', 'a']);
    });
  });

  group('joins', () {
    test('take effect from the next period, at the end of the line', () {
      final old = rotation([
        version(0, ['a', 'b', 'c']),
      ]);
      // During period 0, "d" joins.
      final joined = rotation([
        version(0, ['a', 'b', 'c']),
        version(1, [...old.sequenceAt(1), 'd']),
      ]);
      expect(people(joined, 6), ['a', 'b', 'c', 'a', 'd', 'b']);
    });
  });

  group('leaves', () {
    test('never change the current duty person', () {
      final old = rotation([
        version(0, ['a', 'b', 'c']),
      ]);
      // During period 0, "a" moves out while on duty.
      final left = rotation([
        version(0, ['a', 'b', 'c']),
        version(1, old.sequenceAt(1).where((id) => id != 'a').toList()),
      ]);
      expect(left.personAt(0), 'a');
      expect(people(left, 5).skip(1), ['b', 'c', 'b', 'c']);
    });

    test('of the next person move everyone up', () {
      final old = rotation([
        version(0, ['a', 'b', 'c']),
      ]);
      final left = rotation([
        version(0, ['a', 'b', 'c']),
        version(1, old.sequenceAt(1).where((id) => id != 'b').toList()),
      ]);
      expect(people(left, 5), ['a', 'c', 'a', 'c', 'a']);
    });
  });

  group('swaps', () {
    test('exchange exactly the two periods', () {
      final r = rotation(
        [
          version(0, ['a', 'b', 'c']),
        ],
        overrides: {0: 'c', 2: 'a'},
      );
      expect(people(r, 6), ['c', 'b', 'a', 'a', 'b', 'c']);
    });

    test('survive a later version', () {
      final r = rotation(
        [
          version(0, ['a', 'b']),
          version(3, ['b', 'a', 'c']),
        ],
        overrides: {5: 'a'},
      );
      expect(r.personAt(4), 'a');
      expect(r.personAt(5), 'a');
    });
  });

  group('status', () {
    final r = rotation(
      [
        version(0, ['a', 'b']),
      ],
      done: {1, 3},
    );

    test('is derived from the period and completion', () {
      expect(r.statusOf(0, current: 3), DutyStatus.missed);
      expect(r.statusOf(1, current: 3), DutyStatus.done);
      expect(r.statusOf(2, current: 2), DutyStatus.active);
      expect(r.statusOf(3, current: 3), DutyStatus.done);
      expect(r.statusOf(4, current: 3), DutyStatus.upcoming);
    });
  });

  group('next turn', () {
    test('is the first period after the given one', () {
      final r = rotation([
        version(0, ['a', 'b', 'c']),
      ]);
      expect(r.nextTurnOf('a', after: 0), 3);
      expect(r.nextTurnOf('b', after: 0), 1);
    });

    test('accounts for swaps', () {
      final r = rotation(
        [
          version(0, ['a', 'b', 'c']),
        ],
        overrides: {1: 'c', 2: 'b'},
      );
      expect(r.nextTurnOf('b', after: 0), 2);
    });

    test('is null for someone outside the rotation', () {
      final r = rotation([
        version(0, ['a', 'b']),
      ]);
      expect(r.nextTurnOf('z', after: 0), isNull);
    });
  });
}
