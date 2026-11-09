import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/utils/text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      child: Text(
        AppLocalizations.of(context).tabHome,
        style: GeneralTextStyle.titleText(),
      ),
    );
  }
}
