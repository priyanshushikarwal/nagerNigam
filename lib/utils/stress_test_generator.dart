import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/repositories/bills_repository.dart';
import '../data/repositories/payments_dao.dart';
import '../data/repositories/tenders_repository.dart';
import '../database/app_database.dart';
import '../models/bill.dart' as model;
import '../models/tender.dart' as model;

class StressTestGenerator {
  StressTestGenerator({
    required AppDatabase database,
    required BillsDao billsDao,
    required TnDao tnDao,
    required PaymentsDao paymentsDao,
  }) : _database = database,
       _billsDao = billsDao,
       _tnDao = tnDao,
       _paymentsDao = paymentsDao;

  final AppDatabase _database;
  final BillsDao _billsDao;
  final TnDao _tnDao;
  final PaymentsDao _paymentsDao;
  final Random _random = Random();

  /// Generate stress test data
  Future<StressTestResult> generateData({
    int tnCount = 500,
    int minBillsPerTn = 3,
    int maxBillsPerTn = 7,
    int minPaymentsPerBill = 0,
    int maxPaymentsPerBill = 3,
    Function(String message, double progress)? progressCallback,
  }) async {
    final startTime = DateTime.now();
    int totalTns = 0;
    int totalBills = 0;
    int totalPayments = 0;

    try {
      // Get available firms
      final firms = await _getFirms();
      if (firms.isEmpty) {
        throw StateError(
          'No firms available. Please add at least one firm first.',
        );
      }

      progressCallback?.call('Starting stress test data generation...', 0.0);

      for (int i = 0; i < tnCount; i++) {
        final progress = (i + 1) / tnCount;
        progressCallback?.call('Generating TN ${i + 1}/$tnCount...', progress);

        // Generate TN
        final firm = firms[_random.nextInt(firms.length)];
        final tender = _generateTender(i + 1, firm.id);
        final insertedTender = await _tnDao.createTender(
          firmId: firm.id,
          tnNumber: tender.tnNumber,
          purchaseOrderNo: tender.poNumber,
          workDescription: tender.workDescription,
        );
        final tenderId = insertedTender.id!;
        totalTns++;

        // Generate Bills for this TN
        final billCount =
            minBillsPerTn + _random.nextInt(maxBillsPerTn - minBillsPerTn + 1);

        for (int j = 0; j < billCount; j++) {
          final bill = _generateBill(
            tenderId: tenderId,
            firmId: firm.id,
            tnNumber: tender.tnNumber,
            billIndex: j + 1,
          );
          final billId = await _billsDao.addBill(bill);
          totalBills++;

          // Generate Payments for this Bill
          final paymentCount =
              minPaymentsPerBill +
              _random.nextInt(maxPaymentsPerBill - minPaymentsPerBill + 1);

          for (int k = 0; k < paymentCount; k++) {
            final payment = _generatePayment(
              billId: billId,
              bill: bill,
              paymentIndex: k + 1,
            );
            await _paymentsDao.addPayment(payment: payment);
            totalPayments++;
          }

          // Update bill payment totals
          await _billsDao.updateBillPaymentTotals(billId);
        }

        // Small delay every 50 TNs to prevent UI freezing
        if ((i + 1) % 50 == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      final duration = DateTime.now().difference(startTime);
      progressCallback?.call('Stress test completed!', 1.0);

      return StressTestResult(
        success: true,
        totalTns: totalTns,
        totalBills: totalBills,
        totalPayments: totalPayments,
        duration: duration,
      );
    } catch (e, stackTrace) {
      debugPrint('Stress test failed: $e');
      debugPrint('Stack trace: $stackTrace');

      return StressTestResult(
        success: false,
        totalTns: totalTns,
        totalBills: totalBills,
        totalPayments: totalPayments,
        duration: DateTime.now().difference(startTime),
        error: e.toString(),
      );
    }
  }

  /// Clear all stress test data
  Future<void> clearAllData({
    Function(String message)? progressCallback,
  }) async {
    progressCallback?.call('Clearing all payments...');
    await _database.delete(_database.payments).go();

    progressCallback?.call('Clearing all bills...');
    await _database.delete(_database.bills).go();

    progressCallback?.call('Clearing all tenders...');
    await _database.delete(_database.tenders).go();

    progressCallback?.call('Data cleared successfully!');
  }

  Future<List<_FirmRecord>> _getFirms() async {
    final rows = await _database.select(_database.firms).get();
    return rows
        .map((row) => _FirmRecord(id: row.id, name: row.name, code: row.code))
        .toList();
  }

  model.Tender _generateTender(int index, int firmId) {
    final discomCodes = ['JDVVNL', 'JVVNL', 'AVVNL'];
    final discomCode = discomCodes[_random.nextInt(discomCodes.length)];

    final year = DateTime.now().year;
    final tnNumber = 'TN-$discomCode-${index.toString().padLeft(5, '0')}/$year';

    final workDescriptions = [
      'Transformer Repair and Maintenance',
      'Cable Installation and Testing',
      'Meter Replacement Project',
      'Pole Installation Work',
      'Line Extension Project',
      'Substation Maintenance',
      'Street Light Installation',
      'Electrical Panel Upgrades',
    ];

    final poPrefix = ['PO', 'WO', 'SO'];

    final now = DateTime.now();
    final createdAt = now.subtract(Duration(days: _random.nextInt(365)));

    return model.Tender(
      tnNumber: tnNumber,
      firmId: firmId,
      poNumber:
          '${poPrefix[_random.nextInt(poPrefix.length)]}/$year/${_random.nextInt(9999) + 1000}',
      workDescription:
          workDescriptions[_random.nextInt(workDescriptions.length)],
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  model.Bill _generateBill({
    required int tenderId,
    required int firmId,
    required String tnNumber,
    required int billIndex,
  }) {
    final billDate = DateTime.now().subtract(
      Duration(days: _random.nextInt(180)),
    );
    final dueDate = billDate.add(Duration(days: 45 + _random.nextInt(30)));

    final invoiceAmount =
        50000.0 + _random.nextDouble() * 450000.0; // 50K to 500K

    // Calculate manual deductions (realistic percentages)
    final tdsAmount =
        invoiceAmount * (0.015 + _random.nextDouble() * 0.015); // 1.5-3%
    final gstTdsAmount =
        invoiceAmount * (0.015 + _random.nextDouble() * 0.015); // 1.5-3%
    final tcsAmount =
        invoiceAmount * (0.008 + _random.nextDouble() * 0.012); // 0.8-2%
    final csdAmount =
        _random.nextBool() ? invoiceAmount * 0.025 : 0; // 2.5% or 0
    final scrapAmount = _random.nextDouble() * 5000; // 0-5K
    final scrapGstAmount = scrapAmount * 0.18; // 18% GST
    final mdLdAmount = _random.nextDouble() * 10000; // 0-10K

    final workOrders = [
      'WO-2024-001',
      'WO-2024-002',
      'WO-2024-003',
      'WO-2024-004',
    ];
    final consignments = [
      'Transformer Batch A',
      'Cable Package B',
      'Meter Set C',
      'Pole Group D',
    ];

    final now = DateTime.now();

    return model.Bill(
      tenderId: tenderId,
      firmId: firmId,
      tnNumber: tnNumber,
      invoiceNo:
          'INV-${tnNumber.split('/').last}-${billIndex.toString().padLeft(3, '0')}',
      billDate: billDate,
      dueDate: dueDate,
      invoiceDate: billDate.subtract(const Duration(days: 2)),
      invoiceAmount: invoiceAmount,
      amount: invoiceAmount,
      workOrderNo: workOrders[_random.nextInt(workOrders.length)],
      workOrderDate: billDate.subtract(
        Duration(days: _random.nextInt(60) + 30),
      ),
      consignmentName: consignments[_random.nextInt(consignments.length)],
      tdsAmount: tdsAmount,
      gstTdsAmount: gstTdsAmount,
      tcsAmount: tcsAmount,
      csdAmount: csdAmount.toDouble(),
      csdReleasedDate: dueDate.add(const Duration(days: 90)),
      scrapAmount: scrapAmount,
      scrapGstAmount: scrapGstAmount,
      mdLdAmount: mdLdAmount,
      emptyOilIssued: 0,
      emptyOilReturned: 0,
      billPassAmount: 0,
      remarks: _random.nextBool() ? 'Auto-generated test data' : null,
      totalPaid: 0,
      dueAmount: invoiceAmount,
      status: 'Pending',
      createdAt: now,
      updatedAt: now,
    );
  }

  model.Payment _generatePayment({
    required int billId,
    required model.Bill bill,
    required int paymentIndex,
  }) {
    final paymentDate = bill.billDate.add(
      Duration(days: _random.nextInt(90) + 15),
    );

    // Pay 30-70% of bill amount per payment
    final paymentPercent = 0.3 + _random.nextDouble() * 0.4;
    final amountPaid = bill.invoiceAmount * paymentPercent;

    final transactionPrefixes = ['UTR', 'CHQ', 'NEFT', 'RTGS', 'IMPS'];

    final now = DateTime.now();

    return model.Payment(
      billId: billId,
      amountPaid: amountPaid,
      paymentDate: paymentDate,
      transactionNo:
          '${transactionPrefixes[_random.nextInt(transactionPrefixes.length)]}-${_random.nextInt(999999) + 100000}',
      workOrderNo: bill.workOrderNo,
      consignmentName: bill.consignmentName,
      remarks:
          paymentIndex == 1 ? 'First payment' : 'Partial payment $paymentIndex',
      lastEdited: now,
      createdAt: now,
    );
  }
}

class StressTestResult {
  const StressTestResult({
    required this.success,
    required this.totalTns,
    required this.totalBills,
    required this.totalPayments,
    required this.duration,
    this.error,
  });

  final bool success;
  final int totalTns;
  final int totalBills;
  final int totalPayments;
  final Duration duration;
  final String? error;

  @override
  String toString() {
    if (!success) {
      return 'Stress Test FAILED: $error\n'
          'Generated: $totalTns TNs, $totalBills bills, $totalPayments payments\n'
          'Duration: ${duration.inSeconds}s';
    }

    return 'Stress Test SUCCESS!\n'
        '✅ Generated $totalTns TNs\n'
        '✅ Generated $totalBills bills\n'
        '✅ Generated $totalPayments payments\n'
        '⏱️ Duration: ${duration.inSeconds}s\n'
        '📊 Average: ${(totalBills / totalTns).toStringAsFixed(1)} bills/TN, '
        '${(totalPayments / totalBills).toStringAsFixed(1)} payments/bill';
  }
}

class _FirmRecord {
  const _FirmRecord({required this.id, required this.name, required this.code});

  final int id;
  final String name;
  final String code;
}
