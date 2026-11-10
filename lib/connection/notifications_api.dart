import 'package:dio/dio.dart';
import 'package:hostel/connection/model/app_notification.dart';

/// In-app notifications. The server writes them; clients only read them.
class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  Future<NotificationsFeed> list() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/rest/v1/rpc/my_notifications',
      data: const <String, dynamic>{},
    );
    return NotificationsFeed.fromJson(response.data!);
  }

  Future<void> markAllRead() => _dio.post<void>(
    '/rest/v1/rpc/mark_notifications_read',
    data: const <String, dynamic>{},
  );
}
