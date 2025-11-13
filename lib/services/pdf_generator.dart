import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/payslip.dart';

class PayslipPdfGenerator {
  static Future<void> generateAndPrint(Payslip payslip) async {
    final pdf = await generate(payslip);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static String _amountInWords(double amount) {
    final ones = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
    final teens = ['ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
    final tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

    if (amount == 0) return 'Zero euros only';

    final intAmount = amount.toInt();
    String result = '';

    if (intAmount >= 1000) {
      final thousands = intAmount ~/ 1000;
      if (thousands < 10) {
        result += ones[thousands] + ' thousand ';
      } else if (thousands < 20) {
        result += teens[thousands - 10] + ' thousand ';
      } else {
        result += tens[thousands ~/ 10] + ' ' + ones[thousands % 10] + ' thousand ';
      }
    }

    final remainder = intAmount % 1000;
    if (remainder >= 100) {
      result += ones[remainder ~/ 100] + ' hundred ';
    }

    final lastTwo = remainder % 100;
    if (lastTwo >= 10 && lastTwo < 20) {
      result += teens[lastTwo - 10] + ' ';
    } else {
      if (lastTwo >= 20) {
        result += tens[lastTwo ~/ 10] + ' ';
      }
      if (lastTwo % 10 > 0) {
        result += ones[lastTwo % 10] + ' ';
      }
    }

    result = result.trim();
    if (result.isEmpty) result = 'zero';

    return result[0].toUpperCase() + result.substring(1) + ' euros only.';
  }

  static Future<pw.Document> generate(Payslip payslip) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Header - Simple and Clean
              _buildCleanHeader(payslip.company),
              pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  'Payslip / Salary Statement',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Employee Details Section
              _buildEmployeeDetails(payslip, dateFormat),
              pw.SizedBox(height: 20),

              // Earnings and Deductions Table
              _buildEarningsDeductionsTable(payslip, currencyFormat),
              pw.SizedBox(height: 15),

              // Amount in Words
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.5),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Amount in words: ',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _amountInWords(payslip.netPay),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Net Pay Box
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Net Pay (Amount credited)',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'EUR ${currencyFormat.format(payslip.netPay)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Signature Section
              _buildSignatureSection(payslip.company),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildCleanHeader(Company company) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          company.name,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          company.address,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          company.website,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget _buildEmployeeDetails(Payslip payslip, DateFormat dateFormat) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Column(
        children: [
          // Row 1: Employee Name and Bank Account
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailCell('Employee Name:', payslip.employee.name, isLeft: true),
              ),
              pw.Container(
                width: 0.5,
                height: 40,
                color: PdfColors.black,
              ),
              pw.Expanded(
                child: _buildDetailCell('Bank A/C:', payslip.employee.bankAccount),
              ),
            ],
          ),
          pw.Container(height: 0.5, color: PdfColors.black),

          // Row 2: Employee ID and PAN/Tax ID
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailCell('Employee ID:', payslip.employee.employeeId, isLeft: true),
              ),
              pw.Container(
                width: 0.5,
                height: 40,
                color: PdfColors.black,
              ),
              pw.Expanded(
                child: _buildDetailCell('PAN / Tax ID:', payslip.employee.taxId),
              ),
            ],
          ),
          pw.Container(height: 0.5, color: PdfColors.black),

          // Row 3: Designation and Location
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailCell('Designation:', payslip.employee.position, isLeft: true),
              ),
              pw.Container(
                width: 0.5,
                height: 40,
                color: PdfColors.black,
              ),
              pw.Expanded(
                child: _buildDetailCell('Location:', payslip.employee.location),
              ),
            ],
          ),
          pw.Container(height: 0.5, color: PdfColors.black),

          // Row 4: Department and Pay Period
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailCell('Department:', payslip.employee.department, isLeft: true),
              ),
              pw.Container(
                width: 0.5,
                height: 40,
                color: PdfColors.black,
              ),
              pw.Expanded(
                child: _buildDetailCell(
                  'Pay Period:',
                  '${dateFormat.format(payslip.periodStart)} - ${dateFormat.format(payslip.periodEnd)}',
                ),
              ),
            ],
          ),
          pw.Container(height: 0.5, color: PdfColors.black),

          // Row 5: Pay Date
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(),
              ),
              pw.Container(
                width: 0.5,
                height: 40,
                color: PdfColors.black,
              ),
              pw.Expanded(
                child: _buildDetailCell('Pay Date:', dateFormat.format(payslip.paymentDate)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailCell(String label, String value, {bool isLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: isLeft ? 110 : 90,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildEarningsDeductionsTable(Payslip payslip, NumberFormat currencyFormat) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Earnings Column
          pw.Expanded(
            child: pw.Column(
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                    ),
                  ),
                  child: pw.Text(
                    'Earnings',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                // Earnings Items
                _buildTableRow('Basic Salary', currencyFormat.format(payslip.basicSalary)),
                _buildTableRow('HRA / Allowance', currencyFormat.format(payslip.hra)),
                _buildTableRow('Bonus (pro-rated)', currencyFormat.format(payslip.bonus)),
                _buildTableRow('Other Allowances', currencyFormat.format(payslip.otherAllowances)),
                // Total
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Earnings:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        currencyFormat.format(payslip.totalEarnings),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Vertical Divider
          pw.Container(
            width: 0.5,
            color: PdfColors.black,
          ),
          // Deductions Column
          pw.Expanded(
            child: pw.Column(
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                    ),
                  ),
                  child: pw.Text(
                    'Deductions',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                // Deduction Items
                _buildTableRow('Tax Withholding', currencyFormat.format(payslip.taxWithholding)),
                _buildTableRow('Social Security', currencyFormat.format(payslip.socialSecurity)),
                _buildTableRow('Health Insurance', currencyFormat.format(payslip.healthInsurance)),
                _buildTableRow('Other Deductions', currencyFormat.format(payslip.otherDeductions)),
                // Total
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Deductions:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        currencyFormat.format(payslip.totalDeductions),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableRow(String label, String value) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.25),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureSection(Company company) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Prepared by:',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                ),
              ),
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    company.ceo,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    company.name,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Employee Signature:',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                ),
              ),
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Text(
                '',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
