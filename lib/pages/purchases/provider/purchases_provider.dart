import 'package:flutter/foundation.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/connection/purchases_api.dart';

class PurchasesProvider extends ChangeNotifier {
  PurchasesProvider(this._api);

  final PurchasesApi _api;

  PurchasesOverview? _overview;
  bool _failed = false;
  bool _busy = false;
  bool _disposed = false;

  PurchasesOverview? get overview => _overview;
  bool get failed => _failed && _overview == null;
  bool get busy => _busy;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    _failed = false;
    try {
      await _fetch();
    } catch (_) {
      _failed = true;
    }
    _notify();
  }

  Future<void> _fetch() async {
    _overview = await _api.overview();
  }

  /// Saves a change, then shows the server's result. Throws if saving fails.
  Future<void> _save(Future<void> Function() change) async {
    if (_busy) return;
    _busy = true;
    _notify();
    try {
      await change();
      await _fetch();
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> addPurchase(String title, int amount) =>
      _save(() => _api.addPurchase(title, amount));

  Future<void> deletePurchase(String id) =>
      _save(() => _api.deletePurchase(id));

  Future<void> setSharePaid(String purchaseId, bool paid) =>
      _save(() => _api.setSharePaid(purchaseId, paid));

  Future<PaymentInfo> paymentInfo(String purchaseId) =>
      _api.paymentInfo(purchaseId);

  Future<void> addItem(String name) => _save(() => _api.addItem(name));

  Future<void> claimItem(String id) => _save(() => _api.claimItem(id));

  Future<void> unclaimItem(String id) => _save(() => _api.unclaimItem(id));

  Future<void> completeItem(String id, int amount) =>
      _save(() => _api.completeItem(id, amount));

  Future<void> removeItem(String id) => _save(() => _api.removeItem(id));
}
