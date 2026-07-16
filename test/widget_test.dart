import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oasis/main.dart';

void main() {
  testWidgets('renders onboarding on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OasisApp()),
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a OASIS'), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
  });
}
