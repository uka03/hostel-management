import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/profile/provider/banks.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';

typedef BankAccountInput = ({String bank, String number, String holder});

Future<BankAccountInput?> showBankAccountSheet(
  BuildContext context,
  UserResponseData? user,
) {
  return showModalBottomSheet<BankAccountInput>(
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
      child: SafeArea(child: _BankAccountForm(user: user)),
    ),
  );
}

class _BankAccountForm extends StatefulWidget {
  const _BankAccountForm({required this.user});

  final UserResponseData? user;

  @override
  State<_BankAccountForm> createState() => _BankAccountFormState();
}

class _BankAccountFormState extends State<_BankAccountForm> {
  late String? _bank = widget.user?.bankName;
  late final _number = TextEditingController(
    text: widget.user?.bankAccountNumber ?? '',
  );
  late final _holder = TextEditingController(
    text: widget.user?.bankAccountHolder ?? widget.user?.name ?? '',
  );

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bank = _bank;
    final number = _number.text;
    final holder = _holder.text.trim();
    final isValid = bank != null && number.length >= 4 && holder.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.profileBankTitle, style: GeneralTextStyle.sectionText()),
        VSpacer(size: 12),
        DropdownButtonFormField<String>(
          initialValue: bank,
          isExpanded: true,
          hint: Text(l10n.purchasesPayBank),
          items: [
            for (final name in mongolianBanks)
              DropdownMenuItem(value: name, child: Text(name)),
          ],
          onChanged: (value) => setState(() => _bank = value),
        ),
        VSpacer.sm(),
        TextField(
          controller: _number,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(20),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: l10n.purchasesPayAccountNumber),
        ),
        VSpacer.sm(),
        TextField(
          controller: _holder,
          maxLength: 60,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.purchasesPayAccountHolder,
            counterText: '',
          ),
        ),
        VSpacer(size: 12),
        PrimaryButton(
          title: l10n.purchasesSave,
          isEnable: isValid,
          disabledColor: GeneralColors.borderColor,
          onPressed: () =>
              Navigator.of(context)
                  .pop((bank: bank!, number: number, holder: holder)),
        ),
      ],
    );
  }
}
