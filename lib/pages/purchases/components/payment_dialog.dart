import 'package:flutter/material.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/provider/purchases_provider.dart';
import 'package:hostel/shared/components/copy_row.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:provider/provider.dart';

/// Shows who to pay and where. Returns true if the resident confirms they paid.
Future<bool?> showPaymentDialog(BuildContext context, Purchase purchase) {
  // Requested once out here: the builder below can run several times.
  final info = context.read<PurchasesProvider>().paymentInfo(purchase.id);
  return showDialog<bool>(
    context: context,
    builder: (_) => _PaymentDialog(amount: purchase.myShare ?? 0, info: info),
  );
}

class _PaymentDialog extends StatelessWidget {
  const _PaymentDialog({required this.amount, required this.info});

  final int amount;
  final Future<PaymentInfo> info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: GeneralColors.cardColor,
      surfaceTintColor: GeneralColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<PaymentInfo>(
          future: info,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.purchasesPayTitle,
                  style: GeneralTextStyle.sectionText(),
                ),
                VSpacer.sm(),
                Text(
                  amount.toMnt(),
                  style: GeneralTextStyle.titleText(
                    fontSize: 32,
                    textColor: GeneralColors.primaryColor,
                  ),
                ),
                VSpacer.md(),
                if (snapshot.hasError)
                  Text(
                    l10n.purchasesPayLoadFailed,
                    style: GeneralTextStyle.bodyText(
                      textColor: GeneralColors.mutedColor,
                    ),
                  )
                else if (data == null)
                  const Center(child: CircularProgressIndicator())
                else
                  _AccountDetails(info: data),
                VSpacer.lg(),
                PrimaryButton(
                  title: l10n.purchasesMarkPaid,
                  isEnable: data != null || snapshot.hasError,
                  disabledColor: GeneralColors.borderColor,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                VSpacer.xs(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    l10n.purchasesPayClose,
                    style: GeneralTextStyle.bodyText(
                      textColor: GeneralColors.mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountDetails extends StatelessWidget {
  const _AccountDetails({required this.info});

  final PaymentInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buyer = info.buyerName ?? l10n.cleaningUnnamed;
    final number = info.accountNumber;
    if (number == null) {
      return Text(
        l10n.purchasesPayNoAccount(buyer),
        style: GeneralTextStyle.bodyText(
          textColor: GeneralColors.mutedColor,
          height: 1.4,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Detail(label: l10n.purchasesPayBank, value: info.bankName ?? ''),
        VSpacer(size: 12),
        _Detail(
          label: l10n.purchasesPayAccountHolder,
          value: info.accountHolder ?? buyer,
        ),
        VSpacer(size: 12),
        CopyRow(
          label: l10n.purchasesPayAccountNumber,
          value: number,
          valueFontSize: 17,
          valueColor: GeneralColors.primaryColor,
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GeneralTextStyle.bodyText(textColor: GeneralColors.mutedColor),
        ),
        VSpacer.xs(),
        Text(value, style: GeneralTextStyle.sectionText()),
      ],
    );
  }
}
