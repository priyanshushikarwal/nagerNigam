import '../data/repositories/tenders_repository.dart';
import '../database/app_database.dart' as db;
import '../models/tender.dart';
import '../models/tn_bill_stats.dart';
import 'global_id_service.dart';

class TenderService {
  TenderService()
    : _tendersRepository = TnDao(_database, GlobalIdService.instance);

  static final db.AppDatabase _database = db.AppDatabase();
  final TnDao _tendersRepository;

  // Get all tenders for a firm with bill statistics
  Future<List<Tender>> getTendersByFirm(int firmId) async {
    return _tendersRepository.getTendersByFirm(firmId);
  }

  // Get live bill statistics for a tender
  Future<TNBillStats> getTenderStats(int tenderId) async {
    return _tendersRepository.getTenderStats(tenderId);
  }

  // Get a single tender by ID
  Future<Tender?> getTenderById(int id) async {
    return _tendersRepository.getTenderById(id);
  }

  // Get tender by TN number and firm
  Future<Tender?> getTenderByTnNumber(int firmId, String tnNumber) async {
    return _tendersRepository.getTenderByTnNumber(firmId, tnNumber);
  }

  // Create a new tender and return the persisted model
  Future<Tender> createTender({
    required int firmId,
    required String tnNumber,
    String? purchaseOrderNo,
    String? workDescription,
  }) async {
    return _tendersRepository.createTender(
      firmId: firmId,
      tnNumber: tnNumber,
      purchaseOrderNo: purchaseOrderNo,
      workDescription: workDescription,
    );
  }

  // Update an existing tender
  Future<int> updateTender(Tender tender) async {
    return _tendersRepository.updateTender(tender);
  }

  // Delete a tender
  Future<bool> deleteTender(int id) async {
    return _tendersRepository.deleteTender(id);
  }

  // Get all tenders for dropdown (firm_id, tn_number only)
  Future<List<Tender>> getTenderDropdownList(int firmId) async {
    return _tendersRepository.getTenderDropdownList(firmId);
  }

  // Check if TN number already exists for this firm
  Future<bool> tnNumberExists(
    int firmId,
    String tnNumber, {
    int? excludeId,
  }) async {
    return _tendersRepository.tnNumberExists(
      firmId,
      tnNumber,
      excludeId: excludeId,
    );
  }
}
