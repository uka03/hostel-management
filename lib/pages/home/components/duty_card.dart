import 'package:flutter/material.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The blue card: this resident's current or next duty, with one action.
class DutyCard extends StatelessWidget {
  const DutyCard({
    super.key,
    required this.label,
    required this.title,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.dateLine,
  });

  final String label, title, actionLabel;
  final String? dateLine;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    const onCard = GeneralColors.onPrimaryColor;
    final line = dateLine;
    final actionColor = onAction == null
        ? GeneralColors.mutedColor
        : GeneralColors.primaryColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GeneralColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GeneralTextStyle.titleText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              textColor: GeneralColors.primarySoftColor,
            ),
          ),
          VSpacer.sm(),
          Text(
            title,
            style: GeneralTextStyle.titleText(fontSize: 20, textColor: onCard),
          ),
          if (line != null) ...[
            VSpacer.sm(),
            Row(
              children: [
                const Icon(LucideIcons.calendar, size: 15, color: onCard),
                HSpacer(size: 6),
                Expanded(
                  child: Text(
                    line,
                    style: GeneralTextStyle.bodyText(textColor: onCard),
                  ),
                ),
              ],
            ),
          ],
          VSpacer(size: 14),
          CustomButton(
            onTap: () => onAction?.call(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: GeneralColors.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(actionIcon, size: 16, color: actionColor),
                  HSpacer.sm(),
                  Flexible(
                    child: Text(
                      actionLabel,
                      style: GeneralTextStyle.sectionText(
                        fontSize: 14,
                        textColor: actionColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
