import 'package:hostel/connection/model/report.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_notification.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum NotificationKind { paid, newPurchase, reportNew, reportUpdate, other }

/// What a notification is about. Which fields are set depends on the kind.
///
/// PRIVACY: report notifications never carry who wrote the report.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class NotificationData {
  const NotificationData({
    this.personName,
    this.title,
    this.amount,
    this.category,
    this.location,
    this.status,
    this.replied = false,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);

  /// Purchases: who paid, or who bought.
  final String? personName;
  final String? title;

  /// Whole tögrög: the share paid, or the share to pay.
  final int? amount;

  @JsonKey(unknownEnumValue: ReportCategory.other)
  final ReportCategory? category;
  final String? location;
  final ReportStatus? status;
  final bool replied;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.data,
    required this.createdAt,
    required this.read,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  final String id;
  @JsonKey(unknownEnumValue: NotificationKind.other)
  final NotificationKind kind;
  final NotificationData data;
  final DateTime createdAt;
  final bool read;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class NotificationsFeed {
  const NotificationsFeed({required this.unreadCount, required this.items});

  factory NotificationsFeed.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFeedFromJson(json);

  final int unreadCount;

  /// Newest first.
  final List<AppNotification> items;
}
