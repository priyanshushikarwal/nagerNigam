import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart' as db;
import '../core/app_paths.dart';

const _kDatabaseFileName = 'discom_data.db';

class BackupEntry {
  const BackupEntry({
    required this.path,
    required this.modified,
    required this.sizeBytes,
  });

  final String path;
  final DateTime modified;
  final int sizeBytes;

  String get fileName => p.basename(path);
}

class BackupService {
  BackupService({required db.AppDatabase database}) : _database = database;

  final db.AppDatabase _database;
  final _timestampFormat = DateFormat('yyyy-MM-dd_HH-mm');

  Future<String> createBackup({
    required String discomCode,
    String? destinationDir,
  }) async {
    final baseDir = await _resolveBaseDirectory();
    final dataDir = Directory(p.join(baseDir.path, 'data'));
    final dbFile = File(p.join(dataDir.path, _kDatabaseFileName));
    if (!await dbFile.exists()) {
      throw StateError('Database file not found at ${dbFile.path}');
    }

    final filesDir = Directory(p.join(baseDir.path, 'files'));
    final backupsDir = destinationDir ?? await _ensureDefaultBackupDirectory();
    final timestamp = _timestampFormat.format(DateTime.now());
    final outputPath = p.join(
      backupsDir,
      'backup_${discomCode}_$timestamp.zip',
    );

    final encoder = ZipFileEncoder();
    encoder.create(outputPath);
    encoder.addFile(dbFile, p.join('data', _kDatabaseFileName));
    if (await filesDir.exists()) {
      await _addDirectoryToArchive(encoder, filesDir, 'files');
    }
    encoder.close();

    return outputPath;
  }

  Future<void> restoreBackup({required String zipPath}) async {
    final archiveFile = File(zipPath);
    if (!await archiveFile.exists()) {
      throw StateError('Backup file not found at $zipPath');
    }

    await _database.close();

    final baseDir = await _resolveBaseDirectory();
    await _purgeExisting(baseDir);

    final bytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);

    for (final file in archive.files) {
      final targetPath = p.join(baseDir.path, file.name);
      final normalized = p.normalize(targetPath);
      if (!p.isWithin(baseDir.path, normalized) && normalized != baseDir.path) {
        throw StateError(
          'Archive entry resolves outside application directory',
        );
      }

      if (file.isFile) {
        final outFile = File(normalized);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>, flush: true);
      } else {
        final dir = Directory(normalized);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }
    }
  }

  Future<List<BackupEntry>> listBackups({String? directory}) async {
    final backupsDir = directory ?? await _ensureDefaultBackupDirectory();
    final dir = Directory(backupsDir);
    if (!await dir.exists()) {
      return const [];
    }

    final entries = <BackupEntry>[];
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.toLowerCase().endsWith('.zip')) {
        continue;
      }
      final stats = await entity.stat();
      entries.add(
        BackupEntry(
          path: entity.path,
          modified: stats.modified,
          sizeBytes: stats.size,
        ),
      );
    }

    entries.sort((a, b) => b.modified.compareTo(a.modified));
    return entries;
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<String> _ensureDefaultBackupDirectory() async {
    return AppPaths.ensureSubdirectory('backups');
  }

  Future<String> defaultBackupDirectory() => _ensureDefaultBackupDirectory();

  Future<void> _purgeExisting(Directory baseDir) async {
    final baseDir = await _resolveBaseDirectory();
    final dataDir = Directory(p.join(baseDir.path, 'data'));
    final dbFile = File(p.join(dataDir.path, _kDatabaseFileName));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    final filesDir = Directory(p.join(baseDir.path, 'files'));
    if (await filesDir.exists()) {
      await filesDir.delete(recursive: true);
    }
  }

  Future<void> _addDirectoryToArchive(
    ZipFileEncoder encoder,
    Directory directory,
    String prefix,
  ) async {
    final entities = directory.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is! File) continue;
      final relativePath = p.relative(entity.path, from: directory.path);
      final targetPath = p.join(prefix, relativePath).replaceAll('\\', '/');
      encoder.addFile(entity, targetPath);
    }
  }

  Future<Directory> _resolveBaseDirectory() async {
    final path = await AppPaths.appDataDir();
    return Directory(path);
  }
}
