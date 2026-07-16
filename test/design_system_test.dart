import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/core/theme/app_theme.dart';
import 'package:oasis/shared/widgets/app_card.dart';
import 'package:oasis/shared/widgets/app_text_field.dart';
import 'package:oasis/shared/widgets/filter_chip.dart' as oasis_filter_chip;
import 'package:oasis/shared/widgets/primary_button.dart';
import 'package:oasis/shared/widgets/secondary_button.dart';
import 'package:oasis/shared/widgets/status_chip.dart';
import 'package:oasis/shared/widgets/tag_chip.dart';
import 'package:oasis/shared/widgets/text_button.dart';
import 'package:oasis/shared/widgets/icon_button.dart';
import 'package:oasis/shared/widgets/floating_button.dart';

void main() {
  testWidgets('design system widgets render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                PrimaryButton(text: 'Continue'),
                SecondaryButton(text: 'Cancel'),
                AppTextField(label: 'Email'),
                AppCard(child: Text('Card')),
                StatusChip(label: 'Ready', type: StatusType.success),
                TagChip(label: 'Home'),
                oasis_filter_chip.FilterChip(label: 'All', isSelected: true),
                AppTextButton(text: 'Learn more'),
                AppIconButton(icon: Icons.add),
                AppFloatingButton(icon: Icons.add),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
  });
}
