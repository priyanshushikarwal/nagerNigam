import 'package:drift/drift.dart';

import '../../database/app_database.dart' as db;
import '../models/client_firm.dart';

class ClientFirmsDao {
  ClientFirmsDao(this._database);

  final db.AppDatabase _database;

  // Get all client firms
  Future<List<ClientFirm>> getAllClientFirms() async {
    final rows = await _database.select(_database.clientFirms).get();
    return rows
        .map(
          (row) => ClientFirm(
            id: row.id,
            firmName: row.firmName,
            address: row.address,
            contactNo: row.contactNo,
            gstNo: row.gstNo,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  // Get client firm by ID
  Future<ClientFirm?> getClientFirmById(int id) async {
    final row =
        await (_database.select(_database.clientFirms)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    return ClientFirm(
      id: row.id,
      firmName: row.firmName,
      address: row.address,
      contactNo: row.contactNo,
      gstNo: row.gstNo,
      createdAt: row.createdAt,
    );
  }

  // Insert new client firm
  Future<int> insertClientFirm(ClientFirm firm) async {
    return await _database
        .into(_database.clientFirms)
        .insert(
          db.ClientFirmsCompanion.insert(
            firmName: firm.firmName,
            address: Value(firm.address),
            contactNo: Value(firm.contactNo),
            gstNo: Value(firm.gstNo),
          ),
        );
  }

  // Update existing client firm
  Future<bool> updateClientFirm(ClientFirm firm) async {
    if (firm.id == null) return false;

    final updated = await (_database.update(_database.clientFirms)
      ..where((tbl) => tbl.id.equals(firm.id!))).write(
      db.ClientFirmsCompanion(
        firmName: Value(firm.firmName),
        address: Value(firm.address),
        contactNo: Value(firm.contactNo),
        gstNo: Value(firm.gstNo),
      ),
    );

    return updated > 0;
  }

  // Delete client firm
  Future<int> deleteClientFirm(int id) async {
    return await (_database.delete(_database.clientFirms)
      ..where((tbl) => tbl.id.equals(id))).go();
  }

  // Check if client firm has associated bills
  Future<bool> clientFirmHasData(int firmId) async {
    final billCount = await (_database.select(_database.bills)..where(
      (tbl) => tbl.clientFirmId.equals(firmId),
    )).get().then((rows) => rows.length);

    return billCount > 0;
  }
}
