import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/therapist_listing.dart';
import '../../services/api_exception.dart';
import '../../services/booking_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/gradient_background.dart';

class TherapistBookingsScreen extends StatefulWidget {
  const TherapistBookingsScreen({super.key});

  @override
  State<TherapistBookingsScreen> createState() => _TherapistBookingsScreenState();
}

class _TherapistBookingsScreenState extends State<TherapistBookingsScreen> {
  List<TherapistListing> _list = [];
  bool _loading = true;
  String? _error;
  String? _bookingBusyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final therapists = await context.read<BookingService>().fetchTherapists();
      if (mounted) {
        setState(() {
          _list = therapists;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not load therapists.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _request(TherapistListing t) async {
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Request time with ${t.name}'),
        content: TextField(
          controller: note,
          decoration: const InputDecoration(
            labelText: 'Optional note (topics, availability)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send request')),
        ],
      ),
    );
    final noteText = note.text.trim();
    note.dispose();
    if (ok != true || !mounted) return;
    setState(() => _bookingBusyId = t.id);
    try {
      await context.read<BookingService>().requestBooking(
            therapistId: t.id,
            note: noteText.isEmpty ? null : noteText,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking request sent for ${t.name}.')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request could not be sent.')),
        );
      }
    } finally {
      if (mounted) setState(() => _bookingBusyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a session'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Try again')),
                      ],
                    ),
                  )
                : _list.isEmpty
                    ? const EmptyState(
                        title: 'No therapists listed',
                        subtitle:
                            'Your school or program can expose therapists here via GET /therapists. You can still use Human support for messaging when assigned.',
                        icon: Icons.event_available_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.teal,
                        child: ListView.separated(
                          itemCount: _list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final t = _list[i];
                            final busy = _bookingBusyId == t.id;
                            return FadeIn(
                              delay: Duration(milliseconds: 40 * i.clamp(0, 12)),
                              child: Material(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(18),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      if (t.title != null && t.title!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          t.title!,
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: AppColors.teal,
                                              ),
                                        ),
                                      ],
                                      if (t.bio != null && t.bio!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          t.bio!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppColors.inkMuted,
                                                height: 1.35,
                                              ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: FilledButton(
                                          onPressed: busy ? null : () => _request(t),
                                          style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                                          child: busy
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text('Request booking'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
