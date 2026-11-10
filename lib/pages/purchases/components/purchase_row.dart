import 'package:flutter/material.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/extensions/date_extensions.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/components/payment_dialog.dart';
import 'package:hostel/pages/purchases/components/person_avatar.dart';
import 'package:hostel/pages/purchases/provider/purchases_provider.dart';
import 'package:hostel/pages/purchases/provider/split.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class PurchaseRow extends StatelessWidget {
  const PurchaseRow({super.key, required this.purchase, this.trailing});

  static const _avatarGap = 12.0;

  final Purchase purchase;
  final Widget? trailing;

  /// Paying opens the buyer's account details first; undoing is immediate.
  Future<void> _togglePaid(BuildContext context) async {
    final provider = context.read<PurchasesProvider>();
    if (!purchase.myPaid) {
      final confirmed = await showPaymentDialog(context, purchase);
      if (confirmed != true) return;
    }
    try {
      await provider.setSharePaid(purchase.id, !purchase.myPaid);
    } catch (_) {
      if (context.mounted) Toast.error(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meId = context
        .select<AuthProvider, UserResponseData?>((a) => a.user)
        ?.id;
    final busy = context.select<PurchasesProvider, bool>((p) => p.busy);
    final name = purchase.buyerName ?? l10n.cleaningUnnamed;
    final date = purchase.purchasedOn;
    final share = splitCost(purchase.amount, purchase.peopleCount).share;
    final payers = purchase.peopleCount - 1;
    final canPay = purchase.myShare != null && purchase.buyerId != meId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonAvatar(personId: purchase.buyerId, name: name),
              HSpacer(size: _avatarGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.title,
                      style: GeneralTextStyle.sectionText(fontSize: 14),
                    ),
                    VSpacer(size: 2),
                    Text(
                      '$name · ${DateTime.utc(date.year, date.month, date.day).mnShort()}',
                      style: GeneralTextStyle.captionText(),
                    ),
                  ],
                ),
              ),
              HSpacer.sm(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.purchasesPerPerson(share.toMnt()),
                    style: GeneralTextStyle.titleText(
                      fontSize: 18,
                      textColor: GeneralColors.primaryColor,
                    ),
                  ),
                  VSpacer(size: 2),
                  Text(
                    purchase.amount.toMnt(),
                    style: GeneralTextStyle.captionText(),
                  ),
                ],
              ),
            ],
          ),
          if (payers > 0 || trailing != null) ...[
            VSpacer.sm(),
            Row(
              children: [
                const SizedBox(width: PersonAvatar.size + _avatarGap),
                Expanded(
                  child: payers > 0
                      ? Text(
                          l10n.purchasesPaidCount(purchase.paidCount, payers),
                          style: GeneralTextStyle.captionText(),
                        )
                      : const SizedBox.shrink(),
                ),
                if (canPay)
                  _PaidButton(
                    isPaid: purchase.myPaid,
                    onTap: busy ? null : () => _togglePaid(context),
                  ),
                ?trailing,
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PaidButton extends StatelessWidget {
  const _PaidButton({required this.isPaid, required this.onTap});

  final bool isPaid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isPaid
        ? GeneralColors.successColor
        : GeneralColors.primaryColor;
    return Semantics(
      button: true,
      selected: isPaid,
      child: CustomButton(
        onTap: () => onTap?.call(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isPaid
                ? GeneralColors.successSoftColor
                : GeneralColors.primarySoftColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPaid) ...[
                Icon(LucideIcons.check, size: 14, color: color),
                HSpacer.xs(),
              ],
              Text(
                isPaid
                    ? AppLocalizations.of(context).purchasesMarkPaid
                    : AppLocalizations.of(context).purchasesPay,
                style: GeneralTextStyle.bodyText(
                  fontSize: 13,
                  textColor: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
