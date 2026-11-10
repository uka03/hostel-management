import 'package:flutter/foundation.dart';
import 'package:hostel/connection/cleaning_api.dart';
import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';

class CleaningProvider extends ChangeNotifier {
  CleaningProvider(this._api);

  final CleaningApi _api;

  CleaningOverview? _overview;
  bool _failed = false;
  bool _busy = false;
  bool _disposed = false;

  CleaningOverview? get overview => _overview;

  /// True when the first load failed and there is nothing to show.
  bool get failed => _failed && _overview == null;

  /// True while a change is being saved.
  bool get busy => _busy;

  /// Null until the schedule has started.
  Rotation? get rotation {
    final data = _overview;
    return data == null ? null : rotationFrom(data);
  }

  int? get currentPeriod => rotation?.periodOf(_overview!.today);

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
      _overview = await _api.overview();
    } catch (_) {
      _failed = true;
    }
    _notify();
  }

  /// Saves a change, then shows the server's result. Throws if saving fails.
  Future<void> _save(Future<void> Function() change) async {
    if (_busy) return;
    _busy = true;
    _notify();
    try {
      await change();
      _overview = await _api.overview();
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> setAreaChecked(String areaId, bool checked) =>
      _save(() => _api.setAreaChecked(areaId, checked));

  /// Ticks several areas at once, for the "finished" button.
  Future<void> completeAreas(List<String> areaIds) => _save(() async {
    for (final id in areaIds) {
      await _api.setAreaChecked(id, true);
    }
  });

  Future<void> requestSwap(int myPeriod, int theirPeriod) =>
      _save(() => _api.requestSwap(myPeriod, theirPeriod));

  Future<void> respondSwap(String swapId, bool accept) =>
      _save(() => _api.respondSwap(swapId, accept));

  Future<void> cancelSwap(String swapId) =>
      _save(() => _api.cancelSwap(swapId));

  Future<void> approveResident(String userId) =>
      _save(() => _api.approveResident(userId));

  Future<void> removeResident(String userId) =>
      _save(() => _api.removeResident(userId));

  Future<void> setRotationOrder(List<String> ids) =>
      _save(() => _api.setRotationOrder(ids));

  Future<void> addArea(String name) => _save(() => _api.addArea(name));

  Future<void> removeArea(String areaId) =>
      _save(() => _api.removeArea(areaId));
}
