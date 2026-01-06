import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_logger.dart';
import '../database/app_database.dart';
import '../state/database_providers.dart';
import 'supabase_service.dart';

/// Represents a pending sync operation
class SyncOperation {
  final String table;
  final String operation; // 'insert', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? localId;

  SyncOperation({
    required this.table,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.localId,
  });

  Map<String, dynamic> toJson() => {
    'table': table,
    'operation': operation,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'localId': localId,
  };
}

/// Sync status for UI feedback
class SyncStatus {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? lastError;
  final int pendingOperations;

  const SyncStatus({
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastError,
    this.pendingOperations = 0,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? lastError,
    int? pendingOperations,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError,
      pendingOperations: pendingOperations ?? this.pendingOperations,
    );
  }
}

/// Main sync service that handles bidirectional sync between local SQLite and Supabase
class SyncService extends StateNotifier<SyncStatus> {
  SyncService(this._ref) : super(const SyncStatus()) {
    _init();
  }

  final Ref _ref;
  final AppLogger _logger = AppLogger.instance;

  Timer? _syncTimer;
  StreamSubscription? _realtimeSubscription;
  final List<SyncOperation> _pendingOperations = [];

  AppDatabase get _database => _ref.read(appDatabaseProvider);
  SupabaseService get _supabaseService => _ref.read(supabaseServiceProvider);
  SupabaseClient? get _client => _supabaseService.client;

  void _init() {
    // Start periodic sync every 30 seconds when online
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_ref.read(isOnlineProvider) && _supabaseService.isInitialized) {
        syncAll();
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  /// Perform a full sync with the server
  Future<void> syncAll() async {
    if (!_supabaseService.isInitialized || !_supabaseService.isEnabled) {
      await _logger.logWarning(
        'Sync skipped: Supabase not initialized or not enabled',
        operation: 'sync:all',
      );
      return;
    }

    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true, lastError: null);
    _ref.read(connectionStatusProvider.notifier).setSyncing();

    try {
      await _logger.logInfo('Starting full sync', operation: 'sync:all');

      // Push ALL local data to cloud first
      await _pushAllLocalData();

      // Push any pending operations
      await _pushPendingOperations();

      // Then pull remote changes
      await _pullFirms();
      await _pullClientFirms();
      await _pullTenders();
      await _pullBills();
      await _pullPayments();

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        pendingOperations: _pendingOperations.length,
      );

      await _logger.logInfo('Full sync completed', operation: 'sync:all');
    } catch (e, stackTrace) {
      await _logger.logError(
        'Sync failed',
        operation: 'sync:all',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(isSyncing: false, lastError: e.toString());
    } finally {
      _ref.read(connectionStatusProvider.notifier).setSyncComplete();
    }
  }

  /// Push all local data to Supabase using BATCH operations for speed
  Future<void> _pushAllLocalData() async {
    if (_client == null) return;

    await _logger.logInfo(
      'Pushing all local data to cloud (batch mode)',
      operation: 'sync:push',
    );

    final now = DateTime.now().toIso8601String();

    // Push all firms in ONE batch request
    final firms = await _database.select(_database.firms).get();
    if (firms.isNotEmpty) {
      try {
        final firmData =
            firms
                .map(
                  (firm) => {
                    'id': firm.id,
                    'name': firm.name,
                    'code': firm.code,
                    'description': firm.description,
                    'address': firm.address,
                    'contact_no': firm.contactNo,
                    'gst_no': firm.gstNo,
                    'created_at': firm.createdAt.toIso8601String(),
                    'updated_at': now,
                  },
                )
                .toList();
        await _client!.from('firms').upsert(firmData, onConflict: 'id');
      } catch (e) {
        await _logger.logWarning(
          'Failed to batch push firms: $e',
          operation: 'sync:push',
        );
      }
    }

    // Push all client firms in ONE batch request
    final clientFirms = await _database.select(_database.clientFirms).get();
    if (clientFirms.isNotEmpty) {
      try {
        final clientFirmData =
            clientFirms
                .map(
                  (cf) => {
                    'id': cf.id,
                    'firm_name': cf.firmName,
                    'address': cf.address,
                    'contact_no': cf.contactNo,
                    'gst_no': cf.gstNo,
                    'created_at': cf.createdAt.toIso8601String(),
                    'updated_at': now,
                  },
                )
                .toList();
        await _client!
            .from('client_firms')
            .upsert(clientFirmData, onConflict: 'id');
      } catch (e) {
        await _logger.logWarning(
          'Failed to batch push client firms: $e',
          operation: 'sync:push',
        );
      }
    }

    // Push all tenders in ONE batch request
    final tenders = await _database.select(_database.tenders).get();
    if (tenders.isNotEmpty) {
      try {
        final tenderData =
            tenders
                .map(
                  (tender) => {
                    'id': tender.id,
                    'firm_id': tender.firmId,
                    'tn_number': tender.tnNumber,
                    'po_number': tender.poNumber,
                    'work_description': tender.workDescription,
                    'created_at': tender.createdAt.toIso8601String(),
                    'updated_at': tender.updatedAt.toIso8601String(),
                  },
                )
                .toList();
        await _client!.from('tenders').upsert(tenderData, onConflict: 'id');
      } catch (e) {
        await _logger.logWarning(
          'Failed to batch push tenders: $e',
          operation: 'sync:push',
        );
      }
    }

    // Push all bills in ONE batch request
    final bills = await _database.select(_database.bills).get();
    if (bills.isNotEmpty) {
      try {
        final billData =
            bills
                .map(
                  (bill) => {
                    'id': bill.id,
                    'tender_id': bill.tenderId,
                    'firm_id': bill.firmId,
                    'supplier_firm_id': bill.supplierFirmId,
                    'client_firm_id': bill.clientFirmId,
                    'tn_number': bill.tnNumber,
                    'bill_date': bill.billDate.toIso8601String(),
                    'due_date': bill.dueDate.toIso8601String(),
                    'amount': bill.amount,
                    'invoice_amount': bill.invoiceAmount,
                    'csd_amount': bill.csdAmount,
                    'bill_pass_amount': bill.billPassAmount,
                    'csd_released_date':
                        bill.csdReleasedDate?.toIso8601String(),
                    'csd_due_date': bill.csdDueDate?.toIso8601String(),
                    'csd_status': bill.csdStatus,
                    'scrap_amount': bill.scrapAmount,
                    'scrap_gst_amount': bill.scrapGstAmount,
                    'md_ld_amount': bill.mdLdAmount,
                    'empty_oil_issued': bill.emptyOilIssued,
                    'empty_oil_returned': bill.emptyOilReturned,
                    'tds_amount': bill.tdsAmount,
                    'tcs_amount': bill.tcsAmount,
                    'gst_tds_amount': bill.gstTdsAmount,
                    'total_paid': bill.totalPaid,
                    'due_amount': bill.dueAmount,
                    'status': bill.status,
                    'remarks': bill.remarks,
                    'invoice_no': bill.invoiceNo,
                    'invoice_date': bill.invoiceDate?.toIso8601String(),
                    'work_order_no': bill.workOrderNo,
                    'work_order_date': bill.workOrderDate?.toIso8601String(),
                    'consignment_name': bill.consignmentName,
                    'invoice_type': bill.invoiceType,
                    'created_at': bill.createdAt.toIso8601String(),
                    'updated_at': now,
                  },
                )
                .toList();
        await _client!.from('bills').upsert(billData, onConflict: 'id');
      } catch (e) {
        await _logger.logWarning(
          'Failed to batch push bills: $e',
          operation: 'sync:push',
        );
      }
    }

    // Push all payments in ONE batch request
    final payments = await _database.select(_database.payments).get();
    if (payments.isNotEmpty) {
      try {
        final paymentData =
            payments
                .map(
                  (payment) => {
                    'id': payment.id,
                    'bill_id': payment.billId,
                    'payment_date': payment.paymentDate.toIso8601String(),
                    'amount_paid': payment.amountPaid,
                    'paid_date': payment.paidDate?.toIso8601String(),
                    'transaction_no': payment.transactionNo,
                    'due_release_date':
                        payment.dueReleaseDate?.toIso8601String(),
                    'invoice_no': payment.invoiceNo,
                    'invoice_date': payment.invoiceDate?.toIso8601String(),
                    'work_order_no': payment.workOrderNo,
                    'work_order_date': payment.workOrderDate?.toIso8601String(),
                    'consignment_name': payment.consignmentName,
                    'proof_path': payment.proofPath,
                    'remarks': payment.remarks,
                    'last_edited': payment.lastEdited.toIso8601String(),
                    'created_at': payment.createdAt.toIso8601String(),
                  },
                )
                .toList();
        await _client!.from('payments').upsert(paymentData, onConflict: 'id');
      } catch (e) {
        await _logger.logWarning(
          'Failed to batch push payments: $e',
          operation: 'sync:push',
        );
      }
    }

    await _logger.logInfo(
      'Batch pushed: ${firms.length} firms, ${clientFirms.length} client firms, ${tenders.length} tenders, ${bills.length} bills, ${payments.length} payments',
      operation: 'sync:push',
    );
  }

  /// Queue a local change for sync
  void queueOperation(SyncOperation operation) {
    _pendingOperations.add(operation);
    state = state.copyWith(pendingOperations: _pendingOperations.length);

    // Try to sync immediately if online
    if (_ref.read(isOnlineProvider) && _supabaseService.isInitialized) {
      _pushPendingOperations();
    }
  }

  /// Push pending local changes to server
  Future<void> _pushPendingOperations() async {
    if (_client == null || _pendingOperations.isEmpty) return;

    final operations = List<SyncOperation>.from(_pendingOperations);

    for (final op in operations) {
      try {
        switch (op.operation) {
          case 'insert':
            await _client!.from(op.table).insert(op.data);
            break;
          case 'update':
            await _client!
                .from(op.table)
                .update(op.data)
                .eq('id', op.data['id']);
            break;
          case 'delete':
            await _client!.from(op.table).delete().eq('id', op.data['id']);
            break;
        }
        _pendingOperations.remove(op);
      } catch (e) {
        await _logger.logWarning(
          'Failed to push operation: ${op.table} ${op.operation}',
          operation: 'sync:push',
        );
      }
    }

    state = state.copyWith(pendingOperations: _pendingOperations.length);
  }

  /// Pull firms from server and update local database (batch optimized)
  Future<void> _pullFirms() async {
    if (_client == null) return;

    try {
      final response = await _client!
          .from('firms')
          .select()
          .order('updated_at', ascending: false);

      if (response.isEmpty) {
        await _logger.logInfo(
          'No firms to pull from cloud',
          operation: 'sync:pull',
        );
        return;
      }

      // Get all existing firm IDs in one query
      final existingFirms = await _database.select(_database.firms).get();
      final existingIds = existingFirms.map((f) => f.id).toSet();

      // Filter to only new firms
      final newFirms =
          response
              .where((row) => !existingIds.contains(row['id'] as int))
              .toList();

      if (newFirms.isNotEmpty) {
        // Batch insert all new firms using a single statement
        for (final data in newFirms) {
          await _database.customInsert(
            'INSERT OR IGNORE INTO firms (id, name, code, description, address, contact_no, gst_no, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            variables: [
              Variable.withInt(data['id'] as int),
              Variable.withString(data['name'] as String),
              Variable.withString(data['code'] as String),
              data['description'] != null
                  ? Variable.withString(data['description'] as String)
                  : const Variable(null),
              data['address'] != null
                  ? Variable.withString(data['address'] as String)
                  : const Variable(null),
              data['contact_no'] != null
                  ? Variable.withString(data['contact_no'] as String)
                  : const Variable(null),
              data['gst_no'] != null
                  ? Variable.withString(data['gst_no'] as String)
                  : const Variable(null),
              Variable.withDateTime(
                DateTime.parse(data['created_at'] as String),
              ),
            ],
          );
        }
        await _logger.logInfo(
          'Pulled ${newFirms.length} new firms',
          operation: 'sync:pull',
        );
      }
    } catch (e) {
      await _logger.logWarning(
        'Failed to pull firms: $e',
        operation: 'sync:pull',
      );
    }
  }

  /// Pull client firms from server (batch optimized)
  Future<void> _pullClientFirms() async {
    if (_client == null) return;

    try {
      final response = await _client!
          .from('client_firms')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) return;

      // Get all existing IDs in one query
      final existing = await _database.select(_database.clientFirms).get();
      final existingIds = existing.map((f) => f.id).toSet();

      // Filter to only new records
      final newRecords =
          response
              .where((row) => !existingIds.contains(row['id'] as int))
              .toList();

      if (newRecords.isNotEmpty) {
        for (final data in newRecords) {
          await _database.customInsert(
            'INSERT OR IGNORE INTO client_firms (id, firm_name, address, contact_no, gst_no, created_at) VALUES (?, ?, ?, ?, ?, ?)',
            variables: [
              Variable.withInt(data['id'] as int),
              Variable.withString(data['firm_name'] as String),
              data['address'] != null
                  ? Variable.withString(data['address'] as String)
                  : const Variable(null),
              data['contact_no'] != null
                  ? Variable.withString(data['contact_no'] as String)
                  : const Variable(null),
              data['gst_no'] != null
                  ? Variable.withString(data['gst_no'] as String)
                  : const Variable(null),
              Variable.withDateTime(
                DateTime.parse(data['created_at'] as String),
              ),
            ],
          );
        }
        await _logger.logInfo(
          'Pulled ${newRecords.length} new client firms',
          operation: 'sync:pull',
        );
      }
    } catch (e) {
      await _logger.logWarning(
        'Failed to pull client firms: $e',
        operation: 'sync:pull',
      );
    }
  }

  /// Pull tenders from server (batch optimized)
  Future<void> _pullTenders() async {
    if (_client == null) return;

    try {
      final response = await _client!
          .from('tenders')
          .select()
          .order('updated_at', ascending: false);

      if (response.isEmpty) return;

      // Get all existing IDs in one query
      final existing = await _database.select(_database.tenders).get();
      final existingIds = existing.map((t) => t.id).toSet();

      // Filter to only new records
      final newRecords =
          response
              .where((row) => !existingIds.contains(row['id'] as int))
              .toList();

      if (newRecords.isNotEmpty) {
        for (final data in newRecords) {
          await _database.customInsert(
            'INSERT OR IGNORE INTO tenders (id, firm_id, tn_number, po_number, work_description, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
            variables: [
              Variable.withInt(data['id'] as int),
              Variable.withInt(data['firm_id'] as int),
              Variable.withString(data['tn_number'] as String),
              data['po_number'] != null
                  ? Variable.withString(data['po_number'] as String)
                  : const Variable(null),
              data['work_description'] != null
                  ? Variable.withString(data['work_description'] as String)
                  : const Variable(null),
              Variable.withDateTime(
                DateTime.parse(data['created_at'] as String),
              ),
              Variable.withDateTime(
                DateTime.parse(data['updated_at'] as String),
              ),
            ],
          );
        }
        await _logger.logInfo(
          'Pulled ${newRecords.length} new tenders',
          operation: 'sync:pull',
        );
      }
    } catch (e) {
      await _logger.logWarning(
        'Failed to pull tenders: $e',
        operation: 'sync:pull',
      );
    }
  }

  /// Pull bills from server (batch optimized)
  Future<void> _pullBills() async {
    if (_client == null) return;

    try {
      final response = await _client!
          .from('bills')
          .select()
          .order('updated_at', ascending: false);

      await _logger.logInfo(
        'Fetched ${response.length} bills from cloud',
        operation: 'sync:pull',
      );

      if (response.isEmpty) return;

      // Get all existing bill IDs in one query - much faster than individual lookups
      final existingBills = await _database.select(_database.bills).get();
      final existingIds = existingBills.map((b) => b.id).toSet();

      // Filter to only new bills
      final newBills =
          response
              .where((row) => !existingIds.contains(row['id'] as int))
              .toList();

      if (newBills.isNotEmpty) {
        await _logger.logInfo(
          'Inserting ${newBills.length} new bills...',
          operation: 'sync:pull',
        );
        for (final data in newBills) {
          await _insertLocalBill(data);
        }
        await _logger.logInfo(
          'Pulled ${newBills.length} new bills',
          operation: 'sync:pull',
        );
      } else {
        await _logger.logInfo('No new bills to pull', operation: 'sync:pull');
      }
    } catch (e) {
      await _logger.logWarning(
        'Failed to pull bills: $e',
        operation: 'sync:pull',
      );
    }
  }

  /// Insert a bill into local database (used by _pullBills)
  Future<void> _insertLocalBill(Map<String, dynamic> data) async {
    try {
      final existing =
          await (_database.select(_database.bills)
            ..where((b) => b.id.equals(data['id'] as int))).getSingleOrNull();

      if (existing == null) {
        // Insert new bill with ALL fields to ensure calculations work correctly
        await _database.customInsert(
          '''INSERT OR IGNORE INTO bills (
            id, tender_id, firm_id, supplier_firm_id, client_firm_id,
            tn_number, bill_date, due_date, amount, status,
            invoice_amount, csd_amount, bill_pass_amount, csd_released_date, csd_due_date, csd_status,
            scrap_amount, scrap_gst_amount, md_ld_amount,
            empty_oil_issued, empty_oil_returned,
            tds_amount, tcs_amount, gst_tds_amount,
            total_paid, due_amount,
            remarks, invoice_no, invoice_date,
            work_order_no, work_order_date, consignment_name, invoice_type,
            created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          variables: [
            Variable.withInt(data['id'] as int),
            data['tender_id'] != null
                ? Variable.withInt(data['tender_id'] as int)
                : const Variable(null),
            Variable.withInt(data['firm_id'] as int),
            data['supplier_firm_id'] != null
                ? Variable.withInt(data['supplier_firm_id'] as int)
                : const Variable(null),
            data['client_firm_id'] != null
                ? Variable.withInt(data['client_firm_id'] as int)
                : const Variable(null),
            Variable.withString(data['tn_number'] as String),
            Variable.withDateTime(DateTime.parse(data['bill_date'] as String)),
            Variable.withDateTime(DateTime.parse(data['due_date'] as String)),
            Variable.withReal((data['amount'] as num?)?.toDouble() ?? 0.0),
            Variable.withString(data['status'] as String? ?? 'Pending'),
            Variable.withReal(
              (data['invoice_amount'] as num?)?.toDouble() ?? 0.0,
            ),
            Variable.withReal((data['csd_amount'] as num?)?.toDouble() ?? 0.0),
            Variable.withReal(
              (data['bill_pass_amount'] as num?)?.toDouble() ?? 0.0,
            ),
            data['csd_released_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['csd_released_date'] as String),
                )
                : const Variable(null),
            data['csd_due_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['csd_due_date'] as String),
                )
                : const Variable(null),
            Variable.withString((data['csd_status'] as String?) ?? 'Pending'),
            Variable.withReal(
              (data['scrap_amount'] as num?)?.toDouble() ?? 0.0,
            ),
            Variable.withReal(
              (data['scrap_gst_amount'] as num?)?.toDouble() ?? 0.0,
            ),
            Variable.withReal(
              (data['md_ld_amount'] as num?)?.toDouble() ?? 0.0,
            ),
            Variable.withReal(
              (data['empty_oil_issued'] as num?)?.toDouble() ?? 0.0,
            ),
            Variable.withReal(
              (data['empty_oil_returned'] as num?)?.toDouble() ?? 0.0,
            ),
            Variable.withReal((data['tds_amount'] as num?)?.toDouble() ?? 0.0),
            Variable.withReal((data['tcs_amount'] as num?)?.toDouble() ?? 0.0),
            Variable.withReal(
              (data['gst_tds_amount'] as num?)?.toDouble() ?? 0.0,
            ),
            Variable.withReal((data['total_paid'] as num?)?.toDouble() ?? 0.0),
            Variable.withReal((data['due_amount'] as num?)?.toDouble() ?? 0.0),
            data['remarks'] != null
                ? Variable.withString(data['remarks'] as String)
                : const Variable(null),
            data['invoice_no'] != null
                ? Variable.withString(data['invoice_no'] as String)
                : const Variable(null),
            data['invoice_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['invoice_date'] as String),
                )
                : const Variable(null),
            data['work_order_no'] != null
                ? Variable.withString(data['work_order_no'] as String)
                : const Variable(null),
            data['work_order_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['work_order_date'] as String),
                )
                : const Variable(null),
            data['consignment_name'] != null
                ? Variable.withString(data['consignment_name'] as String)
                : const Variable(null),
            data['invoice_type'] != null
                ? Variable.withString(data['invoice_type'] as String)
                : const Variable(null),
            Variable.withDateTime(DateTime.parse(data['created_at'] as String)),
            Variable.withDateTime(DateTime.parse(data['updated_at'] as String)),
          ],
        );
      }
    } catch (e) {
      await _logger.logWarning(
        'Failed to upsert local bill: $e',
        operation: 'sync:pull',
      );
    }
  }

  /// Pull payments from server (batch optimized)
  Future<void> _pullPayments() async {
    if (_client == null) return;

    try {
      final response = await _client!
          .from('payments')
          .select()
          .order('created_at', ascending: false);

      await _logger.logInfo(
        'Fetched ${response.length} payments from cloud',
        operation: 'sync:pull',
      );

      if (response.isEmpty) return;

      // Get all existing payment IDs in one query
      final existingPayments = await _database.select(_database.payments).get();
      final existingIds = existingPayments.map((p) => p.id).toSet();

      // Filter to only new payments
      final newPayments =
          response
              .where((row) => !existingIds.contains(row['id'] as int))
              .toList();

      if (newPayments.isNotEmpty) {
        await _logger.logInfo(
          'Inserting ${newPayments.length} new payments...',
          operation: 'sync:pull',
        );
        for (final data in newPayments) {
          await _insertLocalPayment(data);
        }
        await _logger.logInfo(
          'Pulled ${newPayments.length} new payments',
          operation: 'sync:pull',
        );
      } else {
        await _logger.logInfo(
          'No new payments to pull',
          operation: 'sync:pull',
        );
      }
    } catch (e) {
      await _logger.logWarning(
        'Failed to pull payments: $e',
        operation: 'sync:pull',
      );
    }
  }

  /// Insert a payment into local database (used by _pullPayments)
  Future<void> _insertLocalPayment(Map<String, dynamic> data) async {
    try {
      final existing =
          await (_database.select(_database.payments)
            ..where((p) => p.id.equals(data['id'] as int))).getSingleOrNull();

      if (existing == null) {
        // Insert new payment with ALL fields to ensure data is complete
        await _database.customInsert(
          '''INSERT OR IGNORE INTO payments (
            id, bill_id, payment_date, amount_paid,
            paid_date, transaction_no, due_release_date,
            invoice_no, invoice_date, work_order_no, work_order_date,
            consignment_name, proof_path, remarks, last_edited, created_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          variables: [
            Variable.withInt(data['id'] as int),
            Variable.withInt(data['bill_id'] as int),
            Variable.withDateTime(
              DateTime.parse(data['payment_date'] as String),
            ),
            Variable.withReal((data['amount_paid'] as num?)?.toDouble() ?? 0.0),
            data['paid_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['paid_date'] as String),
                )
                : const Variable(null),
            data['transaction_no'] != null
                ? Variable.withString(data['transaction_no'] as String)
                : const Variable(null),
            data['due_release_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['due_release_date'] as String),
                )
                : const Variable(null),
            data['invoice_no'] != null
                ? Variable.withString(data['invoice_no'] as String)
                : const Variable(null),
            data['invoice_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['invoice_date'] as String),
                )
                : const Variable(null),
            data['work_order_no'] != null
                ? Variable.withString(data['work_order_no'] as String)
                : const Variable(null),
            data['work_order_date'] != null
                ? Variable.withDateTime(
                  DateTime.parse(data['work_order_date'] as String),
                )
                : const Variable(null),
            data['consignment_name'] != null
                ? Variable.withString(data['consignment_name'] as String)
                : const Variable(null),
            data['proof_path'] != null
                ? Variable.withString(data['proof_path'] as String)
                : const Variable(null),
            data['remarks'] != null
                ? Variable.withString(data['remarks'] as String)
                : const Variable(null),
            Variable.withDateTime(
              data['last_edited'] != null
                  ? DateTime.parse(data['last_edited'] as String)
                  : DateTime.now(),
            ),
            Variable.withDateTime(DateTime.parse(data['created_at'] as String)),
          ],
        );
      }
    } catch (e) {
      await _logger.logWarning(
        'Failed to upsert local payment: $e',
        operation: 'sync:pull',
      );
    }
  }

  /// Push a single firm to server
  Future<void> pushFirm(Firm firm) async {
    if (!_supabaseService.isInitialized || _client == null) {
      queueOperation(
        SyncOperation(
          table: 'firms',
          operation: 'insert',
          data: {
            'id': firm.id,
            'name': firm.name,
            'code': firm.code,
            'description': firm.description,
            'address': firm.address,
            'contact_no': firm.contactNo,
            'gst_no': firm.gstNo,
            'created_at': firm.createdAt.toIso8601String(),
          },
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    try {
      await _client!.from('firms').upsert({
        'id': firm.id,
        'name': firm.name,
        'code': firm.code,
        'description': firm.description,
        'address': firm.address,
        'contact_no': firm.contactNo,
        'gst_no': firm.gstNo,
        'created_at': firm.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      await _logger.logWarning(
        'Failed to push firm: $e',
        operation: 'sync:push',
      );
    }
  }

  /// Push a single tender to server
  Future<void> pushTender(Tender tender) async {
    if (!_supabaseService.isInitialized || _client == null) {
      queueOperation(
        SyncOperation(
          table: 'tenders',
          operation: 'insert',
          data: {
            'id': tender.id,
            'firm_id': tender.firmId,
            'tn_number': tender.tnNumber,
            'po_number': tender.poNumber,
            'work_description': tender.workDescription,
            'created_at': tender.createdAt.toIso8601String(),
            'updated_at': tender.updatedAt.toIso8601String(),
          },
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    try {
      await _client!.from('tenders').upsert({
        'id': tender.id,
        'firm_id': tender.firmId,
        'tn_number': tender.tnNumber,
        'po_number': tender.poNumber,
        'work_description': tender.workDescription,
        'created_at': tender.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      await _logger.logWarning(
        'Failed to push tender: $e',
        operation: 'sync:push',
      );
    }
  }

  /// Push a single bill to server
  Future<void> pushBill(Bill bill) async {
    if (!_supabaseService.isInitialized || _client == null) {
      queueOperation(
        SyncOperation(
          table: 'bills',
          operation: 'insert',
          data: _billToMap(bill),
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    try {
      await _client!.from('bills').upsert(_billToMap(bill));
    } catch (e) {
      await _logger.logWarning(
        'Failed to push bill: $e',
        operation: 'sync:push',
      );
    }
  }

  Map<String, dynamic> _billToMap(Bill bill) {
    return {
      'id': bill.id,
      'firm_id': bill.firmId,
      'tender_id': bill.tenderId,
      'tn_number': bill.tnNumber,
      'bill_date': bill.billDate.toIso8601String(),
      'due_date': bill.dueDate.toIso8601String(),
      'amount': bill.amount,
      'invoice_amount': bill.invoiceAmount,
      'csd_amount': bill.csdAmount,
      'bill_pass_amount': bill.billPassAmount,
      'status': bill.status,
      'total_paid': bill.totalPaid,
      'due_amount': bill.dueAmount,
      'tds_amount': bill.tdsAmount,
      'tcs_amount': bill.tcsAmount,
      'gst_tds_amount': bill.gstTdsAmount,
      'created_at': bill.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Push a single payment to server
  Future<void> pushPayment(Payment payment) async {
    if (!_supabaseService.isInitialized || _client == null) {
      queueOperation(
        SyncOperation(
          table: 'payments',
          operation: 'insert',
          data: {
            'id': payment.id,
            'bill_id': payment.billId,
            'payment_date': payment.paymentDate.toIso8601String(),
            'amount_paid': payment.amountPaid,
            'transaction_no': payment.transactionNo,
            'remarks': payment.remarks,
            'created_at': payment.createdAt.toIso8601String(),
          },
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    try {
      await _client!.from('payments').upsert({
        'id': payment.id,
        'bill_id': payment.billId,
        'payment_date': payment.paymentDate.toIso8601String(),
        'amount_paid': payment.amountPaid,
        'transaction_no': payment.transactionNo,
        'remarks': payment.remarks,
        'created_at': payment.createdAt.toIso8601String(),
      });
    } catch (e) {
      await _logger.logWarning(
        'Failed to push payment: $e',
        operation: 'sync:push',
      );
    }
  }

  /// Delete a bill from Supabase
  Future<bool> deleteBillFromCloud(int billId) async {
    if (!_supabaseService.isInitialized || _client == null) {
      // Queue the delete operation for later
      queueOperation(
        SyncOperation(
          table: 'bills',
          operation: 'delete',
          data: {'id': billId},
          timestamp: DateTime.now(),
        ),
      );
      await _logger.logInfo(
        'Queued bill delete for sync: $billId',
        operation: 'sync:delete',
      );
      return true;
    }

    try {
      // First delete associated payments from cloud
      await _client!.from('payments').delete().eq('bill_id', billId);

      // Then delete the bill
      await _client!.from('bills').delete().eq('id', billId);

      await _logger.logInfo(
        'Deleted bill from cloud: $billId',
        operation: 'sync:delete',
      );
      return true;
    } catch (e) {
      await _logger.logWarning(
        'Failed to delete bill from cloud: $e',
        operation: 'sync:delete',
      );
      // Queue for retry
      queueOperation(
        SyncOperation(
          table: 'bills',
          operation: 'delete',
          data: {'id': billId},
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }
  }

  /// Delete a tender from Supabase
  Future<bool> deleteTenderFromCloud(int tenderId) async {
    if (!_supabaseService.isInitialized || _client == null) {
      // Queue the delete operation for later
      queueOperation(
        SyncOperation(
          table: 'tenders',
          operation: 'delete',
          data: {'id': tenderId},
          timestamp: DateTime.now(),
        ),
      );
      await _logger.logInfo(
        'Queued tender delete for sync: $tenderId',
        operation: 'sync:delete',
      );
      return true;
    }

    try {
      // Update bills to unlink from this tender (set tender_id to null)
      await _client!
          .from('bills')
          .update({'tender_id': null})
          .eq('tender_id', tenderId);

      // Then delete the tender
      await _client!.from('tenders').delete().eq('id', tenderId);

      await _logger.logInfo(
        'Deleted tender from cloud: $tenderId',
        operation: 'sync:delete',
      );
      return true;
    } catch (e) {
      await _logger.logWarning(
        'Failed to delete tender from cloud: $e',
        operation: 'sync:delete',
      );
      // Queue for retry
      queueOperation(
        SyncOperation(
          table: 'tenders',
          operation: 'delete',
          data: {'id': tenderId},
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }
  }

  /// Delete a payment from Supabase
  Future<bool> deletePaymentFromCloud(int paymentId) async {
    if (!_supabaseService.isInitialized || _client == null) {
      // Queue the delete operation for later
      queueOperation(
        SyncOperation(
          table: 'payments',
          operation: 'delete',
          data: {'id': paymentId},
          timestamp: DateTime.now(),
        ),
      );
      await _logger.logInfo(
        'Queued payment delete for sync: $paymentId',
        operation: 'sync:delete',
      );
      return true;
    }

    try {
      await _client!.from('payments').delete().eq('id', paymentId);

      await _logger.logInfo(
        'Deleted payment from cloud: $paymentId',
        operation: 'sync:delete',
      );
      return true;
    } catch (e) {
      await _logger.logWarning(
        'Failed to delete payment from cloud: $e',
        operation: 'sync:delete',
      );
      // Queue for retry
      queueOperation(
        SyncOperation(
          table: 'payments',
          operation: 'delete',
          data: {'id': paymentId},
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }
  }
}

/// Provider for the sync service
final syncServiceProvider = StateNotifierProvider<SyncService, SyncStatus>((
  ref,
) {
  return SyncService(ref);
});

/// Provider for sync status
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(syncServiceProvider).isSyncing;
});

final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(syncServiceProvider).lastSyncTime;
});
