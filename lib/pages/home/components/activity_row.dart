import 'package:flutter/material.dart';
import 'package:hostel/extensions/date_extensions.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/home/provider/home_summary.dart';
import 'package:hostel/pages/purchases/provider/split.dart';
import 'package:hostel/pages/reports/components/report_labels.dart';
import 'package:hostel/pages/reports/provider/report_text.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.activity,
    required this.today,
    required this.now,
  });

  final HomeActivity activity;
  final DateTime today, now;

  String _text(AppLocalizations l10n) {
    final name = activity.personName ?? l10n.cleaningUnnamed;
    return switch (activity.kind) {
      HomeActivityKind.cleaning => l10n.homeActivityCleaned(name),
      HomeActivityKind.purchase => l10n.homeActivityBought(
        name,
        activity.title,
        activity.amount.toMnt(),
      ),
      HomeActivityKind.report => l10n.homeActivityReport(
        splitReportText(activity.title).title,
      ),
    };
  }

  String _when(AppLocalizations l10n) {
    final created = activity.reportCreatedAt;
    if (created != null) return l10n.reportAgeLabel(reportAge(created, now));
    return switch (daysBetween(activity.day, today)) {
      <= 0 => l10n.homeToday,
      1 => l10n.reportsAgeYesterday,
      _ => activity.day.mnShort(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color, background) = switch (activity.kind) {
      HomeActivityKind.cleaning => (
        LucideIcons.check,
        GeneralColors.successColor,
        GeneralColors.successSoftColor,
      ),
      HomeActivityKind.purchase => (
        LucideIcons.shoppingCart,
        GeneralColors.warningColor,
        GeneralColors.warningSoftColor,
      ),
      HomeActivityKind.report => (
        LucideIcons.eyeOff,
        GeneralColors.anonymousColor,
        GeneralColors.anonymousSoftColor,
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: IconBox(
              icon: icon,
              backgroundColor: background,
              iconColor: color,
              size: 34,
              iconSize: 16,
              radius: 10,
            ),
          ),
          HSpacer(size: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GeneralTextStyle.bodyText(),
                ),
                VSpacer(size: 2),
                Text(_when(l10n), style: GeneralTextStyle.captionText()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
