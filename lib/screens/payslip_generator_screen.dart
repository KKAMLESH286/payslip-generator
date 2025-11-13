import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payslip.dart';
import '../services/pdf_generator.dart';

class PayslipGeneratorScreen extends StatefulWidget {
  const PayslipGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<PayslipGeneratorScreen> createState() => _PayslipGeneratorScreenState();
}

class _PayslipGeneratorScreenState extends State<PayslipGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for earnings
  final _basicSalaryController = TextEditingController(text: '600');
  final _hraController = TextEditingController(text: '0');
  final _bonusController = TextEditingController(text: '0');
  final _otherAllowancesController = TextEditingController(text: '0');

  // Controllers for deductions
  final _taxWithholdingController = TextEditingController(text: '0');
  final _socialSecurityController = TextEditingController(text: '0');
  final _healthInsuranceController = TextEditingController(text: '0');
  final _otherDeductionsController = TextEditingController(text: '0');

  // Date controllers
  DateTime _paymentDate = DateTime.now();
  DateTime _periodStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _periodEnd = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  @override
  void dispose() {
    _basicSalaryController.dispose();
    _hraController.dispose();
    _bonusController.dispose();
    _otherAllowancesController.dispose();
    _taxWithholdingController.dispose();
    _socialSecurityController.dispose();
    _healthInsuranceController.dispose();
    _otherDeductionsController.dispose();
    super.dispose();
  }

  double _calculateTotal(List<TextEditingController> controllers) {
    return controllers.fold(0.0, (sum, controller) => sum + (double.tryParse(controller.text) ?? 0));
  }

  double _calculateNetPay() {
    final earnings = _calculateTotal([
      _basicSalaryController,
      _hraController,
      _bonusController,
      _otherAllowancesController,
    ]);

    final deductions = _calculateTotal([
      _taxWithholdingController,
      _socialSecurityController,
      _healthInsuranceController,
      _otherDeductionsController,
    ]);

    return earnings - deductions;
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: type == 'payment'
          ? _paymentDate
          : type == 'start'
              ? _periodStart
              : _periodEnd,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (type == 'payment') {
          _paymentDate = picked;
        } else if (type == 'start') {
          _periodStart = picked;
        } else {
          _periodEnd = picked;
        }
      });
    }
  }

  void _generatePayslip() async {
    if (_formKey.currentState!.validate()) {
      final payslip = Payslip(
        company: Payslip.heyFlutterCompany(),
        employee: Payslip.kamleshPanwar(),
        paymentDate: _paymentDate,
        periodStart: _periodStart,
        periodEnd: _periodEnd,
        basicSalary: double.parse(_basicSalaryController.text),
        hra: double.parse(_hraController.text),
        bonus: double.parse(_bonusController.text),
        otherAllowances: double.parse(_otherAllowancesController.text),
        taxWithholding: double.parse(_taxWithholdingController.text),
        socialSecurity: double.parse(_socialSecurityController.text),
        healthInsurance: double.parse(_healthInsuranceController.text),
        otherDeductions: double.parse(_otherDeductionsController.text),
        payslipNumber: 'PS-${DateFormat('yyyyMM').format(_paymentDate)}-001',
      );

      try {
        await PayslipPdfGenerator.generateAndPrint(payslip);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payslip generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating payslip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HeyFlutter Payslip Generator'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Company Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HeyFlutter UG (haftungsbeschränkt)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Kassel, Germany'),
                    const Text('www.heyflutter.com'),
                    const Text('CEO: Johannes Milke'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Employee Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Name:', 'Kamlesh Panwar'),
                    _buildInfoRow('Position:', 'Flutter Developer'),
                    _buildInfoRow('Department:', 'Product Engineering'),
                    _buildInfoRow('Email:', 'kkamlesh286@gmail.com'),
                    _buildInfoRow('Bank A/C:', '70010392360'),
                    _buildInfoRow('Tax ID:', 'GXTPK7054L'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date Selection Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay Period & Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, 'start'),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Period Start Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd MMM yyyy').format(_periodStart)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, 'end'),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Period End Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd MMM yyyy').format(_periodEnd)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, 'payment'),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Payment Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        child: Text(DateFormat('dd MMM yyyy').format(_paymentDate)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Earnings Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earnings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildAmountField(
                      'Basic Salary (€)',
                      _basicSalaryController,
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 12),
                    _buildAmountField(
                      'HRA / Allowance (€)',
                      _hraController,
                      Icons.home,
                    ),
                    const SizedBox(height: 12),
                    _buildAmountField(
                      'Bonus (pro-rated) (€)',
                      _bonusController,
                      Icons.card_giftcard,
                    ),
                    const SizedBox(height: 12),
                    _buildAmountField(
                      'Other Allowances (€)',
                      _otherAllowancesController,
                      Icons.add_circle_outline,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Earnings:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '€ ${_calculateTotal([_basicSalaryController, _hraController, _bonusController, _otherAllowancesController]).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Deductions Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deductions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildAmountField(
                      'Tax Withholding (€)',
                      _taxWithholdingController,
                      Icons.account_balance,
                    ),
                    const SizedBox(height: 12),
                    _buildAmountField(
                      'Social Security (€)',
                      _socialSecurityController,
                      Icons.security,
                    ),
                    const SizedBox(height: 12),
                    _buildAmountField(
                      'Health Insurance (€)',
                      _healthInsuranceController,
                      Icons.local_hospital,
                    ),
                    const SizedBox(height: 12),
                    _buildAmountField(
                      'Other Deductions (€)',
                      _otherDeductionsController,
                      Icons.remove_circle_outline,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Deductions:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '€ ${_calculateTotal([_taxWithholdingController, _socialSecurityController, _healthInsuranceController, _otherDeductionsController]).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Net Pay Card
            Card(
              elevation: 8,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Pay:',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '€ ${_calculateNetPay().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Generate Button
            ElevatedButton.icon(
              onPressed: _generatePayslip,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate Payslip PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAmountField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      onChanged: (value) => setState(() {}),
    );
  }
}
