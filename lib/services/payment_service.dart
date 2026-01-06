import 'dart:io';

import 'package:path/path.dart';

import '../core/app_logger.dart';
import '../models/bill.dart';
import '../services/database_service.dart';

class PaymentService {
  final DatabaseService _db = DatabaseService.instance;
  final AppLogger _logger = AppLogger.instance;

  // Get all payments for a bill
  Future<List<Payment>> getPaymentsByBill(int billId) async {
    try {
      final maps = await _db.query(
        'payments',
        where: 'bill_id = ?',
        whereArgs: [billId],
        orderBy: 'payment_date DESC',
      );

      return maps.map(Payment.fromMap).toList();
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to load payments for bill $billId',
        operation: 'payments:getByBill',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Get all payments for a firm
  Future<List<Map<String, dynamic>>> getPaymentsByFirm(int firmId) async {
    try {
      return await _db.rawQuery(
        '''
      SELECT p.*, b.tn_number, b.amount as bill_amount
      FROM payments p
      INNER JOIN bills b ON p.bill_id = b.id
      WHERE b.firm_id = ?
      ORDER BY p.payment_date DESC
    ''',
        [firmId],
      );
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to load payments for firm $firmId',
        operation: 'payments:getByFirm',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Create payment
  Future<int> createPayment(Payment payment) async {
    try {
      final paymentId = await _db.transaction<int>((txn) async {
        final id = await txn.insert('payments', payment.toMap());
        await txn.update(
          'bills',
          {'status': 'Paid', 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [payment.billId],
        );
        return id;
      });

      return paymentId;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to create payment for bill ${payment.billId}',
        operation: 'payments:create',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Update payment
  Future<int> updatePayment(Payment payment) async {
    try {
      return await _db.update(
        'payments',
        payment.toMap(),
        where: 'id = ?',
        whereArgs: [payment.id],
      );
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to update payment ${payment.id}',
        operation: 'payments:update',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Delete payment
  Future<int> deletePayment(int id) async {
    try {
      final payments = await _db.query(
        'payments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (payments.isEmpty) {
        return 0;
      }

      final payment = Payment.fromMap(payments.first);

      if (payment.proofPath != null) {
        final file = File(payment.proofPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final result = await _db.transaction<int>((txn) async {
        final deleted = await txn.delete(
          'payments',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (deleted > 0) {
          final remainingPayments = await txn.query(
            'payments',
            where: 'bill_id = ?',
            whereArgs: [payment.billId],
          );

          if (remainingPayments.isEmpty) {
            await txn.update(
              'bills',
              {
                'status': 'Pending',
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [payment.billId],
            );
          }
        }

        return deleted;
      });

      return result;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to delete payment $id',
        operation: 'payments:delete',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Save proof file and return path
  Future<String> saveProofFile(
    String sourcePath,
    String discomCode,
    int billId,
  ) async {
    try {
      final filesDir = await _db.getFilesDirectory(discomCode);
      final extension = sourcePath.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'proof_bill${billId}_$timestamp.$extension';
      final destPath = join(filesDir, fileName);

      final sourceFile = File(sourcePath);
      await sourceFile.copy(destPath);

      return destPath;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to save proof file for bill $billId',
        operation: 'payments:saveProof',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Get total paid amount for a bill
  Future<double> getTotalPaidForBill(int billId) async {
    try {
      final result = await _db.rawQuery(
        '''
      SELECT COALESCE(SUM(amount_paid), 0) as total
      FROM payments
      WHERE bill_id = ?
    ''',
        [billId],
      );

      return (result.first['total'] as num).toDouble();
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to calculate total paid for bill $billId',
        operation: 'payments:totalForBill',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
