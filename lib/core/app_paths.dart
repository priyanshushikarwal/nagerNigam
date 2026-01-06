import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppPaths {
  AppPaths._();

  static Future<String> appDataDir() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        final target = Directory(p.join(appData, 'DISCOMBillManager'));
        if (!await target.exists()) {
          await target.create(recursive: true);
        }
        return target.path;
      }
    }

    final documents = await getApplicationDocumentsDirectory();
    final fallback = Directory(p.join(documents.path, 'DISCOMBillManager'));
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return fallback.path;
  }

  static Future<String> ensureSubdirectory(String name) async {
    final base = await appDataDir();
    final directory = Directory(p.join(base, name));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  static Future<String> logsDir() => ensureSubdirectory('logs');

  static Future<String> logFilePath() async {
    final dir = await logsDir();
    return p.join(dir, 'app.log');
  }

  static Future<String> dataDir() => ensureSubdirectory('data');

  static Future<String> backupsDir() => ensureSubdirectory('backups');

  static Future<String> filesDir(String discomCode) async {
    final base = await ensureSubdirectory('files');
    final directory = Directory(p.join(base, discomCode));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }
}
