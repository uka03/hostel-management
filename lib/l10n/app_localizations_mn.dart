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

  @override
  String get reportsSubtitle => 'Бүх мэдэгдэл нэргүй';

  @override
  String get reportsFilterAll => 'Бүгд';

  @override
  String get reportsStatusOpen => 'Нээлттэй';

  @override
  String get reportsStatusInProgress => 'Явцад';

  @override
  String get reportsStatusResolved => 'Шийдэгдсэн';

  @override
  String get reportsCategoryNoise => 'Чимээ шуугиан';

  @override
  String get reportsCategoryHygiene => 'Ариун цэвэр';

  @override
  String get reportsCategoryDamage => 'Эвдрэл / Засвар';

  @override
  String get reportsCategorySafety => 'Аюулгүй байдал';

  @override
  String get reportsCategoryOther => 'Бусад';

  @override
  String get reportsAgeRecent => 'Саяхан';

  @override
  String reportsAgeHours(int hours) {
    return '$hours цагийн өмнө';
  }

  @override
  String get reportsAgeYesterday => 'Өчигдөр';

  @override
  String get reportsAnonymousAuthor => 'Нэргүй оршин суугч';

  @override
  String reportsManagerReply(String reply) {
    return 'Менежер: $reply';
  }

  @override
  String get reportsVote => 'Надад ч бас';

  @override
  String get reportsEmpty => 'Мэдэгдэл алга байна.';

  @override
  String get reportsLoadFailed => 'Мэдэгдлүүдийг ачаалж чадсангүй.';

  @override
  String get reportsFormTitle => 'Асуудал мэдэгдэх';

  @override
  String get reportsAnonymousTitle => 'Та нэргүй байна';

  @override
  String get reportsAnonymousBody =>
      'Таны нэр, өрөөний дугаар бусад оршин суугч болон менежерт хэзээ ч харагдахгүй.';

  @override
  String get reportsCategoryLabel => 'Ангилал';

  @override
  String get reportsLocationLabel => 'Байршил';

  @override
  String get reportsLocationHint => 'Жишээ: 2-р давхрын коридор';

  @override
  String get reportsDescriptionLabel => 'Асуудлаа тайлбарлана уу';

  @override
  String get reportsPhotoAdd => 'Зураг нэмэх (заавал биш)';

  @override
  String get reportsPhotoNote =>
      'Зургийн байршил, төхөөрөмжийн мэдээллийг автоматаар устгана.';

  @override
  String get reportsPhotoCamera => 'Зураг авах';

  @override
  String get reportsPhotoGallery => 'Зургийн сангаас сонгох';

  @override
  String get reportsPhotoRemove => 'Зураг хасах';

  @override
  String get reportsPhotoFailed => 'Зургийг ашиглаж чадсангүй.';

  @override
  String get reportsSend => 'Нэргүйгээр илгээх';

  @override
  String get reportsSent => 'Нэргүйгээр илгээгдлээ.';

  @override
  String get reportsRateLimited =>
      'Өнөөдөр хэт олон мэдэгдэл илгээсэн байна. Маргааш дахин оролдоно уу.';

  @override
  String get reportsManagerTitle => 'Менежерийн хариу';

  @override
  String get reportsReplyHint => 'Хариугаа бичнэ үү';

  @override
  String get reportsSaved => 'Хадгалагдлаа.';

  @override
  String get purchasesTitle => 'Хамтын худалдан авалт';

  @override
  String purchasesSubtitle(int count) {
    return '$count хүнд тэнцүү хуваана';
  }

  @override
  String get purchasesFundLabel => 'Хамтын сан';

  @override
  String get purchasesYouPaid => 'Та төлсөн';

  @override
  String get purchasesYourShare => 'Таны хувь';

  @override
  String purchasesGetBack(String amount) {
    return 'Танд буцаж ирэх $amount';
  }

  @override
  String purchasesYouOwe(String amount) {
    return 'Таны төлөх $amount';
  }

  @override
  String get purchasesNeededTitle => 'Шаардлагатай бараа';

  @override
  String get purchasesNoNeeded => 'Шаардлагатай бараа алга.';

  @override
  String get purchasesClaim => 'Би авна';

  @override
  String get purchasesReceipt => 'Баримт';

  @override
  String get purchasesClaimedByYou => 'Та авахаар болсон';

  @override
  String purchasesClaimedBy(String name) {
    return '$name авахаар болсон';
  }

  @override
  String get purchasesRequestedToday => 'Өнөөдөр хүссэн';

  @override
  String get purchasesRequestedYesterday => 'Өчигдөр хүссэн';

  @override
  String purchasesRequestedDays(int days) {
    return '$days өдрийн өмнө хүссэн';
  }

  @override
  String get purchasesRemoveItem => 'Хүсэлт устгах';

  @override
  String get purchasesSeeAll => 'Бүгдийг харах';

  @override
  String get purchasesNoRecent => 'Худалдан авалт алга.';

  @override
  String purchasesPerPerson(String amount) {
    return '$amount / хүн';
  }

  @override
  String get purchasesLoadFailed => 'Худалдан авалтыг ачаалж чадсангүй.';

  @override
  String get purchasesAddPurchase => 'Худалдан авалт нэмэх';

  @override
  String get purchasesAddItem => 'Шаардлагатай бараа нэмэх';

  @override
  String get purchasesItemName => 'Барааны нэр';

  @override
  String get purchasesAmount => 'Дүн';

  @override
  String purchasesEachPays(int people, String amount) {
    return '$people хүнд хуваавал нэг хүнд $amount';
  }

  @override
  String get purchasesSave => 'Хадгалах';

  @override
  String get purchasesReceiptHint => 'Баримтын дүнгээ оруулна уу.';

  @override
  String get purchasesGiveUpItem => 'Авахаа болих';

  @override
  String get purchasesDeleteTitle => 'Устгах уу?';

  @override
  String get purchasesDeleteBody =>
      'Энэ худалдан авалт бүх хүний тооцооноос хасагдана.';

  @override
  String get purchasesMarkPaid => 'Төлсөн';

  @override
  String get purchasesPay => 'Төлөх';

  @override
  String purchasesPaidCount(int paid, int total) {
    return '$paid/$total төлсөн';
  }

  @override
  String get purchasesPayTitle => 'Төлбөр төлөх';

  @override
  String get purchasesPayBank => 'Банк';

  @override
  String get purchasesPayAccountNumber => 'Дансны дугаар';

  @override
  String get purchasesPayAccountHolder => 'Данс эзэмшигчийн нэр';

  @override
  String purchasesPayNoAccount(String name) {
    return '$name дансны мэдээллээ оруулаагүй байна. Биечлэн төлж болно.';
  }

  @override
  String get purchasesPayLoadFailed => 'Дансны мэдээллийг ачаалж чадсангүй.';

  @override
  String get purchasesPayClose => 'Хаах';

  @override
  String get purchasesUnpaidTitle => 'Төлөөгүй худалдан авалт';

  @override
  String get purchasesUnpaidNone => 'Бүх худалдан авалтаа төлсөн байна.';

  @override
  String get purchasesHistoryTitle => 'Худалдан авалтын түүх';

  @override
  String get profileBankTitle => 'Дансны мэдээлэл';

  @override
  String get profileEditName => 'Нэр засах';

  @override
  String get profileRoleResident => 'Оршин суугч';

  @override
  String get profileRoleManager => 'Менежер';

  @override
  String get profileApartment => 'Манай байр';

  @override
  String profileResidentCount(int count) {
    return '$count оршин суугч';
  }

  @override
  String get profileStatCleaned => 'Удаа цэвэрлэсэн';

  @override
  String get profileStatNextTurn => 'Дараагийн ээлж';

  @override
  String get profileStatGetBack => 'Буцаж авах';

  @override
  String get profileStatOwe => 'Төлөх';

  @override
  String get profileBankNone => 'Данс нэмээгүй байна';

  @override
  String get profileNotifications => 'Мэдэгдэл';

  @override
  String get profileLanguage => 'Хэл';

  @override
  String get languageMongolian => 'Монгол';

  @override
  String get languageEnglish => 'English';

  @override
  String get profilePrivacy => 'Нууцлал';

  @override
  String get profilePrivacySubtitle => 'Мэдэгдлүүд таны нэртэй холбогдохгүй';

  @override
  String get profilePrivacyBody =>
      'Таны илгээсэн мэдэгдэл нэргүй бөгөөд бусад оршин суугч, менежер хэн илгээснийг харах боломжгүй. Утасны дугаар тань бусад хэрэглэгчид харагдахгүй. Дансны мэдээлэл тань зөвхөн таны авсан зүйлд хувиа төлөх хүмүүст харагдана.';

  @override
  String get profileHelp => 'Тусламж';

  @override
  String get profileHelpBody =>
      'Асуудал гарвал байрныхаа менежертэй холбогдоно уу.';

  @override
  String get profileSignOutTitle => 'Гарах уу?';

  @override
  String get profileSignOutBody => 'Дахин нэвтрэхэд SMS илгээх шаардлагатай.';

  @override
  String get homeGreetingMorning => 'Өглөөний мэнд,';

  @override
  String get homeGreetingAfternoon => 'Өдрийн мэнд,';

  @override
  String get homeGreetingEvening => 'Оройн мэнд,';

  @override
  String get homeCurrentDutyLabel => 'Таны жижүүр';

  @override
  String get homeNextDutyLabel => 'Таны дараагийн жижүүр';

  @override
  String get homeDutyTitle => 'Нийтийн талбайн цэвэрлэгээ';

  @override
  String get homeNoDuty => 'Ээлж товлогдоогүй';

  @override
  String get homeMarkDone => 'Хийсэн гэж тэмдэглэх';

  @override
  String get homeViewSchedule => 'Хуваарь харах';

  @override
  String get homeQuickTitle => 'Хурдан үйлдэл';

  @override
  String homeItemsMissing(int count) {
    return '$count бараа дутуу';
  }

  @override
  String get homeReportAction => 'Мэдэгдэх';

  @override
  String get homeAnonymous => 'Нэргүй';

  @override
  String get homeActivityTitle => 'Сүүлийн үйл явдал';

  @override
  String get homeNoActivity => 'Одоохондоо үйл явдал алга.';

  @override
  String get homeToday => 'Өнөөдөр';

  @override
  String homeActivityCleaned(String name) {
    return '$name цэвэрлэгээ хийлээ';
  }

  @override
  String homeActivityBought(String name, String item, String amount) {
    return '$name $item авлаа · $amount';
  }

  @override
  String homeActivityReport(String title) {
    return 'Нэргүй мэдэгдэл: $title';
  }

  @override
  String get notificationsTitle => 'Сонордуулга';

  @override
  String get notificationsEmpty => 'Одоохондоо сонордуулга алга.';

  @override
  String notificationPaid(String name, String amount) {
    return '$name танд $amount төллөө';
  }

  @override
  String notificationNewPurchase(String name, String item, String amount) {
    return '$name $item авлаа · таны хувь $amount';
  }

  @override
  String notificationReportNew(String category, String location) {
    return 'Шинэ нэргүй мэдэгдэл: $category · $location';
  }

  @override
  String notificationReportReplied(String location) {
    return '«$location» мэдэгдэлд хариу ирлээ';
  }

  @override
  String notificationReportStatus(String location, String status) {
    return '«$location» мэдэгдэл: $status';
  }
}
