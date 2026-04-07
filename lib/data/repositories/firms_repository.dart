import 'package:drift/drift.dart';

import '../../database/app_database.dart' as db;
import '../../models/bill.dart';
import '../../services/global_id_service.dart';

class FirmsDao {
  final db.AppDatabase _database;
  final GlobalIdService _idService;

  FirmsDao(this._database, this._idService);

  /// Get all firms
  Future<List<Firm>> getAllFirms() async {
    final rows = await _database.select(_database.firms).get();
    return rows.map(_mapFirm).toList();
  }

  /// Get a single firm by ID
  Future<Firm?> getFirmById(int id) async {
    final row =
        await (_database.select(_database.firms)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    return row != null ? _mapFirm(row) : null;
  }

  /// Get firms by type (supplier or DISCOM)
  /// Suppliers have longer names, DISCOMs are short codes
  Future<List<Firm>> getSupplierFirms() async {
    final rows =
        await (_database.select(_database.firms)
          ..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    // Filter suppliers (longer names) in code
    return rows.where((row) => row.name.length > 10).map(_mapFirm).toList();
  }

  /// Get DISCOM firms (utilities)
  Future<List<Firm>> getDiscomFirms() async {
    final rows =
        await (_database.select(_database.firms)
          ..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    // Filter DISCOMs (shorter names) in code
    return rows.where((row) => row.name.length <= 10).map(_mapFirm).toList();
  }

  /// Insert a new firm
  Future<int> insertFirm({
    required String name,
    required String code,
    String? description,
    String? address,
    String? contactNo,
    String? gstNo,
  }) async {
    final id = await _idService.nextId();
    return await _database
        .into(_database.firms)
        .insert(
          db.FirmsCompanion.insert(
            id: Value(id),
            name: name,
            code: code,
            description: Value(description),
            address: Value(address),
            contactNo: Value(contactNo),
            gstNo: Value(gstNo),
          ),
        );
  }

  /// Update an existing firm
  Future<bool> updateFirm({
    required int id,
    required String name,
    required String code,
    String? description,
    String? address,
    String? contactNo,
    String? gstNo,
  }) async {
    final result = await (_database.update(_database.firms)
      ..where((tbl) => tbl.id.equals(id))).write(
      db.FirmsCompanion(
        name: Value(name),
        code: Value(code),
        description: Value(description),
        address: Value(address),
        contactNo: Value(contactNo),
        gstNo: Value(gstNo),
      ),
    );
    return result > 0;
  }

  /// Delete a firm
  /// Note: This will cascade delete all related tenders, bills, and payments
  Future<bool> deleteFirm(int id) async {
    final result =
        await (_database.delete(_database.firms)
          ..where((tbl) => tbl.id.equals(id))).go();
    return result > 0;
  }

  /// Check if a firm has any tenders/bills
  Future<bool> firmHasData(int id) async {
    final query =
        _database.selectOnly(_database.tenders)
          ..addColumns([_database.tenders.id.count()])
          ..where(_database.tenders.firmId.equals(id));

    final result = await query.getSingle();
    final count = result.read(_database.tenders.id.count());

    return (count ?? 0) > 0;
  }

  /// Map database row to Firm model
  Firm _mapFirm(db.Firm row) {
    return Firm(
      id: row.id,
      name: row.name,
      code: row.code,
      description: row.description,
      address: row.address,
      contactNo: row.contactNo,
      gstNo: row.gstNo,
      createdAt: row.createdAt,
    );
  }
}
