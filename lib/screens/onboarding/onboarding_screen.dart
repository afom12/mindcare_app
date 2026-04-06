import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/onboarding_prefs.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_Slide> _slides = const [
    _Slide(
      title: 'You are not alone',
      body:
          'Whatever you carry today — stress, worry, or fatigue — you deserve gentle support.',
      icon: Icons.handshake_rounded,
    ),
    _Slide(
      title: 'Talk freely',
      body:
          'Share at your pace. MindCare AI listens without judgment and keeps the tone calm.',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    _Slide(
      title: 'Your space is safe',
      body:
          'A distraction-free place to reflect, breathe, and track how you feel over time.',
      icon: Icons.shield_moon_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingPrefs().setCompletedOnboarding();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SoftHeroOrb(size: 140),
                      const SizedBox(height: 36),
                      Icon(s.icon, size: 44, color: AppColors.teal),
                      const SizedBox(height: 28),
                      Text(
                        s.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.body,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.inkMuted,
                              height: 1.45,
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 26 : 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.line,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _index == _slides.length - 1 ? 'Get Started' : 'Continue',
              icon: _index == _slides.length - 1 ? Icons.arrow_forward_rounded : null,
              onPressed: () {
                if (_index < _slides.length - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                  );
                } else {
                  _finish();
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
