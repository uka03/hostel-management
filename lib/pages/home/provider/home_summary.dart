import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/extensions/date_extensions.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';

enum DayPart { morning, afternoon, evening }

/// The part of the day in Ulaanbaatar, for the greeting.
DayPart dayPartAt(DateTime now) {
  final hour = now.toUlaanbaatar().hour;
  if (hour >= 5 && hour < 12) return DayPart.morning;
  if (hour >= 12 && hour < 18) return DayPart.afternoon;
  return DayPart.evening;
}

enum HomeActivityKind { cleaning, purchase, report }

/// One line of the activity feed.
///
/// PRIVACY: a report activity carries only the report's own text and time.
class HomeActivity {
  const HomeActivity({
    required this.kind,
    required this.day,
    this.personName,
    this.title = '',
    this.amount = 0,
    this.reportCreatedAt,
  });

  final HomeActivityKind kind;

  /// The calendar day it happened, in Ulaanbaatar.
  final DateTime day;
  final String? personName;

  /// The purchase title or the report text.
  final String title;
  final int amount;

  /// Hour-rounded time of a report; null for other kinds.
  final DateTime? reportCreatedAt;
}

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Newest first. Days are the finest order, because cleaning and purchases
/// are only known to the day.
List<HomeActivity> buildActivity({
  CleaningOverview? cleaning,
  PurchasesOverview? purchases,
  List<Report>? reports,
  int limit = 30,
}) {
  final activity = <HomeActivity>[];

  final rotation = cleaning == null ? null : rotationFrom(cleaning);
  if (cleaning != null && rotation != null) {
    final current = rotation.periodOf(cleaning.today);
    for (final period in cleaning.donePeriods) {
      final person = rotation.personAt(period);
      String? name;
      for (final member in cleaning.members) {
        if (member.id == person) name = member.name;
      }
      activity.add(
        HomeActivity(
          kind: HomeActivityKind.cleaning,
          day: period == current
              ? _day(cleaning.today)
              : rotation.lastDayOf(period),
          personName: name,
        ),
      );
    }
  }

  for (final purchase in purchases?.purchases ?? const <Purchase>[]) {
    activity.add(
      HomeActivity(
        kind: HomeActivityKind.purchase,
        day: _day(purchase.purchasedOn),
        personName: purchase.buyerName,
        title: purchase.title,
        amount: purchase.amount,
      ),
    );
  }

  for (final report in reports ?? const <Report>[]) {
    activity.add(
      HomeActivity(
        kind: HomeActivityKind.report,
        day: _day(report.createdAt.toUlaanbaatar()),
        title: report.description,
        reportCreatedAt: report.createdAt,
      ),
    );
  }

  final ordered = activity.indexed.toList()
    ..sort((a, b) {
      final byDay = b.$2.day.compareTo(a.$2.day);
      return byDay != 0 ? byDay : a.$1.compareTo(b.$1);
    });
  return [for (final (_, item) in ordered.take(limit)) item];
}
