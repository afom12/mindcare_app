import 'package:flutter/foundation.dart';

import '../models/mood_entry.dart';
import '../services/mood_repository.dart';

class MoodProvider extends ChangeNotifier {
  MoodProvider(this._repo);

  final MoodRepository _repo;

  List<MoodEntry> _entries = [];
  List<MoodEntry> get entries => List.unmodifiable(_entries);

  bool _loading = true;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _entries = await _repo.load();
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
  }
}
