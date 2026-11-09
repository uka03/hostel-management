// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
  id: json['id'] as String,
  category: $enumDecode(_$ReportCategoryEnumMap, json['category']),
  location: json['location'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$ReportStatusEnumMap, json['status']),
  reply: json['reply'] as String?,
  hasPhoto: json['has_photo'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  voteCount: (json['vote_count'] as num).toInt(),
  voted: json['voted'] as bool,
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
