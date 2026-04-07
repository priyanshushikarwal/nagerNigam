import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import '../services/update_service.dart';
import '../services/updater_service.dart';

class UpdateAvailableDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateAvailableDialog({super.key, required this.updateInfo});

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  final UpdaterService _updaterService = UpdaterService();

  void _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      if (widget.updateInfo.packageUrl.isEmpty) {
        _onDownloadError(
          'Update metadata is missing a package URL. Check version.json.',
        );
        return;
      }

      // Start downloading the update
      await for (final progress in _updaterService.downloadUpdate(
        widget.updateInfo.packageUrl,
        (downloadedFile) => _onDownloadComplete(downloadedFile),
        (error) => _onDownloadError(error),
      )) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Download failed: $e';
          _isDownloading = false;
        });
      }
    }
  }

  void _onDownloadComplete(File downloadedFile) async {
    if (!mounted) return;

    try {
      // Show a brief "Installing..." message
      setState(() {
        _downloadProgress = 1.0;
      });

      // Small delay to show 100% progress
      await Future.delayed(const Duration(milliseconds: 500));

      // Install the update and restart
      await _updaterService.installUpdateAndRestart(
        downloadedFile,
        targetVersion: widget.updateInfo.version,
      );

      // Note: The app will exit, so code below won't execute
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Installation failed: $e';
          _isDownloading = false;
        });
      }
    }
  }

  void _onDownloadError(String error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Update Available"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "A new version (${widget.updateInfo.version}) is available.",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              "What's New:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  widget.updateInfo.notes,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 20),
              Text(
                _downloadProgress < 1.0
                    ? 'Downloading update... ${(_downloadProgress * 100).toStringAsFixed(1)}%'
                    : 'Installing update...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ProgressBar(value: _downloadProgress * 100),
              const SizedBox(height: 12),
              const Text(
                'Please wait. The application will restart automatically.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              InfoBar(
                title: const Text('Update Failed'),
                content: Text(_errorMessage!),
                severity: InfoBarSeverity.error,
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isDownloading) ...[
          Button(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text("Update Now"),
            onPressed: _startUpdate,
          ),
        ] else ...[
          Button(
            child: const Text("Cancel"),
            onPressed: null, // Disabled during download
          ),
        ],
      ],
    );
  }
}
