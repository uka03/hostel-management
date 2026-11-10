/// An equal split between people. The server applies the same rule when it
/// stores a purchase; this is for showing and previewing it.
class CostSplit {
  const CostSplit(this.share, this.remainder);

  /// What each person pays, in whole tögrög.
  final int share;

  /// Left over after dividing. It stays with the buyer.
  final int remainder;

  int get buyerShare => share + remainder;
}

CostSplit splitCost(int amount, int people) {
  if (people <= 0) return const CostSplit(0, 0);
  return CostSplit(amount ~/ people, amount % people);
}

/// Where a resident stands across all purchases.
class BalanceSummary {
  const BalanceSummary({
    required this.total,
    required this.paid,
    required this.share,
  });

  final int total, paid, share;

  /// Positive means this resident gets money back.
  int get balance => paid - share;
}

/// Whole calendar days from [from] to [to], ignoring time of day.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
