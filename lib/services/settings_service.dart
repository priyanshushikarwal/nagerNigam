import '../core/app_logger.dart';
import '../models/app_settings.dart';
import 'database_service.dart';

/// Encapsulates persistence of user-configurable application settings.
class SettingsService {
  SettingsService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;
  final AppLogger _logger = AppLogger.instance;

  Future<AppSettings> fetchSettings() async {
    try {
      final rows = await _databaseService.query('settings');
      final storage = <String, String>{};

      for (final row in rows) {
        final key = row['key'] as String?;
        final value = row['value'] as String?;
        if (key != null && value != null) {
          storage[key] = value;
        }
      }

      return AppSettings.fromStorage(storage);
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to fetch application settings',
        operation: 'settings:fetch',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _save('auto_backup_enabled', enabled.toString());
  }

  Future<void> setAutoBackupIntervalDays(int days) async {
    await _save('auto_backup_interval_days', days.toString());
  }

  Future<void> setLastAutoBackup(DateTime? date) async {
    await _save('last_auto_backup', date?.toIso8601String() ?? '');
  }

  Future<void> setExportsDirectory(String? path) async {
    await _save('exports_directory', path ?? '');
  }

  Future<void> _save(String key, String value) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _databaseService.rawExecute(
        'INSERT OR REPLACE INTO settings (key, value, updated_at) VALUES (?, ?, ?)',
        [key, value, timestamp],
      );
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to persist setting $key',
        operation: 'settings:save',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
