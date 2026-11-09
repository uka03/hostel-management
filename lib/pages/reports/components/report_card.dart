import 'package:flutter/material.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/reports/components/report_labels.dart';
import 'package:hostel/pages/reports/provider/report_text.dart';
import 'package:hostel/shared/components/app_badge.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.now,
    required this.onTap,
    required this.onVote,
  });

  final Report report;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback? onVote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = splitReportText(report.description);
    final detail = text.detail.isEmpty
        ? report.location
        : '${report.location} · ${text.detail}';
    return CustomButton(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppBadge(
                  label: l10n.reportCategory(report.category),
                  color: GeneralColors.mutedColor,
                  backgroundColor: GeneralColors.borderColor,
                ),
                const Spacer(),
                Text(
                  l10n.reportAgeLabel(reportAge(report.createdAt, now)),
                  style: GeneralTextStyle.captionText(),
                ),
              ],
            ),
            VSpacer(size: 12),
            Text(text.title, style: GeneralTextStyle.sectionText(fontSize: 15)),
            VSpacer.sm(),
            Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GeneralTextStyle.bodyText(
                textColor: GeneralColors.mutedColor,
                height: 1.4,
              ),
            ),
            if (report.reply case final reply?) ...[
              VSpacer.sm(),
              Text(
                l10n.reportsManagerReply(reply),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GeneralTextStyle.bodyText(
                  textColor: GeneralColors.mutedColor,
                  height: 1.4,
                ),
              ),
            ],
            const Divider(height: 24, color: GeneralColors.borderColor),
            Row(
              children: [
                const AnonymousAuthorIcon(),
                HSpacer.xs(),
                Expanded(
                  child: Text(
                    l10n.reportsAnonymousAuthor,
                    style: GeneralTextStyle.captionText(),
                  ),
                ),
                HSpacer.sm(),
                ReportStatusBadge(status: report.status),
                HSpacer.sm(),
                VoteButton(
                  count: report.voteCount,
                  voted: report.voted,
                  onTap: onVote,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnonymousAuthorIcon extends StatelessWidget {
  const AnonymousAuthorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      LucideIcons.eyeOff,
      size: 14,
      color: GeneralColors.mutedColor,
    );
  }
}

/// The "me too" button.
class VoteButton extends StatelessWidget {
  const VoteButton({
    super.key,
    required this.count,
    required this.voted,
    required this.onTap,
  });

  final int count;
  final bool voted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = voted ? GeneralColors.primaryColor : GeneralColors.textColor;
    return Semantics(
      button: true,
      selected: voted,
      label: AppLocalizations.of(context).reportsVote,
      child: CustomButton(
        onTap: () => onTap?.call(),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: voted
                ? GeneralColors.primarySoftColor
                : GeneralColors.cardColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: voted
                  ? GeneralColors.primaryColor
                  : GeneralColors.borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.chevronUp, size: 14, color: color),
              HSpacer.xs(),
              Text(
                '$count',
                style: GeneralTextStyle.captionText(
                  textColor: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
