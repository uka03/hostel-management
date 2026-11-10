// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchases_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Purchase _$PurchaseFromJson(Map<String, dynamic> json) => Purchase(
  id: json['id'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toInt(),
  buyerId: json['buyer_id'] as String,
  buyerName: json['buyer_name'] as String?,
  purchasedOn: DateTime.parse(json['purchased_on'] as String),
  myShare: (json['my_share'] as num?)?.toInt(),
  peopleCount: (json['people_count'] as num).toInt(),
  myPaid: json['my_paid'] as bool,
  paidCount: (json['paid_count'] as num).toInt(),
);

PaymentInfo _$PaymentInfoFromJson(Map<String, dynamic> json) => PaymentInfo(
  buyerName: json['buyer_name'] as String?,
  bankName: json['bank_name'] as String?,
  accountNumber: json['account_number'] as String?,
  accountHolder: json['account_holder'] as String?,
);

NeededItem _$NeededItemFromJson(Map<String, dynamic> json) => NeededItem(
  id: json['id'] as String,
  name: json['name'] as String,
  requestedBy: json['requested_by'] as String,
  requestedOn: DateTime.parse(json['requested_on'] as String),
  claimedBy: json['claimed_by'] as String?,
  claimedByName: json['claimed_by_name'] as String?,
);

PurchasesOverview _$PurchasesOverviewFromJson(Map<String, dynamic> json) =>
    PurchasesOverview(
      today: DateTime.parse(json['today'] as String),
      activeCount: (json['active_count'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toInt(),
      myPaid: (json['my_paid'] as num).toInt(),
      myShare: (json['my_share'] as num).toInt(),
      purchases: (json['purchases'] as List<dynamic>)
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList(),
      neededItems: (json['needed_items'] as List<dynamic>)
          .map((e) => NeededItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
