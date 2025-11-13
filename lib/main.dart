import 'package:flutter/material.dart';
import 'screens/payslip_generator_screen.dart';

void main() {
  runApp(const PayslipGeneratorApp());
}

class PayslipGeneratorApp extends StatelessWidget {
  const PayslipGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeyFlutter Payslip Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PayslipGeneratorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
