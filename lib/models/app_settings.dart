/// Represents the persisted backup preferences for the app.
class AppSettings {
  const AppSettings({
    required this.autoBackupEnabled,
    required this.autoBackupIntervalDays,
    required this.lastAutoBackup,
    this.exportsDirectory,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      autoBackupEnabled: true,
      autoBackupIntervalDays: 7,
      lastAutoBackup: null,
      exportsDirectory: null,
    );
  }

  factory AppSettings.fromStorage(Map<String, String> storage) {
    final defaults = AppSettings.defaults();
    final backupEnabledValue = storage['auto_backup_enabled'];
    final backupIntervalValue = storage['auto_backup_interval_days'];
    final lastBackupValue = storage['last_auto_backup'];
    final exportsDirectoryValue = storage['exports_directory'];

    final parsedLastBackup =
        (lastBackupValue == null || lastBackupValue.isEmpty)
            ? null
            : DateTime.tryParse(lastBackupValue);

    return AppSettings(
      autoBackupEnabled:
          backupEnabledValue == null
              ? defaults.autoBackupEnabled
              : backupEnabledValue.toLowerCase() == 'true',
      autoBackupIntervalDays:
          int.tryParse(backupIntervalValue ?? '') ??
          defaults.autoBackupIntervalDays,
      lastAutoBackup: parsedLastBackup ?? defaults.lastAutoBackup,
      exportsDirectory:
          (exportsDirectoryValue == null || exportsDirectoryValue.isEmpty)
              ? null
              : exportsDirectoryValue,
    );
  }

  final bool autoBackupEnabled;
  final int autoBackupIntervalDays;
  final DateTime? lastAutoBackup;
  final String? exportsDirectory;

  AppSettings copyWith({
    bool? autoBackupEnabled,
    int? autoBackupIntervalDays,
    DateTime? lastAutoBackup,
    String? exportsDirectory,
    bool clearLastAutoBackup = false,
    bool clearExportsDirectory = false,
  }) {
    return AppSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupIntervalDays:
          autoBackupIntervalDays ?? this.autoBackupIntervalDays,
      lastAutoBackup:
          clearLastAutoBackup ? null : lastAutoBackup ?? this.lastAutoBackup,
      exportsDirectory:
          clearExportsDirectory
              ? null
              : exportsDirectory ?? this.exportsDirectory,
    );
  }

  Map<String, String> toStorage() {
    return {
      'auto_backup_enabled': autoBackupEnabled.toString(),
      'auto_backup_interval_days': autoBackupIntervalDays.toString(),
      'last_auto_backup': lastAutoBackup?.toIso8601String() ?? '',
      'exports_directory': exportsDirectory ?? '',
    };
  }
}
