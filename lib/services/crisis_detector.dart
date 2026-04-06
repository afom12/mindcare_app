/// UI-level keyword hints — not clinical diagnosis. Shows supportive resources.
class CrisisDetector {
  CrisisDetector._();

  static const _keywords = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'hurt myself',
    'self harm',
    'no reason to live',
    'better off dead',
    'hopeless',
    'worthless',
    'end it all',
    'can\'t go on',
    'cant go on',
  ];

  /// Returns true if [text] should trigger a supportive safety sheet.
  static bool shouldFlag(String text) {
    final t = text.toLowerCase();
    for (final k in _keywords) {
      if (t.contains(k)) return true;
    }
    return false;
  }
}
