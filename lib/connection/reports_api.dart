import 'package:dio/dio.dart';
import 'package:hostel/connection/model/report.dart';

/// Anonymous reports. The path contains a `reports` segment, which is what
/// keeps this traffic out of the logs: see NetworkInterceptor.
class ReportsApi {
  ReportsApi(this._dio);

  static const _path = '/functions/v1/reports';

  final Dio _dio;

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(_path, data: body);
    return response.data ?? const {};
  }

  Future<List<Report>> list() async {
    final data = await _call({'action': 'list'});
    return (data['reports'] as List<dynamic>)
        .map((json) => Report.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required ReportCategory category,
    required String location,
    required String description,
    String? photoBase64,
  }) => _call({
    'action': 'create',
    'category': category.name,
    'location': location,
    'description': description,
    'photo_base64': ?photoBase64,
  });

  Future<void> setVoted(String reportId, bool voted) =>
      _call({'action': 'vote', 'report_id': reportId, 'voted': voted});

  Future<void> update(String reportId, ReportStatus status, String reply) =>
      _call({
        'action': 'update',
        'report_id': reportId,
        'status': status == ReportStatus.inProgress
            ? 'in_progress'
            : status.name,
        'reply': reply,
      });

  Future<String> photo(String reportId) async {
    final data = await _call({'action': 'photo', 'report_id': reportId});
    return data['photo_base64'] as String;
  }
}
