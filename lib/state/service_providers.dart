import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/backup_service.dart';
import '../services/export_service.dart';
import '../services/payment_proof_storage_service.dart';
import '../services/pdf_service.dart';
import '../services/supabase_service.dart';
import 'database_providers.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final billsDao = ref.watch(billsDaoProvider);
  return ExportService(database: database, billsDao: billsDao);
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final billsDao = ref.watch(billsDaoProvider);
  final tnDao = ref.watch(tnDaoProvider);
  final paymentsDao = ref.watch(paymentsDaoProvider);
  return PdfService(
    database: database,
    billsDao: billsDao,
    tnDao: tnDao,
    paymentsDao: paymentsDao,
  );
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BackupService(database: database);
});

final paymentProofStorageServiceProvider =
    Provider<PaymentProofStorageService>((ref) {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return PaymentProofStorageService(supabaseService: supabaseService);
    });

final backupEntriesProvider = FutureProvider.autoDispose<List<BackupEntry>>((
  ref,
) async {
  final backupService = ref.watch(backupServiceProvider);
  return backupService.listBackups();
});
