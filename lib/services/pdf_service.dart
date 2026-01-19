import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/repositories/bills_repository.dart';
import '../data/repositories/payments_dao.dart';
import '../data/repositories/tenders_repository.dart';
import '../database/app_database.dart' as db;
import '../models/bill.dart';
import '../models/tender.dart';
import 'settings_service.dart';

class PdfService {
  PdfService({
    required db.AppDatabase database,
    required BillsDao billsDao,
    required TnDao tnDao,
    required PaymentsDao paymentsDao,
  }) : _database = database,
       _billsDao = billsDao,
       _tnDao = tnDao,
       _paymentsDao = paymentsDao;

  final db.AppDatabase _database;
  final BillsDao _billsDao;
  final TnDao _tnDao;
  final PaymentsDao _paymentsDao;

  final NumberFormat _indianCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final DateFormat _displayDate = DateFormat('dd-MM-yyyy');
  final DateFormat _tableDate = DateFormat('dd/MM/yyyy');
  final DateFormat _timestampFormat = DateFormat('yyyy-MM-dd_HH-mm');

  // Font caching for Unicode support
  pw.Font? _robotoRegular;
  pw.Font? _robotoBold;

  /// Load Roboto fonts with Unicode support (cached)
  Future<void> _loadFonts() async {
    if (_robotoRegular != null && _robotoBold != null) {
      return; // Already loaded
    }

    final robotoRegularData = await rootBundle.load(
      'assets/fonts/Roboto-Regular.ttf',
    );
    final robotoBoldData = await rootBundle.load(
      'assets/fonts/Roboto-Bold.ttf',
    );

    _robotoRegular = pw.Font.ttf(robotoRegularData);
    _robotoBold = pw.Font.ttf(robotoBoldData);
  }

  /// Create PDF theme with Unicode-supporting fonts
  pw.ThemeData _createPdfTheme() {
    return pw.ThemeData.withFont(base: _robotoRegular!, bold: _robotoBold!);
  }

  Future<String> generateBillPdf({int? billId, int? tenderId}) async {
    // Load Unicode fonts first
    await _loadFonts();

    if (billId == null && tenderId == null) {
      throw ArgumentError('Either billId or tenderId must be provided');
    }

    List<Bill> bills;
    Tender? tender;

    if (billId != null) {
      // When a specific billId is provided, only generate PDF for that single bill
      final bill = await _billsDao.getBillById(billId);
      if (bill == null) {
        throw StateError('Bill not found');
      }
      bills = [bill];
      // Get tender info for reference number, but DON'T replace the single bill
      if (bill.tenderId != null) {
        tender = await _tnDao.getTenderById(bill.tenderId!);
      }
    } else {
      // When tenderId is provided, generate PDF for ALL bills of that tender
      final tnId = tenderId!;
      bills = await _billsDao.getBillsByTender(tnId);
      if (bills.isEmpty) {
        throw StateError('No bills recorded for this TN');
      }
      tender = await _tnDao.getTenderById(tnId);
    }

    bills.sort((a, b) => a.billDate.compareTo(b.billDate));
    final firm = await _loadFirm(bills.first.firmId);
    final enrichedBills = await _ensurePaymentsLoaded(bills);
    final rows = _buildBillTableRows(enrichedBills);
    final totals = _BillTableTotals.fromRows(rows);
    final workOrderNo = _resolveWorkOrder(enrichedBills, tender);

    final letterDate = DateTime.now();
    final tnNumber = tender?.tnNumber ?? enrichedBills.first.tnNumber;
    final referenceNo = _buildReferenceNumber(firm.code, tnNumber, letterDate);
    final workOrderDate = _resolveWorkOrderDate(enrichedBills, tender);
    final latestPayment = _resolveLatestPayment(enrichedBills);
    final chequeNo =
        (latestPayment?.transactionNo ?? '').isEmpty
            ? '________'
            : latestPayment!.transactionNo!;
    final chequeDate = latestPayment?.paymentDate;
    final totalPayable = totals.amountPayable;

    final pdf = pw.Document(theme: _createPdfTheme());
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20), // 20pt margins as specified
        build: (context) {
          return [
            // Header Row 1: No. and Date
            _buildHeaderRow1(referenceNo, letterDate),
            pw.SizedBox(height: 8),
            // Header Row 2: Subject and TN No.
            _buildHeaderRow2(tnNumber),
            pw.SizedBox(height: 8),
            // Horizontal divider
            pw.Divider(thickness: 0.5, color: PdfColors.black),
            pw.SizedBox(height: 12),
            // Bill Summary Section (Two Columns)
            _buildBillSummarySection(
              workOrderNo: workOrderNo,
              workOrderDate: workOrderDate,
              tnNumber: tnNumber,
              totalAmount: totals.amountOfBill,
              chequeNo: chequeNo,
              chequeDate: chequeDate,
              amountPayable: totalPayable,
            ),
            pw.SizedBox(height: 16),
            // Main Table
            _buildLandscapeTable(rows, totals),
            pw.SizedBox(height: 16),
            // Footer
            _buildFooterNotes(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (format) async => bytes);

    final filename = _billFilename(enrichedBills, tender);
    final savedPath = await _savePdf(bytes, filename);
    return savedPath;
  }

  Future<String> exportBillPdf({required int billId}) async {
    return generateBillPdf(billId: billId);
  }

  /// Generate PDF for multiple selected bills
  Future<String> exportSelectedBillsPdf({required List<int> billIds}) async {
    if (billIds.isEmpty) {
      throw ArgumentError('At least one bill ID must be provided');
    }

    // Load Unicode fonts first
    await _loadFonts();

    // Fetch all selected bills
    final List<Bill> bills = [];
    for (final billId in billIds) {
      final bill = await _billsDao.getBillById(billId);
      if (bill != null) {
        bills.add(bill);
      }
    }

    if (bills.isEmpty) {
      throw StateError('No bills found for the selected IDs');
    }

    // Get tender if all bills belong to the same tender
    Tender? tender;
    final tenderIds =
        bills.map((b) => b.tenderId).where((id) => id != null).toSet();
    if (tenderIds.length == 1 && tenderIds.first != null) {
      tender = await _tnDao.getTenderById(tenderIds.first!);
    }

    bills.sort((a, b) => a.billDate.compareTo(b.billDate));
    final firm = await _loadFirm(bills.first.firmId);
    final enrichedBills = await _ensurePaymentsLoaded(bills);
    final rows = _buildBillTableRows(enrichedBills);
    final totals = _BillTableTotals.fromRows(rows);
    final workOrderNo = _resolveWorkOrder(enrichedBills, tender);

    final letterDate = DateTime.now();
    final tnNumber = tender?.tnNumber ?? enrichedBills.first.tnNumber;
    final referenceNo = _buildReferenceNumber(firm.code, tnNumber, letterDate);
    final workOrderDate = _resolveWorkOrderDate(enrichedBills, tender);
    final latestPayment = _resolveLatestPayment(enrichedBills);
    final chequeNo =
        (latestPayment?.transactionNo ?? '').isEmpty
            ? '________'
            : latestPayment!.transactionNo!;
    final chequeDate = latestPayment?.paymentDate;
    final totalPayable = totals.amountPayable;

    final pdf = pw.Document(theme: _createPdfTheme());
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            _buildHeaderRow1(referenceNo, letterDate),
            pw.SizedBox(height: 8),
            _buildHeaderRow2(tnNumber),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.5, color: PdfColors.black),
            pw.SizedBox(height: 12),
            _buildBillSummarySection(
              workOrderNo: workOrderNo,
              workOrderDate: workOrderDate,
              tnNumber: tnNumber,
              totalAmount: totals.amountOfBill,
              chequeNo: chequeNo,
              chequeDate: chequeDate,
              amountPayable: totalPayable,
            ),
            pw.SizedBox(height: 16),
            _buildLandscapeTable(rows, totals),
            pw.SizedBox(height: 16),
            _buildFooterNotes(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (format) async => bytes);

    final timestamp = _timestampFormat.format(DateTime.now());
    final filename = 'selected_bills_${billIds.length}_$timestamp.pdf';
    final savedPath = await _savePdf(bytes, filename);
    return savedPath;
  }

  /// Generate Payment Details PDF for a tender showing payment information
  Future<String> exportPaymentDetailsPdf({required int tenderId}) async {
    // Load Unicode fonts first
    await _loadFonts();

    final bills = await _billsDao.getBillsByTender(tenderId);
    if (bills.isEmpty) {
      throw StateError('No bills found for this TN');
    }

    final tender = await _tnDao.getTenderById(tenderId);
    final firm = await _loadFirm(bills.first.firmId);
    final enrichedBills = await _ensurePaymentsLoaded(bills);

    // Sort by bill date
    enrichedBills.sort((a, b) => a.billDate.compareTo(b.billDate));

    final tnNumber = tender?.tnNumber ?? enrichedBills.first.tnNumber;
    final letterDate = DateTime.now();
    final referenceNo = _buildReferenceNumber(firm.code, tnNumber, letterDate);
    final workOrderNo = _resolveWorkOrder(enrichedBills, tender) ?? '-';
    final workOrderDate = _resolveWorkOrderDate(enrichedBills, tender);
    final paymentRows = _buildPaymentDetailRows(enrichedBills);
    final totalPayable = paymentRows.fold<double>(
      0,
      (sum, row) => sum + row.netPayable,
    );
    final latestPayment = _resolveLatestPayment(enrichedBills);

    final pdf = pw.Document(theme: _createPdfTheme());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build:
            (context) => [
              _referenceLine(referenceNo, letterDate),
              pw.SizedBox(height: 12),
              _workOrderDetailsSection(
                workOrderNo: workOrderNo,
                workOrderDate: workOrderDate,
                referenceNo: referenceNo,
              ),
              pw.SizedBox(height: 12),
              _paymentDetailsSection(paymentRows, totalPayable),
              pw.SizedBox(height: 16),
              _paymentReceivedSection(
                paymentDate: latestPayment?.paymentDate,
                amount: latestPayment?.amountPaid,
                transactionNo: latestPayment?.transactionNo,
                totalPayable: totalPayable,
                totalPaid: enrichedBills
                    .expand((b) => b.payments ?? [])
                    .fold<double>(0, (sum, p) => sum + p.amountPaid),
                dueAmount:
                    totalPayable -
                    enrichedBills
                        .expand((b) => b.payments ?? [])
                        .fold<double>(0, (sum, p) => sum + p.amountPaid),
                status: () {
                  final paid = enrichedBills
                      .expand((b) => b.payments ?? [])
                      .fold<double>(0, (sum, p) => sum + p.amountPaid);
                  if (paid == 0) return 'Pending';
                  if (paid < totalPayable) return 'Partially Paid';
                  return 'Paid';
                }(),
              ),
            ],
      ),
    );

    final exportsDir = await _getExportsDirectory();
    final timestamp = _timestampFormat.format(DateTime.now());
    final sanitized = tnNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
    final fileName = 'Payment_Details_${sanitized}_$timestamp.pdf';
    final file = File(p.join(exportsDir, fileName));
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  /// Generate Payment Details PDF for a SINGLE bill showing payment information
  Future<String> exportSingleBillPaymentDetailsPdf({
    required int billId,
  }) async {
    // Load Unicode fonts first
    await _loadFonts();

    final bill = await _billsDao.getBillById(billId);
    if (bill == null) {
      throw StateError('Bill not found');
    }

    // Load payments for this bill
    final payments = await _paymentsDao.getPaymentsByBill(billId);
    final enrichedBill = bill.copyWith(payments: payments);

    final firm = await _loadFirm(bill.firmId);
    final tender =
        bill.tenderId != null
            ? await _tnDao.getTenderById(bill.tenderId!)
            : null;

    final tnNumber = tender?.tnNumber ?? bill.tnNumber;
    final letterDate = DateTime.now();
    final referenceNo = _buildReferenceNumber(firm.code, tnNumber, letterDate);
    final workOrderNo = bill.workOrderNo ?? '-';
    final workOrderDate = bill.workOrderDate;

    // Build payment row for single bill
    final paymentRows = _buildPaymentDetailRows([enrichedBill]);
    final totalPayable = paymentRows.fold<double>(
      0,
      (sum, row) => sum + row.netPayable,
    );

    // Get latest payment for this bill
    final latestPayment =
        payments.isNotEmpty
            ? (payments..sort((a, b) => b.paymentDate.compareTo(a.paymentDate)))
                .first
            : null;

    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amountPaid);
    final dueAmount = totalPayable - totalPaid;

    String status;
    if (totalPaid == 0) {
      status = 'Pending';
    } else if (totalPaid < totalPayable) {
      status = 'Partially Paid';
    } else {
      status = 'Paid';
    }

    final pdf = pw.Document(theme: _createPdfTheme());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build:
            (context) => [
              // Firm Name Header
              pw.Center(
                child: pw.Text(
                  firm.name,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              _referenceLine(referenceNo, letterDate),
              pw.SizedBox(height: 12),
              _workOrderDetailsSectionWithInvoice(
                workOrderNo: workOrderNo,
                workOrderDate: workOrderDate,
                referenceNo: referenceNo,
                invoiceNo: bill.invoiceNo,
              ),
              pw.SizedBox(height: 12),
              _paymentDetailsSection(
                paymentRows,
                totalPayable,
                payments: payments,
              ),
              pw.SizedBox(height: 16),
              _paymentReceivedSection(
                paymentDate: latestPayment?.paymentDate,
                amount: latestPayment?.amountPaid,
                transactionNo: latestPayment?.transactionNo,
                totalPayable: totalPayable,
                totalPaid: totalPaid,
                dueAmount: dueAmount,
                status: status,
              ),
            ],
      ),
    );

    final exportsDir = await _getExportsDirectory();
    final timestamp = _timestampFormat.format(DateTime.now());
    final billNo = bill.invoiceNo ?? 'Bill_$billId';
    final sanitized = billNo.replaceAll(RegExp(r'[^\w\-]'), '_');
    final fileName = 'Payment_Details_${sanitized}_$timestamp.pdf';
    final file = File(p.join(exportsDir, fileName));
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> exportTenderSummaryPdf({required int tenderId}) async {
    // Load Unicode fonts first
    await _loadFonts();

    final tender = await _tnDao.getTenderById(tenderId);
    if (tender == null) {
      throw StateError('TN not found for export');
    }

    final firm = await _loadFirm(tender.firmId);
    final bills = await _billsDao.getBillsByTender(tenderId);
    if (bills.isEmpty) {
      throw StateError('No bills recorded for this TN');
    }

    final rows = bills.map(_buildLegacyBillRow).toList();
    final pdf = pw.Document(theme: _createPdfTheme());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        footer:
            (context) => pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generated by DISCOM Bill Manager (Offline Desktop App)',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ),
        build: (context) {
          return [
            _legacyHeader(
              firm: firm,
              tender: tender,
              consignmentName: _resolveConsignmentName(bills),
              title: 'TN Summary',
              bills: bills,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Bill Details',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _legacyBillDetailsTable(rows),
            pw.SizedBox(height: 20),
            _legacyAggregates(bills),
          ];
        },
      ),
    );

    return _persistAndShare(
      pdf: pdf,
      filename:
          'tn_${tender.tnNumber}_${_timestampFormat.format(DateTime.now())}.pdf',
    );
  }

  Future<List<Bill>> _ensurePaymentsLoaded(List<Bill> bills) async {
    final results = <Bill>[];
    for (final bill in bills) {
      if (bill.id == null) {
        results.add(bill);
        continue;
      }
      if (bill.payments != null && bill.payments!.isNotEmpty) {
        results.add(bill);
        continue;
      }
      final payments = await _paymentsDao.getPaymentsByBill(bill.id!);
      results.add(bill.copyWith(payments: payments));
    }
    return results;
  }

  // ==================== NEW LANDSCAPE PDF METHODS ====================

  /// Header Row 1: No. (left) and Date (right)
  pw.Widget _buildHeaderRow1(String referenceNo, DateTime letterDate) {
    final style = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('No.: $referenceNo', style: style),
        pw.Text('Date: ${_displayDate.format(letterDate)}', style: style),
      ],
    );
  }

  /// Header Row 2: SUB (left) and T.N. No. (right)
  pw.Widget _buildHeaderRow2(String tnNumber) {
    final style = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('SUB: PAYMENT OF YOUR BILL', style: style),
        pw.Text('T.N. No.: $tnNumber', style: style),
      ],
    );
  }

  /// Bill Summary Section - Two Column Layout
  pw.Widget _buildBillSummarySection({
    required String? workOrderNo,
    required DateTime? workOrderDate,
    required String tnNumber,
    required double totalAmount,
    required String chequeNo,
    required DateTime? chequeDate,
    required double amountPayable,
  }) {
    final labelStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final valueStyle = const pw.TextStyle(fontSize: 10);

    String formatDate(DateTime? date) =>
        date != null ? _displayDate.format(date) : '________';

    pw.Widget row(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 120,
              child: pw.Text('$label:', style: labelStyle),
            ),
            pw.Expanded(child: pw.Text(value, style: valueStyle)),
          ],
        ),
      );
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left Column
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              row('W.O. No.', workOrderNo ?? '________'),
              row('TN Number', tnNumber),
              row('Total Bill Amount', _indianCurrency.format(totalAmount)),
              row('Cheque/DD No.', chequeNo),
            ],
          ),
        ),
        pw.SizedBox(width: 40),
        // Right Column
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              row('W.O. Date', formatDate(workOrderDate)),
              row('Cheque Date', formatDate(chequeDate)),
              row('Amount Payable', _indianCurrency.format(amountPayable)),
            ],
          ),
        ),
      ],
    );
  }

  /// Main Landscape Table matching reference image exactly
  pw.Widget _buildLandscapeTable(
    List<_BillTableRow> rows,
    _BillTableTotals totals,
  ) {
    // Column headers matching reference image exactly (13 columns)
    const headers = [
      'S.\nNO',
      'BILL',
      'RR DATE',
      'AMOUNT\nOF BILL',
      'I.TAX\n(TDS@\n1%)',
      'SC\n(SAP)',
      'GST ON\nSCRAP',
      'IN TAX\n(TCS\n1%)',
      'TCS\n(₹1%)',
      'MD\n(NPW)',
      'GST\n(TDS @)',
      'TOTAL DED.',
      'AMOUNT\nPAYABLE',
    ];

    String currency(double value) => _indianCurrency.format(value);
    String date(DateTime value) => _tableDate.format(value);

    // Build data rows (13 columns)
    final dataRows = <List<String>>[];
    for (final row in rows) {
      dataRows.add([
        row.serial.toString(),
        row.billNo,
        date(row.billDate),
        currency(row.amountOfBill),
        currency(row.tds),
        currency(row.scrap),
        currency(row.gstOnScrap),
        currency(row.tcs),
        currency(row.tcs),
        currency(row.md),
        currency(row.gstTds),
        currency(row.totalDeduction),
        currency(row.amountPayable),
      ]);
    }

    // Add TOTAL row
    dataRows.add([
      'TOTAL',
      '',
      '',
      currency(totals.amountOfBill),
      currency(totals.tds),
      currency(totals.scrap),
      currency(totals.gstOnScrap),
      currency(totals.tcs),
      currency(totals.tcs),
      currency(totals.md),
      currency(totals.gstTds),
      currency(totals.totalDeduction),
      currency(totals.amountPayable),
    ]);

    // A4 Landscape: 842 - 40 margins = ~800 usable width
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: dataRows,
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.white),
      headerAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellHeight: 28,
      // All cells centered
      cellAlignments: {
        0: pw.Alignment.center, // S.NO
        1: pw.Alignment.center, // BILL
        2: pw.Alignment.center, // BILL NO.
        3: pw.Alignment.center, // AMOUNT OF BILL
        4: pw.Alignment.center, // I.TAX
        5: pw.Alignment.center, // SC
        6: pw.Alignment.center, // GST ON SCRAP
        7: pw.Alignment.center, // IN TAX
        8: pw.Alignment.center, // TCS
        9: pw.Alignment.center, // MD
        10: pw.Alignment.center, // GST
        11: pw.Alignment.center, // TOTAL DED.
        12: pw.Alignment.center, // AMOUNT PAYABLE
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // S.NO
        1: const pw.FixedColumnWidth(60), // BILL
        2: const pw.FixedColumnWidth(65), // BILL NO.
        3: const pw.FixedColumnWidth(70), // AMOUNT OF BILL
        4: const pw.FixedColumnWidth(55), // I.TAX
        5: const pw.FixedColumnWidth(50), // SC
        6: const pw.FixedColumnWidth(60), // GST ON SCRAP
        7: const pw.FixedColumnWidth(55), // IN TAX
        8: const pw.FixedColumnWidth(50), // TCS
        9: const pw.FixedColumnWidth(50), // MD
        10: const pw.FixedColumnWidth(55), // GST
        11: const pw.FixedColumnWidth(70), // TOTAL DED.
        12: const pw.FixedColumnWidth(75), // AMOUNT PAYABLE
      },
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    );
  }

  /// Footer Notes
  pw.Widget _buildFooterNotes() {
    final style = const pw.TextStyle(fontSize: 10);
    final boldStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Kindly send us stamped receipt immediately for our reference record.',
          style: style,
        ),
        pw.SizedBox(height: 6),
        pw.Text('End: As above', style: boldStyle),
      ],
    );
  }

  // ==================== END NEW METHODS ====================

  pw.Widget _referenceLine(String referenceNo, DateTime letterDate) {
    final headingStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('No.: $referenceNo', style: headingStyle),
        pw.Text(
          'Date : ${_displayDate.format(letterDate)}',
          style: headingStyle,
        ),
      ],
    );
  }

  pw.Widget _workOrderDetailsSection({
    required String workOrderNo,
    DateTime? workOrderDate,
    required String referenceNo,
  }) {
    pw.Widget row(String label, String value) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ],
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'WORK ORDER DETAILS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 8),
          row('Work Order No.:', workOrderNo),
          pw.SizedBox(height: 4),
          row(
            'Work Order Date:',
            workOrderDate != null ? _displayDate.format(workOrderDate) : '-',
          ),
          pw.SizedBox(height: 4),
          row('Reference No.:', referenceNo),
        ],
      ),
    );
  }

  /// Work Order Details section with Invoice Number for single bill PDF
  pw.Widget _workOrderDetailsSectionWithInvoice({
    required String workOrderNo,
    DateTime? workOrderDate,
    required String referenceNo,
    String? invoiceNo,
  }) {
    pw.Widget row(String label, String value, {bool isHighlighted = false}) =>
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: isHighlighted ? PdfColors.red : PdfColors.black,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                color: isHighlighted ? PdfColors.red : PdfColors.black,
              ),
            ),
          ],
        );

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'WORK ORDER DETAILS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 8),
          row('Invoice Number:', invoiceNo ?? '-', isHighlighted: true),
          pw.SizedBox(height: 4),
          row('Work Order No.:', workOrderNo),
          pw.SizedBox(height: 4),
          row(
            'Work Order Date:',
            workOrderDate != null ? _displayDate.format(workOrderDate) : '-',
          ),
          pw.SizedBox(height: 4),
          row('Reference No.:', referenceNo),
        ],
      ),
    );
  }

  List<_PaymentDetailRow> _buildPaymentDetailRows(List<Bill> bills) {
    return bills.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final bill = entry.value;
      final amount = _amountOfBill(bill);
      final gstTds = bill.gstTdsAmount;
      final tds = bill.tdsAmount;
      final tcs = bill.tcsAmount;
      final csd = bill.csdAmount;
      final scrap = bill.scrapAmount;
      final scrapGst = bill.scrapGstAmount;
      final md = bill.mdLdAmount;

      // Calculate net payable from invoice amount
      // CSD and MD are NOT deducted - they are receivables that will be paid back
      final totalDeductions = gstTds + tds + tcs + scrap + scrapGst;
      final computedNet = bill.invoiceAmount - totalDeductions;

      final description =
          '${bill.invoiceNo ?? 'Bill ${index.toString().padLeft(2, '0')}'} '
          '(${_displayDate.format(bill.billDate)})';

      return _PaymentDetailRow(
        serial: index,
        description: description,
        amount: amount,
        gstTds: gstTds,
        tds: tds,
        tcs: tcs,
        csd: csd,
        scrap: scrap,
        scrapGst: scrapGst,
        md: md,
        netPayable: computedNet < 0 ? 0 : computedNet,
        remarks: bill.remarks?.trim() ?? '',
      );
    }).toList();
  }

  pw.Widget _paymentDetailsSection(
    List<_PaymentDetailRow> rows,
    double totalPayable, {
    List<Payment>? payments,
  }) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            'PAYMENT DETAILS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 6),
          _paymentDetailsTable(rows, totalPayable, payments: payments),
        ],
      ),
    );
  }

  pw.Widget _paymentDetailsTable(
    List<_PaymentDetailRow> rows,
    double totalPayable, {
    List<Payment>? payments,
  }) {
    final headerStyle = pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
    );
    final cellStyle = const pw.TextStyle(fontSize: 7);

    // Sort payments by date if provided
    final sortedPayments =
        payments != null
            ? (List<Payment>.from(payments)
              ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate)))
            : <Payment>[];

    // Calculate running balance for each payment
    List<double> remainingAmounts = [];
    double runningBalance = totalPayable;
    for (var payment in sortedPayments) {
      runningBalance -= payment.amountPaid;
      remainingAmounts.add(runningBalance);
    }

    // Build fixed headers
    final fixedHeaders = [
      'S.No',
      'Description',
      'Amount (₹)',
      'TDS',
      'GST TDS',
      'TCS',
      'Scrap',
      'Scrap GST',
      'CSD',
      'MD',
      'Net Payable',
    ];

    // Build dynamic payment headers (3 columns per payment: Amount, Date, Remaining)
    final paymentHeaders = <String>[];
    for (int i = 0; i < sortedPayments.length; i++) {
      paymentHeaders.add('${i + 1}${_getOrdinalSuffix(i + 1)} Pmt');
      paymentHeaders.add('Date');
      paymentHeaders.add('Rem');
    }

    // All headers combined
    final allHeaders = [...fixedHeaders, ...paymentHeaders];

    // Define column widths
    final columnWidths = <int, pw.TableColumnWidth>{};
    // Fixed columns
    columnWidths[0] = const pw.FixedColumnWidth(25); // S.No
    columnWidths[1] = const pw.FlexColumnWidth(2); // Description
    columnWidths[2] = const pw.FixedColumnWidth(50); // Amount
    columnWidths[3] = const pw.FixedColumnWidth(35); // TDS
    columnWidths[4] = const pw.FixedColumnWidth(35); // GST TDS
    columnWidths[5] = const pw.FixedColumnWidth(35); // TCS
    columnWidths[6] = const pw.FixedColumnWidth(35); // Scrap
    columnWidths[7] = const pw.FixedColumnWidth(35); // Scrap GST
    columnWidths[8] = const pw.FixedColumnWidth(35); // CSD
    columnWidths[9] = const pw.FixedColumnWidth(35); // MD
    columnWidths[10] = const pw.FixedColumnWidth(50); // Net Payable
    // Payment columns
    for (int i = 0; i < sortedPayments.length * 3; i++) {
      columnWidths[11 + i] = const pw.FixedColumnWidth(45);
    }

    // Build header row
    final headerRow = pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children:
          allHeaders
              .map(
                (header) => pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    header,
                    style: headerStyle,
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              )
              .toList(),
    );

    // Build data rows
    final dataRows =
        rows.map((row) {
          final fixedCells = [
            '${row.serial}',
            row.description,
            _indianCurrency.format(row.amount),
            _indianCurrency.format(row.tds),
            _indianCurrency.format(row.gstTds),
            _indianCurrency.format(row.tcs),
            _indianCurrency.format(row.scrap),
            _indianCurrency.format(row.scrapGst),
            _indianCurrency.format(row.csd),
            _indianCurrency.format(row.md),
            _indianCurrency.format(row.netPayable),
          ];

          // Add payment data cells
          final paymentCells = <String>[];
          for (int i = 0; i < sortedPayments.length; i++) {
            final payment = sortedPayments[i];
            paymentCells.add(_indianCurrency.format(payment.amountPaid));
            paymentCells.add(_tableDate.format(payment.paymentDate));
            paymentCells.add(_indianCurrency.format(remainingAmounts[i]));
          }

          final allCells = [...fixedCells, ...paymentCells];
          return pw.TableRow(
            children:
                allCells
                    .asMap()
                    .entries
                    .map(
                      (entry) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          entry.value,
                          style: cellStyle,
                          textAlign:
                              entry.key == 1
                                  ? pw.TextAlign.left
                                  : pw.TextAlign.right,
                        ),
                      ),
                    )
                    .toList(),
          );
        }).toList();

    // Build total row
    final totalPaid = sortedPayments.fold<double>(
      0,
      (sum, p) => sum + p.amountPaid,
    );
    final totalCells = <String>[];
    for (int i = 0; i < fixedHeaders.length; i++) {
      switch (i) {
        case 0:
          totalCells.add('TOTAL');
          break;
        case 2:
          totalCells.add(
            _indianCurrency.format(
              rows.fold<double>(0, (s, r) => s + r.amount),
            ),
          );
          break;
        case 10:
          totalCells.add(_indianCurrency.format(totalPayable));
          break;
        default:
          totalCells.add('');
      }
    }
    // Payment totals
    for (int i = 0; i < sortedPayments.length; i++) {
      if (i == sortedPayments.length - 1) {
        totalCells.add(_indianCurrency.format(totalPaid));
        totalCells.add('');
        totalCells.add(
          _indianCurrency.format(
            remainingAmounts.isNotEmpty ? remainingAmounts.last : totalPayable,
          ),
        );
      } else {
        totalCells.add('');
        totalCells.add('');
        totalCells.add('');
      }
    }

    final totalRow = pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children:
          totalCells
              .asMap()
              .entries
              .map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    entry.value,
                    style: headerStyle,
                    textAlign:
                        entry.key == 0 ? pw.TextAlign.left : pw.TextAlign.right,
                  ),
                ),
              )
              .toList(),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
      columnWidths: columnWidths,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [headerRow, ...dataRows, totalRow],
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  pw.Widget _paymentReceivedSection({
    DateTime? paymentDate,
    double? amount,
    String? transactionNo,
    double? totalPayable,
    double? totalPaid,
    double? dueAmount,
    String? status,
  }) {
    String formatDate(DateTime? date) =>
        date == null ? '________' : _displayDate.format(date);
    String formatAmount(double? value) =>
        value == null ? '________' : _indianCurrency.format(value);
    String formatText(String? value) =>
        value == null || value.trim().isEmpty ? '________' : value.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT SUMMARY',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Total Payable Amount:      ${formatAmount(totalPayable)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Total Paid Amount:         ${formatAmount(totalPaid)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Due Amount:                ${formatAmount(dueAmount)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Status:                    ${formatText(status)}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: status == 'Paid' ? PdfColors.green : PdfColors.orange,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'LATEST PAYMENT DETAILS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Payment Date:              ${formatDate(paymentDate)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Payment Amount:            ${formatAmount(amount)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Transaction No:            ${formatText(transactionNo)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 14),
          pw.Text('Verified By:', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 18),
          pw.Text(
            'ACCOUNTANT',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.Text(
            'DOON INFRAPOWER PROJECTS PVT LTD',
            style: const pw.TextStyle(fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  pw.Widget _subjectSection({
    required String subject,
    required String tnNumber,
  }) {
    final labelStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('SUB: $subject', style: labelStyle),
        pw.Text('T.N. No.: $tnNumber', style: labelStyle),
      ],
    );
  }

  pw.Widget _closingNotes({required Firm firm}) {
    final notesStyle = pw.TextStyle(fontSize: 10);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Kindly send us stamped receipt immediately for our reference record.',
          style: notesStyle,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'End: As above',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  String _buildReferenceNumber(
    String firmCode,
    String tnNumber,
    DateTime date,
  ) {
    final prefix = firmCode.toUpperCase();
    final year = date.year;
    return '$prefix/SAO(CPC)/$tnNumber/$year';
  }

  DateTime? _resolveWorkOrderDate(List<Bill> bills, Tender? tender) {
    for (final bill in bills) {
      if (bill.workOrderDate != null) {
        return bill.workOrderDate;
      }
    }
    return tender?.createdAt;
  }

  Payment? _resolveLatestPayment(List<Bill> bills) {
    final payments = <Payment>[];
    for (final bill in bills) {
      if (bill.payments != null) {
        payments.addAll(bill.payments!);
      }
    }
    if (payments.isEmpty) {
      return null;
    }
    payments.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
    return payments.last;
  }

  String _discomCity(String code) {
    switch (code.toUpperCase()) {
      case 'JDVVNL':
        return 'JODHPUR';
      case 'JVVNL':
        return 'JAIPUR';
      case 'AVVNL':
        return 'AJMER';
      default:
        return code.toUpperCase();
    }
  }

  pw.Widget _invoiceTitleSection({
    Tender? tender,
    required List<Bill> bills,
    required String referenceNo,
    required String? workOrderNo,
    DateTime? workOrderDate,
    required String chequeNo,
    DateTime? chequeDate,
    required double totalAmount,
    required double amountPayable,
  }) {
    String formatDate(DateTime? value) =>
        value == null ? '' : _displayDate.format(value);

    final tnNumber = tender?.tnNumber ?? bills.first.tnNumber;
    final billDate = bills.first.billDate;

    final labelStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );
    final valueStyle = const pw.TextStyle(fontSize: 11);

    // Helper to create a row with label and value
    pw.Widget row(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 130,
              child: pw.Text('$label:', style: labelStyle),
            ),
            pw.Expanded(child: pw.Text(value, style: valueStyle)),
          ],
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left Column
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                row('W.O. No.', workOrderNo ?? ''),
                row('TN Number', formatDate(billDate)),
                row('Total Bill Amount', _indianCurrency.format(totalAmount)),
                row('Cheque/DD No.', '________'),
                row('Amount Payable', _indianCurrency.format(amountPayable)),
              ],
            ),
          ),
          pw.SizedBox(width: 60),
          // Right Column
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                row('W.O. Date', formatDate(workOrderDate)),
                row('TN Number', tnNumber),
                row('Cheque/DD No.', '________'),
                row('Cheque Date', formatDate(chequeDate)),
                row('Amount Payable', _indianCurrency.format(amountPayable)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _deductionsTable(
    List<_BillTableRow> rows,
    _BillTableTotals totals,
  ) {
    // Headers matching the reference image format exactly
    const headers = [
      'S.\nNO',
      'BILL',
      'BILL NO.',
      'AMOUNT\nOF BILL',
      'I.TAX\n(TDS@\n1%)',
      'SC\n(SAP)',
      'GST ON\nSCRAP',
      'IN TAX\n(TCS\n1%)',
      'TCS\n(₹1%)',
      'MD\n(NPW)',
      'GST\n(TDS @)',
      'TOTAL DED.',
      'AMOUNT\nPAYABLE',
    ];

    String currency(double value) => _indianCurrency.format(value);
    String date(DateTime value) => _tableDate.format(value);

    // Prepare data rows matching reference format
    final dataRows = <List<String>>[];
    for (final row in rows) {
      dataRows.add([
        row.serial.toString(),
        row.billNo, // BILL (invoice number)
        date(row.billDate), // BILL NO. (date)
        currency(row.amountOfBill), // AMOUNT OF BILL
        currency(row.tds), // I.TAX (TDS@1%)
        currency(row.scrap), // SC (SAP) - Scrap
        currency(row.gstOnScrap), // GST ON SCRAP
        currency(row.tcs), // IN TAX (TCS 1%)
        currency(row.tcs), // TCS (₹1%)
        currency(row.md), // MD (NPW)
        currency(row.gstTds), // GST (TDS @)
        currency(row.totalDeduction), // TOTAL DED.
        currency(row.amountPayable), // AMOUNT PAYABLE
      ]);
    }

    // Add totals row
    dataRows.add([
      'TOTAL',
      '',
      '',
      currency(totals.amountOfBill),
      currency(totals.tds),
      currency(totals.scrap),
      currency(totals.gstOnScrap),
      currency(totals.tcs),
      currency(totals.tcs),
      currency(totals.md),
      currency(totals.gstTds),
      currency(totals.totalDeduction),
      currency(totals.amountPayable),
    ]);

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: dataRows,
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.white),
      headerAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.center, // S.NO
        1: pw.Alignment.center, // BILL
        2: pw.Alignment.center, // BILL NO.
        3: pw.Alignment.centerRight, // AMOUNT OF BILL
        4: pw.Alignment.centerRight, // I.TAX
        5: pw.Alignment.centerRight, // SC(SAP)
        6: pw.Alignment.centerRight, // GST ON SCRAP
        7: pw.Alignment.centerRight, // IN TAX
        8: pw.Alignment.centerRight, // TCS
        9: pw.Alignment.centerRight, // MD
        10: pw.Alignment.centerRight, // GST
        11: pw.Alignment.centerRight, // TOTAL DED.
        12: pw.Alignment.centerRight, // AMOUNT PAYABLE
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // S.NO
        1: const pw.FixedColumnWidth(60), // BILL
        2: const pw.FixedColumnWidth(60), // BILL NO.
        3: const pw.FixedColumnWidth(70), // AMOUNT OF BILL
        4: const pw.FixedColumnWidth(50), // I.TAX
        5: const pw.FixedColumnWidth(45), // SC(SAP)
        6: const pw.FixedColumnWidth(55), // GST ON SCRAP
        7: const pw.FixedColumnWidth(50), // IN TAX
        8: const pw.FixedColumnWidth(50), // TCS
        9: const pw.FixedColumnWidth(50), // MD
        10: const pw.FixedColumnWidth(55), // GST
        11: const pw.FixedColumnWidth(70), // TOTAL DED.
        12: const pw.FixedColumnWidth(70), // AMOUNT PAYABLE
      },
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    );
  }

  pw.Widget _footerSignature({required Firm firm}) {
    final discom = _discomNameForSignature(firm.code);
    final city = _discomCity(firm.code);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.SizedBox(height: 24),
            pw.Text(
              'Sr. ACCOUNTS OFFICER (CPC)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('$discom, $city', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  List<_BillTableRow> _buildBillTableRows(List<Bill> bills) {
    return bills.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final bill = entry.value;
      final amountOfBill = _amountOfBill(bill);
      final csd = bill.csdAmount;
      final tds = bill.tdsAmount;
      final scrap = bill.scrapAmount;
      final gstOnScrap = bill.scrapGstAmount;
      final tcs = bill.tcsAmount;
      final md = bill.mdLdAmount;
      final mq =
          bill.emptyOilIssued > 0
              ? (bill.emptyOilIssued - bill.emptyOilReturned).toDouble()
              : 0.0;
      final gstTds = bill.gstTdsAmount;
      // CSD and MD are RECEIVABLES (not deductions) - they will be paid back
      // So they should NOT be subtracted from the Amount Payable
      final totalDed = tds + scrap + gstOnScrap + tcs + gstTds;
      // Amount Payable = Invoice Amount - Actual Deductions (excluding receivables)
      final amountPayable = amountOfBill - totalDed;

      return _BillTableRow(
        serial: index,
        billNo: bill.invoiceNo ?? bill.tnNumber,
        billDate: bill.billDate,
        amountOfBill: amountOfBill,
        csd: csd,
        tds: tds,
        scrap: scrap,
        gstOnScrap: gstOnScrap,
        tcs: tcs,
        md: md,
        mq: mq,
        gstTds: gstTds,
        totalDeduction: totalDed < 0 ? 0 : totalDed,
        amountPayable: amountPayable < 0 ? 0 : amountPayable,
      );
    }).toList();
  }

  double _amountOfBill(Bill bill) =>
      bill.invoiceAmount > 0 ? bill.invoiceAmount : bill.amount;

  String _discomNameForSignature(String code) {
    switch (code.toUpperCase()) {
      case 'AVVNL':
        return 'AJMER VIDYUT VITRAN NIGAM LIMITED';
      case 'JVVNL':
        return 'JAIPUR VIDYUT VITRAN NIGAM LIMITED';
      case 'JDVVNL':
        return 'JODHPUR VIDYUT VITRAN NIGAM LIMITED';
      default:
        return code;
    }
  }

  String? _resolveWorkOrder(List<Bill> bills, Tender? tender) {
    for (final bill in bills) {
      if ((bill.workOrderNo ?? '').isNotEmpty) {
        return bill.workOrderNo;
      }
    }
    return tender?.poNumber;
  }

  String _billFilename(List<Bill> bills, Tender? tender) {
    final tn = tender?.tnNumber ?? bills.first.tnNumber;
    final stamp = _timestampFormat.format(DateTime.now());
    return 'bill_${tn}_$stamp.pdf';
  }

  Future<String> _savePdf(Uint8List bytes, String filename) async {
    final exportsDir = await _getExportsDirectory();
    final filePath = p.join(exportsDir, filename);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  Future<String> _persistAndShare({
    required pw.Document pdf,
    required String filename,
  }) async {
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: filename);

    final exportsDir = await _getExportsDirectory();
    final filePath = p.join(exportsDir, filename);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  pw.Widget _legacyHeader({
    required Firm firm,
    Tender? tender,
    String? consignmentName,
    required String title,
    List<Bill>? bills,
  }) {
    final headerStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: headerStyle),
        pw.SizedBox(height: 6),
        pw.Text(firm.name, style: pw.TextStyle(fontSize: 12)),
        if (consignmentName != null && consignmentName.isNotEmpty)
          pw.Text('Consignment: $consignmentName'),
        if (tender != null) ...[
          pw.Text('TN Number: ${tender.tnNumber}'),
          if ((tender.poNumber ?? '').isNotEmpty)
            pw.Text('Purchase Order: ${tender.poNumber}'),
          if ((tender.workDescription ?? '').isNotEmpty)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                tender.workDescription!,
                style: pw.TextStyle(color: PdfColors.grey700),
              ),
            ),
        ],
        // Add client firm if available from bills
        if (bills != null &&
            bills.isNotEmpty &&
            bills.any(
              (b) => b.clientFirmName != null && b.clientFirmName!.isNotEmpty,
            ))
          pw.Text(
            'Client Firm: ${bills.firstWhere((b) => b.clientFirmName != null && b.clientFirmName!.isNotEmpty).clientFirmName}',
            style: pw.TextStyle(fontSize: 10),
          ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated: ${_displayDate.format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'DISCOM Code: ${firm.code}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.Divider(thickness: 1.2),
      ],
    );
  }

  pw.Widget _legacyBillDetailsTable(List<_LegacyBillRow> rows) {
    final headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold);
    final right = pw.Alignment.centerRight;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FixedColumnWidth(65),
        2: const pw.FixedColumnWidth(65),
        3: const pw.FixedColumnWidth(70),
        4: const pw.FixedColumnWidth(50),
        5: const pw.FixedColumnWidth(50),
        6: const pw.FixedColumnWidth(50),
        7: const pw.FixedColumnWidth(50),
        8: const pw.FixedColumnWidth(50),
        9: const pw.FixedColumnWidth(60),
        10: const pw.FixedColumnWidth(50),
        11: const pw.FixedColumnWidth(60),
        12: const pw.FixedColumnWidth(70),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Bill No', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('RR Date', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Due Date', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Invoice Amount', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('CSD', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('TDS 2%', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('GST 2%', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('TCS 1%', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Scrap', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('GST on Scrap', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('MD/LD', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Other Deduction', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Net Payable', style: headerStyle),
            ),
          ],
        ),
        for (final row in rows)
          pw.TableRow(
            children: [
              _legacyTableCell(row.billNo),
              _legacyTableCell(row.billDate),
              _legacyTableCell(row.dueDate),
              _legacyTableCell(row.invoiceAmount, align: right),
              _legacyTableCell(row.csd, align: right),
              _legacyTableCell(row.tds, align: right),
              _legacyTableCell(row.gst, align: right),
              _legacyTableCell(row.tcs, align: right),
              _legacyTableCell(row.scrap, align: right),
              _legacyTableCell(row.gstOnScrap, align: right),
              _legacyTableCell(row.mdld, align: right),
              _legacyTableCell(row.otherDeduction, align: right),
              _legacyTableCell(row.netPayable, align: right),
            ],
          ),
      ],
    );
  }

  pw.Widget _legacyAggregates(List<Bill> bills) {
    final totalInvoice = bills.fold<double>(
      0,
      (sum, bill) => sum + _amountOfBill(bill),
    );
    final totalCsd = bills.fold<double>(0, (sum, bill) => sum + bill.csdAmount);
    final totalTds = bills.fold<double>(0, (sum, bill) => sum + bill.tdsAmount);
    final totalGst = bills.fold<double>(
      0,
      (sum, bill) => sum + bill.gstTdsAmount,
    );
    final totalTcs = bills.fold<double>(0, (sum, bill) => sum + bill.tcsAmount);
    final totalScrap = bills.fold<double>(
      0,
      (sum, bill) => sum + bill.scrapAmount,
    );
    final totalGstScrap = bills.fold<double>(
      0,
      (sum, bill) => sum + bill.scrapGstAmount,
    );
    final totalMdld = bills.fold<double>(
      0,
      (sum, bill) => sum + bill.mdLdAmount,
    );
    final totalOther = bills.fold<double>(
      0,
      (sum, bill) =>
          sum +
          (bill.invoiceAmount > 0 ? bill.invoiceAmount : bill.amount) -
          (bill.billPassAmount > 0 ? bill.billPassAmount : bill.amount),
    );
    final totalNet = bills.fold<double>(
      0,
      (sum, bill) =>
          sum + (bill.billPassAmount > 0 ? bill.billPassAmount : bill.amount),
    );

    pw.Widget line(String label, double value) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(_indianCurrency.format(value)),
      ],
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Aggregated Totals',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 8),
          line('Invoice Amount', totalInvoice),
          line('CSD', totalCsd),
          line('TDS 2%', totalTds),
          line('GST 2%', totalGst),
          line('TCS 1%', totalTcs),
          line('Scrap', totalScrap),
          line('GST on Scrap', totalGstScrap),
          line('MD/LD', totalMdld),
          line('Other Deduction', totalOther),
          pw.Divider(),
          line('Net Payable', totalNet),
        ],
      ),
    );
  }

  pw.Widget _legacyTableCell(
    String value, {
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: pw.Text(value, style: pw.TextStyle(fontSize: 10)),
    );
  }

  _LegacyBillRow _buildLegacyBillRow(Bill bill) {
    return _LegacyBillRow(
      billNo: bill.invoiceNo ?? bill.tnNumber,
      billDate: _displayDate.format(bill.billDate),
      dueDate: _displayDate.format(bill.dueDate),
      invoiceAmount: _indianCurrency.format(_amountOfBill(bill)),
      csd: _indianCurrency.format(bill.csdAmount),
      tds: _indianCurrency.format(bill.tdsAmount),
      gst: _indianCurrency.format(bill.gstTdsAmount),
      tcs: _indianCurrency.format(bill.tcsAmount),
      scrap: _indianCurrency.format(bill.scrapAmount),
      gstOnScrap: _indianCurrency.format(bill.scrapGstAmount),
      mdld: _indianCurrency.format(bill.mdLdAmount),
      otherDeduction: _indianCurrency.format(
        _amountOfBill(bill) -
            (bill.billPassAmount > 0 ? bill.billPassAmount : bill.amount),
      ),
      netPayable: _indianCurrency.format(
        bill.billPassAmount > 0 ? bill.billPassAmount : bill.amount,
      ),
    );
  }

  Payment? _latestPayment(List<Payment> payments) {
    if (payments.isEmpty) return null;
    final sorted = [...payments]
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
    return sorted.last;
  }

  String _resolveConsignmentName(List<Bill> bills) {
    // First priority: Check if any bill has a supplier firm name
    for (final bill in bills) {
      if (bill.supplierFirmName != null && bill.supplierFirmName!.isNotEmpty) {
        return bill.supplierFirmName!;
      }
    }

    // Second priority: Check consignment name from payments
    for (final bill in bills) {
      final payments = bill.payments ?? const <Payment>[];
      final candidate = _latestPayment(payments)?.consignmentName;
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }

    return '';
  }

  Future<Firm> _loadFirm(int id) async {
    final row =
        await (_database.select(_database.firms)
          ..where((tbl) => tbl.id.equals(id))).getSingle();
    return Firm(
      id: row.id,
      name: row.name,
      code: row.code,
      description: row.description,
      createdAt: row.createdAt,
    );
  }

  Future<String> _getExportsDirectory() async {
    // Try to get custom exports directory from settings
    try {
      final settingsService = SettingsService();
      final settings = await settingsService.fetchSettings();

      if (settings.exportsDirectory != null &&
          settings.exportsDirectory!.isNotEmpty) {
        final customDir = Directory(settings.exportsDirectory!);
        if (await customDir.exists()) {
          return settings.exportsDirectory!;
        }
      }
    } catch (_) {
      // Fall back to default if settings can't be loaded
    }

    // Default location
    final envPath = Platform.environment['APPDATA'];
    String basePath;

    if (envPath != null && envPath.isNotEmpty) {
      basePath = p.join(envPath, 'DISCOMBillManager');
    } else {
      final supportDir = await getApplicationSupportDirectory();
      basePath = p.join(supportDir.path, 'DISCOMBillManager');
    }

    final exportsDir = Directory(p.join(basePath, 'exports'));
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    return exportsDir.path;
  }
}

class _BillTableRow {
  _BillTableRow({
    required this.serial,
    required this.billNo,
    required this.billDate,
    required this.amountOfBill,
    required this.csd,
    required this.tds,
    required this.scrap,
    required this.gstOnScrap,
    required this.tcs,
    required this.md,
    required this.mq,
    required this.gstTds,
    required this.totalDeduction,
    required this.amountPayable,
  });

  final int serial;
  final String billNo;
  final DateTime billDate;
  final double amountOfBill;
  final double csd;
  final double tds;
  final double scrap;
  final double gstOnScrap;
  final double tcs;
  final double md;
  final double mq;
  final double gstTds;
  final double totalDeduction;
  final double amountPayable;
}

class _BillTableTotals {
  const _BillTableTotals({
    required this.amountOfBill,
    required this.csd,
    required this.tds,
    required this.scrap,
    required this.gstOnScrap,
    required this.tcs,
    required this.md,
    required this.mq,
    required this.gstTds,
    required this.totalDeduction,
    required this.amountPayable,
  });

  factory _BillTableTotals.fromRows(List<_BillTableRow> rows) {
    double sum(double Function(_BillTableRow row) selector) {
      return rows.fold<double>(0, (value, row) => value + selector(row));
    }

    return _BillTableTotals(
      amountOfBill: sum((row) => row.amountOfBill),
      csd: sum((row) => row.csd),
      tds: sum((row) => row.tds),
      scrap: sum((row) => row.scrap),
      gstOnScrap: sum((row) => row.gstOnScrap),
      tcs: sum((row) => row.tcs),
      md: sum((row) => row.md),
      mq: sum((row) => row.mq),
      gstTds: sum((row) => row.gstTds),
      totalDeduction: sum((row) => row.totalDeduction),
      amountPayable: sum((row) => row.amountPayable),
    );
  }

  final double amountOfBill;
  final double csd;
  final double tds;
  final double scrap;
  final double gstOnScrap;
  final double tcs;
  final double md;
  final double mq;
  final double gstTds;
  final double totalDeduction;
  final double amountPayable;
}

class _PaymentDetailRow {
  const _PaymentDetailRow({
    required this.serial,
    required this.description,
    required this.amount,
    required this.gstTds,
    required this.tds,
    required this.tcs,
    required this.csd,
    required this.scrap,
    required this.scrapGst,
    required this.md,
    required this.netPayable,
    required this.remarks,
  });

  final int serial;
  final String description;
  final double amount;
  final double gstTds;
  final double tds;
  final double tcs;
  final double csd;
  final double scrap;
  final double scrapGst;
  final double md;
  final double netPayable;
  final String remarks;
}

class _LegacyBillRow {
  _LegacyBillRow({
    required this.billNo,
    required this.billDate,
    required this.dueDate,
    required this.invoiceAmount,
    required this.csd,
    required this.tds,
    required this.gst,
    required this.tcs,
    required this.scrap,
    required this.gstOnScrap,
    required this.mdld,
    required this.otherDeduction,
    required this.netPayable,
  });

  final String billNo;
  final String billDate;
  final String dueDate;
  final String invoiceAmount;
  final String csd;
  final String tds;
  final String gst;
  final String tcs;
  final String scrap;
  final String gstOnScrap;
  final String mdld;
  final String otherDeduction;
  final String netPayable;
}
