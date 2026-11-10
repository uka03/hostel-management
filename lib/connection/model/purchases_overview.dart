import 'package:json_annotation/json_annotation.dart';

part 'purchases_overview.g.dart';

const _snake = JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: false,
);

@_snake
class Purchase {
  const Purchase({
    required this.id,
    required this.title,
    required this.amount,
    required this.buyerId,
    this.buyerName,
    required this.purchasedOn,
    this.myShare,
    required this.peopleCount,
    required this.myPaid,
    required this.paidCount,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);

  final String id;
  final String title;

  /// Whole tögrög.
  final int amount;
  final String buyerId;
  final String? buyerName;
  final DateTime purchasedOn;

  /// Null if this resident wasn't active when it was bought.
  final int? myShare;

  /// How many people the cost was split between.
  final int peopleCount;

  /// Whether this resident has paid the buyer their share.
  final bool myPaid;

  /// How many people have paid the buyer so far.
  final int paidCount;
}

/// Where to send a buyer their money. The account fields are null if the
/// buyer hasn't added one.
@_snake
class PaymentInfo {
  const PaymentInfo({
    this.buyerName,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoFromJson(json);

  final String? buyerName, bankName, accountNumber, accountHolder;
}

@_snake
class NeededItem {
  const NeededItem({
    required this.id,
    required this.name,
    required this.requestedBy,
    required this.requestedOn,
    this.claimedBy,
    this.claimedByName,
  });

  factory NeededItem.fromJson(Map<String, dynamic> json) =>
      _$NeededItemFromJson(json);

  final String id;
  final String name;
  final String requestedBy;
  final DateTime requestedOn;
  final String? claimedBy;
  final String? claimedByName;
}

@_snake
class PurchasesOverview {
  const PurchasesOverview({
    required this.today,
    required this.activeCount,
    required this.totalAmount,
    required this.myPaid,
    required this.myShare,
    required this.purchases,
    required this.neededItems,
  });

  factory PurchasesOverview.fromJson(Map<String, dynamic> json) =>
      _$PurchasesOverviewFromJson(json);

  /// Today in Asia/Ulaanbaatar, according to the server.
  final DateTime today;
  final int activeCount;

  /// Running totals across every purchase, in whole tögrög.
  final int totalAmount, myPaid, myShare;

  /// Newest first.
  final List<Purchase> purchases;
  final List<NeededItem> neededItems;
}
