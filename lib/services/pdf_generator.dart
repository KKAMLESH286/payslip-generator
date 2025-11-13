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

  static Future<pw.Document> generate(Payslip payslip) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd.MM.yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Header
              _buildHeader(payslip.company),
              pw.SizedBox(height: 30),

              // Payslip Title
              pw.Center(
                child: pw.Text(
                  'PAYSLIP',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Payslip Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Payslip Number: ${payslip.payslipNumber}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Payment Period: ${payslip.paymentPeriod}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Payment Date: ${dateFormat.format(payslip.paymentDate)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Employee Information
              _buildSection('Employee Information', [
                ['Name:', payslip.employee.name],
                ['Position:', payslip.employee.position],
                ['Email:', payslip.employee.email],
              ]),
              pw.SizedBox(height: 20),

              // Salary Breakdown
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SALARY BREAKDOWN',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Divider(),
                    pw.SizedBox(height: 10),

                    // Gross Salary
                    _buildRow('Gross Salary:', currencyFormat.format(payslip.grossSalary)),
                    pw.SizedBox(height: 10),

                    // Additions
                    if (payslip.additions.isNotEmpty) ...[
                      pw.Text('Additions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...payslip.additions.entries.map((entry) =>
                          _buildRow('  ${entry.key}:', currencyFormat.format(entry.value))),
                      pw.SizedBox(height: 10),
                    ],

                    // Deductions
                    if (payslip.deductions.isNotEmpty) ...[
                      pw.Text('Deductions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...payslip.deductions.entries.map((entry) =>
                          _buildRow('  ${entry.key}:', '- ${currencyFormat.format(entry.value)}')),
                      pw.SizedBox(height: 10),
                    ],

                    pw.Divider(),
                    pw.SizedBox(height: 10),

                    // Net Salary
                    _buildRow(
                      'Net Salary:',
                      currencyFormat.format(payslip.netSalary),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Payment Details
              _buildSection('Payment Details', [
                ['Payment Method:', 'Cryptocurrency'],
                ['Currency:', payslip.employee.cryptoCurrency],
                ['Wallet Address:', payslip.employee.cryptoAddress],
              ]),
              pw.SizedBox(height: 30),

              // Company Bank Details
              _buildSection('Company Bank Details', [
                ['IBAN:', payslip.company.iban],
                ['BIC:', payslip.company.bic],
              ]),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      payslip.company.name,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'CEO: ${payslip.company.ceo}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      payslip.company.website,
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(Company company) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            company.name,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(company.address, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(company.website, style: const pw.TextStyle(fontSize: 12)),
          pw.Text('CEO: ${company.ceo}', style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(String title, List<List<String>> items) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 150,
                      child: pw.Text(item[0],
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(child: pw.Text(item[1])),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static pw.Widget _buildRow(String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
