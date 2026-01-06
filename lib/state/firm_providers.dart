import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bill.dart';
import 'database_providers.dart';

/// Notifier that persists the selected firm across app restarts
class SelectedFirmNotifier extends StateNotifier<Firm?> {
  static const String _keyFirmId = 'selected_firm_id';
  static const String _keyFirmName = 'selected_firm_name';
  static const String _keyFirmCode = 'selected_firm_code';

  SelectedFirmNotifier() : super(null) {
    _restoreFirm();
  }

  Future<void> _restoreFirm() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firmId = prefs.getInt(_keyFirmId);
      final firmName = prefs.getString(_keyFirmName);
      final firmCode = prefs.getString(_keyFirmCode);

      if (firmId != null && firmName != null && firmCode != null) {
        state = Firm(
          id: firmId,
          name: firmName,
          code: firmCode,
          createdAt: DateTime.now(), // Placeholder, actual value from DB
        );
      }
    } catch (e) {
      // Ignore errors during restoration
    }
  }

  Future<void> setFirm(Firm? firm) async {
    state = firm;
    final prefs = await SharedPreferences.getInstance();

    if (firm != null) {
      await prefs.setInt(_keyFirmId, firm.id!);
      await prefs.setString(_keyFirmName, firm.name);
      await prefs.setString(_keyFirmCode, firm.code);
    } else {
      await prefs.remove(_keyFirmId);
      await prefs.remove(_keyFirmName);
      await prefs.remove(_keyFirmCode);
    }
  }
}

/// Holds the currently selected firm throughout the app.
final selectedFirmProvider = StateNotifierProvider<SelectedFirmNotifier, Firm?>(
  (ref) => SelectedFirmNotifier(),
);

/// Convenience provider that exposes the selected firm's id.
final selectedFirmIdProvider = Provider<int?>((ref) {
  final firm = ref.watch(selectedFirmProvider);
  return firm?.id;
});

/// Fetches all firms from the database
final allFirmsProvider = FutureProvider<List<Firm>>((ref) async {
  final firmsDao = ref.watch(firmsDaoProvider);
  return await firmsDao.getAllFirms();
});

/// Fetches supplier firms only (for bill assignment)
final supplierFirmsProvider = FutureProvider<List<Firm>>((ref) async {
  final firmsDao = ref.watch(firmsDaoProvider);
  return await firmsDao.getSupplierFirms();
});

/// Fetches DISCOM firms only (utilities)
final discomFirmsProvider = FutureProvider<List<Firm>>((ref) async {
  final firmsDao = ref.watch(firmsDaoProvider);
  return await firmsDao.getDiscomFirms();
});
