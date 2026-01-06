import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/supabase_service.dart';
import '../services/sync_service.dart';

/// Widget for configuring Supabase cloud sync settings
class CloudSyncSettings extends ConsumerStatefulWidget {
  const CloudSyncSettings({super.key});

  @override
  ConsumerState<CloudSyncSettings> createState() => _CloudSyncSettingsState();
}

class _CloudSyncSettingsState extends ConsumerState<CloudSyncSettings> {
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();

  bool _isLoading = true;
  bool _isBusy = false;
  bool _isConfigured = false;
  bool _isEnabled = false;
  bool _showCredentials = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);

    try {
      final config = await SupabaseConfig.load();
      if (config != null) {
        _urlController.text = config.url;
        _anonKeyController.text = config.anonKey;
        _isConfigured = config.isConfigured;
        _isEnabled = config.enabled;
      }
    } catch (e) {
      _errorMessage = 'Failed to load configuration';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showInfoBar(String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder:
          (context, close) => InfoBar(
            title: const Text('Cloud Sync'),
            content: Text(message),
            severity: severity,
            onClose: close,
          ),
    );
  }

  Future<void> _saveConfiguration() async {
    final url = _urlController.text.trim();
    final anonKey = _anonKeyController.text.trim();

    if (url.isEmpty || anonKey.isEmpty) {
      _showInfoBar(
        'Please enter both URL and Anon Key',
        InfoBarSeverity.warning,
      );
      return;
    }

    if (!url.startsWith('https://')) {
      _showInfoBar('URL must start with https://', InfoBarSeverity.warning);
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final success = await supabaseService.configure(url, anonKey);

      if (success) {
        setState(() {
          _isConfigured = true;
          _isEnabled = true;
        });
        _showInfoBar(
          'Connected to Supabase successfully!',
          InfoBarSeverity.success,
        );

        // Trigger initial sync
        ref.read(syncServiceProvider.notifier).syncAll();
      } else {
        _showInfoBar(
          'Failed to connect. Check your credentials.',
          InfoBarSeverity.error,
        );
      }
    } catch (e) {
      _showInfoBar('Connection error: $e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _toggleSync(bool enabled) async {
    setState(() => _isBusy = true);

    try {
      await ref.read(supabaseServiceProvider).setEnabled(enabled);
      setState(() => _isEnabled = enabled);

      if (enabled) {
        ref.read(syncServiceProvider.notifier).syncAll();
        _showInfoBar('Cloud sync enabled', InfoBarSeverity.success);
      } else {
        _showInfoBar(
          'Cloud sync disabled. Data will only be saved locally.',
          InfoBarSeverity.info,
        );
      }
    } catch (e) {
      _showInfoBar('Failed to update setting: $e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _manualSync() async {
    setState(() => _isBusy = true);

    try {
      await ref.read(syncServiceProvider.notifier).syncAll();
      _showInfoBar('Sync completed successfully!', InfoBarSeverity.success);
    } catch (e) {
      _showInfoBar('Sync failed: $e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _clearConfiguration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Clear Cloud Sync Configuration?'),
            content: const Text(
              'This will disconnect from Supabase. Your local data will remain intact.',
            ),
            actions: [
              Button(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              FilledButton(
                child: const Text('Clear'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isBusy = true);

    try {
      await SupabaseConfig.clear();
      _urlController.clear();
      _anonKeyController.clear();
      setState(() {
        _isConfigured = false;
        _isEnabled = false;
      });
      _showInfoBar('Configuration cleared', InfoBarSeverity.success);
    } catch (e) {
      _showInfoBar('Failed to clear configuration: $e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showSetupGuide() {
    showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Supabase Setup Guide'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSetupStep(
                      '1. Create a Supabase Account',
                      'Go to supabase.com and create a free account',
                    ),
                    const SizedBox(height: 12),
                    _buildSetupStep(
                      '2. Create a New Project',
                      'Click "New Project" and choose a name and password',
                    ),
                    const SizedBox(height: 12),
                    _buildSetupStep(
                      '3. Create Database Tables',
                      'Go to SQL Editor and run the provided SQL script to create tables',
                    ),
                    const SizedBox(height: 12),
                    _buildSetupStep(
                      '4. Get Your Credentials',
                      'Go to Project Settings → API\n'
                          '• Copy "Project URL" → paste in URL field\n'
                          '• Copy "anon public" key → paste in Anon Key field',
                    ),
                    const SizedBox(height: 12),
                    _buildSetupStep(
                      '5. Configure Both Computers',
                      'Enter the same credentials on both computers to sync data',
                    ),
                    const SizedBox(height: 16),
                    const InfoBar(
                      title: Text('📝 SQL Script'),
                      content: SelectableText(
                        'Copy this to Supabase SQL Editor:\n\n'
                        'See SUPABASE_SETUP.sql file in the app folder',
                      ),
                      severity: InfoBarSeverity.info,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              FilledButton(
                child: const Text('Got it'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Widget _buildSetupStep(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final syncStatus = ref.watch(syncServiceProvider);
    final dateFormat = DateFormat.yMMMd().add_jm();

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (connectionStatus) {
      case ConnectionStatus.online:
        statusColor = Colors.green;
        statusText = 'Online';
        statusIcon = FluentIcons.cloud;
        break;
      case ConnectionStatus.offline:
        statusColor = Colors.grey;
        statusText = 'Offline';
        statusIcon = FluentIcons.cloud_not_synced;
        break;
      case ConnectionStatus.syncing:
        statusColor = Colors.blue;
        statusText = 'Syncing...';
        statusIcon = FluentIcons.sync;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              if (syncStatus.isSyncing) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: ProgressRing(strokeWidth: 2),
                ),
              ],
            ],
          ),
          if (syncStatus.lastSyncTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last sync: ${dateFormat.format(syncStatus.lastSyncTime!)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (syncStatus.pendingOperations > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${syncStatus.pendingOperations} pending changes',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
          if (syncStatus.lastError != null) ...[
            const SizedBox(height: 4),
            Text(
              'Error: ${syncStatus.lastError}',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: ProgressRing()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(FluentIcons.cloud, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Cloud Sync (Multi-User)',
                      style: theme.typography.titleLarge,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(FluentIcons.help, size: 16),
                  onPressed: _showSetupGuide,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sync data between multiple computers using Supabase cloud. Works offline - syncs when connected.',
              style: theme.typography.caption,
            ),
            const SizedBox(height: 16),

            // Connection Status
            if (_isConfigured && _isEnabled) ...[
              _buildConnectionStatus(),
              const SizedBox(height: 16),
            ],

            // Configuration Form
            if (!_isConfigured || _showCredentials) ...[
              InfoLabel(
                label: 'Supabase Project URL',
                child: TextBox(
                  controller: _urlController,
                  placeholder: 'https://your-project.supabase.co',
                  enabled: !_isBusy,
                ),
              ),
              const SizedBox(height: 12),
              InfoLabel(
                label: 'Anon Key (public)',
                child: PasswordBox(
                  controller: _anonKeyController,
                  placeholder: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                  enabled: !_isBusy,
                  revealMode: PasswordRevealMode.peek,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isBusy) ...[const ProgressBar(), const SizedBox(height: 16)],

            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (!_isConfigured) ...[
                  FilledButton(
                    onPressed: _isBusy ? null : _saveConfiguration,
                    child: const Text('Connect to Supabase'),
                  ),
                ] else ...[
                  // Sync toggle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enable Sync: '),
                      ToggleSwitch(
                        checked: _isEnabled,
                        onChanged: _isBusy ? null : _toggleSync,
                      ),
                    ],
                  ),

                  // Manual sync button
                  if (_isEnabled)
                    Button(
                      onPressed: _isBusy ? null : _manualSync,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.sync, size: 14),
                          SizedBox(width: 8),
                          Text('Sync Now'),
                        ],
                      ),
                    ),

                  // Edit credentials
                  Button(
                    onPressed:
                        _isBusy
                            ? null
                            : () {
                              setState(
                                () => _showCredentials = !_showCredentials,
                              );
                            },
                    child: Text(
                      _showCredentials
                          ? 'Hide Credentials'
                          : 'Edit Credentials',
                    ),
                  ),

                  // Clear configuration
                  Button(
                    onPressed: _isBusy ? null : _clearConfiguration,
                    child: const Text('Disconnect'),
                  ),
                ],
              ],
            ),

            // Info about local data
            const SizedBox(height: 16),
            const InfoBar(
              title: Text('💾 Your data is always saved locally'),
              content: Text(
                'The app works offline. Changes sync automatically when you\'re connected to the internet.',
              ),
              severity: InfoBarSeverity.info,
            ),
          ],
        ),
      ),
    );
  }
}
