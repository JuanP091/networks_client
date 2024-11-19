import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/main.dart';

void main() {
  testWidgets('MyHomePage has a title and button', (WidgetTester tester) async {
    // Build the widget and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: MyHomePage(title: 'Test Title'),
    ));

    // Verify the title exists.
    expect(find.text('Test Title'), findsOneWidget);

    // Verify the button exists.
    expect(find.text('Connect to Server'), findsOneWidget);
  });
}
