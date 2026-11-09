import 'package:flutter/material.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';

/// A pending swap, with the actions available to this resident.
class SwapRequestCard extends StatelessWidget {
  const SwapRequestCard({
    super.key,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String message, primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final actionStyle = GeneralTextStyle.bodyText(
      textColor: GeneralColors.primaryColor,
      fontWeight: FontWeight.w600,
    );
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(message, style: GeneralTextStyle.bodyText(height: 1.4)),
          ),
          VSpacer.xs(),
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              if (secondaryLabel != null)
                TextButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryLabel!,
                    style: GeneralTextStyle.bodyText(
                      textColor: GeneralColors.mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              TextButton(
                onPressed: onPrimary,
                child: Text(primaryLabel, style: actionStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
