import 'package:flutter/foundation.dart';

/// Coordinates bottom navigation between [MainShell] and nested screens.
/// Indices: 0 Home, 1 Mood, 2 Calm, 3 Therapist, 4 Insights, 5 Profile.
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
  void goCalm() => goTo(2);
  void goTherapist() => goTo(3);
  void goInsights() => goTo(4);
  void goProfile() => goTo(5);
}
