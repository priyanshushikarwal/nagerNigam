import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Autosave draft manager - stores drafts ONLY in SharedPreferences (local UI storage)
/// NO database changes
class DraftManager {
  static const String _keyPrefix = 'draft_bill_';

  /// Save bill draft to local storage only
  static Future<void> saveDraft(
    String draftId,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$draftId', json.encode(data));
  }

  /// Load bill draft from local storage
  static Future<Map<String, dynamic>?> loadDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_keyPrefix$draftId');
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  /// Delete draft from local storage
  static Future<void> deleteDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$draftId');
  }

  /// List all draft IDs
  static Future<List<String>> listDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.substring(_keyPrefix.length))
        .toList();
  }
}
