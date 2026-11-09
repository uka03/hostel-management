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
  String get tabReports => 'Мэдэгдэл';

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

  @override
  String get authPhoneTitle => 'Утасны дугаараа оруулна уу';

  @override
  String get authPhoneSubtitle =>
      'Бид таны дугаарыг SMS-ээр баталгаажуулж, байрныхаа бусад оршин суугчидтай холбоно.';

  @override
  String get authPhoneLabel => 'Утасны дугаар';

  @override
  String get authPhonePrivacy => 'Таны дугаарыг бусад хэрэглэгчид харахгүй.';

  @override
  String get authTermsPrefix => 'Үргэлжлүүлснээр та ';

  @override
  String get authTermsService => 'Үйлчилгээний нөхцөл';

  @override
  String get authTermsJoin => ' болон ';

  @override
  String get authTermsPrivacy => 'Нууцлалын бодлогыг';

  @override
  String get authTermsSuffix => ' зөвшөөрч байна.';

  @override
  String authSmsSubtitle(String phone) {
    return '$phone дугаараасаа доорх мессежийг илгээж баталгаажуулна уу.';
  }

  @override
  String get authSmsRecipient => 'Хүлээн авагч';

  @override
  String get authSmsMessage => 'Мессеж';

  @override
  String get authSmsCopy => 'Хуулах';

  @override
  String get authSmsCopied => 'Хуулсан';

  @override
  String authSmsDualSim(String phone) {
    return '2 SIM-тэй бол $phone дугаартай SIM-ээ сонгож илгээнэ үү.';
  }

  @override
  String get authSmsWaitingHint => 'Ихэвчлэн 10–30 секундэд баталгаажна';

  @override
  String get authSmsChangeNumber => 'Дугаар солих';

  @override
  String get authContinue => 'Үргэлжлүүлэх';

  @override
  String get authSmsTitle => 'SMS-ээр баталгаажуулах';

  @override
  String get authSmsOpen => 'SMS илгээх';

  @override
  String get authSmsCost => 'Илгээсэн SMS бүрт оператор ₮150 суутгана.';

  @override
  String get authSmsWaiting => 'SMS хүлээж байна...';

  @override
  String get authSmsExpired => 'Хугацаа дууслаа. Хуучин код хүчингүй болсон.';

  @override
  String get authSmsNewCode => 'Шинэ код авах';

  @override
  String get authSmsOpenFailed =>
      'SMS апп нээгдсэнгүй. Зааврын дагуу гараар илгээнэ үү.';

  @override
  String get authPendingTitle => 'Зөвшөөрөл хүлээж байна';

  @override
  String get authPendingBody =>
      'Менежер таны бүртгэлийг баталгаажуулсны дараа апп ашиглах боломжтой.';

  @override
  String get authPendingCheck => 'Дахин шалгах';

  @override
  String get profileSignOut => 'Гарах';

  @override
  String get authNameTitle => 'Нэрээ оруулна уу';

  @override
  String get authNameSubtitle =>
      'Хуваарь, зардал дээр бусад оршин суугчид таны нэрийг харна.';

  @override
  String get authNameLabel => 'Нэр';

  @override
  String get cleaningTitle => 'Цэвэрлэгээний хуваарь';

  @override
  String get cleaningYou => 'Та';

  @override
  String get cleaningUnnamed => 'Нэр оруулаагүй';

  @override
  String cleaningDaysLeft(int count) {
    return '$count өдөр үлдсэн';
  }

  @override
  String get cleaningStatusUpcoming => 'Удахгүй';

  @override
  String get cleaningStatusActive => 'Явцад';

  @override
  String get cleaningStatusDone => 'Дууссан';

  @override
  String get cleaningStatusMissed => 'Хийгээгүй';

  @override
  String get cleaningAreasTitle => 'Цэвэрлэх газрууд';

  @override
  String get cleaningNoAreas => 'Цэвэрлэх газар нэмээгүй байна.';

  @override
  String get cleaningSwapAction => 'Ээлж солих';

  @override
  String get cleaningSwapSheetTitle => 'Хэнтэй солих вэ?';

  @override
  String cleaningSwapSheetBody(String dates) {
    return 'Таны ээлж: $dates';
  }

  @override
  String get cleaningSwapSent =>
      'Хүсэлт илгээлээ. Нөгөө хүн зөвшөөрсний дараа солигдоно.';

  @override
  String cleaningSwapIncoming(String name, String mine, String theirs) {
    return '$name таны $mine ээлжийг өөрийн $theirs ээлжтэй солихыг хүсэж байна.';
  }

  @override
  String cleaningSwapOutgoing(String name, String mine, String theirs) {
    return 'Солих хүсэлт хүлээгдэж байна: $name, $mine ↔ $theirs';
  }

  @override
  String get cleaningAccept => 'Зөвшөөрөх';

  @override
  String get cleaningDecline => 'Татгалзах';

  @override
  String get cleaningCancelRequest => 'Цуцлах';

  @override
  String get cleaningUpcomingTitle => 'Ээлжийн хуваарь';

  @override
  String get cleaningNotStarted => 'Хуваарь хараахан эхлээгүй байна.';

  @override
  String get cleaningLoadFailed => 'Хуваарийг ачаалж чадсангүй.';

  @override
  String get cleaningRetry => 'Дахин оролдох';

  @override
  String get cleaningManageTitle => 'Хуваарь удирдах';

  @override
  String get cleaningManagePending => 'Шинэ бүртгэл';

  @override
  String get cleaningManageOrder => 'Ээлжийн дараалал';

  @override
  String get cleaningManageOrderHint => 'Өөрчлөлт дараагийн ээлжээс хэрэгжинэ.';

  @override
  String get cleaningRemoveFromRotation => 'Ээлжээс хасах';

  @override
  String get cleaningAddToRotation => 'Нэмэх';

  @override
  String get cleaningSave => 'Хадгалах';

  @override
  String get cleaningMoveOutTitle => 'Байрнаас хасах уу?';

  @override
  String cleaningMoveOutBody(String name) {
    return '$name апп ашиглах эрхээ алдаж, дараагийн ээлжээс хасагдана.';
  }

  @override
  String get cleaningMoveOutConfirm => 'Хасах';

  @override
  String get cleaningRemoveArea => 'Устгах';

  @override
  String get cleaningNewAreaHint => 'Шинэ газрын нэр';

  @override
  String get cleaningThisPeriod => 'Энэ ээлж';

  @override
  String cleaningProgress(int done, int total) {
    return '$done/$total хийгдсэн';
  }

  @override
  String cleaningAreaCount(int count) {
    return '$count ажил';
  }

  @override
  String get cleaningYourTurn => 'Таны ээлж';

  @override
  String get cleaningAreaDone => 'Хийсэн';

  @override
  String get cleaningAreaNotDone => 'Хийгээгүй';

  @override
  String get cleaningFinish => 'Дууссан';

  @override
  String cleaningNextTurnLine(String dates) {
    return 'Таны дараагийн ээлж: $dates';
  }

  @override
  String cleaningLongDate(String month, String day, String weekday) {
    return '$month-р сарын $day, $weekday';
  }

  @override
  String get weekdayShortMon => 'Да';

  @override
  String get weekdayShortTue => 'Мя';

  @override
  String get weekdayShortWed => 'Лх';

  @override
  String get weekdayShortThu => 'Пү';

  @override
  String get weekdayShortFri => 'Ба';

  @override
  String get weekdayShortSat => 'Бя';

  @override
  String get weekdayShortSun => 'Ня';

  @override
  String get weekdayLongMon => 'Даваа';

  @override
  String get weekdayLongTue => 'Мягмар';

  @override
  String get weekdayLongWed => 'Лхагва';

  @override
  String get weekdayLongThu => 'Пүрэв';

  @override
  String get weekdayLongFri => 'Баасан';

  @override
  String get weekdayLongSat => 'Бямба';

  @override
  String get weekdayLongSun => 'Ням';
}
