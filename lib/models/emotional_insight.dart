/// Local-only insight derived from mood logs (no server).
class EmotionalInsight {
  EmotionalInsight({
    required this.weekLabel,
    required this.summary,
    required this.patterns,
    required this.suggestions,
    required this.dominantMoods,
    required this.checkInCount,
  });

  final String weekLabel;
  final String summary;
  final List<String> patterns;
  final List<String> suggestions;
  final Map<String, int> dominantMoods;
  final int checkInCount;
}
