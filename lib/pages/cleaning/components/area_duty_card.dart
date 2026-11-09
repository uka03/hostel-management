import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/app_badge.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AreaCardState { yourTurn, done, notDone, upcoming }

class AreaDutyCard extends StatelessWidget {
  const AreaDutyCard({
    super.key,
    required this.name,
    required this.person,
    required this.state,
    this.isHighlighted = false,
    this.onTap,
  });

  final String name, person;
  final AreaCardState state;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color, background) = switch (state) {
      AreaCardState.yourTurn => (
        l10n.cleaningYourTurn,
        GeneralColors.primaryColor,
        GeneralColors.primarySoftColor,
      ),
      AreaCardState.done => (
        l10n.cleaningAreaDone,
        GeneralColors.successColor,
        GeneralColors.successSoftColor,
      ),
      AreaCardState.notDone => (
        l10n.cleaningAreaNotDone,
        GeneralColors.warningColor,
        GeneralColors.warningSoftColor,
      ),
      AreaCardState.upcoming => (
        l10n.cleaningStatusUpcoming,
        GeneralColors.mutedColor,
        GeneralColors.backgroundColor,
      ),
    };

    final card = AppCard(
      padding: const EdgeInsets.all(12),
      borderColor: isHighlighted ? GeneralColors.primaryColor : null,
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: IconBox(
              icon: LucideIcons.sparkle,
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
                Text(name, style: GeneralTextStyle.sectionText(fontSize: 15)),
                VSpacer(size: 2),
                Text(person, style: GeneralTextStyle.captionText()),
              ],
            ),
          ),
          HSpacer.sm(),
          AppBadge(label: label, color: color, backgroundColor: background),
        ],
      ),
    );

    if (onTap == null) return card;
    return Semantics(
      checked: state == AreaCardState.done,
      child: CustomButton(
        onTap: onTap!,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}
