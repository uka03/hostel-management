import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows that the app is waiting for the SMS, and how long is left.
class SmsStatusCard extends StatelessWidget {
  const SmsStatusCard({super.key, required this.remaining});

  final Duration remaining;

  String get _countdown {
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Row(
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: GeneralColors.primaryColor,
              backgroundColor: GeneralColors.borderColor,
            ),
          ),
          HSpacer(size: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.authSmsWaiting,
                  style: GeneralTextStyle.sectionText(),
                ),
                VSpacer(size: 2),
                Text(
                  l10n.authSmsWaitingHint,
                  style: GeneralTextStyle.captionText(height: 1.3),
                ),
              ],
            ),
          ),
          HSpacer.sm(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GeneralColors.backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: GeneralColors.mutedColor,
                ),
                HSpacer.xs(),
                Text(
                  _countdown,
                  style: GeneralTextStyle.bodyText(
                    textColor: GeneralColors.darkCardInnerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
