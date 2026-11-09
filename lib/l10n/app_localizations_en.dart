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
}
