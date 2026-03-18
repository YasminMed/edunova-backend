import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _fullName;
  String? _email;
  String? _role;
  
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;

  void setUser(String fullName, String email, String role) {
    _fullName = fullName;
    _email = email;
    _role = role;
    notifyListeners();
  }

  void clearUser() {
    _fullName = null;
    _email = null;
    _role = null;
    notifyListeners();
  }
}
