import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In mn, this message translates to:
  /// **'Hostel Manager'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In mn, this message translates to:
  /// **'Нүүр'**
  String get tabHome;

  /// No description provided for @tabCleaning.
  ///
  /// In mn, this message translates to:
  /// **'Цэвэрлэгээ'**
  String get tabCleaning;

  /// No description provided for @tabPurchases.
  ///
  /// In mn, this message translates to:
  /// **'Зардал'**
  String get tabPurchases;

  /// No description provided for @tabReports.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдэл'**
  String get tabReports;

  /// No description provided for @tabProfile.
  ///
  /// In mn, this message translates to:
  /// **'Профайл'**
  String get tabProfile;

  /// No description provided for @toastSuccessTitle.
  ///
  /// In mn, this message translates to:
  /// **'Амжилттай'**
  String get toastSuccessTitle;

  /// No description provided for @toastErrorTitle.
  ///
  /// In mn, this message translates to:
  /// **'Уучлаарай'**
  String get toastErrorTitle;

  /// No description provided for @toastErrorDescription.
  ///
  /// In mn, this message translates to:
  /// **'Алдаа гарлаа.'**
  String get toastErrorDescription;

  /// No description provided for @emptyDefault.
  ///
  /// In mn, this message translates to:
  /// **'Хоосон байна'**
  String get emptyDefault;

  /// No description provided for @authPhoneTitle.
  ///
  /// In mn, this message translates to:
  /// **'Утасны дугаараа оруулна уу'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In mn, this message translates to:
  /// **'Бид таны дугаарыг SMS-ээр баталгаажуулж, байрныхаа бусад оршин суугчидтай холбоно.'**
  String get authPhoneSubtitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In mn, this message translates to:
  /// **'Утасны дугаар'**
  String get authPhoneLabel;

  /// No description provided for @authPhonePrivacy.
  ///
  /// In mn, this message translates to:
  /// **'Таны дугаарыг бусад хэрэглэгчид харахгүй.'**
  String get authPhonePrivacy;

  /// No description provided for @authTermsPrefix.
  ///
  /// In mn, this message translates to:
  /// **'Үргэлжлүүлснээр та '**
  String get authTermsPrefix;

  /// No description provided for @authTermsService.
  ///
  /// In mn, this message translates to:
  /// **'Үйлчилгээний нөхцөл'**
  String get authTermsService;

  /// No description provided for @authTermsJoin.
  ///
  /// In mn, this message translates to:
  /// **' болон '**
  String get authTermsJoin;

  /// No description provided for @authTermsPrivacy.
  ///
  /// In mn, this message translates to:
  /// **'Нууцлалын бодлогыг'**
  String get authTermsPrivacy;

  /// No description provided for @authTermsSuffix.
  ///
  /// In mn, this message translates to:
  /// **' зөвшөөрч байна.'**
  String get authTermsSuffix;

  /// No description provided for @authSmsSubtitle.
  ///
  /// In mn, this message translates to:
  /// **'{phone} дугаараасаа доорх мессежийг илгээж баталгаажуулна уу.'**
  String authSmsSubtitle(String phone);

  /// No description provided for @authSmsRecipient.
  ///
  /// In mn, this message translates to:
  /// **'Хүлээн авагч'**
  String get authSmsRecipient;

  /// No description provided for @authSmsMessage.
  ///
  /// In mn, this message translates to:
  /// **'Мессеж'**
  String get authSmsMessage;

  /// No description provided for @authSmsCopy.
  ///
  /// In mn, this message translates to:
  /// **'Хуулах'**
  String get authSmsCopy;

  /// No description provided for @authSmsCopied.
  ///
  /// In mn, this message translates to:
  /// **'Хуулсан'**
  String get authSmsCopied;

  /// No description provided for @authSmsDualSim.
  ///
  /// In mn, this message translates to:
  /// **'2 SIM-тэй бол {phone} дугаартай SIM-ээ сонгож илгээнэ үү.'**
  String authSmsDualSim(String phone);

  /// No description provided for @authSmsWaitingHint.
  ///
  /// In mn, this message translates to:
  /// **'Ихэвчлэн 10–30 секундэд баталгаажна'**
  String get authSmsWaitingHint;

  /// No description provided for @authSmsChangeNumber.
  ///
  /// In mn, this message translates to:
  /// **'Дугаар солих'**
  String get authSmsChangeNumber;

  /// No description provided for @authContinue.
  ///
  /// In mn, this message translates to:
  /// **'Үргэлжлүүлэх'**
  String get authContinue;

  /// No description provided for @authSmsTitle.
  ///
  /// In mn, this message translates to:
  /// **'SMS-ээр баталгаажуулах'**
  String get authSmsTitle;

  /// No description provided for @authSmsOpen.
  ///
  /// In mn, this message translates to:
  /// **'SMS илгээх'**
  String get authSmsOpen;

  /// No description provided for @authSmsCost.
  ///
  /// In mn, this message translates to:
  /// **'Илгээсэн SMS бүрт оператор ₮150 суутгана.'**
  String get authSmsCost;

  /// No description provided for @authSmsWaiting.
  ///
  /// In mn, this message translates to:
  /// **'SMS хүлээж байна...'**
  String get authSmsWaiting;

  /// No description provided for @authSmsExpired.
  ///
  /// In mn, this message translates to:
  /// **'Хугацаа дууслаа. Хуучин код хүчингүй болсон.'**
  String get authSmsExpired;

  /// No description provided for @authSmsNewCode.
  ///
  /// In mn, this message translates to:
  /// **'Шинэ код авах'**
  String get authSmsNewCode;

  /// No description provided for @authSmsOpenFailed.
  ///
  /// In mn, this message translates to:
  /// **'SMS апп нээгдсэнгүй. Зааврын дагуу гараар илгээнэ үү.'**
  String get authSmsOpenFailed;

  /// No description provided for @authPendingTitle.
  ///
  /// In mn, this message translates to:
  /// **'Зөвшөөрөл хүлээж байна'**
  String get authPendingTitle;

  /// No description provided for @authPendingBody.
  ///
  /// In mn, this message translates to:
  /// **'Менежер таны бүртгэлийг баталгаажуулсны дараа апп ашиглах боломжтой.'**
  String get authPendingBody;

  /// No description provided for @authPendingCheck.
  ///
  /// In mn, this message translates to:
  /// **'Дахин шалгах'**
  String get authPendingCheck;

  /// No description provided for @profileSignOut.
  ///
  /// In mn, this message translates to:
  /// **'Гарах'**
  String get profileSignOut;

  /// No description provided for @authNameTitle.
  ///
  /// In mn, this message translates to:
  /// **'Нэрээ оруулна уу'**
  String get authNameTitle;

  /// No description provided for @authNameSubtitle.
  ///
  /// In mn, this message translates to:
  /// **'Хуваарь, зардал дээр бусад оршин суугчид таны нэрийг харна.'**
  String get authNameSubtitle;

  /// No description provided for @authNameLabel.
  ///
  /// In mn, this message translates to:
  /// **'Нэр'**
  String get authNameLabel;

  /// No description provided for @cleaningTitle.
  ///
  /// In mn, this message translates to:
  /// **'Цэвэрлэгээний хуваарь'**
  String get cleaningTitle;

  /// No description provided for @cleaningYou.
  ///
  /// In mn, this message translates to:
  /// **'Та'**
  String get cleaningYou;

  /// No description provided for @cleaningUnnamed.
  ///
  /// In mn, this message translates to:
  /// **'Нэр оруулаагүй'**
  String get cleaningUnnamed;

  /// No description provided for @cleaningDaysLeft.
  ///
  /// In mn, this message translates to:
  /// **'{count} өдөр үлдсэн'**
  String cleaningDaysLeft(int count);

  /// No description provided for @cleaningStatusUpcoming.
  ///
  /// In mn, this message translates to:
  /// **'Удахгүй'**
  String get cleaningStatusUpcoming;

  /// No description provided for @cleaningStatusActive.
  ///
  /// In mn, this message translates to:
  /// **'Явцад'**
  String get cleaningStatusActive;

  /// No description provided for @cleaningStatusDone.
  ///
  /// In mn, this message translates to:
  /// **'Дууссан'**
  String get cleaningStatusDone;

  /// No description provided for @cleaningStatusMissed.
  ///
  /// In mn, this message translates to:
  /// **'Хийгээгүй'**
  String get cleaningStatusMissed;

  /// No description provided for @cleaningAreasTitle.
  ///
  /// In mn, this message translates to:
  /// **'Цэвэрлэх газрууд'**
  String get cleaningAreasTitle;

  /// No description provided for @cleaningNoAreas.
  ///
  /// In mn, this message translates to:
  /// **'Цэвэрлэх газар нэмээгүй байна.'**
  String get cleaningNoAreas;

  /// No description provided for @cleaningSwapAction.
  ///
  /// In mn, this message translates to:
  /// **'Ээлж солих'**
  String get cleaningSwapAction;

  /// No description provided for @cleaningSwapSheetTitle.
  ///
  /// In mn, this message translates to:
  /// **'Хэнтэй солих вэ?'**
  String get cleaningSwapSheetTitle;

  /// No description provided for @cleaningSwapSheetBody.
  ///
  /// In mn, this message translates to:
  /// **'Таны ээлж: {dates}'**
  String cleaningSwapSheetBody(String dates);

  /// No description provided for @cleaningSwapSent.
  ///
  /// In mn, this message translates to:
  /// **'Хүсэлт илгээлээ. Нөгөө хүн зөвшөөрсний дараа солигдоно.'**
  String get cleaningSwapSent;

  /// No description provided for @cleaningSwapIncoming.
  ///
  /// In mn, this message translates to:
  /// **'{name} таны {mine} ээлжийг өөрийн {theirs} ээлжтэй солихыг хүсэж байна.'**
  String cleaningSwapIncoming(String name, String mine, String theirs);

  /// No description provided for @cleaningSwapOutgoing.
  ///
  /// In mn, this message translates to:
  /// **'Солих хүсэлт хүлээгдэж байна: {name}, {mine} ↔ {theirs}'**
  String cleaningSwapOutgoing(String name, String mine, String theirs);

  /// No description provided for @cleaningAccept.
  ///
  /// In mn, this message translates to:
  /// **'Зөвшөөрөх'**
  String get cleaningAccept;

  /// No description provided for @cleaningDecline.
  ///
  /// In mn, this message translates to:
  /// **'Татгалзах'**
  String get cleaningDecline;

  /// No description provided for @cleaningCancelRequest.
  ///
  /// In mn, this message translates to:
  /// **'Цуцлах'**
  String get cleaningCancelRequest;

  /// No description provided for @cleaningUpcomingTitle.
  ///
  /// In mn, this message translates to:
  /// **'Ээлжийн хуваарь'**
  String get cleaningUpcomingTitle;

  /// No description provided for @cleaningNotStarted.
  ///
  /// In mn, this message translates to:
  /// **'Хуваарь хараахан эхлээгүй байна.'**
  String get cleaningNotStarted;

  /// No description provided for @cleaningLoadFailed.
  ///
  /// In mn, this message translates to:
  /// **'Хуваарийг ачаалж чадсангүй.'**
  String get cleaningLoadFailed;

  /// No description provided for @cleaningRetry.
  ///
  /// In mn, this message translates to:
  /// **'Дахин оролдох'**
  String get cleaningRetry;

  /// No description provided for @cleaningManageTitle.
  ///
  /// In mn, this message translates to:
  /// **'Хуваарь удирдах'**
  String get cleaningManageTitle;

  /// No description provided for @cleaningManagePending.
  ///
  /// In mn, this message translates to:
  /// **'Шинэ бүртгэл'**
  String get cleaningManagePending;

  /// No description provided for @cleaningManageOrder.
  ///
  /// In mn, this message translates to:
  /// **'Ээлжийн дараалал'**
  String get cleaningManageOrder;

  /// No description provided for @cleaningManageOrderHint.
  ///
  /// In mn, this message translates to:
  /// **'Өөрчлөлт дараагийн ээлжээс хэрэгжинэ.'**
  String get cleaningManageOrderHint;

  /// No description provided for @cleaningRemoveFromRotation.
  ///
  /// In mn, this message translates to:
  /// **'Ээлжээс хасах'**
  String get cleaningRemoveFromRotation;

  /// No description provided for @cleaningAddToRotation.
  ///
  /// In mn, this message translates to:
  /// **'Нэмэх'**
  String get cleaningAddToRotation;

  /// No description provided for @cleaningSave.
  ///
  /// In mn, this message translates to:
  /// **'Хадгалах'**
  String get cleaningSave;

  /// No description provided for @cleaningMoveOutTitle.
  ///
  /// In mn, this message translates to:
  /// **'Байрнаас хасах уу?'**
  String get cleaningMoveOutTitle;

  /// No description provided for @cleaningMoveOutBody.
  ///
  /// In mn, this message translates to:
  /// **'{name} апп ашиглах эрхээ алдаж, дараагийн ээлжээс хасагдана.'**
  String cleaningMoveOutBody(String name);

  /// No description provided for @cleaningMoveOutConfirm.
  ///
  /// In mn, this message translates to:
  /// **'Хасах'**
  String get cleaningMoveOutConfirm;

  /// No description provided for @cleaningRemoveArea.
  ///
  /// In mn, this message translates to:
  /// **'Устгах'**
  String get cleaningRemoveArea;

  /// No description provided for @cleaningNewAreaHint.
  ///
  /// In mn, this message translates to:
  /// **'Шинэ газрын нэр'**
  String get cleaningNewAreaHint;

  /// No description provided for @cleaningThisPeriod.
  ///
  /// In mn, this message translates to:
  /// **'Энэ ээлж'**
  String get cleaningThisPeriod;

  /// No description provided for @cleaningProgress.
  ///
  /// In mn, this message translates to:
  /// **'{done}/{total} хийгдсэн'**
  String cleaningProgress(int done, int total);

  /// No description provided for @cleaningAreaCount.
  ///
  /// In mn, this message translates to:
  /// **'{count} ажил'**
  String cleaningAreaCount(int count);

  /// No description provided for @cleaningYourTurn.
  ///
  /// In mn, this message translates to:
  /// **'Таны ээлж'**
  String get cleaningYourTurn;

  /// No description provided for @cleaningAreaDone.
  ///
  /// In mn, this message translates to:
  /// **'Хийсэн'**
  String get cleaningAreaDone;

  /// No description provided for @cleaningAreaNotDone.
  ///
  /// In mn, this message translates to:
  /// **'Хийгээгүй'**
  String get cleaningAreaNotDone;

  /// No description provided for @cleaningFinish.
  ///
  /// In mn, this message translates to:
  /// **'Дууссан'**
  String get cleaningFinish;

  /// No description provided for @cleaningNextTurnLine.
  ///
  /// In mn, this message translates to:
  /// **'Таны дараагийн ээлж: {dates}'**
  String cleaningNextTurnLine(String dates);

  /// No description provided for @cleaningLongDate.
  ///
  /// In mn, this message translates to:
  /// **'{month}-р сарын {day}, {weekday}'**
  String cleaningLongDate(String month, String day, String weekday);

  /// No description provided for @weekdayShortMon.
  ///
  /// In mn, this message translates to:
  /// **'Да'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In mn, this message translates to:
  /// **'Мя'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In mn, this message translates to:
  /// **'Лх'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In mn, this message translates to:
  /// **'Пү'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In mn, this message translates to:
  /// **'Ба'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In mn, this message translates to:
  /// **'Бя'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In mn, this message translates to:
  /// **'Ня'**
  String get weekdayShortSun;

  /// No description provided for @weekdayLongMon.
  ///
  /// In mn, this message translates to:
  /// **'Даваа'**
  String get weekdayLongMon;

  /// No description provided for @weekdayLongTue.
  ///
  /// In mn, this message translates to:
  /// **'Мягмар'**
  String get weekdayLongTue;

  /// No description provided for @weekdayLongWed.
  ///
  /// In mn, this message translates to:
  /// **'Лхагва'**
  String get weekdayLongWed;

  /// No description provided for @weekdayLongThu.
  ///
  /// In mn, this message translates to:
  /// **'Пүрэв'**
  String get weekdayLongThu;

  /// No description provided for @weekdayLongFri.
  ///
  /// In mn, this message translates to:
  /// **'Баасан'**
  String get weekdayLongFri;

  /// No description provided for @weekdayLongSat.
  ///
  /// In mn, this message translates to:
  /// **'Бямба'**
  String get weekdayLongSat;

  /// No description provided for @weekdayLongSun.
  ///
  /// In mn, this message translates to:
  /// **'Ням'**
  String get weekdayLongSun;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mn':
      return AppLocalizationsMn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
