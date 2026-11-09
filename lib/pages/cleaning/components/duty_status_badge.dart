import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';
import 'package:hostel/shared/components/app_badge.dart';
import 'package:hostel/utils/colors.dart';

class DutyStatusBadge extends StatelessWidget {
  const DutyStatusBadge({super.key, required this.status});

  final DutyStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color, background) = switch (status) {
      DutyStatus.upcoming => (
        l10n.cleaningStatusUpcoming,
        GeneralColors.mutedColor,
        GeneralColors.backgroundColor,
      ),
      DutyStatus.active => (
        l10n.cleaningStatusActive,
        GeneralColors.primaryColor,
        GeneralColors.primarySoftColor,
      ),
      DutyStatus.done => (
        l10n.cleaningStatusDone,
        GeneralColors.successColor,
        GeneralColors.successSoftColor,
      ),
      DutyStatus.missed => (
        l10n.cleaningStatusMissed,
        GeneralColors.dangerColor,
        GeneralColors.dangerSoftColor,
      ),
    };
    return AppBadge(label: label, color: color, backgroundColor: background);
  }
}
