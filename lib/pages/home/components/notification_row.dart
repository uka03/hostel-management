import 'package:flutter/material.dart';
import 'package:hostel/connection/model/app_notification.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/reports/components/report_labels.dart';
import 'package:hostel/pages/reports/provider/report_text.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.notification,
    required this.now,
    this.onTap,
  });

  final AppNotification notification;
  final DateTime now;
  final VoidCallback? onTap;

  String _text(AppLocalizations l10n) {
    final data = notification.data;
    final name = data.personName ?? l10n.cleaningUnnamed;
    final amount = (data.amount ?? 0).toMnt();
    final location = data.location ?? '';
    return switch (notification.kind) {
      NotificationKind.paid => l10n.notificationPaid(name, amount),
      NotificationKind.newPurchase => l10n.notificationNewPurchase(
        name,
        data.title ?? '',
        amount,
      ),
      NotificationKind.reportNew => l10n.notificationReportNew(
        l10n.reportCategory(data.category ?? ReportCategory.other),
        location,
      ),
      NotificationKind.reportUpdate =>
        data.replied || data.status == null
            ? l10n.notificationReportReplied(location)
            : l10n.notificationReportStatus(
                location,
                l10n.reportStatus(data.status!),
              ),
      NotificationKind.other => l10n.notificationsTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color, background) = switch (notification.kind) {
      NotificationKind.paid => (
        LucideIcons.wallet,
        GeneralColors.successColor,
        GeneralColors.successSoftColor,
      ),
      NotificationKind.newPurchase => (
        LucideIcons.shoppingCart,
        GeneralColors.warningColor,
        GeneralColors.warningSoftColor,
      ),
      NotificationKind.reportNew || NotificationKind.reportUpdate => (
        LucideIcons.eyeOff,
        GeneralColors.anonymousColor,
        GeneralColors.anonymousSoftColor,
      ),
      NotificationKind.other => (
        LucideIcons.bell,
        GeneralColors.primaryColor,
        GeneralColors.primarySoftColor,
      ),
    };
    final title = notification.data.title;
    final age = l10n.reportAgeLabel(reportAge(notification.createdAt, now));
    final unread = !notification.read;

    return CustomButton(
      onTap: () => onTap?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconBox(
              icon: icon,
              backgroundColor: background,
              iconColor: color,
              size: 34,
              iconSize: 16,
              radius: 10,
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
                    style: GeneralTextStyle.bodyText(
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  VSpacer(size: 2),
                  Text(
                    notification.kind == NotificationKind.paid && title != null
                        ? '$title · $age'
                        : age,
                    style: GeneralTextStyle.captionText(),
                  ),
                ],
              ),
            ),
            if (unread) ...[
              HSpacer.sm(),
              Semantics(
                label: l10n.notificationsTitle,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: GeneralColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
