import 'package:flutter/material.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/provider/split.dart';
import 'package:hostel/shared/components/app_badge.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';

/// All shared spending so far and where this resident stands.
class PurchasesHeroCard extends StatelessWidget {
  const PurchasesHeroCard({super.key, required this.summary});

  final BalanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = summary.balance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GeneralColors.darkCardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.purchasesFundLabel,
            style: GeneralTextStyle.bodyText(
              textColor: GeneralColors.borderColor,
            ),
          ),
          VSpacer.sm(),
          Text(
            summary.total.toMnt(),
            style: GeneralTextStyle.titleText(
              fontSize: 32,
              textColor: GeneralColors.onPrimaryColor,
            ),
          ),
          VSpacer.md(),
          Row(
            children: [
              Expanded(
                child: _Stat(label: l10n.purchasesYouPaid, value: summary.paid),
              ),
              HSpacer(size: 12),
              Expanded(
                child: _Stat(
                  label: l10n.purchasesYourShare,
                  value: summary.share,
                ),
              ),
            ],
          ),
          if (balance != 0) ...[
            VSpacer(size: 12),
            AppBadge(
              label: balance > 0
                  ? l10n.purchasesGetBack(balance.toMnt())
                  : l10n.purchasesYouOwe((-balance).toMnt()),
              color: balance > 0
                  ? GeneralColors.successColor
                  : GeneralColors.warningTextColor,
              backgroundColor: balance > 0
                  ? GeneralColors.successSoftColor
                  : GeneralColors.warningSoftColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GeneralColors.darkCardInnerColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GeneralTextStyle.captionText(
              textColor: GeneralColors.borderColor,
            ),
          ),
          VSpacer.xs(),
          Text(
            value.toMnt(),
            style: GeneralTextStyle.sectionText(
              fontSize: 18,
              textColor: GeneralColors.onPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
