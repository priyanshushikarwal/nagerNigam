import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<AppSettings>>((ref) {
      final controller = SettingsController(ref.watch(settingsServiceProvider));
      controller.load();
      return controller;
    });

class SettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsController(this._service) : super(const AsyncValue.loading());

  final SettingsService _service;

  Future<void> load() async {
    try {
      final settings = await _service.fetchSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _applyUpdate(
      transform: (current) => current.copyWith(autoBackupEnabled: enabled),
      persist: () => _service.setAutoBackupEnabled(enabled),
    );
  }

  Future<void> setAutoBackupInterval(int days) async {
    final clamped = days < 1 ? 1 : days;
    await _applyUpdate(
      transform: (current) => current.copyWith(autoBackupIntervalDays: clamped),
      persist: () => _service.setAutoBackupIntervalDays(clamped),
    );
  }

  Future<void> recordAutoBackup(DateTime? date) async {
    await _applyUpdate(
      transform:
          (current) =>
              date == null
                  ? current.copyWith(clearLastAutoBackup: true)
                  : current.copyWith(lastAutoBackup: date),
      persist: () => _service.setLastAutoBackup(date),
    );
  }

  Future<void> setExportsDirectory(String? path) async {
    await _applyUpdate(
      transform:
          (current) =>
              path == null
                  ? current.copyWith(clearExportsDirectory: true)
                  : current.copyWith(exportsDirectory: path),
      persist: () => _service.setExportsDirectory(path),
    );
  }

  Future<void> _applyUpdate({
    required AppSettings Function(AppSettings current) transform,
    required Future<void> Function() persist,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      await load();
      return;
    }

    final previousState = state;
    final updated = transform(current);
    state = AsyncValue.data(updated);

    try {
      await persist();
    } catch (error, stackTrace) {
      state = previousState;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
