import 'package:flutter/material.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/provider/split.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NeededItemsCard extends StatelessWidget {
  const NeededItemsCard({
    super.key,
    required this.items,
    required this.today,
    required this.meId,
    required this.isManager,
    required this.enabled,
    required this.onClaim,
    required this.onReceipt,
    required this.onRemove,
  });

  final List<NeededItem> items;
  final DateTime today;
  final String? meId;
  final bool isManager, enabled;
  final ValueChanged<NeededItem> onClaim, onReceipt, onRemove;

  String _subtitle(AppLocalizations l10n, NeededItem item) {
    if (item.claimedBy != null) {
      return item.claimedBy == meId
          ? l10n.purchasesClaimedByYou
          : l10n.purchasesClaimedBy(item.claimedByName ?? l10n.cleaningUnnamed);
    }
    return switch (daysBetween(item.requestedOn, today)) {
      <= 0 => l10n.purchasesRequestedToday,
      1 => l10n.purchasesRequestedYesterday,
      final days => l10n.purchasesRequestedDays(days),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return AppCard(
        child: Text(
          l10n.purchasesNoNeeded,
          style: GeneralTextStyle.bodyText(textColor: GeneralColors.mutedColor),
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              const Divider(height: 1, color: GeneralColors.borderColor),
            _ItemRow(
              name: item.name,
              subtitle: _subtitle(l10n, item),
              isClaimed: item.claimedBy != null,
              actionLabel: item.claimedBy == null
                  ? l10n.purchasesClaim
                  : item.claimedBy == meId
                  ? l10n.purchasesReceipt
                  : null,
              onAction: !enabled
                  ? null
                  : item.claimedBy == null
                  ? () => onClaim(item)
                  : () => onReceipt(item),
              onRemove:
                  enabled &&
                      item.claimedBy == null &&
                      (item.requestedBy == meId || isManager)
                  ? () => onRemove(item)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.name,
    required this.subtitle,
    required this.isClaimed,
    required this.actionLabel,
    required this.onAction,
    required this.onRemove,
  });

  final String name, subtitle;
  final bool isClaimed;
  final String? actionLabel;
  final VoidCallback? onAction, onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isClaimed
                  ? GeneralColors.primarySoftColor
                  : GeneralColors.cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isClaimed
                    ? GeneralColors.primaryColor
                    : GeneralColors.borderColor,
                width: 1.5,
              ),
            ),
          ),
          HSpacer(size: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GeneralTextStyle.sectionText(fontSize: 14)),
                VSpacer(size: 2),
                Text(subtitle, style: GeneralTextStyle.captionText()),
              ],
            ),
          ),
          if (actionLabel case final label?) ...[
            HSpacer.sm(),
            CustomButton(
              onTap: () => onAction?.call(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: GeneralColors.primarySoftColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: GeneralTextStyle.bodyText(
                    fontSize: 13,
                    textColor: GeneralColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (onRemove case final onRemove?) ...[
            HSpacer.xs(),
            Tooltip(
              message: l10n.purchasesRemoveItem,
              child: CustomButton(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.x,
                    size: 16,
                    color: GeneralColors.mutedColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
