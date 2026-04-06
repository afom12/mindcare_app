import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/main_shell_controller.dart';
import 'providers/mood_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/mood_repository.dart';
import 'services/secure_storage_service.dart';

/// Shared root widget for `runApp` and tests.
Widget mindCareRoot() {
  final storage = SecureStorageService();
  final api = ApiClient(storage);
  final authService = AuthService(api);
  final chatService = ChatService(api);
  final moodRepo = MoodRepository();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => MainShellController()),
      Provider<SecureStorageService>.value(value: storage),
      Provider<ApiClient>.value(value: api),
      Provider<AuthService>.value(value: authService),
      Provider<ChatService>.value(value: chatService),
      Provider<MoodRepository>.value(value: moodRepo),
      ChangeNotifierProvider(
        create: (c) => AuthProvider(
          c.read<AuthService>(),
          c.read<SecureStorageService>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (c) => ChatProvider(c.read<ChatService>()),
      ),
      ChangeNotifierProvider(
        create: (c) => MoodProvider(c.read<MoodRepository>()),
      ),
    ],
    child: const MindCareApp(),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(mindCareRoot());
}

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

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
