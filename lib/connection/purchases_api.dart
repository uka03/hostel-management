import 'package:dio/dio.dart';
import 'package:hostel/connection/model/purchases_overview.dart';

/// Shared purchases. The server does the splitting and enforces who may do
/// what.
class PurchasesApi {
  PurchasesApi(this._dio);

  final Dio _dio;

  Future<Response<T>> _rpc<T>(String name, [Map<String, dynamic>? params]) =>
      _dio.post<T>('/rest/v1/rpc/$name', data: params ?? const {});

  Future<PurchasesOverview> overview() async {
    final response = await _rpc<Map<String, dynamic>>('purchases_overview');
    return PurchasesOverview.fromJson(response.data!);
  }

  Future<void> addPurchase(String title, int amount) =>
      _rpc<void>('add_purchase', {'p_title': title, 'p_amount': amount});

  Future<void> deletePurchase(String id) =>
      _rpc<void>('delete_purchase', {'p_purchase_id': id});

  Future<void> setSharePaid(String purchaseId, bool paid) => _rpc<void>(
    'set_share_paid',
    {'p_purchase_id': purchaseId, 'p_paid': paid},
  );

  Future<PaymentInfo> paymentInfo(String purchaseId) async {
    final response = await _rpc<Map<String, dynamic>>('purchase_payment_info', {
      'p_purchase_id': purchaseId,
    });
    return PaymentInfo.fromJson(response.data!);
  }

  Future<void> addItem(String name) =>
      _rpc<void>('add_needed_item', {'p_name': name});

  Future<void> claimItem(String id) =>
      _rpc<void>('claim_item', {'p_item_id': id});

  Future<void> unclaimItem(String id) =>
      _rpc<void>('unclaim_item', {'p_item_id': id});

  Future<void> completeItem(String id, int amount) =>
      _rpc<void>('complete_item', {'p_item_id': id, 'p_amount': amount});

  Future<void> removeItem(String id) =>
      _rpc<void>('remove_needed_item', {'p_item_id': id});
}
