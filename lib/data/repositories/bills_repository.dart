import 'package:drift/drift.dart';

import '../../database/app_database.dart' as db;
import '../../models/bill.dart';
import '../../models/tn_bill_stats.dart';

class BillsDao {
  BillsDao(this._database);

  final db.AppDatabase _database;

  static const _billSelect = '''
    SELECT
      b.id,
      b.firm_id,
      b.client_firm_id,
      b.tender_id,
      b.tn_number,
      b.bill_date,
      b.due_date,
      b.amount,
      b.remarks,
      b.invoice_amount,
      b.bill_pass_amount,
      b.csd_amount,
      b.csd_released_date,
      b.csd_due_date,
      b.csd_status,
      b.scrap_amount,
  b.scrap_gst_amount,
      b.md_ld_amount,
      b.md_ld_status,
      b.md_ld_released_date,
      b.empty_oil_issued,
      b.empty_oil_returned,
      b.tds_amount,
      b.tcs_amount,
      b.gst_tds_amount,
      b.total_paid,
      b.due_amount,
      b.status,
      b.paid_date,
      b.transaction_no,
  b.due_release_date,
  b.invoice_no AS bill_no,
      b.invoice_date,
      b.work_order_no,
      b.work_order_date,
      b.consignment_name,
      b.invoice_type,
      b.proof_path,
      b.created_at,
      b.updated_at,
      f.name AS firm_name,
      cf.firm_name AS client_firm_name,
      COALESCE(pay.total_paid, 0) AS total_paid,
      COALESCE(pay.payment_count, 0) AS payment_count
    FROM bills b
    LEFT JOIN firms f ON f.id = b.firm_id
    LEFT JOIN client_firms cf ON cf.id = b.client_firm_id
    LEFT JOIN (
      SELECT
        bill_id,
        SUM(amount_paid) AS total_paid,
        COUNT(*) AS payment_count
      FROM payments
      GROUP BY bill_id
    ) pay ON pay.bill_id = b.id
  ''';

  Future<List<Bill>> getBillsByFirm(int firmId) async {
    return _fetchBills(
      whereClause: 'b.firm_id = ?',
      variables: [Variable<int>(firmId)],
    );
  }

  Future<List<Bill>> searchBills(int firmId, String query) async {
    final pattern = '%${query.toLowerCase()}%';
    return _fetchBills(
      whereClause:
          "b.firm_id = ? AND (LOWER(b.tn_number) LIKE ? OR LOWER(COALESCE(b.remarks, '')) LIKE ?)",
      variables: [
        Variable<int>(firmId),
        Variable<String>(pattern),
        Variable<String>(pattern),
      ],
    );
  }

  Future<List<Bill>> getBillsByTender(int tenderId) async {
    // First get the tender to know the tn_number
    final tenderRow =
        await (_database.select(_database.tenders)
          ..where((tbl) => tbl.id.equals(tenderId))).getSingleOrNull();

    if (tenderRow == null) {
      return const [];
    }

    // Match bills by tender_id OR by tn_number (for legacy bills without tender_id)
    return _fetchBills(
      whereClause:
          '(b.tender_id = ? OR (b.tender_id IS NULL AND b.tn_number = ? AND b.firm_id = ?))',
      variables: [
        Variable<int>(tenderId),
        Variable<String>(tenderRow.tnNumber),
        Variable<int>(tenderRow.firmId),
      ],
    );
  }

  Future<Bill?> getBillById(int billId) async {
    final results = await _fetchBills(
      whereClause: 'b.id = ?',
      variables: [Variable<int>(billId)],
    );
    if (results.isEmpty) {
      return null;
    }
    return results.first;
  }

  /// Get a bill with all its associated payments
  Future<BillWithPayments?> getBillWithPayments(int billId) async {
    final bill = await getBillById(billId);
    if (bill == null) {
      return null;
    }

    // Payments are already loaded in _fetchBills via _loadPaymentsForBills
    final payments = bill.payments ?? const <Payment>[];

    return BillWithPayments(bill: bill, payments: payments);
  }

  Future<DashboardStats> getDashboardStats(int firmId) async {
    final bills = await getBillsByFirm(firmId);
    if (bills.isEmpty) {
      return DashboardStats(
        totalBills: 0,
        dueSoonBills: 0,
        overdueBills: 0,
        paidBills: 0,
        partiallyPaidBills: 0,
        totalAmount: 0,
        paidAmount: 0,
        pendingAmount: 0,
      );
    }

    var totalAmount = 0.0;
    var paidAmount = 0.0;
    var paidBills = 0;
    var partiallyPaidBills = 0;
    var dueSoonBills = 0;
    var overdueBills = 0;

    for (final bill in bills) {
      final targetAmount = _targetAmountForBill(bill);
      totalAmount += targetAmount;

      // Use totalPaid from bill (automatically calculated)
      paidAmount += bill.totalPaid;

      // Count bills by payment status
      switch (bill.status) {
        case 'Paid':
          paidBills += 1;
          break;
        case 'Partially Paid':
          partiallyPaidBills += 1;
          break;
        case 'DueSoon':
          dueSoonBills += 1;
          break;
        case 'Overdue':
          overdueBills += 1;
          break;
        default:
          break;
      }
    }

    final pendingAmount = totalAmount - paidAmount;

    return DashboardStats(
      totalBills: bills.length,
      dueSoonBills: dueSoonBills,
      overdueBills: overdueBills,
      paidBills: paidBills,
      partiallyPaidBills: partiallyPaidBills,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount < 0 ? 0 : pendingAmount,
    );
  }

  Future<TNBillStats> getTNStats(int tenderId) async {
    final bills = await getBillsByTender(tenderId);
    if (bills.isEmpty) {
      return const TNBillStats(
        totalBills: 0,
        paidBills: 0,
        partiallyPaidBills: 0,
        overdueBills: 0,
        pendingBills: 0,
        dueSoonBills: 0,
      );
    }

    var paid = 0;
    var partiallyPaid = 0;
    var overdue = 0;
    var dueSoon = 0;

    for (final bill in bills) {
      switch (bill.status) {
        case 'Paid':
          paid += 1;
          break;
        case 'Partially Paid':
          partiallyPaid += 1;
          break;
        case 'Overdue':
          overdue += 1;
          break;
        case 'DueSoon':
          dueSoon += 1;
          break;
        default:
          break;
      }
    }

    final pending = bills.length - paid - partiallyPaid;

    return TNBillStats(
      totalBills: bills.length,
      paidBills: paid,
      partiallyPaidBills: partiallyPaid,
      overdueBills: overdue,
      pendingBills: pending < 0 ? 0 : pending,
      dueSoonBills: dueSoon,
    );
  }

  Future<int> addBill(Bill bill) async {
    final companion = _companionFromBill(bill, forInsert: true);
    return _database.into(_database.bills).insert(companion);
  }

  Future<int> updateBill(Bill bill) async {
    if (bill.id == null) {
      throw ArgumentError('Cannot update a bill without an id');
    }

    final companion = _companionFromBill(bill);
    return (_database.update(_database.bills)
      ..where((tbl) => tbl.id.equals(bill.id!))).write(companion);
  }

  /// Delete a bill and all its associated payments
  /// Returns true if the bill was successfully deleted
  Future<bool> deleteBill(int billId) async {
    // First, verify the bill exists
    final billExists =
        await (_database.select(_database.bills)
          ..where((tbl) => tbl.id.equals(billId))).getSingleOrNull();

    if (billExists == null) {
      // Bill doesn't exist, nothing to delete
      return false;
    }

    // Delete associated payments first (even though we have CASCADE, be explicit)
    await (_database.delete(_database.payments)
      ..where((tbl) => tbl.billId.equals(billId))).go();

    // Now delete the bill
    final deletedCount =
        await (_database.delete(_database.bills)
          ..where((tbl) => tbl.id.equals(billId))).go();

    return deletedCount > 0;
  }

  /// Update only the CSD Status of a bill (for quick toggle from table)
  Future<void> updateCsdStatus(int billId, String csdStatus) async {
    await (_database.update(_database.bills)
      ..where((tbl) => tbl.id.equals(billId))).write(
      db.BillsCompanion(
        csdStatus: Value(csdStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update the CSD Release Date of a bill
  Future<void> updateCsdReleaseDate(int billId, DateTime releaseDate) async {
    await (_database.update(_database.bills)
      ..where((tbl) => tbl.id.equals(billId))).write(
      db.BillsCompanion(
        csdReleasedDate: Value(releaseDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update only the MD/LD Status of a bill
  Future<void> updateMdLdStatus(int billId, String mdLdStatus) async {
    await (_database.update(_database.bills)
      ..where((tbl) => tbl.id.equals(billId))).write(
      db.BillsCompanion(
        mdLdStatus: Value(mdLdStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update the MD/LD Release Date of a bill
  Future<void> updateMdLdReleaseDate(int billId, DateTime releaseDate) async {
    await (_database.update(_database.bills)
      ..where((tbl) => tbl.id.equals(billId))).write(
      db.BillsCompanion(
        mdLdReleasedDate: Value(releaseDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<Bill>> _fetchBills({
    required String whereClause,
    required List<Variable> variables,
  }) async {
    final rows =
        await _database
            .customSelect(
              '$_billSelect WHERE $whereClause ORDER BY b.bill_date DESC, b.created_at DESC',
              variables: variables,
              readsFrom: {_database.bills, _database.payments, _database.firms},
            )
            .get();

    if (rows.isEmpty) {
      return const [];
    }

    final bills = rows.map(_mapRowToBill).toList();
    final paymentsByBill = await _loadPaymentsForBills(bills);

    return bills.map((bill) {
      final payments = paymentsByBill[bill.id] ?? const <Payment>[];
      final totalPaid = Bill.calculateTotalPaid(payments);
      final dueAmount = Bill.calculateDueAmount(bill, payments);
      final status = Bill.calculateStatus(bill, payments);
      return bill.copyWith(
        totalPaid: totalPaid,
        dueAmount: dueAmount,
        status: status,
        payments: payments,
      );
    }).toList();
  }

  Future<Map<int, List<Payment>>> _loadPaymentsForBills(
    List<Bill> bills,
  ) async {
    final billIds = bills.map((bill) => bill.id).whereType<int>().toList();
    if (billIds.isEmpty) {
      return const {};
    }

    final paymentRows =
        await (_database.select(_database.payments)
              ..where((tbl) => tbl.billId.isIn(billIds))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.paymentDate)]))
            .get();

    final grouped = <int, List<Payment>>{};

    for (final row in paymentRows) {
      final payment = Payment(
        id: row.id,
        billId: row.billId,
        paymentDate: row.paymentDate,
        amountPaid: row.amountPaid,
        proofPath: row.proofPath,
        remarks: row.remarks,
        lastEdited: row.lastEdited,
        createdAt: row.createdAt,
        paidDate: row.paidDate,
        transactionNo: row.transactionNo,
        dueReleaseDate: row.dueReleaseDate,
        invoiceNo: row.invoiceNo,
        invoiceDate: row.invoiceDate,
        workOrderNo: row.workOrderNo,
        workOrderDate: row.workOrderDate,
        consignmentName: row.consignmentName,
      );

      grouped.putIfAbsent(row.billId, () => <Payment>[]).add(payment);
    }

    return grouped;
  }

  Bill _mapRowToBill(QueryRow row) {
    final data = row.data;
    return Bill(
      id: row.read<int>('id'),
      firmId: row.read<int>('firm_id'),
      clientFirmId: row.readNullable<int>('client_firm_id'),
      tenderId: row.readNullable<int>('tender_id'),
      tnNumber: row.read<String>('tn_number'),
      billDate: row.read<DateTime>('bill_date'),
      dueDate: row.read<DateTime>('due_date'),
      amount: row.read<double>('amount'),
      remarks: row.readNullable<String>('remarks'),
      invoiceAmount: row.read<double>('invoice_amount'),
      billPassAmount: row.read<double>('bill_pass_amount'),
      csdAmount: row.read<double>('csd_amount'),
      csdReleasedDate: row.readNullable<DateTime>('csd_released_date'),
      csdDueDate: row.readNullable<DateTime>('csd_due_date'),
      csdStatus: row.readNullable<String>('csd_status') ?? 'Pending',
      scrapAmount: row.read<double>('scrap_amount'),
      scrapGstAmount: row.read<double>('scrap_gst_amount'),
      mdLdAmount: row.read<double>('md_ld_amount'),
      mdLdStatus: row.readNullable<String>('md_ld_status') ?? 'Pending',
      mdLdReleasedDate: row.readNullable<DateTime>('md_ld_released_date'),
      emptyOilIssued: row.read<double>('empty_oil_issued'),
      emptyOilReturned: row.read<double>('empty_oil_returned'),
      tdsAmount: row.read<double>('tds_amount'),
      tcsAmount: row.read<double>('tcs_amount'),
      gstTdsAmount: row.read<double>('gst_tds_amount'),
      totalPaid: row.read<double>('total_paid'),
      dueAmount: row.read<double>('due_amount'),
      status: row.read<String>('status'),
      paidDate: row.readNullable<DateTime>('paid_date'),
      transactionNo: row.readNullable<String>('transaction_no'),
      dueReleaseDate: row.readNullable<DateTime>('due_release_date'),
      invoiceNo: row.readNullable<String>('bill_no'),
      invoiceDate: row.readNullable<DateTime>('invoice_date'),
      workOrderNo: row.readNullable<String>('work_order_no'),
      workOrderDate: row.readNullable<DateTime>('work_order_date'),
      consignmentName: row.readNullable<String>('consignment_name'),
      invoiceType: row.readNullable<String>('invoice_type'),
      proofPath: row.readNullable<String>('proof_path'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
      firmName: data['firm_name'] as String?,
      clientFirmName: data['client_firm_name'] as String?,
      payments: const [],
    );
  }

  db.BillsCompanion _companionFromBill(Bill bill, {bool forInsert = false}) {
    final now = DateTime.now();
    return db.BillsCompanion(
      id: forInsert || bill.id == null ? const Value.absent() : Value(bill.id!),
      firmId: Value(bill.firmId),
      clientFirmId:
          bill.clientFirmId != null
              ? Value(bill.clientFirmId!)
              : const Value.absent(),
      tenderId:
          bill.tenderId != null ? Value(bill.tenderId!) : const Value.absent(),
      tnNumber: Value(bill.tnNumber),
      billDate: Value(bill.billDate),
      dueDate: Value(bill.dueDate),
      amount: Value(bill.amount),
      remarks:
          bill.remarks != null ? Value(bill.remarks!) : const Value.absent(),
      invoiceAmount: Value(bill.invoiceAmount),
      billPassAmount: Value(bill.billPassAmount),
      csdAmount: Value(bill.csdAmount),
      csdReleasedDate:
          bill.csdReleasedDate != null
              ? Value(bill.csdReleasedDate!)
              : const Value.absent(),
      csdDueDate:
          bill.csdDueDate != null
              ? Value(bill.csdDueDate!)
              : const Value.absent(),
      csdStatus: Value(bill.csdStatus),
      scrapAmount: Value(bill.scrapAmount),
      scrapGstAmount: Value(bill.scrapGstAmount),
      mdLdAmount: Value(bill.mdLdAmount),
      mdLdStatus: Value(bill.mdLdStatus),
      mdLdReleasedDate:
          bill.mdLdReleasedDate != null
              ? Value(bill.mdLdReleasedDate!)
              : const Value.absent(),
      emptyOilIssued: Value(bill.emptyOilIssued),
      emptyOilReturned: Value(bill.emptyOilReturned),
      tdsAmount: Value(bill.tdsAmount),
      tcsAmount: Value(bill.tcsAmount),
      gstTdsAmount: Value(bill.gstTdsAmount),
      totalPaid: Value(bill.totalPaid),
      dueAmount: Value(bill.dueAmount),
      status: Value(bill.status),
      paidDate:
          bill.paidDate != null ? Value(bill.paidDate!) : const Value.absent(),
      transactionNo:
          bill.transactionNo != null
              ? Value(bill.transactionNo!)
              : const Value.absent(),
      dueReleaseDate:
          bill.dueReleaseDate != null
              ? Value(bill.dueReleaseDate!)
              : const Value.absent(),
      invoiceNo:
          bill.invoiceNo != null
              ? Value(bill.invoiceNo!)
              : const Value.absent(),
      invoiceDate:
          bill.invoiceDate != null
              ? Value(bill.invoiceDate!)
              : const Value.absent(),
      workOrderNo:
          bill.workOrderNo != null
              ? Value(bill.workOrderNo!)
              : const Value.absent(),
      workOrderDate:
          bill.workOrderDate != null
              ? Value(bill.workOrderDate!)
              : const Value.absent(),
      consignmentName:
          bill.consignmentName != null
              ? Value(bill.consignmentName!)
              : const Value.absent(),
      invoiceType:
          bill.invoiceType != null
              ? Value(bill.invoiceType!)
              : const Value.absent(),
      proofPath:
          bill.proofPath != null
              ? Value(bill.proofPath!)
              : const Value.absent(),
      createdAt: Value(forInsert ? now : bill.createdAt),
      updatedAt: Value(forInsert ? now : bill.updatedAt),
    );
  }

  /// Recalculate and update bill payment totals after payment changes
  Future<void> updateBillPaymentTotals(int billId) async {
    // Get all payments for this bill
    final paymentRows =
        await (_database.select(_database.payments)
          ..where((tbl) => tbl.billId.equals(billId))).get();

    final payments =
        paymentRows.map((row) {
          return Payment(
            id: row.id,
            billId: row.billId,
            paymentDate: row.paymentDate,
            amountPaid: row.amountPaid,
            proofPath: row.proofPath,
            remarks: row.remarks,
            lastEdited: row.lastEdited,
            createdAt: row.createdAt,
            paidDate: row.paidDate,
            transactionNo: row.transactionNo,
            dueReleaseDate: row.dueReleaseDate,
            invoiceNo: row.invoiceNo,
            invoiceDate: row.invoiceDate,
            workOrderNo: row.workOrderNo,
            workOrderDate: row.workOrderDate,
            consignmentName: row.consignmentName,
          );
        }).toList();

    // Get the bill
    final billRow =
        await (_database.select(_database.bills)
          ..where((tbl) => tbl.id.equals(billId))).getSingleOrNull();

    if (billRow == null) return;

    // Create a temporary Bill object for calculations
    final bill = Bill(
      id: billRow.id,
      firmId: billRow.firmId,
      tnNumber: billRow.tnNumber,
      billDate: billRow.billDate,
      dueDate: billRow.dueDate,
      amount: billRow.amount,
      status: billRow.status,
      invoiceAmount: billRow.invoiceAmount,
      tdsAmount: billRow.tdsAmount,
      tcsAmount: billRow.tcsAmount,
      gstTdsAmount: billRow.gstTdsAmount,
      scrapAmount: billRow.scrapAmount,
      scrapGstAmount: billRow.scrapGstAmount,
      mdLdAmount: billRow.mdLdAmount,
      createdAt: billRow.createdAt,
      updatedAt: billRow.updatedAt,
    );

    // Calculate new values
    final totalPaid = Bill.calculateTotalPaid(payments);
    final dueAmount = Bill.calculateDueAmount(bill, payments);
    final status = Bill.calculateStatus(bill, payments);

    // Update the bill
    await (_database.update(_database.bills)
      ..where((tbl) => tbl.id.equals(billId))).write(
      db.BillsCompanion(
        totalPaid: Value(totalPaid),
        dueAmount: Value(dueAmount),
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  double _targetAmountForBill(Bill bill) {
    if (bill.billPassAmount > 0) {
      return bill.billPassAmount;
    }
    if (bill.invoiceAmount > 0) {
      return bill.invoiceAmount;
    }
    return bill.amount;
  }
}
