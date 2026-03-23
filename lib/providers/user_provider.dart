import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _fullName;
  String? _email;
  String? _role;
  String? _department;
  String? _stage;
  
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;
  String? get department => _department;
  String? get stage => _stage;

  bool get isProfileComplete => 
      _department != null && _department!.isNotEmpty && 
      _stage != null && _stage!.isNotEmpty;

  void setUser(String fullName, String email, String role, {String? department, String? stage}) {
    _fullName = fullName;
    _email = email;
    _role = role;
    _department = department;
    _stage = stage;
    notifyListeners();
  }

  void clearUser() {
    _fullName = null;
    _email = null;
    _role = null;
    _department = null;
    _stage = null;
    notifyListeners();
  }
}
