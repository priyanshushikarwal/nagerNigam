import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_logger.dart';
import '../models/bill.dart';
import 'supabase_service.dart';

class PaymentProofStorageService {
  PaymentProofStorageService({required SupabaseService supabaseService})
    : _supabaseService = supabaseService;

  static const String bucketName = 'payment-proofs';

  final SupabaseService _supabaseService;
  final AppLogger _logger = AppLogger.instance;

  SupabaseClient? get _client => _supabaseService.client;

  bool hasProof(Payment payment) {
    final proofPath = payment.proofPath;
    return proofPath != null && proofPath.trim().isNotEmpty;
  }

  String storagePathForPayment(Payment payment) {
    if (payment.id == null) {
      throw ArgumentError('Cannot build proof storage path without payment id.');
    }

    return 'payments/${payment.id}/proof.zip';
  }

  Future<String?> uploadPaymentProof(Payment payment) async {
    if (!_supabaseService.isInitialized || _client == null || payment.id == null) {
      return null;
    }

    final localFile = await resolveLocalProofFile(
      payment,
      allowDownload: false,
      preferCached: true,
    );
    if (localFile == null || !await localFile.exists()) {
      return null;
    }

    final originalBytes = await localFile.readAsBytes();
    final originalName = p.basename(localFile.path);
    final zipBytes = _compressProof(originalBytes, originalName);
    final storagePath = storagePathForPayment(payment);

    await _client!.storage.from(bucketName).uploadBinary(
      storagePath,
      zipBytes,
      fileOptions: FileOptions(
        cacheControl: '3600',
        contentType: 'application/zip',
        upsert: true,
      ),
    );

    await _cacheProofBytes(payment.id!, originalName, originalBytes);

    await _logger.logInfo(
      'Uploaded payment proof to storage: $storagePath',
      operation: 'payment-proof:upload',
    );

    return storagePath;
  }

  Future<void> deletePaymentProof(Payment payment) async {
    if (!_supabaseService.isInitialized || _client == null || payment.id == null) {
      return;
    }

    final storagePath = storagePathForPayment(payment);
    try {
      await _client!.storage.from(bucketName).remove([storagePath]);
    } catch (_) {
      final proofPath = payment.proofPath;
      if (proofPath != null &&
          proofPath.isNotEmpty &&
          !_isLocalPath(proofPath) &&
          proofPath != storagePath) {
        try {
          await _client!.storage.from(bucketName).remove([proofPath]);
        } catch (_) {
          // Ignore cleanup fallback failures.
        }
      }
    }
  }

  Future<File?> resolveLocalProofFile(
    Payment payment, {
    bool allowDownload = true,
    bool preferCached = true,
  }) async {
    if (!hasProof(payment)) {
      return null;
    }

    final proofPath = payment.proofPath!;

    if (_isLocalPath(proofPath)) {
      final localFile = File(proofPath);
      if (await localFile.exists()) {
        return localFile;
      }
    }

    if (preferCached && payment.id != null) {
      final cachedFile = await _findCachedProof(payment.id!);
      if (cachedFile != null) {
        return cachedFile;
      }
    }

    if (!allowDownload || !_supabaseService.isInitialized || _client == null) {
      return null;
    }

    final storagePath =
        _isLocalPath(proofPath) ? storagePathForPayment(payment) : proofPath;
    final zippedBytes = await _client!.storage.from(bucketName).download(
      storagePath,
    );

    return _extractProofToCache(payment.id!, zippedBytes);
  }

  Future<void> openPaymentProof(Payment payment) async {
    final file = await resolveLocalProofFile(payment);
    if (file == null || !await file.exists()) {
      throw StateError(
        'Payment proof not found locally or in Supabase Storage.',
      );
    }

    await Process.start(
      'cmd.exe',
      ['/c', 'start', '', file.path],
      mode: ProcessStartMode.detached,
    );
  }

  Uint8List _compressProof(Uint8List bytes, String fileName) {
    final archive = Archive()
      ..addFile(ArchiveFile(fileName, bytes.length, bytes));
    final zipped = ZipEncoder().encode(archive);

    if (zipped == null) {
      throw StateError('Unable to compress payment proof.');
    }

    return Uint8List.fromList(zipped);
  }

  bool _isLocalPath(String path) {
    return p.isAbsolute(path) || path.contains(':\\');
  }

  Future<Directory> _proofCacheDirectory(int paymentId) async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(
      p.join(supportDir.path, 'DISCOMBillManager', 'proof_cache', '$paymentId'),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _cacheProofBytes(
    int paymentId,
    String fileName,
    Uint8List bytes,
  ) async {
    final cacheDir = await _proofCacheDirectory(paymentId);
    final target = File(p.join(cacheDir.path, fileName));
    await target.writeAsBytes(bytes, flush: true);
  }

  Future<File?> _findCachedProof(int paymentId) async {
    final cacheDir = await _proofCacheDirectory(paymentId);
    if (!await cacheDir.exists()) {
      return null;
    }

    final files =
        cacheDir
            .listSync()
            .whereType<File>()
            .where((file) => !p.basename(file.path).startsWith('.'))
            .toList();

    if (files.isEmpty) {
      return null;
    }

    files.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
    return files.first;
  }

  Future<File> _extractProofToCache(int? paymentId, Uint8List zippedBytes) async {
    if (paymentId == null) {
      throw ArgumentError('Cannot cache payment proof without payment id.');
    }

    final archive = ZipDecoder().decodeBytes(zippedBytes, verify: true);
    ArchiveFile? archivedFile;
    for (final file in archive.files) {
      if (file.isFile) {
        archivedFile = file;
        break;
      }
    }

    if (archivedFile == null) {
      throw StateError('Compressed payment proof is empty.');
    }

    final content = archivedFile.content;
    final bytes =
        content is Uint8List
            ? content
            : Uint8List.fromList((content as List<int>).toList());

    final fileName = archivedFile.name.isEmpty ? 'proof.bin' : archivedFile.name;
    await _cacheProofBytes(paymentId, fileName, bytes);

    final cachedFile = await _findCachedProof(paymentId);
    if (cachedFile == null) {
      throw StateError('Unable to prepare local proof file.');
    }

    return cachedFile;
  }
}
