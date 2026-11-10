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

  @override
  String get authPhoneTitle => 'Enter your phone number';

  @override
  String get authPhoneSubtitle =>
      'We\'ll verify your number by SMS and connect you with the other residents of your apartment.';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhonePrivacy => 'Other users can\'t see your number.';

  @override
  String get authTermsPrefix => 'By continuing you agree to the ';

  @override
  String get authTermsService => 'Terms of Service';

  @override
  String get authTermsJoin => ' and ';

  @override
  String get authTermsPrivacy => 'Privacy Policy';

  @override
  String get authTermsSuffix => '.';

  @override
  String authSmsSubtitle(String phone) {
    return 'Send the message below from $phone to verify.';
  }

  @override
  String get authSmsRecipient => 'To';

  @override
  String get authSmsMessage => 'Message';

  @override
  String get authSmsCopy => 'Copy';

  @override
  String get authSmsCopied => 'Copied';

  @override
  String authSmsDualSim(String phone) {
    return 'If you have 2 SIMs, choose the one with the number $phone.';
  }

  @override
  String get authSmsWaitingHint => 'Usually confirmed in 10–30 seconds';

  @override
  String get authSmsChangeNumber => 'Change number';

  @override
  String get authContinue => 'Continue';

  @override
  String get authSmsTitle => 'Verify by SMS';

  @override
  String get authSmsOpen => 'Send SMS';

  @override
  String get authSmsCost => 'Your operator charges ₮150 for each SMS sent.';

  @override
  String get authSmsWaiting => 'Waiting for your SMS...';

  @override
  String get authSmsExpired => 'Time ran out. The old code is no longer valid.';

  @override
  String get authSmsNewCode => 'Get a new code';

  @override
  String get authSmsOpenFailed =>
      'Couldn\'t open the SMS app. Please send it manually.';

  @override
  String get authPendingTitle => 'Waiting for approval';

  @override
  String get authPendingBody =>
      'You can use the app once a manager approves your account.';

  @override
  String get authPendingCheck => 'Check again';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get authNameTitle => 'What\'s your name?';

  @override
  String get authNameSubtitle =>
      'Other residents will see your name on the schedule and expenses.';

  @override
  String get authNameLabel => 'Name';

  @override
  String get cleaningTitle => 'Cleaning schedule';

  @override
  String get cleaningYou => 'You';

  @override
  String get cleaningUnnamed => 'No name yet';

  @override
  String cleaningDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get cleaningStatusUpcoming => 'Upcoming';

  @override
  String get cleaningStatusActive => 'In progress';

  @override
  String get cleaningStatusDone => 'Done';

  @override
  String get cleaningStatusMissed => 'Missed';

  @override
  String get cleaningAreasTitle => 'Areas to clean';

  @override
  String get cleaningNoAreas => 'No areas have been added yet.';

  @override
  String get cleaningSwapAction => 'Swap turn';

  @override
  String get cleaningSwapSheetTitle => 'Who do you want to swap with?';

  @override
  String cleaningSwapSheetBody(String dates) {
    return 'Your turn: $dates';
  }

  @override
  String get cleaningSwapSent =>
      'Request sent. The swap happens once they accept.';

  @override
  String cleaningSwapIncoming(String name, String mine, String theirs) {
    return '$name wants to swap your $mine turn for their $theirs turn.';
  }

  @override
  String cleaningSwapOutgoing(String name, String mine, String theirs) {
    return 'Swap request pending: $name, $mine ↔ $theirs';
  }

  @override
  String get cleaningAccept => 'Accept';

  @override
  String get cleaningDecline => 'Decline';

  @override
  String get cleaningCancelRequest => 'Cancel';

  @override
  String get cleaningUpcomingTitle => 'Rotation';

  @override
  String get cleaningNotStarted => 'The schedule hasn\'t started yet.';

  @override
  String get cleaningLoadFailed => 'Couldn\'t load the schedule.';

  @override
  String get cleaningRetry => 'Try again';

  @override
  String get cleaningManageTitle => 'Manage schedule';

  @override
  String get cleaningManagePending => 'New sign-ups';

  @override
  String get cleaningManageOrder => 'Rotation order';

  @override
  String get cleaningManageOrderHint => 'Changes apply from the next period.';

  @override
  String get cleaningRemoveFromRotation => 'Remove from rotation';

  @override
  String get cleaningAddToRotation => 'Add';

  @override
  String get cleaningSave => 'Save';

  @override
  String get cleaningMoveOutTitle => 'Remove from the apartment?';

  @override
  String cleaningMoveOutBody(String name) {
    return '$name will lose access to the app and leave the rotation from the next period.';
  }

  @override
  String get cleaningMoveOutConfirm => 'Remove';

  @override
  String get cleaningRemoveArea => 'Delete';

  @override
  String get cleaningNewAreaHint => 'New area name';

  @override
  String get cleaningThisPeriod => 'This turn';

  @override
  String cleaningProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String cleaningAreaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get cleaningYourTurn => 'Your turn';

  @override
  String get cleaningAreaDone => 'Done';

  @override
  String get cleaningAreaNotDone => 'Not done';

  @override
  String get cleaningFinish => 'Finished';

  @override
  String cleaningNextTurnLine(String dates) {
    return 'Your next turn: $dates';
  }

  @override
  String cleaningLongDate(String month, String day, String weekday) {
    return '$month/$day, $weekday';
  }

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get weekdayLongMon => 'Monday';

  @override
  String get weekdayLongTue => 'Tuesday';

  @override
  String get weekdayLongWed => 'Wednesday';

  @override
  String get weekdayLongThu => 'Thursday';

  @override
  String get weekdayLongFri => 'Friday';

  @override
  String get weekdayLongSat => 'Saturday';

  @override
  String get weekdayLongSun => 'Sunday';

  @override
  String get reportsSubtitle => 'All reports are anonymous';

  @override
  String get reportsFilterAll => 'All';

  @override
  String get reportsStatusOpen => 'Open';

  @override
  String get reportsStatusInProgress => 'In progress';

  @override
  String get reportsStatusResolved => 'Resolved';

  @override
  String get reportsCategoryNoise => 'Noise';

  @override
  String get reportsCategoryHygiene => 'Hygiene';

  @override
  String get reportsCategoryDamage => 'Damage / Repair';

  @override
  String get reportsCategorySafety => 'Safety';

  @override
  String get reportsCategoryOther => 'Other';

  @override
  String get reportsAgeRecent => 'Recently';

  @override
  String reportsAgeHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get reportsAgeYesterday => 'Yesterday';

  @override
  String get reportsAnonymousAuthor => 'Anonymous resident';

  @override
  String reportsManagerReply(String reply) {
    return 'Manager: $reply';
  }

  @override
  String get reportsVote => 'Me too';

  @override
  String get reportsEmpty => 'No reports.';

  @override
  String get reportsLoadFailed => 'Couldn\'t load the reports.';

  @override
  String get reportsFormTitle => 'Report a problem';

  @override
  String get reportsAnonymousTitle => 'You are anonymous';

  @override
  String get reportsAnonymousBody =>
      'Your name and room number are never shown to other residents or the manager.';

  @override
  String get reportsCategoryLabel => 'Category';

  @override
  String get reportsLocationLabel => 'Location';

  @override
  String get reportsLocationHint => 'For example: 2nd floor hallway';

  @override
  String get reportsDescriptionLabel => 'Describe the problem';

  @override
  String get reportsPhotoAdd => 'Add a photo (optional)';

  @override
  String get reportsPhotoNote =>
      'Photo location and device details are removed automatically.';

  @override
  String get reportsPhotoCamera => 'Take a photo';

  @override
  String get reportsPhotoGallery => 'Choose from library';

  @override
  String get reportsPhotoRemove => 'Remove photo';

  @override
  String get reportsPhotoFailed => 'Couldn\'t use that photo.';

  @override
  String get reportsSend => 'Send anonymously';

  @override
  String get reportsSent => 'Sent anonymously.';

  @override
  String get reportsRateLimited =>
      'You\'ve sent too many reports today. Please try again tomorrow.';

  @override
  String get reportsManagerTitle => 'Manager response';

  @override
  String get reportsReplyHint => 'Write a reply';

  @override
  String get reportsSaved => 'Saved.';

  @override
  String get purchasesTitle => 'Shared purchases';

  @override
  String purchasesSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Split equally between $count people',
      one: 'Split with 1 person',
    );
    return '$_temp0';
  }

  @override
  String get purchasesFundLabel => 'Shared fund';

  @override
  String get purchasesYouPaid => 'You paid';

  @override
  String get purchasesYourShare => 'Your share';

  @override
  String purchasesGetBack(String amount) {
    return 'You get back $amount';
  }

  @override
  String purchasesYouOwe(String amount) {
    return 'You owe $amount';
  }

  @override
  String get purchasesNeededTitle => 'Needed items';

  @override
  String get purchasesNoNeeded => 'Nothing is needed right now.';

  @override
  String get purchasesClaim => 'I\'ll buy';

  @override
  String get purchasesReceipt => 'Receipt';

  @override
  String get purchasesClaimedByYou => 'You\'re buying this';

  @override
  String purchasesClaimedBy(String name) {
    return '$name is buying this';
  }

  @override
  String get purchasesRequestedToday => 'Requested today';

  @override
  String get purchasesRequestedYesterday => 'Requested yesterday';

  @override
  String purchasesRequestedDays(int days) {
    return 'Requested $days days ago';
  }

  @override
  String get purchasesRemoveItem => 'Remove request';

  @override
  String get purchasesSeeAll => 'See all';

  @override
  String get purchasesNoRecent => 'No purchases yet.';

  @override
  String purchasesPerPerson(String amount) {
    return '$amount / person';
  }

  @override
  String get purchasesLoadFailed => 'Couldn\'t load the purchases.';

  @override
  String get purchasesAddPurchase => 'Add a purchase';

  @override
  String get purchasesAddItem => 'Add a needed item';

  @override
  String get purchasesItemName => 'Item name';

  @override
  String get purchasesAmount => 'Amount';

  @override
  String purchasesEachPays(int people, String amount) {
    return 'Split between $people: $amount each';
  }

  @override
  String get purchasesSave => 'Save';

  @override
  String get purchasesReceiptHint => 'Enter the amount on your receipt.';

  @override
  String get purchasesGiveUpItem => 'I won\'t buy this';

  @override
  String get purchasesDeleteTitle => 'Delete this?';

  @override
  String get purchasesDeleteBody =>
      'This purchase will be removed from everyone\'s totals.';

  @override
  String get purchasesMarkPaid => 'Paid';

  @override
  String get purchasesPay => 'Pay';

  @override
  String purchasesPaidCount(int paid, int total) {
    return '$paid/$total paid';
  }

  @override
  String get purchasesPayTitle => 'Pay your share';

  @override
  String get purchasesPayBank => 'Bank';

  @override
  String get purchasesPayAccountNumber => 'Account number';

  @override
  String get purchasesPayAccountHolder => 'Account holder';

  @override
  String purchasesPayNoAccount(String name) {
    return '$name hasn\'t added an account yet. You can pay in person.';
  }

  @override
  String get purchasesPayLoadFailed => 'Couldn\'t load the account details.';

  @override
  String get purchasesPayClose => 'Close';

  @override
  String get purchasesUnpaidTitle => 'Purchases I haven\'t paid';

  @override
  String get purchasesUnpaidNone => 'You\'ve paid for every purchase.';

  @override
  String get purchasesHistoryTitle => 'Purchase history';

  @override
  String get profileBankTitle => 'Bank account';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileRoleResident => 'Resident';

  @override
  String get profileRoleManager => 'Manager';

  @override
  String get profileApartment => 'Our apartment';

  @override
  String profileResidentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count residents',
      one: '1 resident',
    );
    return '$_temp0';
  }

  @override
  String get profileStatCleaned => 'Times cleaned';

  @override
  String get profileStatNextTurn => 'Next turn';

  @override
  String get profileStatGetBack => 'To get back';

  @override
  String get profileStatOwe => 'To pay';

  @override
  String get profileBankNone => 'No account added';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLanguage => 'Language';

  @override
  String get languageMongolian => 'Монгол';

  @override
  String get languageEnglish => 'English';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profilePrivacySubtitle => 'Reports are never linked to your name';

  @override
  String get profilePrivacyBody =>
      'Reports you send are anonymous: other residents and the manager can\'t see who sent them. Your phone number isn\'t shown to other users. Your bank account is shown only to people who owe you for something you bought.';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileHelpBody =>
      'If you have a problem, please contact your apartment\'s manager.';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody =>
      'You\'ll need to send an SMS to sign in again.';

  @override
  String get homeGreetingMorning => 'Good morning,';

  @override
  String get homeGreetingAfternoon => 'Good afternoon,';

  @override
  String get homeGreetingEvening => 'Good evening,';

  @override
  String get homeCurrentDutyLabel => 'Your duty';

  @override
  String get homeNextDutyLabel => 'Your next duty';

  @override
  String get homeDutyTitle => 'Clean the public areas';

  @override
  String get homeNoDuty => 'No turn scheduled';

  @override
  String get homeMarkDone => 'Mark as done';

  @override
  String get homeViewSchedule => 'View schedule';

  @override
  String get homeQuickTitle => 'Quick actions';

  @override
  String homeItemsMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items needed',
      one: '1 item needed',
    );
    return '$_temp0';
  }

  @override
  String get homeReportAction => 'Report';

  @override
  String get homeAnonymous => 'Anonymous';

  @override
  String get homeActivityTitle => 'Recent activity';

  @override
  String get homeNoActivity => 'Nothing has happened yet.';

  @override
  String get homeToday => 'Today';

  @override
  String homeActivityCleaned(String name) {
    return '$name finished cleaning';
  }

  @override
  String homeActivityBought(String name, String item, String amount) {
    return '$name bought $item · $amount';
  }

  @override
  String homeActivityReport(String title) {
    return 'Anonymous report: $title';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String notificationPaid(String name, String amount) {
    return '$name paid you $amount';
  }

  @override
  String notificationNewPurchase(String name, String item, String amount) {
    return '$name bought $item · your share $amount';
  }

  @override
  String notificationReportNew(String category, String location) {
    return 'New anonymous report: $category · $location';
  }

  @override
  String notificationReportReplied(String location) {
    return 'The report about $location got a reply';
  }

  @override
  String notificationReportStatus(String location, String status) {
    return 'Report about $location: $status';
  }
}
