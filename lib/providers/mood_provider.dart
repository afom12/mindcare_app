import 'package:flutter/foundation.dart';

import '../models/mood_entry.dart';
import '../services/api_exception.dart';
import '../services/mood_repository.dart';
import '../services/mood_service.dart';
import 'auth_provider.dart';

class MoodProvider extends ChangeNotifier {
  MoodProvider(
    this._repo,
    this._moodService,
    this._auth,
  );

  final MoodRepository _repo;
  final MoodService _moodService;
  final AuthProvider _auth;

  List<MoodEntry> _entries = [];
  List<MoodEntry> get entries => List.unmodifiable(_entries);

  bool _loading = true;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final local = await _repo.load();
    if (_auth.isAuthenticated) {
      final remote = await _moodService.tryFetchEntries();
      if (remote != null) {
        final ids = remote.map((e) => e.id).toSet();
        final extra = local.where((e) => !ids.contains(e.id));
        _entries = [...remote, ...extra].toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        await _repo.saveAll(_entries);
      } else {
        _entries = local;
      }
    } else {
      _entries = local;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addEntry({
    required String label,
    required String emoji,
    String? note,
  }) async {
    final entry = MoodEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: label,
      emoji: emoji,
      createdAt: DateTime.now(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
    _entries = [entry, ..._entries];
    await _repo.saveAll(_entries);
    notifyListeners();
    if (_auth.isAuthenticated) {
      try {
        await _moodService.createEntry(entry);
      } on ApiException {
        /* keep local copy; sync can retry on next load */
      } catch (_) {}
    }
  }
}
