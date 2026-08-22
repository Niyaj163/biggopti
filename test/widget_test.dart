import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biggopti/main.dart';
import 'package:biggopti/providers/circular_provider.dart';
import 'package:biggopti/models/circular_model.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          circularsProvider.overrideWith((ref) async => <CircularModel>[]),
        ],
        child: const BiggoptiApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(BiggoptiApp), findsOneWidget);
  });
}
