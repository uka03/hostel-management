extension UlaanbaatarDate on DateTime {
  /// This instant as Asia/Ulaanbaatar wall-clock time (fixed UTC+8).
  ///
  /// The result is a UTC-flagged [DateTime] whose fields read as local
  /// Ulaanbaatar time, so use it for display and calendar maths only.
  DateTime toUlaanbaatar() => toUtc().add(const Duration(hours: 8));

  /// Short date in Ulaanbaatar time, e.g. `11/9`.
  String mnShort() {
    final local = toUlaanbaatar();
    return '${local.month}/${local.day}';
  }
}
