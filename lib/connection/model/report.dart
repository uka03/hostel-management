import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum ReportCategory { noise, hygiene, damage, safety, other }

@JsonEnum(fieldRename: FieldRename.snake)
enum ReportStatus { open, inProgress, resolved }

/// PRIVACY: this model must never gain a field identifying the author.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Report {
  const Report({
    required this.id,
    required this.category,
    required this.location,
    required this.description,
    required this.status,
    this.reply,
    required this.hasPhoto,
    required this.createdAt,
    required this.voteCount,
    required this.voted,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  final String id;
  final ReportCategory category;
  final String location;
  final String description;
  final ReportStatus status;
  final String? reply;
  final bool hasPhoto;

  /// Rounded to the hour by the server.
  final DateTime createdAt;
  final int voteCount;
  final bool voted;
}
