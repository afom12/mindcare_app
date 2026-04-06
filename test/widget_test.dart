import 'package:flutter_test/flutter_test.dart';

import 'package:mindcare_ai/main.dart';

void main() {
  testWidgets('MindCare app builds', (WidgetTester tester) async {
    await tester.pumpWidget(mindCareRoot());
    await tester.pump();
    expect(find.text('MindCare AI'), findsOneWidget);
  });
}
