import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payslip_generator/main.dart';

void main() {
  testWidgets('Payslip Generator app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PayslipGeneratorApp());

    // Verify that the app title is displayed
    expect(find.text('HeyFlutter Payslip Generator'), findsOneWidget);

    // Verify that company name is displayed
    expect(find.text('HeyFlutter UG (haftungsbeschränkt)'), findsOneWidget);

    // Verify that employee name is displayed
    expect(find.text('Kamlesh Panwar'), findsOneWidget);

    // Verify that the generate button is present
    expect(find.text('Generate Payslip PDF'), findsOneWidget);
  });
}
