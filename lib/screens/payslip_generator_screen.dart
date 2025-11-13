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

  // Controllers
  final _payslipNumberController = TextEditingController();
  final _paymentPeriodController = TextEditingController();
  final _grossSalaryController = TextEditingController(text: '600');

  DateTime _selectedDate = DateTime.now();
  final Map<String, TextEditingController> _deductionControllers = {};
  final Map<String, TextEditingController> _additionControllers = {};

  List<String> _deductionKeys = [];
  List<String> _additionKeys = [];

  @override
  void initState() {
    super.initState();
    // Set default values
    _payslipNumberController.text =
        'PS-${DateFormat('yyyyMM').format(DateTime.now())}-001';
    _paymentPeriodController.text = DateFormat('MMMM yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _payslipNumberController.dispose();
    _paymentPeriodController.dispose();
    _grossSalaryController.dispose();
    _deductionControllers.values.forEach((controller) => controller.dispose());
    _additionControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _addDeduction() {
    setState(() {
      final key = 'Deduction ${_deductionKeys.length + 1}';
      _deductionKeys.add(key);
      _deductionControllers[key] = TextEditingController(text: '0');
    });
  }

  void _removeDeduction(String key) {
    setState(() {
      _deductionKeys.remove(key);
      _deductionControllers[key]?.dispose();
      _deductionControllers.remove(key);
    });
  }

  void _addAddition() {
    setState(() {
      final key = 'Addition ${_additionKeys.length + 1}';
      _additionKeys.add(key);
      _additionControllers[key] = TextEditingController(text: '0');
    });
  }

  void _removeAddition(String key) {
    setState(() {
      _additionKeys.remove(key);
      _additionControllers[key]?.dispose();
      _additionControllers.remove(key);
    });
  }

  double _calculateNetSalary() {
    double gross = double.tryParse(_grossSalaryController.text) ?? 0;

    double totalAdditions = _additionControllers.values.fold(0.0,
        (sum, controller) => sum + (double.tryParse(controller.text) ?? 0));

    double totalDeductions = _deductionControllers.values.fold(0.0,
        (sum, controller) => sum + (double.tryParse(controller.text) ?? 0));

    return gross + totalAdditions - totalDeductions;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _generatePayslip() async {
    if (_formKey.currentState!.validate()) {
      final deductions = Map<String, double>.fromEntries(
        _deductionKeys.map((key) => MapEntry(
          key,
          double.tryParse(_deductionControllers[key]!.text) ?? 0,
        )),
      );

      final additions = Map<String, double>.fromEntries(
        _additionKeys.map((key) => MapEntry(
          key,
          double.tryParse(_additionControllers[key]!.text) ?? 0,
        )),
      );

      final payslip = Payslip(
        company: Payslip.heyFlutterCompany(),
        employee: Payslip.kamleshPanwar(),
        paymentDate: _selectedDate,
        paymentPeriod: _paymentPeriodController.text,
        grossSalary: double.parse(_grossSalaryController.text),
        netSalary: _calculateNetSalary(),
        deductions: deductions,
        additions: additions,
        payslipNumber: _payslipNumberController.text,
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
                    _buildInfoRow('Email:', 'kkamlesh286@gmail.com'),
                    _buildInfoRow('Crypto:', 'USDT'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payslip Details Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payslip Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _payslipNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Payslip Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter payslip number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _paymentPeriodController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Period',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: 'e.g., November 2025',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter payment period';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Payment Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        child: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _grossSalaryController,
                      decoration: const InputDecoration(
                        labelText: 'Gross Salary (€)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter gross salary';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Additions Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Additions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: Colors.green,
                          onPressed: _addAddition,
                        ),
                      ],
                    ),
                    ..._additionKeys.map((key) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(key),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _additionControllers[key],
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    prefixText: '€ ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => setState(() {}),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _removeAddition(key),
                              ),
                            ],
                          ),
                        )),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deductions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: Colors.orange,
                          onPressed: _addDeduction,
                        ),
                      ],
                    ),
                    ..._deductionKeys.map((key) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(key),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _deductionControllers[key],
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    prefixText: '€ ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => setState(() {}),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _removeDeduction(key),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Net Salary Display
            Card(
              elevation: 4,
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Salary:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '€ ${_calculateNetSalary().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
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
            width: 100,
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
}
