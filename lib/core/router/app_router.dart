import 'package:flutter/material.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/bookings/therapist_bookings_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/home/main_shell.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/resources/resources_screen.dart';
import '../../screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String resources = '/resources';
  static const String bookings = '/bookings';

  static Map<String, WidgetBuilder> routes() => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const MainShell(),
        chat: (_) => const ChatScreen(),
        resources: (_) => const ResourcesScreen(),
        bookings: (_) => const TherapistBookingsScreen(),
      };
}
