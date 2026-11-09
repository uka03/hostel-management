import 'package:flutter/material.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/reports/provider/report_text.dart';
import 'package:hostel/shared/components/app_badge.dart';
import 'package:hostel/utils/colors.dart';

extension ReportLabels on AppLocalizations {
  String reportCategory(ReportCategory category) => switch (category) {
    ReportCategory.noise => reportsCategoryNoise,
    ReportCategory.hygiene => reportsCategoryHygiene,
    ReportCategory.damage => reportsCategoryDamage,
    ReportCategory.safety => reportsCategorySafety,
    ReportCategory.other => reportsCategoryOther,
  };

  String reportStatus(ReportStatus status) => switch (status) {
    ReportStatus.open => reportsStatusOpen,
    ReportStatus.inProgress => reportsStatusInProgress,
    ReportStatus.resolved => reportsStatusResolved,
  };

  String reportAgeLabel(ReportAge age) => switch (age.kind) {
    ReportAgeKind.recent => reportsAgeRecent,
    ReportAgeKind.hours => reportsAgeHours(age.hours),
    ReportAgeKind.yesterday => reportsAgeYesterday,
    ReportAgeKind.date => age.date,
  };
}

class ReportStatusBadge extends StatelessWidget {
  const ReportStatusBadge({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      ReportStatus.open => (
        GeneralColors.dangerColor,
        GeneralColors.dangerSoftColor,
      ),
      ReportStatus.inProgress => (
        GeneralColors.warningColor,
        GeneralColors.warningSoftColor,
      ),
      ReportStatus.resolved => (
        GeneralColors.successColor,
        GeneralColors.successSoftColor,
      ),
    };
    return AppBadge(
      label: AppLocalizations.of(context).reportStatus(status),
      color: color,
      backgroundColor: background,
    );
  }
}
