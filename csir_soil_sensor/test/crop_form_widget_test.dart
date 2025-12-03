import 'package:csir_soil_sensor/src/features/crop_params/crop_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CropFormScreen validates required fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CropFormScreen(),
        ),
      ),
    );

    // Tap save without filling anything or picking an image.
    final saveButtonFinder = find.text('Save parameters');
    expect(saveButtonFinder, findsOneWidget);

    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // Expect validation messages for required fields.
    expect(find.text('Required'), findsWidgets);
  });
}


