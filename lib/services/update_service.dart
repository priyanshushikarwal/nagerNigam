import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'updater_service.dart';

/// Model for update information from version.json
class UpdateInfo {
  final String version;
  final String packageUrl;
  final String notes;
  final bool mandatory;

  UpdateInfo({
    required this.version,
    required this.packageUrl,
    required this.notes,
    required this.mandatory,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    final packageUrl =
        (json['zip_url'] ?? json['url'] ?? json['exe_url'] ?? '').toString();

    return UpdateInfo(
      version: (json['version'] ?? '').toString(),
      packageUrl: packageUrl,
      notes: (json['notes'] ?? '').toString(),
      mandatory: json['mandatory'] == true,
    );
  }

  bool get hasRequiredFields => version.isNotEmpty && packageUrl.isNotEmpty;
}

/// Service to check for updates and coordinate the download/install process
class UpdateService {
  final String versionJsonUrl;

  UpdateService({required this.versionJsonUrl});

  /// Fetches remote version info from GitHub
  Future<UpdateInfo?> fetchRemoteVersion() async {
    try {
      final response = await http.get(
        Uri.parse(versionJsonUrl),
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final updateInfo = UpdateInfo.fromJson(json);
        if (!updateInfo.hasRequiredFields) {
          print('Update check failed: version.json is missing version or package URL');
          return null;
        }
        return updateInfo;
      } else {
        print('Update check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Update check error: $e');
    }
    return null;
  }

  /// Gets the current installed version
  Future<String> getLocalVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '0.0.0';
    }
  }

  /// Compares version strings (e.g., "1.0.15" vs "1.0.16")
  bool isRemoteGreater(String local, String remote) {
    final lv = local.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final rv = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      if (rv[i] > lv[i]) return true;
      if (rv[i] < lv[i]) return false;
    }
    return false;
  }

  /// Downloads the ZIP update and installs it
  /// Returns a stream of download progress (0.0 to 1.0)
  Stream<double> downloadAndInstall(
    UpdateInfo updateInfo,
    void Function(String error) onError,
  ) async* {
    try {
      final updater = UpdaterService();
      File? downloadedFile;

      await for (final progress in updater.downloadUpdate(
        updateInfo.packageUrl,
        (file) => downloadedFile = file,
        onError,
      )) {
        yield progress;
      }

      // If download completed successfully, install
      if (downloadedFile != null) {
        await updater.installUpdateAndRestart(downloadedFile!);
      }
    } catch (e) {
      onError('Download failed: $e');
    }
  }
}
