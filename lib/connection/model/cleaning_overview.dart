import 'package:json_annotation/json_annotation.dart';

part 'cleaning_overview.g.dart';

const _snake = JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: false,
);

@_snake
class RotationVersion {
  const RotationVersion({
    required this.effectivePeriod,
    required this.memberIds,
  });

  factory RotationVersion.fromJson(Map<String, dynamic> json) =>
      _$RotationVersionFromJson(json);

  final int effectivePeriod;
  final List<String> memberIds;
}

@_snake
class DutyOverride {
  const DutyOverride({required this.period, required this.personId});

  factory DutyOverride.fromJson(Map<String, dynamic> json) =>
      _$DutyOverrideFromJson(json);

  final int period;
  final String personId;
}

@_snake
class CleaningArea {
  const CleaningArea({required this.id, required this.name});

  factory CleaningArea.fromJson(Map<String, dynamic> json) =>
      _$CleaningAreaFromJson(json);

  final String id;
  final String name;
}

@_snake
class CleaningMember {
  const CleaningMember({required this.id, this.name, required this.active});

  factory CleaningMember.fromJson(Map<String, dynamic> json) =>
      _$CleaningMemberFromJson(json);

  final String id;
  final String? name;
  final bool active;
}

@_snake
class PendingResident {
  const PendingResident({required this.id, this.name});

  factory PendingResident.fromJson(Map<String, dynamic> json) =>
      _$PendingResidentFromJson(json);

  final String id;
  final String? name;
}

@_snake
class DutySwap {
  const DutySwap({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.requesterPeriod,
    required this.targetPeriod,
  });

  factory DutySwap.fromJson(Map<String, dynamic> json) =>
      _$DutySwapFromJson(json);

  final String id;
  final String requesterId, targetId;
  final int requesterPeriod, targetPeriod;
}

@_snake
class CleaningOverview {
  const CleaningOverview({
    required this.today,
    this.startDate,
    required this.versions,
    required this.overrides,
    required this.areas,
    required this.checkedAreaIds,
    required this.donePeriods,
    required this.members,
    required this.swaps,
    required this.pendingResidents,
  });

  factory CleaningOverview.fromJson(Map<String, dynamic> json) =>
      _$CleaningOverviewFromJson(json);

  /// Today in Asia/Ulaanbaatar, according to the server.
  final DateTime today;

  /// Null until the first resident has joined the rotation.
  final DateTime? startDate;
  final List<RotationVersion> versions;
  final List<DutyOverride> overrides;
  final List<CleaningArea> areas;
  final List<String> checkedAreaIds;
  final List<int> donePeriods;
  final List<CleaningMember> members;
  final List<DutySwap> swaps;
  final List<PendingResident> pendingResidents;
}
