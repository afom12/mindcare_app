import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/privacy_provider.dart';

class PinUnlockOverlay extends StatefulWidget {
  const PinUnlockOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<PinUnlockOverlay> createState() => _PinUnlockOverlayState();
}

class _PinUnlockOverlayState extends State<PinUnlockOverlay> {
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await context.read<PrivacyProvider>().tryUnlock(_pin.text.trim());
    if (!mounted) return;
    if (ok) {
      _pin.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That PIN did not match. Take your time and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final privacy = context.watch<PrivacyProvider>();
    if (!privacy.shouldShowLock) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Material(
            color: Colors.black.withValues(alpha: 0.55),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Material(
                      borderRadius: BorderRadius.circular(26),
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded, size: 40, color: AppColors.teal),
                            const SizedBox(height: 12),
                            Text(
                              'MindCare is locked',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your PIN to continue.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _pin,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                              decoration: const InputDecoration(
                                labelText: 'PIN',
                                hintText: '••••',
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.teal,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Unlock'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
