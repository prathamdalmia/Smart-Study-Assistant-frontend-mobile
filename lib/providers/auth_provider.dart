import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  Map<String, dynamic>? user;
  bool loading = false;

  bool get isAuthenticated => token != null;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      user = {'name': userJson};
    }
    // If a token exists in storage, ensure ApiService uses it
    if (token != null) {
      setToken(token!);
    }
    notifyListeners();
  }

  Future<bool> login(String emailOrUsername, String password) async {
    loading = true;
    notifyListeners();
    try {
      final resp = await ApiService.login(emailOrUsername, password);
      token = resp['token'];
      // backend returns 'student'
      user = resp['student'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setString('user', user?['name'] ?? '');
      setToken(token!);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signup(
      String name, String username, String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      final resp = await ApiService.signup(name, username, email, password);
      token = resp['token'];
      user = resp['student'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setString('user', user?['name'] ?? '');
      setToken(token!);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    token = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    clearToken();
    notifyListeners();
  }
}
