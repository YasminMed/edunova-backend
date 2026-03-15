import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _fullName;
  String? _email;
  
  String? get fullName => _fullName;
  String? get email => _email;

  void setUser(String fullName, String email) {
    _fullName = fullName;
    _email = email;
    notifyListeners();
  }

  void clearUser() {
    _fullName = null;
    _email = null;
    notifyListeners();
  }
}
