import 'package:shared_preferences/shared_preferences.dart';

/// Rotating warm greetings for the AI companion (local persistence of index).
class GreetingCatalog {
  static const _indexKey = 'mindcare_greeting_index';

  static const List<String> _lines = [
    'Hi — I am here to listen. Share what is on your mind, at your own pace.',
    'Welcome back. There is no rush; say only what feels okay to share.',
    'Hello, friend. This space is yours — soft, private, and judgment-free.',
    'Good to see you. Take a breath, then share whatever is heaviest today.',
    'I am with you. Small steps count — even naming a feeling is brave.',
    'Hey there. Whatever you carry, we can unpack it gently, together.',
  ];

  Future<String> nextAssistantGreeting() async {
    final p = await SharedPreferences.getInstance();
    var i = p.getInt(_indexKey) ?? 0;
    final text = _lines[i % _lines.length];
    i = (i + 1) % _lines.length;
    await p.setInt(_indexKey, i);
    return text;
  }

  String greetingForHome(String? firstName) {
    final name = firstName?.trim();
    if (name != null && name.isNotEmpty) {
      return 'Hi, $name — glad you are here.';
    }
    return 'Hi there — glad you are here.';
  }
}
