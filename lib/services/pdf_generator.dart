import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/payslip.dart';

class PayslipPdfGenerator {
  // Color scheme
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF1565C0); // Blue
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF0D47A1); // Dark Blue
  static const PdfColor accentColor = PdfColor.fromInt(0xFF42A5F5); // Light Blue
  static const PdfColor successColor = PdfColor.fromInt(0xFF2E7D32); // Green
  static const PdfColor textColor = PdfColor.fromInt(0xFF263238); // Dark Grey
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF5F5F5); // Light Grey
  static const PdfColor warningColor = PdfColor.fromInt(0xFFFF6F00); // Orange

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
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Modern Header with gradient-like effect
              _buildModernHeader(payslip.company),
              pw.SizedBox(height: 25),

              // Payslip Title Bar
              _buildTitleBar(payslip, dateFormat),
              pw.SizedBox(height: 25),

              // Two-column layout for employee and company info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Employee Information
                  pw.Expanded(
                    child: _buildInfoCard(
                      'EMPLOYEE DETAILS',
                      [
                        ['Name', payslip.employee.name],
                        ['Position', payslip.employee.position],
                        ['Email', payslip.employee.email],
                      ],
                      primaryColor,
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  // Company Bank Details
                  pw.Expanded(
                    child: _buildInfoCard(
                      'COMPANY BANK DETAILS',
                      [
                        ['IBAN', payslip.company.iban],
                        ['BIC', payslip.company.bic],
                      ],
                      secondaryColor,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // Salary Breakdown Table
              _buildSalaryTable(payslip, currencyFormat),
              pw.SizedBox(height: 25),

              // Payment Details with crypto info
              _buildPaymentCard(payslip, currencyFormat),

              pw.Spacer(),

              // Professional Footer
              _buildFooter(payslip.company),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildModernHeader(Company company) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                company.name.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                company.address,
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                company.website,
                style: pw.TextStyle(
                  fontSize: 11,
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'CEO',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: textColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  company.ceo,
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTitleBar(Payslip payslip, DateFormat dateFormat) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: primaryColor, width: 2),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PAYSLIP',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Payment Period: ${payslip.paymentPeriod}',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: textColor,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  payslip.payslipNumber,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Date: ${dateFormat.format(payslip.paymentDate)}',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: textColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoCard(
    String title,
    List<List<String>> items,
    PdfColor color,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(6),
                topRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          // Content
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              children: items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 70,
                        child: pw.Text(
                          '${item[0]}:',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          item[1],
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSalaryTable(Payslip payslip, NumberFormat currencyFormat) {
    final tableHeaders = ['DESCRIPTION', 'AMOUNT'];
    final rows = <List<String>>[];

    // Gross Salary
    rows.add(['Gross Salary', currencyFormat.format(payslip.grossSalary)]);

    // Additions
    if (payslip.additions.isNotEmpty) {
      rows.add(['', '']); // Spacer
      rows.add(['ADDITIONS', '']);
      for (var entry in payslip.additions.entries) {
        rows.add(['  ${entry.key}', '+ ${currencyFormat.format(entry.value)}']);
      }
    }

    // Deductions
    if (payslip.deductions.isNotEmpty) {
      rows.add(['', '']); // Spacer
      rows.add(['DEDUCTIONS', '']);
      for (var entry in payslip.deductions.entries) {
        rows.add(['  ${entry.key}', '- ${currencyFormat.format(entry.value)}']);
      }
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Table Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(6),
                topRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Text(
              'SALARY BREAKDOWN',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          // Table
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColors.grey300),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: lightBg),
                children: tableHeaders.map((header) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Data Rows
              ...rows.map((row) {
                final isSection = row[1].isEmpty && row[0].isNotEmpty;
                final isGross = row[0] == 'Gross Salary';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isSection ? lightBg : null,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        row[0],
                        style: pw.TextStyle(
                          fontSize: isSection ? 10 : 9,
                          fontWeight: (isSection || isGross)
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                          color: isSection ? primaryColor : textColor,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        row[1],
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: isGross ? pw.FontWeight.bold : pw.FontWeight.normal,
                          color: row[1].startsWith('+')
                              ? successColor
                              : row[1].startsWith('-')
                                  ? warningColor
                                  : textColor,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          // Net Salary Footer
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [successColor, PdfColor.fromInt(0xFF1B5E20)],
              ),
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(6),
                bottomRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'NET SALARY',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.Text(
                  currencyFormat.format(payslip.netSalary),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentCard(Payslip payslip, NumberFormat currencyFormat) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [
            PdfColor.fromInt(0xFFF57F17),
            PdfColor.fromInt(0xFFFF6F00),
          ],
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PAYMENT METHOD',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Cryptocurrency',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Currency: ${payslip.employee.cryptoCurrency}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Container(
            width: 200,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Wallet Address:',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: textColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  payslip.employee.cryptoAddress,
                  style: pw.TextStyle(
                    fontSize: 7,
                    color: warningColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Company company) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(top: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This is a computer-generated payslip and does not require a signature.',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                company.name,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: textColor,
                ),
              ),
              pw.Text(' | ', style: const pw.TextStyle(fontSize: 9)),
              pw.Text(
                company.website,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: primaryColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(' | ', style: const pw.TextStyle(fontSize: 9)),
              pw.Text(
                'CEO: ${company.ceo}',
                style: const pw.TextStyle(fontSize: 9, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
