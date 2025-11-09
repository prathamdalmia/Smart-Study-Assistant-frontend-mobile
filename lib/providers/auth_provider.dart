import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  Map<String, dynamic>? user;
  bool loading = false;
  bool isAdmin = false;

  bool get isAuthenticated => token != null;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    isAdmin = prefs.getBool('isAdmin') ?? false;
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

  Future<bool> login(String emailOrUsername, String password, {bool isAdminLogin = false}) async {
    loading = true;
    notifyListeners();
    try {
      final resp = await ApiService.login(emailOrUsername, password, isAdmin: isAdminLogin);
      token = resp['token'];
      isAdmin = resp['isAdmin'] ?? false;
      
      if (isAdmin) {
        user = resp['admin'];
      } else {
        user = resp['student'];
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setBool('isAdmin', isAdmin);
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
    isAdmin = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('isAdmin');
    clearToken();
    notifyListeners();
  }
}
