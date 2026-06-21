import 'package:shared_preferences/shared_preferences.dart';

const String _onboardingKey = 'onboarding_complete';

Future<bool> shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_onboardingKey) ?? false);
}

Future<void> markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingKey, true);
}
