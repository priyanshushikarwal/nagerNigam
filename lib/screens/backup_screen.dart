import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/backup_service.dart';
import '../state/database_providers.dart';
import '../state/firm_providers.dart';
import '../state/service_providers.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isBusy = false;

  void _showInfoBar(String title, String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder:
          (context, close) => InfoBar(
            title: Text(title),
            content: Text(message),
            severity: severity,
            onClose: close,
          ),
    );
  }

  Future<void> _performBackup({String? customDir}) async {
    final firm = ref.read(selectedFirmProvider);
    if (firm == null) {
      _showInfoBar(
        'Select DISCOM',
        'Please choose a DISCOM before running backups.',
        InfoBarSeverity.warning,
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final path = await backupService.createBackup(
        discomCode: firm.code,
        destinationDir: customDir,
      );
      _showInfoBar(
        'Backup Complete',
        'Backup stored at\n$path',
        InfoBarSeverity.success,
      );
      ref.invalidate(backupEntriesProvider);
    } catch (e) {
      _showInfoBar('Backup Failed', '$e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _restoreBackup(BackupEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Restore Backup'),
            content: Text(
              'Restoring "${entry.fileName}" will overwrite current data.\n\n'
              'Continue?',
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.restoreBackup(zipPath: entry.path);
      _showInfoBar(
        'Restore Successful',
        'Restart the app to ensure all changes take effect.',
        InfoBarSeverity.success,
      );
      ref.invalidate(appDatabaseProvider);
      ref.invalidate(billsDaoProvider);
      ref.invalidate(tnDaoProvider);
      ref.invalidate(paymentsDaoProvider);
      ref.invalidate(backupServiceProvider);
      ref.invalidate(exportServiceProvider);
      ref.invalidate(pdfServiceProvider);
      ref.invalidate(backupEntriesProvider);
    } catch (e) {
      _showInfoBar('Restore Failed', '$e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _restoreFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (result == null || result.files.single.path == null) {
      return;
    }

    await _restoreBackup(
      BackupEntry(
        path: result.files.single.path!,
        modified: DateTime.now(),
        sizeBytes: result.files.single.size,
      ),
    );
  }

  Future<void> _backupToSelectedFolder() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory == null) return;
    await _performBackup(customDir: directory);
  }

  Widget _buildHeader(String defaultDir) {
    final firm = ref.watch(selectedFirmProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backups', style: FluentTheme.of(context).typography.title),
          const SizedBox(height: 8),
          Text(
            'Default location: $defaultDir',
            style: FluentTheme.of(context).typography.caption,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: _isBusy ? null : () => _performBackup(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(FluentIcons.archive),
                    SizedBox(width: 8),
                    Text('Backup to Default Folder'),
                  ],
                ),
              ),
              Button(
                onPressed: _isBusy ? null : _backupToSelectedFolder,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(FluentIcons.folder),
                    SizedBox(width: 8),
                    Text('Choose Backup Destination'),
                  ],
                ),
              ),
              Button(
                onPressed: _isBusy ? null : _restoreFromFile,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(FluentIcons.upload),
                    SizedBox(width: 8),
                    Text('Restore From File'),
                  ],
                ),
              ),
              if (firm != null)
                InfoLabel(
                  label: 'Active DISCOM',
                  child: Text('${firm.name} (${firm.code})'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupList(List<BackupEntry> entries) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No backups found yet. Create one to get started.'),
      );
    }

    final backupService = ref.read(backupServiceProvider);
    final dateFormat = DateFormat.yMMMEd().add_jm();

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          child: ListTile(
            title: Text(entry.fileName),
            subtitle: Text(
              'Created: ${dateFormat.format(entry.modified)}\n'
              'Size: ${backupService.formatFileSize(entry.sizeBytes)}',
            ),
            trailing: Button(
              onPressed: _isBusy ? null : () => _restoreBackup(entry),
              child: const Text('Restore'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backupEntries = ref.watch(backupEntriesProvider);
    final backupService = ref.watch(backupServiceProvider);

    return ScaffoldPage(
      padding: const EdgeInsets.all(24),
      content: FutureBuilder<String>(
        future: backupService.defaultBackupDirectory(),
        builder: (context, snapshot) {
          final defaultDir = snapshot.data ?? 'Loading...';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(defaultDir),
              if (_isBusy) ...[const SizedBox(height: 16), const ProgressBar()],
              const SizedBox(height: 24),
              Expanded(
                child: backupEntries.when(
                  data: _buildBackupList,
                  loading: () => const Center(child: ProgressRing()),
                  error:
                      (error, _) => InfoBar(
                        title: const Text('Unable to load backups'),
                        content: Text('$error'),
                        severity: InfoBarSeverity.error,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
