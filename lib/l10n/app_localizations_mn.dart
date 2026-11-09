// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([String locale = 'mn']) : super(locale);

  @override
  String get appTitle => 'Hostel Manager';

  @override
  String get tabHome => 'Нүүр';

  @override
  String get tabCleaning => 'Цэвэрлэгээ';

  @override
  String get tabPurchases => 'Зардал';

  @override
  String get tabReports => 'Асуудал';

  @override
  String get tabProfile => 'Профайл';

  @override
  String get toastSuccessTitle => 'Амжилттай';

  @override
  String get toastErrorTitle => 'Уучлаарай';

  @override
  String get toastErrorDescription => 'Алдаа гарлаа.';

  @override
  String get emptyDefault => 'Хоосон байна';
}
