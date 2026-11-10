// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    NotificationData(
      personName: json['person_name'] as String?,
      title: json['title'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      category: $enumDecodeNullable(
        _$ReportCategoryEnumMap,
        json['category'],
        unknownValue: ReportCategory.other,
      ),
      location: json['location'] as String?,
      status: $enumDecodeNullable(_$ReportStatusEnumMap, json['status']),
      replied: json['replied'] as bool? ?? false,
    );

const _$ReportCategoryEnumMap = {
  ReportCategory.noise: 'noise',
  ReportCategory.hygiene: 'hygiene',
  ReportCategory.damage: 'damage',
  ReportCategory.safety: 'safety',
  ReportCategory.other: 'other',
};

const _$ReportStatusEnumMap = {
  ReportStatus.open: 'open',
  ReportStatus.inProgress: 'in_progress',
  ReportStatus.resolved: 'resolved',
};

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      kind: $enumDecode(
        _$NotificationKindEnumMap,
        json['kind'],
        unknownValue: NotificationKind.other,
      ),
      data: NotificationData.fromJson(json['data'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      read: json['read'] as bool,
    );

const _$NotificationKindEnumMap = {
  NotificationKind.paid: 'paid',
  NotificationKind.newPurchase: 'new_purchase',
  NotificationKind.reportNew: 'report_new',
  NotificationKind.reportUpdate: 'report_update',
  NotificationKind.other: 'other',
};

NotificationsFeed _$NotificationsFeedFromJson(Map<String, dynamic> json) =>
    NotificationsFeed(
      unreadCount: (json['unread_count'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
