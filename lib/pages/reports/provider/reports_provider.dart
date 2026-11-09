import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/connection/reports_api.dart';

class ReportsProvider extends ChangeNotifier {
  ReportsProvider(this._api);

  final ReportsApi _api;

  List<Report>? _reports;
  ReportStatus? _filter;
  bool _failed = false;
  bool _busy = false;
  bool _disposed = false;

  /// Null means every status.
  ReportStatus? get filter => _filter;
  bool get failed => _failed && _reports == null;
  bool get busy => _busy;
  bool get isLoaded => _reports != null;

  List<Report> get visible {
    final reports = _reports ?? const <Report>[];
    final filter = _filter;
    if (filter == null) return reports;
    return reports.where((r) => r.status == filter).toList();
  }

  Report? byId(String id) {
    for (final report in _reports ?? const <Report>[]) {
      if (report.id == id) return report;
    }
    return null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setFilter(ReportStatus? filter) {
    _filter = filter;
    _notify();
  }

  Future<void> load() async {
    _failed = false;
    try {
      _reports = await _api.list();
    } catch (_) {
      _failed = true;
    }
    _notify();
  }

  Future<void> _save(Future<void> Function() change) async {
    if (_busy) return;
    _busy = true;
    _notify();
    try {
      await change();
      _reports = await _api.list();
    } finally {
      _busy = false;
      _notify();
    }
  }

  /// [cleanPhoto] must already be sanitized.
  Future<void> create({
    required ReportCategory category,
    required String location,
    required String description,
    Uint8List? cleanPhoto,
  }) => _save(
    () => _api.create(
      category: category,
      location: location,
      description: description,
      photoBase64: cleanPhoto == null ? null : base64Encode(cleanPhoto),
    ),
  );

  Future<void> toggleVote(Report report) =>
      _save(() => _api.setVoted(report.id, !report.voted));

  Future<void> update(Report report, ReportStatus status, String reply) =>
      _save(() => _api.update(report.id, status, reply));

  Future<Uint8List> photo(String reportId) async =>
      base64Decode(await _api.photo(reportId));
}
