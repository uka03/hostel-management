import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/cleaning/components/weekday_labels.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';

class PeriodStripItem {
  const PeriodStripItem({
    required this.period,
    required this.date,
    required this.isMine,
  });

  final int period;
  final DateTime date;
  final bool isMine;
}

/// One pill per 2-day duty period. A dot marks this resident's turns.
class PeriodStrip extends StatelessWidget {
  const PeriodStrip({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<PeriodStripItem> items;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) HSpacer(size: 6),
          Expanded(
            child: _Pill(
              weekday: l10n.weekdayShort(item.date.weekday),
              day: item.date.day,
              isSelected: item.period == selected,
              isMine: item.isMine,
              onTap: () => onSelected(item.period),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.weekday,
    required this.day,
    required this.isSelected,
    required this.isMine,
    required this.onTap,
  });

  final String weekday;
  final int day;
  final bool isSelected, isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? GeneralColors.onPrimaryColor
        : GeneralColors.textColor;
    return Semantics(
      selected: isSelected,
      button: true,
      child: CustomButton(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? GeneralColors.primaryColor
                : GeneralColors.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? null
                : Border.all(color: GeneralColors.borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: GeneralTextStyle.captionText(
                  textColor: isSelected
                      ? GeneralColors.primarySoftColor
                      : GeneralColors.mutedColor,
                ),
              ),
              Text(
                '$day',
                style: GeneralTextStyle.sectionText(textColor: foreground),
              ),
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: !isMine
                      ? null
                      : isSelected
                      ? GeneralColors.onPrimaryColor
                      : GeneralColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
