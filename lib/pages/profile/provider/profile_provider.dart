import 'package:flutter/foundation.dart';
import 'package:hostel/connection/cleaning_api.dart';
import 'package:hostel/connection/purchases_api.dart';
import 'package:hostel/extensions/date_extensions.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';

class ProfileStats {
  const ProfileStats({
    required this.cleanedCount,
    required this.activeCount,
    required this.balance,
    this.nextTurn,
  });

  final int cleanedCount, activeCount;

  /// Positive means this resident gets money back.
  final int balance;

  /// Short date of this resident's next duty, if they have one.
  final String? nextTurn;
}

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._cleaning, this._purchases);

  final CleaningApi _cleaning;
  final PurchasesApi _purchases;

  ProfileStats? _stats;
  bool _disposed = false;

  /// Null until loaded, or if loading failed.
  ProfileStats? get stats => _stats;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load(String? meId) async {
    try {
      final (cleanedCount, cleaning, purchases) = await (
        _cleaning.cleanedCount(),
        _cleaning.overview(),
        _purchases.overview(),
      ).wait;

      final rotation = rotationFrom(cleaning);
      String? nextTurn;
      if (rotation != null && meId != null) {
        final next = rotation.nextTurnOf(
          meId,
          after: rotation.periodOf(cleaning.today),
        );
        if (next != null) nextTurn = rotation.firstDayOf(next).mnShort();
      }

      _stats = ProfileStats(
        cleanedCount: cleanedCount,
        activeCount: purchases.activeCount,
        balance: purchases.myPaid - purchases.myShare,
        nextTurn: nextTurn,
      );
    } catch (_) {
      // Keep showing the last numbers; the screen works without them.
    }
    if (!_disposed) notifyListeners();
  }
}
