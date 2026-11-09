import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/utils/text_styles.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      child: Text(
        AppLocalizations.of(context).tabPurchases,
        style: GeneralTextStyle.titleText(),
      ),
    );
  }
}
