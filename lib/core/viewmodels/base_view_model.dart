import 'package:flutter/material.dart';

enum ViewState { idle, busy, error }

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setBusy(bool value) {
    _state = value ? ViewState.busy : ViewState.idle;
    notifyListeners();
  }
}
