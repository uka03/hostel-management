// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hostel Manager';

  @override
  String get tabHome => 'Home';

  @override
  String get tabCleaning => 'Cleaning';

  @override
  String get tabPurchases => 'Expenses';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabProfile => 'Profile';

  @override
  String get toastSuccessTitle => 'Success';

  @override
  String get toastErrorTitle => 'Sorry';

  @override
  String get toastErrorDescription => 'Something went wrong.';

  @override
  String get emptyDefault => 'Nothing here yet';
}
