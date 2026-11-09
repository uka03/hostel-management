import 'package:hostel/extensions/date_extensions.dart';

class ReportText {
  const ReportText(this.title, this.detail);

  final String title, detail;
}

/// Splits a description into a headline (its first sentence) and the rest.
ReportText splitReportText(String description) {
  final text = description.trim();
  final end = text.indexOf(RegExp(r'[.!?\n]'));
  if (end <= 0) return ReportText(text, '');
  return ReportText(
    text.substring(0, end).trim(),
    text.substring(end + 1).trim(),
  );
}

enum ReportAgeKind { recent, hours, yesterday, date }

/// How old a report is, at the coarse resolution anonymity allows.
class ReportAge {
  const ReportAge(this.kind, {this.hours = 0, this.date = ''});

  final ReportAgeKind kind;
  final int hours;

  /// Short date, for reports older than yesterday.
  final String date;
}

ReportAge reportAge(DateTime createdAt, DateTime now) {
  final hours = now.difference(createdAt).inHours;
  if (hours < 1) return const ReportAge(ReportAgeKind.recent);

  final created = createdAt.toUlaanbaatar();
  final today = now.toUlaanbaatar();
  final days = DateTime.utc(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime.utc(created.year, created.month, created.day)).inDays;
  if (days == 0) return ReportAge(ReportAgeKind.hours, hours: hours);
  if (days == 1) return const ReportAge(ReportAgeKind.yesterday);
  return ReportAge(ReportAgeKind.date, date: createdAt.mnShort());
}
