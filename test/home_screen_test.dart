import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/core/theme/app_theme.dart';
import 'package:oasis/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders dashboard content and upcoming tasks',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    const greetings = <String>[
      '🌅 Buenos días.',
      '☀ Buenas tardes.',
      '🌙 Buenas noches.',
      '🌅 Buenos días, Erick.',
      '☀ Buenas tardes, Erick.',
      '🌙 Buenas noches, Erick.',
    ];

    expect(
      greetings.any((greeting) => find.text(greeting).evaluate().isNotEmpty),
      isTrue,
    );
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Resumen del día'), findsOneWidget);
    expect(find.text('Próximas tareas'), findsOneWidget);
    expect(find.textContaining('Revisar'), findsOneWidget);
  });
}
