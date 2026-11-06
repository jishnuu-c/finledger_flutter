import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user_profile.dart';

class TokenService extends ChangeNotifier {
  static const String _keyAccessToken = 'fl_access_token';
  static const String _keyRefreshToken = 'fl_refresh_token';
  static const String _keyUserProfile = 'fl_user_profile';

  String? _accessToken;
  String? _refreshToken;
  UserProfile? _currentUser;
  bool _initialized = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyAccessToken);
    _refreshToken = prefs.getString(_keyRefreshToken);

    final userJson = prefs.getString(_keyUserProfile);
    if (userJson != null) {
      try {
        _currentUser = UserProfile.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        _currentUser = UserProfile.defaultMock();
      }
    } else if (isAuthenticated) {
      _currentUser = UserProfile.defaultMock();
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    UserProfile? user,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (user != null) {
      _currentUser = user;
    } else {
      _currentUser ??= UserProfile.defaultMock();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    if (_currentUser != null) {
      await prefs.setString(_keyUserProfile, jsonEncode(_currentUser!.toJson()));
    }
    notifyListeners();
  }

  Future<void> updateAccessToken(String newAccessToken) async {
    _accessToken = newAccessToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, newAccessToken);
    notifyListeners();
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserProfile);
    notifyListeners();
  }

  /// Sets a mock authenticated session for development or demo
  Future<void> setDemoSession() async {
    await saveTokens(
      accessToken: 'demo_jwt_access_token_finledger_2026',
      refreshToken: 'demo_jwt_refresh_token_finledger_2026',
      user: UserProfile.defaultMock(),
    );
  }
}
