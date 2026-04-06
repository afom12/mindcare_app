import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _key = 'mindcare_onboarding_done';

  Future<bool> hasCompletedOnboarding() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? false;
  }

  Future<void> setCompletedOnboarding() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, true);
  }
}
