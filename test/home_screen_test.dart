import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/core/theme/app_theme.dart';
import 'package:oasis/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders redesigned dashboard sections',
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

    expect(find.text('🌿 Buenos días, Erick'), findsOneWidget);
    expect(find.text('✨ Captura rápida'), findsOneWidget);
    expect(find.text('Nueva nota'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsOneWidget);
    expect(find.text('Nueva cita'), findsOneWidget);
    expect(find.text('Registrar estado'), findsOneWidget);
    expect(find.text('Medicación'), findsOneWidget);
    expect(find.text('Agenda del día'), findsOneWidget);
    expect(find.text('Hidratación'), findsOneWidget);
    expect(find.text('Estado emocional'), findsOneWidget);
  });
}
