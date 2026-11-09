import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.onChanged,
    required this.selectedIndex,
  });
  final ValueChanged<int> onChanged;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (icon: LucideIcons.house, title: l10n.tabHome),
      (icon: LucideIcons.sparkles, title: l10n.tabCleaning),
      (icon: LucideIcons.wallet, title: l10n.tabPurchases),
      (icon: LucideIcons.triangleAlert, title: l10n.tabReports),
      (icon: LucideIcons.user, title: l10n.tabProfile),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: GeneralColors.cardColor,
        border: Border(top: BorderSide(color: GeneralColors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              for (final (index, item) in items.indexed)
                Expanded(
                  child: _TabItem(
                    icon: item.icon,
                    title: item.title,
                    isSelected: index == selectedIndex,
                    onTap: () => onChanged(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? GeneralColors.primaryColor
        : GeneralColors.mutedColor;

    return Semantics(
      selected: isSelected,
      button: true,
      child: CustomButton(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            VSpacer.xs(),
            // Mongolian labels run long: shrink to fit rather than break a word.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: GeneralTextStyle.captionText(
                  fontWeight: FontWeight.w500,
                  textColor: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
