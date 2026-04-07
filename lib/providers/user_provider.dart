import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _fullName;
  String? _email;
  String? _role;
  String? _department;
  String? _stage;
  String? _photoUrl;

  int? get userId => _userId;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;
  String? get department => _department;
  String? get stage => _stage;
  String? get photoUrl => _photoUrl;

  bool get isProfileComplete =>
      _department != null &&
      _department!.isNotEmpty &&
      _stage != null &&
      _stage!.isNotEmpty;

  Future<void> setUser(
    int id,
    String fullName,
    String email,
    String role, {
    String? department,
    String? stage,
    String? photoUrl,
    bool persist = true,
  }) async {
    _userId = id;
    _fullName = fullName;
    _email = email;
    _role = role;
    _department = department;
    _stage = stage;
    _photoUrl = photoUrl;

    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', id);
      await prefs.setString('fullName', fullName);
      await prefs.setString('email', email);
      await prefs.setString('role', role);
      if (department != null) await prefs.setString('department', department);
      if (stage != null) await prefs.setString('stage', stage);
      if (photoUrl != null) await prefs.setString('photoUrl', photoUrl);
    }

    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    _fullName = prefs.getString('fullName');
    _email = prefs.getString('email');
    _role = prefs.getString('role');
    _department = prefs.getString('department');
    _stage = prefs.getString('stage');
    _photoUrl = prefs.getString('photoUrl');
    notifyListeners();
  }

  Future<void> clearUser() async {
    _userId = null;
    _fullName = null;
    _email = null;
    _role = null;
    _department = null;
    _stage = null;
    _photoUrl = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
