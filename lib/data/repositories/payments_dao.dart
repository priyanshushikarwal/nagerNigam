import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/app_database.dart' as db;
import '../../models/bill.dart';
import '../../models/payment_record.dart';
import '../../services/global_id_service.dart';
import 'bills_repository.dart';

class PaymentsDao {
  PaymentsDao(this._database, this._billsDao, this._idService);

  final db.AppDatabase _database;
  final BillsDao _billsDao;
  final GlobalIdService _idService;

  Future<List<Payment>> getPaymentsByBill(int billId) async {
    final rows =
        await (_database.select(_database.payments)
              ..where((tbl) => tbl.billId.equals(billId))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.paymentDate)]))
            .get();

    return rows.map(_mapPayment).toList();
  }

  Future<Payment?> getPaymentById(int paymentId) async {
    final row =
        await (_database.select(_database.payments)
          ..where((tbl) => tbl.id.equals(paymentId))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapPayment(row);
  }

  Future<List<FirmPaymentRecord>> getPaymentsForFirm(int firmId) async {
    final rows =
        await _database
            .customSelect(
              '''
          SELECT
            p.id,
            p.bill_id,
            p.payment_date,
            p.amount_paid,
            p.paid_date,
            p.transaction_no,
            p.due_release_date,
            p.invoice_no,
            p.invoice_date,
            p.work_order_no,
            p.work_order_date,
            p.consignment_name,
            p.proof_path,
            p.remarks,
            p.last_edited,
            p.created_at,
            b.tn_number,
            b.amount AS bill_amount,
            b.invoice_amount,
            b.bill_pass_amount,
            b.bill_date,
            b.due_date,
            b.csd_amount,
            b.tds_amount,
            b.gst_tds_amount,
            b.tcs_amount,
            b.scrap_amount,
            b.scrap_gst_amount,
            b.md_ld_amount
          FROM payments p
          INNER JOIN bills b ON b.id = p.bill_id
          WHERE b.firm_id = ?
          ORDER BY p.payment_date DESC, p.id DESC
        ''',
              variables: [Variable<int>(firmId)],
              readsFrom: {_database.payments, _database.bills},
            )
            .get();

    if (rows.isEmpty) {
      return const [];
    }

    return rows.map((row) {
      final payment = Payment(
        id: row.read<int>('id'),
        billId: row.read<int>('bill_id'),
        paymentDate: row.read<DateTime>('payment_date'),
        amountPaid: row.read<double>('amount_paid'),
        proofPath: row.readNullable<String>('proof_path'),
        remarks: row.readNullable<String>('remarks'),
        lastEdited: row.read<DateTime>('last_edited'),
        createdAt: row.read<DateTime>('created_at'),
        paidDate: row.readNullable<DateTime>('paid_date'),
        transactionNo: row.readNullable<String>('transaction_no'),
        dueReleaseDate: row.readNullable<DateTime>('due_release_date'),
        invoiceNo: row.readNullable<String>('invoice_no'),
        invoiceDate: row.readNullable<DateTime>('invoice_date'),
        workOrderNo: row.readNullable<String>('work_order_no'),
        workOrderDate: row.readNullable<DateTime>('work_order_date'),
        consignmentName: row.readNullable<String>('consignment_name'),
      );

      return FirmPaymentRecord(
        payment: payment,
        billId: payment.billId,
        tnNumber: row.read<String>('tn_number'),
        billAmount: row.read<double>('bill_amount'),
        invoiceAmount: row.read<double?>('invoice_amount') ?? 0,
        billPassAmount: row.read<double?>('bill_pass_amount') ?? 0,
        billDate: row.read<DateTime>('bill_date'),
        dueDate: row.read<DateTime>('due_date'),
        csdAmount: row.read<double?>('csd_amount') ?? 0,
        tdsAmount: row.read<double?>('tds_amount') ?? 0,
        gstTdsAmount: row.read<double?>('gst_tds_amount') ?? 0,
        tcsAmount: row.read<double?>('tcs_amount') ?? 0,
        scrapAmount: row.read<double?>('scrap_amount') ?? 0,
        scrapGstAmount: row.read<double?>('scrap_gst_amount') ?? 0,
        mdLdAmount: row.read<double?>('md_ld_amount') ?? 0,
      );
    }).toList();
  }

  Future<int> addPayment({
    required Payment payment,
    String? proofSourcePath,
  }) async {
    final id = await _idService.nextId();
    final proofPath =
        proofSourcePath != null
            ? await _persistProofFile(payment.billId, proofSourcePath)
            : payment.proofPath;

    final companion = db.PaymentsCompanion.insert(
      id: Value(id),
      billId: payment.billId,
      paymentDate: payment.paymentDate,
      amountPaid: Value(payment.amountPaid),
      paidDate: Value(payment.paidDate),
      transactionNo: Value(payment.transactionNo),
      dueReleaseDate: Value(payment.dueReleaseDate),
      invoiceNo: Value(payment.invoiceNo),
      invoiceDate: Value(payment.invoiceDate),
      workOrderNo: Value(payment.workOrderNo),
      workOrderDate: Value(payment.workOrderDate),
      consignmentName: Value(payment.consignmentName),
      proofPath: proofPath != null ? Value(proofPath) : const Value.absent(),
      remarks: Value(payment.remarks),
      lastEdited: Value(DateTime.now()),
      createdAt: Value(payment.createdAt),
    );

    final id = await _database.into(_database.payments).insert(companion);

    // Update bill payment totals
    await _billsDao.updateBillPaymentTotals(payment.billId);

    return id;
  }

  Future<void> updatePayment({
    required Payment payment,
    String? proofSourcePath,
  }) async {
    if (payment.id == null) {
      throw ArgumentError('Cannot update a payment without an id');
    }

    final existing =
        await (_database.select(_database.payments)
          ..where((tbl) => tbl.id.equals(payment.id!))).getSingle();

    String? resolvedProofPath = payment.proofPath;
    if (proofSourcePath != null) {
      resolvedProofPath = await _persistProofFile(
        payment.billId,
        proofSourcePath,
      );

      if (existing.proofPath != null &&
          existing.proofPath != resolvedProofPath) {
        final oldFile = File(existing.proofPath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
    }

    final companion = db.PaymentsCompanion(
      paymentDate: Value(payment.paymentDate),
      amountPaid: Value(payment.amountPaid),
      paidDate:
          payment.paidDate != null
              ? Value(payment.paidDate!)
              : const Value.absent(),
      transactionNo:
          payment.transactionNo != null
              ? Value(payment.transactionNo!)
              : const Value.absent(),
      dueReleaseDate:
          payment.dueReleaseDate != null
              ? Value(payment.dueReleaseDate!)
              : const Value.absent(),
      invoiceNo:
          payment.invoiceNo != null
              ? Value(payment.invoiceNo!)
              : const Value.absent(),
      invoiceDate:
          payment.invoiceDate != null
              ? Value(payment.invoiceDate!)
              : const Value.absent(),
      workOrderNo:
          payment.workOrderNo != null
              ? Value(payment.workOrderNo!)
              : const Value.absent(),
      workOrderDate:
          payment.workOrderDate != null
              ? Value(payment.workOrderDate!)
              : const Value.absent(),
      consignmentName:
          payment.consignmentName != null
              ? Value(payment.consignmentName!)
              : const Value.absent(),
      proofPath:
          resolvedProofPath != null
              ? Value(resolvedProofPath)
              : const Value.absent(),
      remarks:
          payment.remarks != null
              ? Value(payment.remarks!)
              : const Value.absent(),
      lastEdited: Value(DateTime.now()),
    );

    await (_database.update(_database.payments)
      ..where((tbl) => tbl.id.equals(payment.id!))).write(companion);

    // Update bill payment totals
    await _billsDao.updateBillPaymentTotals(payment.billId);
  }

  Future<void> deletePayment(int paymentId) async {
    final row =
        await (_database.select(_database.payments)
          ..where((tbl) => tbl.id.equals(paymentId))).getSingleOrNull();

    if (row == null) {
      return;
    }

    if (row.proofPath != null) {
      final file = File(row.proofPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final billId = row.billId;
    final isCsdPayment = (row.remarks ?? '').trim().toLowerCase() == 'csd received';

    await (_database.delete(_database.payments)
      ..where((tbl) => tbl.id.equals(paymentId))).go();

    if (isCsdPayment) {
      await _billsDao.clearCsdReleaseState(billId);
    }

    // Update bill payment totals
    await _billsDao.updateBillPaymentTotals(billId);
  }

  Future<void> setPaymentProofPath(int paymentId, String? proofPath) async {
    await (_database.update(_database.payments)
      ..where((tbl) => tbl.id.equals(paymentId))).write(
      db.PaymentsCompanion(
        proofPath:
            proofPath != null ? Value(proofPath) : const Value.absent(),
        lastEdited: Value(DateTime.now()),
      ),
    );
  }

  Future<String> _persistProofFile(int billId, String sourcePath) async {
    final envPath = Platform.environment['APPDATA'];
    Directory baseDir;

    if (envPath != null && envPath.isNotEmpty) {
      baseDir = Directory(
        p.join(envPath, 'DISCOMBillManager', 'files', '$billId'),
      );
    } else {
      final supportDir = await getApplicationSupportDirectory();
      baseDir = Directory(
        p.join(supportDir.path, 'DISCOMBillManager', 'files', '$billId'),
      );
    }

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final baseName = p.basename(sourcePath);
    final destination = p.join(baseDir.path, '${timestamp}_$baseName');

    await File(sourcePath).copy(destination);
    return destination;
  }

  Payment _mapPayment(db.Payment row) {
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
  }
}
