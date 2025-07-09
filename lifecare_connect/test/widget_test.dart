// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecare_connect/main.dart'; // Adjust if your app file name is different

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