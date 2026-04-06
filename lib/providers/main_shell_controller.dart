import 'package:flutter/foundation.dart';

/// Coordinates bottom navigation between [MainShell] and nested screens (e.g. Home quick actions).
class MainShellController extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void goTo(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }

  void goHome() => goTo(0);
  void goMood() => goTo(1);
  void goProfile() => goTo(2);
}
