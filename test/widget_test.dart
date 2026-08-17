import 'package:flutter_test/flutter_test.dart';
import 'package:biggopti/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BiggoptiApp());
    expect(find.byType(BiggoptiApp), findsOneWidget);
  });
}
