import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/core/theme/icons/app_icons.dart';
import 'package:oasis/core/theme/app_theme.dart';
import 'package:oasis/features/safety_plan/presentation/screens/safety_plan_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SafetyPlanScreen renders core crisis support content',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          home: const SafetyPlanScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Plan de seguridad'), findsOneWidget);
    expect(find.textContaining('Paso 1'), findsOneWidget);
    expect(find.textContaining('Motivos para seguir'), findsOneWidget);
    expect(find.byIcon(AppIcons.warning), findsOneWidget);
    expect(find.text('Salir'), findsOneWidget);
    expect(find.textContaining('No estoy bien'), findsNothing);
    expect(find.textContaining('No me siento bien'), findsNothing);
  });
}
