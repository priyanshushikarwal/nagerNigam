import '../data/repositories/bills_repository.dart';
import '../database/app_database.dart' as db;
import '../models/bill.dart';
import 'global_id_service.dart';

class BillService {
  BillService() : _repository = BillsDao(_database, GlobalIdService.instance);

  static final db.AppDatabase _database = db.AppDatabase();
  final BillsDao _repository;

  // Get all bills for a firm
  Future<List<Bill>> getBillsByFirm(int firmId) async {
    return _repository.getBillsByFirm(firmId);
  }

  // Get all bills linked to a specific tender (TN)
  Future<List<Bill>> getBillsByTender(int tenderId) async {
    return _repository.getBillsByTender(tenderId);
  }

  // Get dashboard stats
  Future<DashboardStats> getDashboardStats(int firmId) async {
    return _repository.getDashboardStats(firmId);
  }

  // Create bill
  Future<int> createBill(Bill bill) async {
    return _repository.addBill(bill);
  }

  // Update bill
  Future<int> updateBill(Bill bill) async {
    return _repository.updateBill(bill);
  }

  // Delete bill
  Future<bool> deleteBill(int id) async {
    return _repository.deleteBill(id);
  }

  // Search bills
  Future<List<Bill>> searchBills(int firmId, String query) async {
    return _repository.searchBills(firmId, query);
  }
}
