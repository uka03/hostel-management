import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';

/// How much of the current duty is finished, and when this resident is next.
class CleaningProgressCard extends StatelessWidget {
  const CleaningProgressCard({
    super.key,
    required this.done,
    required this.total,
    this.nextTurn,
  });

  final int done, total;
  final String? nextTurn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.cleaningThisPeriod,
                  style: GeneralTextStyle.bodyText(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                l10n.cleaningProgress(done, total),
                style: GeneralTextStyle.bodyText(
                  textColor: GeneralColors.mutedColor,
                ),
              ),
            ],
          ),
          VSpacer(size: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 7,
              color: GeneralColors.primaryColor,
              backgroundColor: GeneralColors.borderColor,
            ),
          ),
          if (nextTurn case final nextTurn?) ...[
            VSpacer(size: 12),
            Text(
              l10n.cleaningNextTurnLine(nextTurn),
              style: GeneralTextStyle.captionText(),
            ),
          ],
        ],
      ),
    );
  }
}
