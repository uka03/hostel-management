import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/provider/split.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _maxAmountDigits = 9;

int? _parseAmount(String text) {
  final amount = int.tryParse(text);
  if (amount == null || amount < 1 || amount > 100000000) return null;
  return amount;
}

Future<T?> _showSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: GeneralColors.cardColor,
    builder: (sheet) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(sheet).bottom + 20,
      ),
      child: SafeArea(child: child),
    ),
  );
}

enum AddChoice { purchase, item }

Future<AddChoice?> showAddChoiceSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<AddChoice>(
    context: context,
    backgroundColor: GeneralColors.cardColor,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.receipt),
            title: Text(l10n.purchasesAddPurchase),
            onTap: () => Navigator.of(sheet).pop(AddChoice.purchase),
          ),
          ListTile(
            leading: const Icon(LucideIcons.listPlus),
            title: Text(l10n.purchasesAddItem),
            onTap: () => Navigator.of(sheet).pop(AddChoice.item),
          ),
        ],
      ),
    ),
  );
}

Future<({String title, int amount})?> showAddPurchaseSheet(
  BuildContext context, {
  required int people,
}) => _showSheet(context, _PurchaseSheet(people: people));

Future<String?> showAddItemSheet(BuildContext context) =>
    _showSheet(context, const _ItemSheet());

/// What to do with a claimed item: a receipt amount, or null to give it up.
class ReceiptResult {
  const ReceiptResult(this.amount);

  final int? amount;
}

Future<ReceiptResult?> showReceiptSheet(
  BuildContext context, {
  required NeededItem item,
  required int people,
}) => _showSheet(context, _ReceiptSheet(item: item, people: people));

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.autofocus,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_maxAmountDigits),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).purchasesAmount,
        prefixText: '₮ ',
      ),
    );
  }
}

class _EachPays extends StatelessWidget {
  const _EachPays({required this.amount, required this.people});

  final int? amount;
  final int people;

  @override
  Widget build(BuildContext context) {
    final amount = this.amount;
    if (amount == null || people <= 0) return const SizedBox.shrink();
    final text = AppLocalizations.of(context)
        .purchasesEachPays(people, splitCost(amount, people).share.toMnt());
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: GeneralTextStyle.captionText()),
    );
  }
}

class _PurchaseSheet extends StatefulWidget {
  const _PurchaseSheet({required this.people});

  final int people;

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  final _title = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = _parseAmount(_amount.text);
    final title = _title.text.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.purchasesAddPurchase, style: GeneralTextStyle.sectionText()),
        VSpacer(size: 12),
        TextField(
          controller: _title,
          autofocus: true,
          maxLength: 80,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.purchasesItemName,
            counterText: '',
          ),
        ),
        VSpacer.sm(),
        _AmountField(
          controller: _amount,
          autofocus: false,
          onChanged: (_) => setState(() {}),
        ),
        _EachPays(amount: amount, people: widget.people),
        VSpacer(size: 12),
        PrimaryButton(
          title: l10n.purchasesSave,
          isEnable: amount != null && title.isNotEmpty,
          disabledColor: GeneralColors.borderColor,
          onPressed: () =>
              Navigator.of(context).pop((title: title, amount: amount!)),
        ),
      ],
    );
  }
}

class _ItemSheet extends StatefulWidget {
  const _ItemSheet();

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.purchasesAddItem, style: GeneralTextStyle.sectionText()),
        VSpacer(size: 12),
        TextField(
          controller: _name,
          autofocus: true,
          maxLength: 80,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.purchasesItemName,
            counterText: '',
          ),
        ),
        VSpacer(size: 12),
        PrimaryButton(
          title: l10n.purchasesSave,
          isEnable: name.isNotEmpty,
          disabledColor: GeneralColors.borderColor,
          onPressed: () => Navigator.of(context).pop(name),
        ),
      ],
    );
  }
}

class _ReceiptSheet extends StatefulWidget {
  const _ReceiptSheet({required this.item, required this.people});

  final NeededItem item;
  final int people;

  @override
  State<_ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends State<_ReceiptSheet> {
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = _parseAmount(_amount.text);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.item.name, style: GeneralTextStyle.sectionText()),
        VSpacer.xs(),
        Text(l10n.purchasesReceiptHint, style: GeneralTextStyle.captionText()),
        VSpacer(size: 12),
        _AmountField(
          controller: _amount,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        _EachPays(amount: amount, people: widget.people),
        VSpacer(size: 12),
        PrimaryButton(
          title: l10n.purchasesSave,
          isEnable: amount != null,
          disabledColor: GeneralColors.borderColor,
          onPressed: () => Navigator.of(context).pop(ReceiptResult(amount)),
        ),
        VSpacer.xs(),
        TextButton(
          onPressed: () => Navigator.of(context).pop(const ReceiptResult(null)),
          child: Text(
            l10n.purchasesGiveUpItem,
            style: GeneralTextStyle.bodyText(
              textColor: GeneralColors.mutedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
