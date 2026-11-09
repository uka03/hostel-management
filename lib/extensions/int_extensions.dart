import 'package:intl/intl.dart';

final _thousands = NumberFormat('#,##0', 'en_US');

extension MoneyFormat on int {
  /// Whole tögrög for display, e.g. `₮48,600`.
  String toMnt() => '${isNegative ? '-' : ''}₮${_thousands.format(abs())}';
}
