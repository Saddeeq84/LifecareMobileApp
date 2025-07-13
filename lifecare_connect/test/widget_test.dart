// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show testWidgets, WidgetTester, find, expect, findsOneWidget;
import '../lib/main.dart'; // Adjust the path if your main.dart is located elsewhere

void main() {
  testWidgets('LifeCareConnectApp loads role selection screen', (WidgetTester tester) async {
    // Launch the app
    await tester.pumpWidget(const LifeCareConnectApp());

    // Look for a known piece of text from your role selection screen
    expect(find.text('Select Account Type'), findsOneWidget);

    // Optionally check if the "Patient" button is there
    expect(find.text('Patient'), findsOneWidget);
  });
}
// This test checks if the main app loads the role selection screen correctly.