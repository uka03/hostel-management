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

  /// No description provided for @reportsSubtitle.
  ///
  /// In mn, this message translates to:
  /// **'Бүх мэдэгдэл нэргүй'**
  String get reportsSubtitle;

  /// No description provided for @reportsFilterAll.
  ///
  /// In mn, this message translates to:
  /// **'Бүгд'**
  String get reportsFilterAll;

  /// No description provided for @reportsStatusOpen.
  ///
  /// In mn, this message translates to:
  /// **'Нээлттэй'**
  String get reportsStatusOpen;

  /// No description provided for @reportsStatusInProgress.
  ///
  /// In mn, this message translates to:
  /// **'Явцад'**
  String get reportsStatusInProgress;

  /// No description provided for @reportsStatusResolved.
  ///
  /// In mn, this message translates to:
  /// **'Шийдэгдсэн'**
  String get reportsStatusResolved;

  /// No description provided for @reportsCategoryNoise.
  ///
  /// In mn, this message translates to:
  /// **'Чимээ шуугиан'**
  String get reportsCategoryNoise;

  /// No description provided for @reportsCategoryHygiene.
  ///
  /// In mn, this message translates to:
  /// **'Ариун цэвэр'**
  String get reportsCategoryHygiene;

  /// No description provided for @reportsCategoryDamage.
  ///
  /// In mn, this message translates to:
  /// **'Эвдрэл / Засвар'**
  String get reportsCategoryDamage;

  /// No description provided for @reportsCategorySafety.
  ///
  /// In mn, this message translates to:
  /// **'Аюулгүй байдал'**
  String get reportsCategorySafety;

  /// No description provided for @reportsCategoryOther.
  ///
  /// In mn, this message translates to:
  /// **'Бусад'**
  String get reportsCategoryOther;

  /// No description provided for @reportsAgeRecent.
  ///
  /// In mn, this message translates to:
  /// **'Саяхан'**
  String get reportsAgeRecent;

  /// No description provided for @reportsAgeHours.
  ///
  /// In mn, this message translates to:
  /// **'{hours} цагийн өмнө'**
  String reportsAgeHours(int hours);

  /// No description provided for @reportsAgeYesterday.
  ///
  /// In mn, this message translates to:
  /// **'Өчигдөр'**
  String get reportsAgeYesterday;

  /// No description provided for @reportsAnonymousAuthor.
  ///
  /// In mn, this message translates to:
  /// **'Нэргүй оршин суугч'**
  String get reportsAnonymousAuthor;

  /// No description provided for @reportsManagerReply.
  ///
  /// In mn, this message translates to:
  /// **'Менежер: {reply}'**
  String reportsManagerReply(String reply);

  /// No description provided for @reportsVote.
  ///
  /// In mn, this message translates to:
  /// **'Надад ч бас'**
  String get reportsVote;

  /// No description provided for @reportsEmpty.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдэл алга байна.'**
  String get reportsEmpty;

  /// No description provided for @reportsLoadFailed.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдлүүдийг ачаалж чадсангүй.'**
  String get reportsLoadFailed;

  /// No description provided for @reportsFormTitle.
  ///
  /// In mn, this message translates to:
  /// **'Асуудал мэдэгдэх'**
  String get reportsFormTitle;

  /// No description provided for @reportsAnonymousTitle.
  ///
  /// In mn, this message translates to:
  /// **'Та нэргүй байна'**
  String get reportsAnonymousTitle;

  /// No description provided for @reportsAnonymousBody.
  ///
  /// In mn, this message translates to:
  /// **'Таны нэр, өрөөний дугаар бусад оршин суугч болон менежерт хэзээ ч харагдахгүй.'**
  String get reportsAnonymousBody;

  /// No description provided for @reportsCategoryLabel.
  ///
  /// In mn, this message translates to:
  /// **'Ангилал'**
  String get reportsCategoryLabel;

  /// No description provided for @reportsLocationLabel.
  ///
  /// In mn, this message translates to:
  /// **'Байршил'**
  String get reportsLocationLabel;

  /// No description provided for @reportsLocationHint.
  ///
  /// In mn, this message translates to:
  /// **'Жишээ: 2-р давхрын коридор'**
  String get reportsLocationHint;

  /// No description provided for @reportsDescriptionLabel.
  ///
  /// In mn, this message translates to:
  /// **'Асуудлаа тайлбарлана уу'**
  String get reportsDescriptionLabel;

  /// No description provided for @reportsPhotoAdd.
  ///
  /// In mn, this message translates to:
  /// **'Зураг нэмэх (заавал биш)'**
  String get reportsPhotoAdd;

  /// No description provided for @reportsPhotoNote.
  ///
  /// In mn, this message translates to:
  /// **'Зургийн байршил, төхөөрөмжийн мэдээллийг автоматаар устгана.'**
  String get reportsPhotoNote;

  /// No description provided for @reportsPhotoCamera.
  ///
  /// In mn, this message translates to:
  /// **'Зураг авах'**
  String get reportsPhotoCamera;

  /// No description provided for @reportsPhotoGallery.
  ///
  /// In mn, this message translates to:
  /// **'Зургийн сангаас сонгох'**
  String get reportsPhotoGallery;

  /// No description provided for @reportsPhotoRemove.
  ///
  /// In mn, this message translates to:
  /// **'Зураг хасах'**
  String get reportsPhotoRemove;

  /// No description provided for @reportsPhotoFailed.
  ///
  /// In mn, this message translates to:
  /// **'Зургийг ашиглаж чадсангүй.'**
  String get reportsPhotoFailed;

  /// No description provided for @reportsSend.
  ///
  /// In mn, this message translates to:
  /// **'Нэргүйгээр илгээх'**
  String get reportsSend;

  /// No description provided for @reportsSent.
  ///
  /// In mn, this message translates to:
  /// **'Нэргүйгээр илгээгдлээ.'**
  String get reportsSent;

  /// No description provided for @reportsRateLimited.
  ///
  /// In mn, this message translates to:
  /// **'Өнөөдөр хэт олон мэдэгдэл илгээсэн байна. Маргааш дахин оролдоно уу.'**
  String get reportsRateLimited;

  /// No description provided for @reportsManagerTitle.
  ///
  /// In mn, this message translates to:
  /// **'Менежерийн хариу'**
  String get reportsManagerTitle;

  /// No description provided for @reportsReplyHint.
  ///
  /// In mn, this message translates to:
  /// **'Хариугаа бичнэ үү'**
  String get reportsReplyHint;

  /// No description provided for @reportsSaved.
  ///
  /// In mn, this message translates to:
  /// **'Хадгалагдлаа.'**
  String get reportsSaved;

  /// No description provided for @purchasesTitle.
  ///
  /// In mn, this message translates to:
  /// **'Хамтын худалдан авалт'**
  String get purchasesTitle;

  /// No description provided for @purchasesSubtitle.
  ///
  /// In mn, this message translates to:
  /// **'{count} хүнд тэнцүү хуваана'**
  String purchasesSubtitle(int count);

  /// No description provided for @purchasesFundLabel.
  ///
  /// In mn, this message translates to:
  /// **'Хамтын сан'**
  String get purchasesFundLabel;

  /// No description provided for @purchasesYouPaid.
  ///
  /// In mn, this message translates to:
  /// **'Та төлсөн'**
  String get purchasesYouPaid;

  /// No description provided for @purchasesYourShare.
  ///
  /// In mn, this message translates to:
  /// **'Таны хувь'**
  String get purchasesYourShare;

  /// No description provided for @purchasesGetBack.
  ///
  /// In mn, this message translates to:
  /// **'Танд буцаж ирэх {amount}'**
  String purchasesGetBack(String amount);

  /// No description provided for @purchasesYouOwe.
  ///
  /// In mn, this message translates to:
  /// **'Таны төлөх {amount}'**
  String purchasesYouOwe(String amount);

  /// No description provided for @purchasesNeededTitle.
  ///
  /// In mn, this message translates to:
  /// **'Шаардлагатай бараа'**
  String get purchasesNeededTitle;

  /// No description provided for @purchasesNoNeeded.
  ///
  /// In mn, this message translates to:
  /// **'Шаардлагатай бараа алга.'**
  String get purchasesNoNeeded;

  /// No description provided for @purchasesClaim.
  ///
  /// In mn, this message translates to:
  /// **'Би авна'**
  String get purchasesClaim;

  /// No description provided for @purchasesReceipt.
  ///
  /// In mn, this message translates to:
  /// **'Баримт'**
  String get purchasesReceipt;

  /// No description provided for @purchasesClaimedByYou.
  ///
  /// In mn, this message translates to:
  /// **'Та авахаар болсон'**
  String get purchasesClaimedByYou;

  /// No description provided for @purchasesClaimedBy.
  ///
  /// In mn, this message translates to:
  /// **'{name} авахаар болсон'**
  String purchasesClaimedBy(String name);

  /// No description provided for @purchasesRequestedToday.
  ///
  /// In mn, this message translates to:
  /// **'Өнөөдөр хүссэн'**
  String get purchasesRequestedToday;

  /// No description provided for @purchasesRequestedYesterday.
  ///
  /// In mn, this message translates to:
  /// **'Өчигдөр хүссэн'**
  String get purchasesRequestedYesterday;

  /// No description provided for @purchasesRequestedDays.
  ///
  /// In mn, this message translates to:
  /// **'{days} өдрийн өмнө хүссэн'**
  String purchasesRequestedDays(int days);

  /// No description provided for @purchasesRemoveItem.
  ///
  /// In mn, this message translates to:
  /// **'Хүсэлт устгах'**
  String get purchasesRemoveItem;

  /// No description provided for @purchasesSeeAll.
  ///
  /// In mn, this message translates to:
  /// **'Бүгдийг харах'**
  String get purchasesSeeAll;

  /// No description provided for @purchasesNoRecent.
  ///
  /// In mn, this message translates to:
  /// **'Худалдан авалт алга.'**
  String get purchasesNoRecent;

  /// No description provided for @purchasesPerPerson.
  ///
  /// In mn, this message translates to:
  /// **'{amount} / хүн'**
  String purchasesPerPerson(String amount);

  /// No description provided for @purchasesLoadFailed.
  ///
  /// In mn, this message translates to:
  /// **'Худалдан авалтыг ачаалж чадсангүй.'**
  String get purchasesLoadFailed;

  /// No description provided for @purchasesAddPurchase.
  ///
  /// In mn, this message translates to:
  /// **'Худалдан авалт нэмэх'**
  String get purchasesAddPurchase;

  /// No description provided for @purchasesAddItem.
  ///
  /// In mn, this message translates to:
  /// **'Шаардлагатай бараа нэмэх'**
  String get purchasesAddItem;

  /// No description provided for @purchasesItemName.
  ///
  /// In mn, this message translates to:
  /// **'Барааны нэр'**
  String get purchasesItemName;

  /// No description provided for @purchasesAmount.
  ///
  /// In mn, this message translates to:
  /// **'Дүн'**
  String get purchasesAmount;

  /// No description provided for @purchasesEachPays.
  ///
  /// In mn, this message translates to:
  /// **'{people} хүнд хуваавал нэг хүнд {amount}'**
  String purchasesEachPays(int people, String amount);

  /// No description provided for @purchasesSave.
  ///
  /// In mn, this message translates to:
  /// **'Хадгалах'**
  String get purchasesSave;

  /// No description provided for @purchasesReceiptHint.
  ///
  /// In mn, this message translates to:
  /// **'Баримтын дүнгээ оруулна уу.'**
  String get purchasesReceiptHint;

  /// No description provided for @purchasesGiveUpItem.
  ///
  /// In mn, this message translates to:
  /// **'Авахаа болих'**
  String get purchasesGiveUpItem;

  /// No description provided for @purchasesDeleteTitle.
  ///
  /// In mn, this message translates to:
  /// **'Устгах уу?'**
  String get purchasesDeleteTitle;

  /// No description provided for @purchasesDeleteBody.
  ///
  /// In mn, this message translates to:
  /// **'Энэ худалдан авалт бүх хүний тооцооноос хасагдана.'**
  String get purchasesDeleteBody;

  /// No description provided for @purchasesMarkPaid.
  ///
  /// In mn, this message translates to:
  /// **'Төлсөн'**
  String get purchasesMarkPaid;

  /// No description provided for @purchasesPay.
  ///
  /// In mn, this message translates to:
  /// **'Төлөх'**
  String get purchasesPay;

  /// No description provided for @purchasesPaidCount.
  ///
  /// In mn, this message translates to:
  /// **'{paid}/{total} төлсөн'**
  String purchasesPaidCount(int paid, int total);

  /// No description provided for @purchasesPayTitle.
  ///
  /// In mn, this message translates to:
  /// **'Төлбөр төлөх'**
  String get purchasesPayTitle;

  /// No description provided for @purchasesPayBank.
  ///
  /// In mn, this message translates to:
  /// **'Банк'**
  String get purchasesPayBank;

  /// No description provided for @purchasesPayAccountNumber.
  ///
  /// In mn, this message translates to:
  /// **'Дансны дугаар'**
  String get purchasesPayAccountNumber;

  /// No description provided for @purchasesPayAccountHolder.
  ///
  /// In mn, this message translates to:
  /// **'Данс эзэмшигчийн нэр'**
  String get purchasesPayAccountHolder;

  /// No description provided for @purchasesPayNoAccount.
  ///
  /// In mn, this message translates to:
  /// **'{name} дансны мэдээллээ оруулаагүй байна. Биечлэн төлж болно.'**
  String purchasesPayNoAccount(String name);

  /// No description provided for @purchasesPayLoadFailed.
  ///
  /// In mn, this message translates to:
  /// **'Дансны мэдээллийг ачаалж чадсангүй.'**
  String get purchasesPayLoadFailed;

  /// No description provided for @purchasesPayClose.
  ///
  /// In mn, this message translates to:
  /// **'Хаах'**
  String get purchasesPayClose;

  /// No description provided for @purchasesUnpaidTitle.
  ///
  /// In mn, this message translates to:
  /// **'Төлөөгүй худалдан авалт'**
  String get purchasesUnpaidTitle;

  /// No description provided for @purchasesUnpaidNone.
  ///
  /// In mn, this message translates to:
  /// **'Бүх худалдан авалтаа төлсөн байна.'**
  String get purchasesUnpaidNone;

  /// No description provided for @purchasesHistoryTitle.
  ///
  /// In mn, this message translates to:
  /// **'Худалдан авалтын түүх'**
  String get purchasesHistoryTitle;

  /// No description provided for @profileBankTitle.
  ///
  /// In mn, this message translates to:
  /// **'Дансны мэдээлэл'**
  String get profileBankTitle;

  /// No description provided for @profileEditName.
  ///
  /// In mn, this message translates to:
  /// **'Нэр засах'**
  String get profileEditName;

  /// No description provided for @profileRoleResident.
  ///
  /// In mn, this message translates to:
  /// **'Оршин суугч'**
  String get profileRoleResident;

  /// No description provided for @profileRoleManager.
  ///
  /// In mn, this message translates to:
  /// **'Менежер'**
  String get profileRoleManager;

  /// No description provided for @profileApartment.
  ///
  /// In mn, this message translates to:
  /// **'Манай байр'**
  String get profileApartment;

  /// No description provided for @profileResidentCount.
  ///
  /// In mn, this message translates to:
  /// **'{count} оршин суугч'**
  String profileResidentCount(int count);

  /// No description provided for @profileStatCleaned.
  ///
  /// In mn, this message translates to:
  /// **'Удаа цэвэрлэсэн'**
  String get profileStatCleaned;

  /// No description provided for @profileStatNextTurn.
  ///
  /// In mn, this message translates to:
  /// **'Дараагийн ээлж'**
  String get profileStatNextTurn;

  /// No description provided for @profileStatGetBack.
  ///
  /// In mn, this message translates to:
  /// **'Буцаж авах'**
  String get profileStatGetBack;

  /// No description provided for @profileStatOwe.
  ///
  /// In mn, this message translates to:
  /// **'Төлөх'**
  String get profileStatOwe;

  /// No description provided for @profileBankNone.
  ///
  /// In mn, this message translates to:
  /// **'Данс нэмээгүй байна'**
  String get profileBankNone;

  /// No description provided for @profileNotifications.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдэл'**
  String get profileNotifications;

  /// No description provided for @profileLanguage.
  ///
  /// In mn, this message translates to:
  /// **'Хэл'**
  String get profileLanguage;

  /// No description provided for @languageMongolian.
  ///
  /// In mn, this message translates to:
  /// **'Монгол'**
  String get languageMongolian;

  /// No description provided for @languageEnglish.
  ///
  /// In mn, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @profilePrivacy.
  ///
  /// In mn, this message translates to:
  /// **'Нууцлал'**
  String get profilePrivacy;

  /// No description provided for @profilePrivacySubtitle.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдлүүд таны нэртэй холбогдохгүй'**
  String get profilePrivacySubtitle;

  /// No description provided for @profilePrivacyBody.
  ///
  /// In mn, this message translates to:
  /// **'Таны илгээсэн мэдэгдэл нэргүй бөгөөд бусад оршин суугч, менежер хэн илгээснийг харах боломжгүй. Утасны дугаар тань бусад хэрэглэгчид харагдахгүй. Дансны мэдээлэл тань зөвхөн таны авсан зүйлд хувиа төлөх хүмүүст харагдана.'**
  String get profilePrivacyBody;

  /// No description provided for @profileHelp.
  ///
  /// In mn, this message translates to:
  /// **'Тусламж'**
  String get profileHelp;

  /// No description provided for @profileHelpBody.
  ///
  /// In mn, this message translates to:
  /// **'Асуудал гарвал байрныхаа менежертэй холбогдоно уу.'**
  String get profileHelpBody;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In mn, this message translates to:
  /// **'Гарах уу?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In mn, this message translates to:
  /// **'Дахин нэвтрэхэд SMS илгээх шаардлагатай.'**
  String get profileSignOutBody;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In mn, this message translates to:
  /// **'Өглөөний мэнд,'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In mn, this message translates to:
  /// **'Өдрийн мэнд,'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In mn, this message translates to:
  /// **'Оройн мэнд,'**
  String get homeGreetingEvening;

  /// No description provided for @homeCurrentDutyLabel.
  ///
  /// In mn, this message translates to:
  /// **'Таны жижүүр'**
  String get homeCurrentDutyLabel;

  /// No description provided for @homeNextDutyLabel.
  ///
  /// In mn, this message translates to:
  /// **'Таны дараагийн жижүүр'**
  String get homeNextDutyLabel;

  /// No description provided for @homeDutyTitle.
  ///
  /// In mn, this message translates to:
  /// **'Нийтийн талбайн цэвэрлэгээ'**
  String get homeDutyTitle;

  /// No description provided for @homeNoDuty.
  ///
  /// In mn, this message translates to:
  /// **'Ээлж товлогдоогүй'**
  String get homeNoDuty;

  /// No description provided for @homeMarkDone.
  ///
  /// In mn, this message translates to:
  /// **'Хийсэн гэж тэмдэглэх'**
  String get homeMarkDone;

  /// No description provided for @homeViewSchedule.
  ///
  /// In mn, this message translates to:
  /// **'Хуваарь харах'**
  String get homeViewSchedule;

  /// No description provided for @homeQuickTitle.
  ///
  /// In mn, this message translates to:
  /// **'Хурдан үйлдэл'**
  String get homeQuickTitle;

  /// No description provided for @homeItemsMissing.
  ///
  /// In mn, this message translates to:
  /// **'{count} бараа дутуу'**
  String homeItemsMissing(int count);

  /// No description provided for @homeReportAction.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдэх'**
  String get homeReportAction;

  /// No description provided for @homeAnonymous.
  ///
  /// In mn, this message translates to:
  /// **'Нэргүй'**
  String get homeAnonymous;

  /// No description provided for @homeActivityTitle.
  ///
  /// In mn, this message translates to:
  /// **'Сүүлийн үйл явдал'**
  String get homeActivityTitle;

  /// No description provided for @homeNoActivity.
  ///
  /// In mn, this message translates to:
  /// **'Одоохондоо үйл явдал алга.'**
  String get homeNoActivity;

  /// No description provided for @homeToday.
  ///
  /// In mn, this message translates to:
  /// **'Өнөөдөр'**
  String get homeToday;

  /// No description provided for @homeActivityCleaned.
  ///
  /// In mn, this message translates to:
  /// **'{name} цэвэрлэгээ хийлээ'**
  String homeActivityCleaned(String name);

  /// No description provided for @homeActivityBought.
  ///
  /// In mn, this message translates to:
  /// **'{name} {item} авлаа · {amount}'**
  String homeActivityBought(String name, String item, String amount);

  /// No description provided for @homeActivityReport.
  ///
  /// In mn, this message translates to:
  /// **'Нэргүй мэдэгдэл: {title}'**
  String homeActivityReport(String title);

  /// No description provided for @notificationsTitle.
  ///
  /// In mn, this message translates to:
  /// **'Сонордуулга'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In mn, this message translates to:
  /// **'Одоохондоо сонордуулга алга.'**
  String get notificationsEmpty;

  /// No description provided for @notificationPaid.
  ///
  /// In mn, this message translates to:
  /// **'{name} танд {amount} төллөө'**
  String notificationPaid(String name, String amount);

  /// No description provided for @notificationNewPurchase.
  ///
  /// In mn, this message translates to:
  /// **'{name} {item} авлаа · таны хувь {amount}'**
  String notificationNewPurchase(String name, String item, String amount);

  /// No description provided for @notificationReportNew.
  ///
  /// In mn, this message translates to:
  /// **'Шинэ нэргүй мэдэгдэл: {category} · {location}'**
  String notificationReportNew(String category, String location);

  /// No description provided for @notificationReportReplied.
  ///
  /// In mn, this message translates to:
  /// **'«{location}» мэдэгдэлд хариу ирлээ'**
  String notificationReportReplied(String location);

  /// No description provided for @notificationReportStatus.
  ///
  /// In mn, this message translates to:
  /// **'«{location}» мэдэгдэл: {status}'**
  String notificationReportStatus(String location, String status);
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
