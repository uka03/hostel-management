import 'package:flutter/foundation.dart';
import 'package:hostel/connection/model/user_response_data.dart';

class AuthProvider extends ChangeNotifier {
  UserResponseData? _user;
  String? _token;

  UserResponseData? get user => _user;
  String? get token => _token;

  void setSession({required UserResponseData user, required String token}) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  void clear() {
    if (_user == null && _token == null) return;
    _user = null;
    _token = null;
    notifyListeners();
  }
}
