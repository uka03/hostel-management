// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cleaning_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RotationVersion _$RotationVersionFromJson(Map<String, dynamic> json) =>
    RotationVersion(
      effectivePeriod: (json['effective_period'] as num).toInt(),
      memberIds: (json['member_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

DutyOverride _$DutyOverrideFromJson(Map<String, dynamic> json) => DutyOverride(
  period: (json['period'] as num).toInt(),
  personId: json['person_id'] as String,
);

CleaningArea _$CleaningAreaFromJson(Map<String, dynamic> json) =>
    CleaningArea(id: json['id'] as String, name: json['name'] as String);

CleaningMember _$CleaningMemberFromJson(Map<String, dynamic> json) =>
    CleaningMember(
      id: json['id'] as String,
      name: json['name'] as String?,
      active: json['active'] as bool,
    );

PendingResident _$PendingResidentFromJson(Map<String, dynamic> json) =>
    PendingResident(id: json['id'] as String, name: json['name'] as String?);

DutySwap _$DutySwapFromJson(Map<String, dynamic> json) => DutySwap(
  id: json['id'] as String,
  requesterId: json['requester_id'] as String,
  targetId: json['target_id'] as String,
  requesterPeriod: (json['requester_period'] as num).toInt(),
  targetPeriod: (json['target_period'] as num).toInt(),
);

CleaningOverview _$CleaningOverviewFromJson(Map<String, dynamic> json) =>
    CleaningOverview(
      today: DateTime.parse(json['today'] as String),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      versions: (json['versions'] as List<dynamic>)
          .map((e) => RotationVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      overrides: (json['overrides'] as List<dynamic>)
          .map((e) => DutyOverride.fromJson(e as Map<String, dynamic>))
          .toList(),
      areas: (json['areas'] as List<dynamic>)
          .map((e) => CleaningArea.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkedAreaIds: (json['checked_area_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      donePeriods: (json['done_periods'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      members: (json['members'] as List<dynamic>)
          .map((e) => CleaningMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      swaps: (json['swaps'] as List<dynamic>)
          .map((e) => DutySwap.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingResidents: (json['pending_residents'] as List<dynamic>)
          .map((e) => PendingResident.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
