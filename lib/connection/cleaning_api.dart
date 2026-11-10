import 'package:dio/dio.dart';
import 'package:hostel/connection/model/cleaning_overview.dart';

/// Cleaning schedule calls. The server enforces who may do what.
class CleaningApi {
  CleaningApi(this._dio);

  final Dio _dio;

  Future<Response<T>> _rpc<T>(String name, [Map<String, dynamic>? params]) =>
      _dio.post<T>('/rest/v1/rpc/$name', data: params ?? const {});

  Future<CleaningOverview> overview() async {
    final response = await _rpc<Map<String, dynamic>>('cleaning_overview');
    return CleaningOverview.fromJson(response.data!);
  }

  /// How many duties this resident has finished, ever.
  Future<int> cleanedCount() async {
    final response = await _rpc<Map<String, dynamic>>('profile_stats');
    return response.data!['cleaned_count'] as int;
  }

  Future<void> setAreaChecked(String areaId, bool checked) => _rpc<void>(
    'set_area_checked',
    {'p_area_id': areaId, 'p_checked': checked},
  );

  Future<void> requestSwap(int myPeriod, int theirPeriod) => _rpc<void>(
    'request_swap',
    {'p_my_period': myPeriod, 'p_their_period': theirPeriod},
  );

  Future<void> respondSwap(String swapId, bool accept) =>
      _rpc<void>('respond_swap', {'p_swap_id': swapId, 'p_accept': accept});

  Future<void> cancelSwap(String swapId) =>
      _rpc<void>('cancel_swap', {'p_swap_id': swapId});

  Future<void> approveResident(String userId) =>
      _rpc<void>('approve_resident', {'p_user_id': userId});

  Future<void> removeResident(String userId) =>
      _rpc<void>('remove_resident', {'p_user_id': userId});

  Future<void> setRotationOrder(List<String> ids) =>
      _rpc<void>('set_rotation_order', {'p_ids': ids});

  Future<void> addArea(String name) =>
      _rpc<void>('add_cleaning_area', {'p_name': name});

  Future<void> removeArea(String areaId) =>
      _rpc<void>('remove_cleaning_area', {'p_area_id': areaId});
}
