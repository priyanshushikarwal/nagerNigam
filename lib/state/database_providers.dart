import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/bills_repository.dart';
import '../data/repositories/firms_repository.dart';
import '../data/repositories/payments_dao.dart';
import '../data/repositories/tenders_repository.dart';
import '../database/app_database.dart';
import '../models/bill.dart' as model;

/// Exposes a shared Drift database instance for the application lifetime.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Provides access to firm-specific data operations backed by Drift.
final firmsDaoProvider = Provider<FirmsDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return FirmsDao(database);
});

/// Provides access to bill-specific data operations backed by Drift.
final billsDaoProvider = Provider<BillsDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BillsDao(database);
});

/// Provides access to tender data and aggregate statistics.
final tnDaoProvider = Provider<TnDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return TnDao(database);
});

/// Provides access to payment persistence and retrieval helpers.
final paymentsDaoProvider = Provider<PaymentsDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final billsDao = ref.watch(billsDaoProvider);
  return PaymentsDao(database, billsDao);
});

/// Fetches a single bill by ID with all related payment information.
final billByIdProvider = FutureProvider.family<model.Bill?, int>((
  ref,
  billId,
) async {
  final dao = ref.watch(billsDaoProvider);
  return dao.getBillById(billId);
});

/// Fetches a bill with all its associated payments
final billWithPaymentsProvider =
    FutureProvider.family<model.BillWithPayments?, int>((ref, billId) async {
      final dao = ref.watch(billsDaoProvider);
      return dao.getBillWithPayments(billId);
    });

/// Fetches all payments for a specific bill
final paymentsByBillProvider = FutureProvider.family<List<model.Payment>, int>((
  ref,
  billId,
) async {
  final dao = ref.watch(paymentsDaoProvider);
  return dao.getPaymentsByBill(billId);
});
