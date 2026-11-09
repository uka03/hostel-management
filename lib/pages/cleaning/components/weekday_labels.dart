import 'package:hostel/l10n/app_localizations.dart';

extension WeekdayLabels on AppLocalizations {
  /// Short weekday for a [DateTime.weekday] value, e.g. `Лх`.
  String weekdayShort(int weekday) => switch (weekday) {
    DateTime.monday => weekdayShortMon,
    DateTime.tuesday => weekdayShortTue,
    DateTime.wednesday => weekdayShortWed,
    DateTime.thursday => weekdayShortThu,
    DateTime.friday => weekdayShortFri,
    DateTime.saturday => weekdayShortSat,
    _ => weekdayShortSun,
  };

  String _weekdayLong(int weekday) => switch (weekday) {
    DateTime.monday => weekdayLongMon,
    DateTime.tuesday => weekdayLongTue,
    DateTime.wednesday => weekdayLongWed,
    DateTime.thursday => weekdayLongThu,
    DateTime.friday => weekdayLongFri,
    DateTime.saturday => weekdayLongSat,
    _ => weekdayLongSun,
  };

  /// Long date, e.g. `11-р сарын 11, Лхагва`.
  String longDate(DateTime date) => cleaningLongDate(
    date.month.toString(),
    date.day.toString(),
    _weekdayLong(date.weekday),
  );
}
