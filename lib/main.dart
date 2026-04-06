import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/main_shell_controller.dart';
import 'providers/mood_provider.dart';
import 'providers/privacy_provider.dart';
import 'providers/therapist_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/chat_local_store.dart';
import 'services/chat_service.dart';
import 'services/greeting_catalog.dart';
import 'services/local_notification_service.dart';
import 'services/mood_repository.dart';
import 'services/privacy_service.dart';
import 'services/secure_storage_service.dart';
import 'services/therapist_service.dart';

/// Shared root widget for `runApp` and tests.
Widget mindCareRoot() {
  final storage = SecureStorageService();
  final api = ApiClient(storage);
  final authService = AuthService(api);
  final chatService = ChatService(api);
  final moodRepo = MoodRepository();
  final chatStore = ChatLocalStore();
  final greetings = GreetingCatalog();
  final privacyService = PrivacyService();
  final notifications = LocalNotificationService();
  final therapistService = TherapistService(api);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => MainShellController()),
      Provider<SecureStorageService>.value(value: storage),
      Provider<ApiClient>.value(value: api),
      Provider<AuthService>.value(value: authService),
      Provider<ChatService>.value(value: chatService),
      Provider<TherapistService>.value(value: therapistService),
      Provider<MoodRepository>.value(value: moodRepo),
      Provider<ChatLocalStore>.value(value: chatStore),
      Provider<GreetingCatalog>.value(value: greetings),
      Provider<PrivacyService>.value(value: privacyService),
      Provider<LocalNotificationService>.value(value: notifications),
      ChangeNotifierProvider(
        create: (c) => PrivacyProvider(c.read<PrivacyService>()),
      ),
      ChangeNotifierProvider(
        create: (c) => AuthProvider(
          c.read<AuthService>(),
          c.read<SecureStorageService>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (c) => ChatProvider(
          c.read<ChatService>(),
          c.read<ChatLocalStore>(),
          c.read<GreetingCatalog>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (c) => MoodProvider(c.read<MoodRepository>()),
      ),
      ChangeNotifierProvider(
        create: (c) => TherapistProvider(
          c.read<TherapistService>(),
          c.read<AuthProvider>(),
        ),
      ),
    ],
    child: const _MindCareRootApp(),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(mindCareRoot());
}

class _MindCareRootApp extends StatefulWidget {
  const _MindCareRootApp();

  @override
  State<_MindCareRootApp> createState() => _MindCareRootAppState();
}

class _MindCareRootAppState extends State<_MindCareRootApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initNotifications());
  }

  Future<void> _initNotifications() async {
    if (!mounted) return;
    final notif = context.read<LocalNotificationService>();
    final privacy = context.read<PrivacyProvider>();
    await notif.init();
    await notif.requestPermissionsIfNeeded();
    await privacy.bootstrap();
    if (!mounted) return;
    if (privacy.dailyReminderEnabled) {
      await notif.scheduleDailyMoodReminder();
    } else {
      await notif.cancelDailyReminder();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final privacy = context.read<PrivacyProvider>();
    if (state == AppLifecycleState.paused) {
      privacy.markPaused();
    } else if (state == AppLifecycleState.resumed) {
      privacy.maybeLockAfterResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'MindCare AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.mode,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes(),
    );
  }
}
