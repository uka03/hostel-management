import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/pages/purchases/provider/split.dart';

void main() {
  group('splitCost', () {
    test('divides evenly when it can', () {
      final split = splitCost(4500, 6);
      expect(split.share, 750);
      expect(split.remainder, 0);
    });

    test('keeps the remainder with the buyer', () {
      final split = splitCost(1000, 3);
      expect(split.share, 333);
      expect(split.remainder, 1);
      expect(split.buyerShare, 334);
    });

    test('always adds up to exactly the amount', () {
      for (var amount = 1; amount < 500; amount++) {
        for (var people = 1; people <= 12; people++) {
          final split = splitCost(amount, people);
          expect(
            split.share * (people - 1) + split.buyerShare,
            amount,
            reason: '$amount / $people',
          );
        }
      }
    });

    test('an amount smaller than the group stays with the buyer', () {
      final split = splitCost(2, 6);
      expect(split.share, 0);
      expect(split.buyerShare, 2);
    });

    test('handles nobody to split between', () {
      expect(splitCost(100, 0).share, 0);
    });
  });

  group('BalanceSummary', () {
    BalanceSummary summary(int paid, int share) =>
        BalanceSummary(total: 48600, paid: paid, share: share);

    test('balance is what you paid minus your shares', () {
      expect(summary(12000, 8100).balance, 3900);
    });

    test('a negative balance means you owe', () {
      expect(summary(0, 100).balance, -100);
    });

    test('paying exactly your share leaves nothing', () {
      expect(summary(500, 500).balance, 0);
    });
  });

  test('daysBetween counts calendar days', () {
    expect(daysBetween(DateTime(2026, 11, 7), DateTime(2026, 11, 9)), 2);
    expect(daysBetween(DateTime(2026, 10, 31), DateTime(2026, 11, 1)), 1);
    expect(daysBetween(DateTime(2026, 11, 9), DateTime(2026, 11, 9)), 0);
  });
}
