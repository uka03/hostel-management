import 'package:flutter/foundation.dart';
import 'package:hostel/connection/cleaning_api.dart';
import 'package:hostel/connection/model/app_notification.dart';
import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/connection/notifications_api.dart';
import 'package:hostel/connection/purchases_api.dart';
import 'package:hostel/connection/reports_api.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';
import 'package:hostel/pages/home/provider/home_summary.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(
    this._cleaning,
    this._purchases,
    this._reports,
    this._notifications,
  );

  final CleaningApi _cleaning;
  final PurchasesApi _purchases;
  final ReportsApi _reports;
  final NotificationsApi _notifications;

  CleaningOverview? _cleaningData;
  PurchasesOverview? _purchasesData;
  List<Report>? _reportsData;
  NotificationsFeed? _feed;
  bool _busy = false;
  bool _disposed = false;

  CleaningOverview? get cleaning => _cleaningData;
  PurchasesOverview? get purchases => _purchasesData;
  bool get busy => _busy;

  /// Newest first.
  List<AppNotification> get notifications => _feed?.items ?? const [];
  int get unreadCount => _feed?.unreadCount ?? 0;

  Rotation? get rotation {
    final data = _cleaningData;
    return data == null ? null : rotationFrom(data);
  }

  List<HomeActivity> get activity => buildActivity(
    cleaning: _cleaningData,
    purchases: _purchasesData,
    reports: _reportsData,
  );

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// One section failing shouldn't blank the others.
  Future<T?> _attempt<T>(Future<T> request) async {
    try {
      return await request;
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    final (cleaning, purchases, reports, feed) = await (
      _attempt(_cleaning.overview()),
      _attempt(_purchases.overview()),
      _attempt(_reports.list()),
      _attempt(_notifications.list()),
    ).wait;
    _cleaningData = cleaning ?? _cleaningData;
    _purchasesData = purchases ?? _purchasesData;
    _reportsData = reports ?? _reportsData;
    _feed = feed ?? _feed;
    _notify();
  }

  Future<void> loadNotifications() async {
    _feed = await _attempt(_notifications.list()) ?? _feed;
    _notify();
  }

  /// Called once the notifications have been seen. The list keeps showing
  /// which ones were new until it's next loaded.
  Future<void> markNotificationsRead() async {
    if (unreadCount == 0) return;
    try {
      await _notifications.markAllRead();
    } catch (_) {
      return;
    }
    final feed = _feed;
    if (feed != null) {
      _feed = NotificationsFeed(unreadCount: 0, items: feed.items);
    }
    _notify();
  }

  /// Ticks every area still open. Only the person on duty is allowed to.
  Future<void> completeDuty() async {
    final data = _cleaningData;
    if (_busy || data == null) return;
    _busy = true;
    _notify();
    try {
      final checked = data.checkedAreaIds.toSet();
      for (final area in data.areas) {
        if (!checked.contains(area.id)) {
          await _cleaning.setAreaChecked(area.id, true);
        }
      }
      _cleaningData = await _cleaning.overview();
    } finally {
      _busy = false;
      _notify();
    }
  }
}
