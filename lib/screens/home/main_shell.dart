import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/main_shell_controller.dart';
import '../../providers/mood_provider.dart';
import '../calm/calm_tools_screen.dart';
import '../insights/insights_screen.dart';
import '../mood/mood_screen.dart';
import '../profile/profile_screen.dart';
import '../security/pin_unlock_overlay.dart';
import '../therapist/therapist_hub_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<MoodProvider>().load();
      final first = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _online = !first.contains(ConnectivityResult.none);
        });
      }
    });
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      setState(() {
        _online = !results.contains(ConnectivityResult.none);
      });
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<MainShellController>();
    final pages = const [
      HomeScreen(),
      MoodScreen(),
      CalmToolsScreen(),
      TherapistHubScreen(),
      InsightsScreen(),
      ProfileScreen(),
    ];
    return PinUnlockOverlay(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_online)
              Material(
                color: AppColors.amber.withValues(alpha: 0.25),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: AppColors.amber.withValues(alpha: 0.95)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You appear offline. AI chat, therapist sync, and sign-in need the network.',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.ink,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: IndexedStack(
                  index: shell.index,
                  children: pages,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.index,
          onDestinationSelected: (i) => context.read<MainShellController>().goTo(i),
          height: 68,
          indicatorColor: AppColors.teal.withValues(alpha: 0.18),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
              tooltip: 'Home tab',
            ),
            NavigationDestination(
              icon: Icon(Icons.mood_outlined),
              selectedIcon: Icon(Icons.mood_rounded),
              label: 'Mood',
              tooltip: 'Mood tab',
            ),
            NavigationDestination(
              icon: Icon(Icons.spa_outlined),
              selectedIcon: Icon(Icons.spa_rounded),
              label: 'Calm',
              tooltip: 'Calm tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.support_agent_outlined),
              selectedIcon: Icon(Icons.support_agent_rounded),
              label: 'Support',
              tooltip: 'Human support',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Insights',
              tooltip: 'Insights tab',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
              tooltip: 'Profile tab',
            ),
          ],
        ),
      ),
    );
  }
}
