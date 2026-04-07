import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../models/resource_item.dart';
import '../../services/api_exception.dart';
import '../../services/resource_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/gradient_background.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  List<ResourceItem> _items = [];
  bool _loading = true;
  String? _error;

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
      final list = await context.read<ResourceService>().fetchResources();
      if (mounted) {
        setState(() {
          _items = list;
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
          _error = 'Could not load resources.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final u = Uri.tryParse(url);
    if (u == null || !u.hasScheme) return;
    final ok = await launchUrl(u, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
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
                : _items.isEmpty
                    ? const EmptyState(
                        title: 'No resources yet',
                        subtitle:
                            'When your program publishes articles and helplines, they will appear here. Pull to refresh after the API is configured.',
                        icon: Icons.menu_book_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.teal,
                        child: ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final r = _items[i];
                            return FadeIn(
                              delay: Duration(milliseconds: 40 * i.clamp(0, 12)),
                              child: Material(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: r.url != null && r.url!.isNotEmpty
                                      ? () => _openUrl(r.url)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (r.category != null && r.category!.isNotEmpty)
                                          Text(
                                            r.category!,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: AppColors.teal,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        if (r.category != null && r.category!.isNotEmpty)
                                          const SizedBox(height: 4),
                                        Text(
                                          r.title,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        if (r.subtitle != null && r.subtitle!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            r.subtitle!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppColors.inkMuted,
                                                  height: 1.35,
                                                ),
                                          ),
                                        ],
                                        if (r.url != null && r.url!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.open_in_new_rounded,
                                                  size: 16, color: AppColors.teal.withValues(alpha: 0.9)),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Open link',
                                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                      color: AppColors.teal,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
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
