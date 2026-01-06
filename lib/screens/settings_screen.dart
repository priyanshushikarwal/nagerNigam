import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/app_settings.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../state/settings_providers.dart';
import '../widgets/cloud_sync_settings.dart';
import '../widgets/update_available_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoBackupBusy = false;
  bool _intervalBusy = false;
  bool _lastBackupBusy = false;
  bool _passwordBusy = false;
  bool _exportsDirectoryBusy = false;

  final updateService = UpdateService(
    versionJsonUrl:
        "https://raw.githubusercontent.com/priyanshushikarwal/discom_bill_manager_updates/main/version.json",
  );

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final DateFormat _dateFormat = DateFormat.yMMMEd().add_jm();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showInfoBar(String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder:
          (context, close) => InfoBar(
            title: const Text('Settings'),
            content: Text(message),
            severity: severity,
            onClose: close,
          ),
    );
  }

  Future<void> _handleChangePassword() async {
    if (_passwordBusy) return;

    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      _showInfoBar(
        'Please fill in all password fields.',
        InfoBarSeverity.warning,
      );
      return;
    }

    if (next != confirm) {
      _showInfoBar(
        'New password and confirmation do not match.',
        InfoBarSeverity.warning,
      );
      return;
    }

    if (next.length < 8) {
      _showInfoBar(
        'Password must be at least 8 characters long.',
        InfoBarSeverity.warning,
      );
      return;
    }

    setState(() => _passwordBusy = true);

    try {
      final notifier = ref.read(authProvider.notifier);
      final success = await notifier.changePassword(current, next);

      if (success) {
        _showInfoBar('Password updated successfully.', InfoBarSeverity.success);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        if (mounted) {
          FocusScope.of(context).unfocus();
        }
      } else {
        _showInfoBar('Current password is incorrect.', InfoBarSeverity.error);
      }
    } catch (error) {
      _showInfoBar('Unable to change password: $error', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _passwordBusy = false);
      }
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    setState(() => _autoBackupBusy = true);
    final controller = ref.read(settingsControllerProvider.notifier);
    try {
      await controller.setAutoBackupEnabled(value);
      _showInfoBar('Auto backup preference saved.', InfoBarSeverity.success);
    } catch (error) {
      _showInfoBar(
        'Failed to update auto backup: $error',
        InfoBarSeverity.error,
      );
    } finally {
      if (mounted) {
        setState(() => _autoBackupBusy = false);
      }
    }
  }

  Future<void> _updateInterval(int days) async {
    setState(() => _intervalBusy = true);
    final controller = ref.read(settingsControllerProvider.notifier);
    try {
      await controller.setAutoBackupInterval(days);
      _showInfoBar('Auto backup interval updated.', InfoBarSeverity.success);
    } catch (error) {
      _showInfoBar('Failed to update interval: $error', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _intervalBusy = false);
      }
    }
  }

  Future<void> _recordLastBackup(DateTime? date) async {
    setState(() => _lastBackupBusy = true);
    final controller = ref.read(settingsControllerProvider.notifier);
    try {
      await controller.recordAutoBackup(date);
      _showInfoBar('Last backup timestamp updated.', InfoBarSeverity.success);
    } catch (error) {
      _showInfoBar('Failed to update timestamp: $error', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _lastBackupBusy = false);
      }
    }
  }

  Future<void> _pickExportsDirectory() async {
    if (_exportsDirectoryBusy) return;

    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Exports Folder',
    );

    if (result == null) return;

    // Verify the directory exists
    final dir = Directory(result);
    if (!await dir.exists()) {
      _showInfoBar('Selected directory does not exist.', InfoBarSeverity.error);
      return;
    }

    setState(() => _exportsDirectoryBusy = true);
    final controller = ref.read(settingsControllerProvider.notifier);
    try {
      await controller.setExportsDirectory(result);
      _showInfoBar(
        'Exports directory updated successfully.',
        InfoBarSeverity.success,
      );
    } catch (error) {
      _showInfoBar(
        'Failed to update exports directory: $error',
        InfoBarSeverity.error,
      );
    } finally {
      if (mounted) {
        setState(() => _exportsDirectoryBusy = false);
      }
    }
  }

  Future<void> _clearExportsDirectory() async {
    if (_exportsDirectoryBusy) return;

    setState(() => _exportsDirectoryBusy = true);
    final controller = ref.read(settingsControllerProvider.notifier);
    try {
      await controller.setExportsDirectory(null);
      _showInfoBar(
        'Exports directory reset to default.',
        InfoBarSeverity.success,
      );
    } catch (error) {
      _showInfoBar(
        'Failed to reset exports directory: $error',
        InfoBarSeverity.error,
      );
    } finally {
      if (mounted) {
        setState(() => _exportsDirectoryBusy = false);
      }
    }
  }

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return ContentDialog(
            title: const Text("Checking for Updates"),
            content: Container(
              height: 80,
              alignment: Alignment.center,
              child: const ProgressRing(),
            ),
          );
        },
      );

      final remote = await updateService.fetchRemoteVersion();
      final local = await updateService.getLocalVersion();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (remote == null) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return ContentDialog(
                title: const Text("Update Check Failed"),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Could not fetch update information. Please check:",
                      ),
                      const SizedBox(height: 12),
                      const Text("• Internet connection"),
                      const Text("• GitHub repository is accessible"),
                      const Text("• version.json file exists"),
                      const SizedBox(height: 16),
                      Text(
                        "URL: ${updateService.versionJsonUrl}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  FilledButton(
                    child: const Text("OK"),
                    onPressed:
                        () =>
                            Navigator.of(
                              dialogContext,
                              rootNavigator: true,
                            ).pop(),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      if (updateService.isRemoteGreater(local, remote.version)) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return UpdateAvailableDialog(updateInfo: remote);
            },
          );
        }
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return ContentDialog(
                title: const Text("Up to Date"),
                content: SizedBox(
                  width: 300,
                  child: Text("You have the latest version ($local)."),
                ),
                actions: [
                  FilledButton(
                    child: const Text("OK"),
                    onPressed:
                        () =>
                            Navigator.of(
                              dialogContext,
                              rootNavigator: true,
                            ).pop(),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return ContentDialog(
              title: const Text("Error"),
              content: SizedBox(
                width: 300,
                child: Text("Update check failed: $e"),
              ),
              actions: [
                FilledButton(
                  child: const Text("OK"),
                  onPressed:
                      () =>
                          Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Widget _buildChangePasswordSection(AuthState authState) {
    final theme = FluentTheme.of(context);
    final fieldsDisabled = _passwordBusy || !authState.isAuthenticated;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Security', style: theme.typography.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Update the password for ${authState.username ?? 'your account'}. Passwords must contain at least 8 characters.',
              style: theme.typography.caption,
            ),
            const SizedBox(height: 16),
            if (!authState.isAuthenticated)
              const InfoBar(
                title: Text('Not signed in'),
                content: Text('Log in again to change your password.'),
                severity: InfoBarSeverity.warning,
              )
            else ...[
              InfoLabel(
                label: 'Current password',
                child: PasswordBox(
                  controller: _currentPasswordController,
                  placeholder: 'Enter current password',
                  enabled: !fieldsDisabled,
                  revealMode: PasswordRevealMode.peek,
                ),
              ),
              const SizedBox(height: 16),
              InfoLabel(
                label: 'New password',
                child: PasswordBox(
                  controller: _newPasswordController,
                  placeholder: 'Enter new password',
                  enabled: !fieldsDisabled,
                  revealMode: PasswordRevealMode.peek,
                ),
              ),
              const SizedBox(height: 16),
              InfoLabel(
                label: 'Confirm new password',
                child: PasswordBox(
                  controller: _confirmPasswordController,
                  placeholder: 'Re-enter new password',
                  enabled: !fieldsDisabled,
                  revealMode: PasswordRevealMode.peek,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: fieldsDisabled ? null : _handleChangePassword,
                    child:
                        _passwordBusy
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: ProgressRing(strokeWidth: 3),
                            )
                            : const Text('Update Password'),
                  ),
                  Button(
                    onPressed:
                        _passwordBusy
                            ? null
                            : () {
                              _currentPasswordController.clear();
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();
                            },
                    child: const Text('Clear Fields'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection(AppSettings settings) {
    final lastBackup = settings.lastAutoBackup;
    final lastBackupText =
        lastBackup == null
            ? 'Never recorded'
            : _dateFormat.format(lastBackup.toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backups',
              style: FluentTheme.of(context).typography.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Configure automatic backup behaviour.',
              style: FluentTheme.of(context).typography.caption,
            ),
            const SizedBox(height: 16),
            InfoLabel(
              label: 'Enable automatic backups',
              child: ToggleSwitch(
                checked: settings.autoBackupEnabled,
                onChanged: _autoBackupBusy ? null : _toggleAutoBackup,
              ),
            ),
            if (_autoBackupBusy) ...[
              const SizedBox(height: 12),
              const ProgressRing(),
            ],
            const SizedBox(height: 24),
            InfoLabel(
              label: 'Backup interval (days)',
              child: NumberBox<int>(
                value: settings.autoBackupIntervalDays,
                min: 1,
                max: 90,
                mode: SpinButtonPlacementMode.inline,
                onChanged:
                    _intervalBusy
                        ? null
                        : (value) {
                          if (value != null) {
                            _updateInterval(value);
                          }
                        },
              ),
            ),
            if (_intervalBusy) ...[
              const SizedBox(height: 12),
              const ProgressRing(),
            ],
            const SizedBox(height: 24),
            InfoLabel(
              label: 'Last automatic backup',
              child: Text(lastBackupText),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed:
                      _lastBackupBusy
                          ? null
                          : () => _recordLastBackup(DateTime.now()),
                  child:
                      _lastBackupBusy
                          ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: ProgressRing(),
                          )
                          : const Text('Record Now'),
                ),
                Button(
                  onPressed:
                      (_lastBackupBusy || lastBackup == null)
                          ? null
                          : () => _recordLastBackup(null),
                  child: const Text('Clear Timestamp'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportsSection(AppSettings settings) {
    final exportsPath = settings.exportsDirectory;
    final displayPath =
        exportsPath ?? 'Default (AppData\\DISCOMBillManager\\exports)';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export & PDF Storage',
              style: FluentTheme.of(context).typography.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose where generated PDFs and exported files will be saved.',
              style: FluentTheme.of(context).typography.caption,
            ),
            const SizedBox(height: 16),
            InfoLabel(
              label: 'Exports Directory',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      FluentIcons.folder_open,
                      size: 16,
                      color: FluentTheme.of(context).typography.body?.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayPath,
                        style: FluentTheme.of(context).typography.body,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_exportsDirectoryBusy) ...[
              const SizedBox(height: 12),
              const ProgressRing(),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed:
                      _exportsDirectoryBusy ? null : _pickExportsDirectory,
                  child:
                      _exportsDirectoryBusy
                          ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: ProgressRing(),
                          )
                          : const Text('Choose Folder'),
                ),
                Button(
                  onPressed:
                      (_exportsDirectoryBusy || exportsPath == null)
                          ? null
                          : _clearExportsDirectory,
                  child: const Text('Reset to Default'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final authState = ref.watch(authProvider);

    return ScaffoldPage(
      padding: const EdgeInsets.all(24),
      content: settingsAsync.when(
        data:
            (settings) => ListView(
              children: [
                Text(
                  'Application Settings',
                  textAlign: TextAlign.center,
                  style: FluentTheme.of(context).typography.title,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage backup automation, keep account credentials secure, and perform maintenance tasks.',
                  textAlign: TextAlign.center,
                  style: FluentTheme.of(context).typography.caption,
                ),
                const SizedBox(height: 24),
                _buildChangePasswordSection(authState),
                const SizedBox(height: 24),
                _buildBackupSection(settings),
                const SizedBox(height: 24),
                _buildExportsSection(settings),
                const SizedBox(height: 24),
                const CloudSyncSettings(),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer Tools',
                          style: FluentTheme.of(context).typography.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tools for testing and debugging the application.',
                          style: FluentTheme.of(context).typography.caption,
                        ),
                        const SizedBox(height: 16),
                        const InfoBar(
                          title: Text('⚠️ Use with Caution'),
                          content: Text(
                            'These tools can generate large amounts of test data. '
                            'Only use in development/testing environments.',
                          ),
                          severity: InfoBarSeverity.warning,
                        ),
                        const SizedBox(height: 12),
                        Button(
                          child: const Text('🧪 Stress Test Generator'),
                          onPressed: () {
                            context.go('/stress-test');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Updates',
                          style: FluentTheme.of(context).typography.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check for the latest version of the application.',
                          style: FluentTheme.of(context).typography.caption,
                        ),
                        const SizedBox(height: 16),
                        Button(
                          child: const Text("Check for Updates"),
                          onPressed: () => checkForUpdates(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        loading: () => const Center(child: ProgressRing()),
        error:
            (error, _) => Center(
              child: InfoBar(
                title: const Text('Unable to load settings'),
                content: Text('$error'),
                severity: InfoBarSeverity.error,
              ),
            ),
      ),
    );
  }
}
