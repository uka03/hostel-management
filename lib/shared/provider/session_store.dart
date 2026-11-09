import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostel/connection/model/auth_session.dart';

abstract class SessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

/// Keeps the session in the iOS Keychain / Android encrypted storage.
class SecureSessionStore implements SessionStore {
  static const _key = 'auth_session';
  final _storage = const FlutterSecureStorage();

  @override
  Future<AuthSession?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      // Unreadable or outdated data just means signing in again.
      debugPrint('[Auth] session storage read failed: ${e.runtimeType}');
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
