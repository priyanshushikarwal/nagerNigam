import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/repositories/bills_repository.dart';
import '../database/app_database.dart' as db;
import '../core/app_logger.dart';
import '../core/app_paths.dart';
import 'settings_service.dart';

class ExportService {
  ExportService({required db.AppDatabase database, required BillsDao billsDao})
    : _database = database,
      _billsRepository = billsDao;

  final db.AppDatabase _database;
  final BillsDao _billsRepository;
  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final _dateFormat = DateFormat('dd-MM-yyyy');
  final AppLogger _logger = AppLogger.instance;

  // Export bills to CSV
  Future<String> exportBillsToCSV({
    required int firmId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final firm = await _getFirmRecord(firmId);
      final allBills = await _billsRepository.getBillsByFirm(firmId);
      final bills =
          allBills.where((bill) {
              final inStartRange =
                  startDate == null ||
                  !bill.billDate.isBefore(_startOfDay(startDate));
              final inEndRange =
                  endDate == null || !bill.billDate.isAfter(_endOfDay(endDate));
              return inStartRange && inEndRange;
            }).toList()
            ..sort((a, b) => b.billDate.compareTo(a.billDate));

      final rows = <List<dynamic>>[
        [
          'TN Number',
          'DISCOM',
          'RR Date',
          'Due Date',
          'Amount',
          'Status',
          'Remarks',
        ],
      ];

      for (final bill in bills) {
        rows.add([
          bill.tnNumber,
          firm.name,
          _dateFormat.format(bill.billDate),
          _dateFormat.format(bill.dueDate),
          bill.amount,
          bill.status,
          bill.remarks ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);

      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final exportsDir = await _getExportsDirectory();
      final filePath = p.join(exportsDir, 'bills_${firm.code}_$timestamp.csv');

      final file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to export bills to CSV for firm $firmId',
        operation: 'export:csv:bills',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Export payments to CSV
  Future<String> exportPaymentsToCSV({
    required int firmId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final firm = await _getFirmRecord(firmId);
      final paymentRows =
          await _database
              .customSelect(
                '''
      SELECT p.*, b.tn_number
      FROM payments p
      JOIN bills b ON p.bill_id = b.id
      WHERE b.firm_id = ?
      ${startDate != null ? 'AND p.payment_date >= ?' : ''}
      ${endDate != null ? 'AND p.payment_date <= ?' : ''}
      ORDER BY p.payment_date DESC
      ''',
                variables: [
                  Variable<int>(firmId),
                  if (startDate != null)
                    Variable<DateTime>(_startOfDay(startDate)),
                  if (endDate != null) Variable<DateTime>(_endOfDay(endDate)),
                ],
                readsFrom: {_database.payments, _database.bills},
              )
              .get();

      final csvRows = <List<dynamic>>[
        ['Payment Date', 'TN Number', 'DISCOM', 'Amount Paid', 'Remarks'],
      ];

      for (final row in paymentRows) {
        final paymentDate = row.read<DateTime>('payment_date');
        csvRows.add([
          _dateFormat.format(paymentDate),
          row.read<String>('tn_number'),
          firm.name,
          row.read<double>('amount_paid'),
          row.readNullable<String>('remarks') ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(csvRows);

      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final exportsDir = await _getExportsDirectory();
      final filePath = p.join(
        exportsDir,
        'payments_${firm.code}_$timestamp.csv',
      );

      final file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to export payments to CSV for firm $firmId',
        operation: 'export:csv:payments',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Generate PDF report for bills
  Future<String> generateBillsReport({
    required int firmId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final firm = await _getFirmRecord(firmId);
      final allBills = await _billsRepository.getBillsByFirm(firmId);
      final bills =
          allBills.where((bill) {
              final inStartRange =
                  startDate == null ||
                  !bill.billDate.isBefore(_startOfDay(startDate));
              final inEndRange =
                  endDate == null || !bill.billDate.isAfter(_endOfDay(endDate));
              return inStartRange && inEndRange;
            }).toList()
            ..sort((a, b) => b.billDate.compareTo(a.billDate));

      final totalAmount = bills.fold<double>(
        0.0,
        (sum, bill) => sum + bill.amount,
      );
      final paidBills = bills.where((b) => b.status == 'Paid').length;
      final pendingBills = bills.where((b) => b.status == 'Pending').length;
      final overdueBills = bills.where((b) => b.isOverdue).length;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Text(
                'DISCOM Bill Manager - Bills Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('DISCOM: ${firm.name}'),
              pw.Text('Report Date: ${_dateFormat.format(DateTime.now())}'),
              if (startDate != null || endDate != null) ...[
                pw.Text(
                  'Period: ${startDate != null ? _dateFormat.format(startDate) : 'All'} to ${endDate != null ? _dateFormat.format(endDate) : 'All'}',
                ),
              ],
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Summary',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Total Bills: ${bills.length}'),
                    pw.Text('Paid: $paidBills'),
                    pw.Text('Pending: $pendingBills'),
                    pw.Text('Overdue: $overdueBills'),
                    pw.Text(
                      'Total Amount: ${_currencyFormat.format(totalAmount)}',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table header
              pw.Text(
                'Bill Details',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              // Bills table
              pw.TableHelper.fromTextArray(
                headers: [
                  'TN Number',
                  'RR Date',
                  'Due Date',
                  'Amount',
                  'Status',
                ],
                data:
                    bills.map((bill) {
                      return [
                        bill.tnNumber,
                        _dateFormat.format(bill.billDate),
                        _dateFormat.format(bill.dueDate),
                        _currencyFormat.format(bill.amount),
                        bill.status,
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ];
          },
        ),
      );

      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final exportsDir = await _getExportsDirectory();
      final filePath = p.join(
        exportsDir,
        'bills_report_${firm.code}_$timestamp.pdf',
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to generate bills report for firm $firmId',
        operation: 'export:report:bills',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Generate PDF report for payments
  Future<String> generatePaymentsReport({
    required int firmId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final firm = await _getFirmRecord(firmId);
      final paymentRows =
          await _database
              .customSelect(
                '''
      SELECT p.*, b.tn_number
      FROM payments p
      JOIN bills b ON p.bill_id = b.id
      WHERE b.firm_id = ?
      ${startDate != null ? 'AND p.payment_date >= ?' : ''}
      ${endDate != null ? 'AND p.payment_date <= ?' : ''}
      ORDER BY p.payment_date DESC
      ''',
                variables: [
                  Variable<int>(firmId),
                  if (startDate != null)
                    Variable<DateTime>(_startOfDay(startDate)),
                  if (endDate != null) Variable<DateTime>(_endOfDay(endDate)),
                ],
                readsFrom: {_database.payments, _database.bills},
              )
              .get();

      final payments =
          paymentRows
              .map(
                (row) => (
                  paymentDate: row.read<DateTime>('payment_date'),
                  tnNumber: row.read<String>('tn_number'),
                  amountPaid: row.read<double>('amount_paid'),
                  remarks: row.readNullable<String>('remarks'),
                ),
              )
              .toList();

      final totalPaid = payments.fold<double>(
        0.0,
        (sum, p) => sum + p.amountPaid,
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Text(
                'DISCOM Bill Manager - Payments Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('DISCOM: ${firm.name}'),
              pw.Text('Report Date: ${_dateFormat.format(DateTime.now())}'),
              if (startDate != null || endDate != null) ...[
                pw.Text(
                  'Period: ${startDate != null ? _dateFormat.format(startDate) : 'All'} to ${endDate != null ? _dateFormat.format(endDate) : 'All'}',
                ),
              ],
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Summary',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Total Payments: ${payments.length}'),
                    pw.Text(
                      'Total Amount Paid: ${_currencyFormat.format(totalPaid)}',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table header
              pw.Text(
                'Payment Details',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              // Payments table
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'TN Number', 'Amount', 'Remarks'],
                data:
                    payments.map((payment) {
                      return [
                        _dateFormat.format(payment.paymentDate),
                        payment.tnNumber,
                        _currencyFormat.format(payment.amountPaid),
                        payment.remarks ?? '',
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ];
          },
        ),
      );

      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final exportsDir = await _getExportsDirectory();
      final filePath = p.join(
        exportsDir,
        'payments_report_${firm.code}_$timestamp.pdf',
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to generate payments report for firm $firmId',
        operation: 'export:report:payments',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Get exports directory
  Future<String> _getExportsDirectory() async {
    try {
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

      return await AppPaths.ensureSubdirectory('exports');
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to resolve exports directory',
        operation: 'export:dir',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<db.Firm> _getFirmRecord(int firmId) async {
    try {
      return await (_database.select(_database.firms)
        ..where((tbl) => tbl.id.equals(firmId))).getSingle();
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to load firm record $firmId',
        operation: 'export:getFirm',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
