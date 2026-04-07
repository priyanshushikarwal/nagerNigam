import 'package:drift/drift.dart';

import '../../database/app_database.dart' as db;
import '../../models/tender.dart';
import '../../models/tn_bill_stats.dart';
import '../../services/global_id_service.dart';

class TnDao {
  TnDao(this._database, this._idService);

  final db.AppDatabase _database;
  final GlobalIdService _idService;

  Future<List<Tender>> getTendersByFirm(int firmId) async {
    final rows =
        await _database
            .customSelect(
              '''
      SELECT
        t.id,
        t.firm_id,
        t.tn_number,
        t.po_number,
        t.work_description,
        t.created_at,
        t.updated_at,
        f.name AS firm_name,
        COUNT(b.id) AS total_bills,
        SUM(CASE WHEN b.status = 'Paid' THEN 1 ELSE 0 END) AS paid_bills,
        SUM(CASE WHEN b.status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_bills,
        SUM(CASE WHEN b.status IN ('Pending', 'Partially Paid') THEN 1 ELSE 0 END) AS pending_bills,
        SUM(CASE WHEN b.status = 'DueSoon' THEN 1 ELSE 0 END) AS due_soon_bills
      FROM tenders t
      LEFT JOIN firms f ON f.id = t.firm_id
      LEFT JOIN bills b ON (
        b.tender_id = t.id 
        OR (b.tender_id IS NULL AND b.tn_number = t.tn_number AND b.firm_id = t.firm_id)
      )
      WHERE t.firm_id = ?
      GROUP BY t.id
      ORDER BY t.created_at DESC
      ''',
              variables: [Variable<int>(firmId)],
              readsFrom: {_database.tenders, _database.bills, _database.firms},
            )
            .get();

    return rows.map(_mapRowToTender).toList();
  }

  Future<TNBillStats> getTenderStats(int tenderId) async {
    final now = DateTime.now();
    final dueSoon = now.add(const Duration(days: 7));

    // First get the tender to know the tn_number and firm_id
    final tenderRow =
        await (_database.select(_database.tenders)
          ..where((tbl) => tbl.id.equals(tenderId))).getSingleOrNull();

    if (tenderRow == null) {
      return const TNBillStats(
        totalBills: 0,
        paidBills: 0,
        partiallyPaidBills: 0,
        overdueBills: 0,
        pendingBills: 0,
        dueSoonBills: 0,
      );
    }

    final row =
        await _database
            .customSelect(
              '''
      SELECT
        COUNT(*) AS totalBills,
        SUM(CASE WHEN b.status = 'Paid' THEN 1 ELSE 0 END) AS paidBills,
        SUM(CASE WHEN b.status = 'Partially Paid' THEN 1 ELSE 0 END) AS partiallyPaidBills,
        SUM(CASE WHEN b.due_date < ? AND b.status = 'Pending' THEN 1 ELSE 0 END) AS overdueBills,
        SUM(CASE WHEN b.status = 'Pending' THEN 1 ELSE 0 END) AS pendingBills,
        SUM(CASE WHEN b.due_date <= ? AND b.due_date >= ? AND b.status = 'Pending' THEN 1 ELSE 0 END) AS dueSoonBills
      FROM bills b
      WHERE (b.tender_id = ? OR (b.tender_id IS NULL AND b.tn_number = ? AND b.firm_id = ?))
      ''',
              variables: [
                Variable<DateTime>(now),
                Variable<DateTime>(dueSoon),
                Variable<DateTime>(now),
                Variable<int>(tenderId),
                Variable<String>(tenderRow.tnNumber),
                Variable<int>(tenderRow.firmId),
              ],
              readsFrom: {_database.bills, _database.tenders},
            )
            .getSingle();

    final data = row.data;
    return TNBillStats(
      totalBills: _readInt(data, 'totalBills'),
      paidBills: _readInt(data, 'paidBills'),
      partiallyPaidBills: _readInt(data, 'partiallyPaidBills'),
      overdueBills: _readInt(data, 'overdueBills'),
      pendingBills: _readInt(data, 'pendingBills'),
      dueSoonBills: _readInt(data, 'dueSoonBills'),
    );
  }

  Future<Tender?> getTenderById(int id) async {
    final result =
        await (_database.select(_database.tenders)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (result == null) return null;
    return Tender(
      id: result.id,
      firmId: result.firmId,
      tnNumber: result.tnNumber,
      poNumber: result.poNumber,
      workDescription: result.workDescription,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
  }

  Future<Tender?> getTenderByTnNumber(int firmId, String tnNumber) async {
    final result =
        await (_database.select(_database.tenders)..where(
          (tbl) => tbl.firmId.equals(firmId) & tbl.tnNumber.equals(tnNumber),
        )).getSingleOrNull();
    if (result == null) return null;
    return Tender(
      id: result.id,
      firmId: result.firmId,
      tnNumber: result.tnNumber,
      poNumber: result.poNumber,
      workDescription: result.workDescription,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
  }

  Future<Tender> createTender({
    required int firmId,
    required String tnNumber,
    String? purchaseOrderNo,
    String? workDescription,
  }) async {
    final now = DateTime.now();
    final id = await _idService.nextId();
    final inserted = await _database
        .into(_database.tenders)
        .insertReturning(
          db.TendersCompanion.insert(
            id: Value(id),
            firmId: firmId,
            tnNumber: tnNumber,
            poNumber: Value(purchaseOrderNo),
            workDescription: Value(workDescription),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return Tender(
      id: inserted.id,
      firmId: inserted.firmId,
      tnNumber: inserted.tnNumber,
      poNumber: inserted.poNumber,
      workDescription: inserted.workDescription,
      createdAt: inserted.createdAt,
      updatedAt: inserted.updatedAt,
    );
  }

  Future<int> updateTender(Tender tender) async {
    if (tender.id == null) {
      throw ArgumentError('Cannot update a tender without an id');
    }

    final companion = db.TendersCompanion(
      tnNumber: Value(tender.tnNumber),
      poNumber: Value(tender.poNumber),
      workDescription: Value(tender.workDescription),
      updatedAt: Value(DateTime.now()),
    );

    return (_database.update(_database.tenders)
      ..where((tbl) => tbl.id.equals(tender.id!))).write(companion);
  }

  /// Delete a tender and unlink any associated bills
  /// Returns true if the tender was successfully deleted
  Future<bool> deleteTender(int id) async {
    // Verify the tender exists first
    final tenderExists =
        await (_database.select(_database.tenders)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (tenderExists == null) {
      return false;
    }

    // Unlink bills from this tender (set tender_id to null)
    await (_database.update(_database.bills)..where(
      (tbl) => tbl.tenderId.equals(id),
    )).write(const db.BillsCompanion(tenderId: Value<int?>(null)));

    // Delete the tender
    final deletedCount =
        await (_database.delete(_database.tenders)
          ..where((tbl) => tbl.id.equals(id))).go();

    return deletedCount > 0;
  }

  Future<bool> tnNumberExists(
    int firmId,
    String tnNumber, {
    int? excludeId,
  }) async {
    final query = (_database.select(_database.tenders)..where(
      (tbl) => tbl.firmId.equals(firmId) & tbl.tnNumber.equals(tnNumber),
    ));

    if (excludeId != null) {
      query.where((tbl) => tbl.id.isNotValue(excludeId));
    }

    final row = await query.getSingleOrNull();
    return row != null;
  }

  Future<List<Tender>> getTenderDropdownList(int firmId) async {
    final rows =
        await (_database.select(_database.tenders)
              ..where((tbl) => tbl.firmId.equals(firmId))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.tnNumber)]))
            .get();

    return rows
        .map(
          (row) => Tender(
            id: row.id,
            firmId: row.firmId,
            tnNumber: row.tnNumber,
            poNumber: row.poNumber,
            workDescription: row.workDescription,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  Tender _mapRowToTender(QueryRow row) {
    final data = row.data;
    return Tender(
      id: row.read<int>('id'),
      firmId: row.read<int>('firm_id'),
      tnNumber: row.read<String>('tn_number'),
      poNumber: row.readNullable<String>('po_number'),
      workDescription: row.readNullable<String>('work_description'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
      firmName: data['firm_name'] as String?,
      totalBills: _readInt(data, 'total_bills'),
      paidBills: _readInt(data, 'paid_bills'),
      pendingBills: _readInt(data, 'pending_bills'),
      overdueBills: _readInt(data, 'overdue_bills'),
    );
  }

  int _readInt(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
