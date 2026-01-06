import 'dart:async';
import 'dart:io';

import 'app_paths.dart';

class AppLogger {
  AppLogger._internal();

  static final AppLogger instance = AppLogger._internal();

  String? _logFilePath;
  Future<void> _pendingWrite = Future.value();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    final path = await AppPaths.logFilePath();
    final logFile = File(path);
    if (!await logFile.exists()) {
      await logFile.create(recursive: true);
    }

    _logFilePath = logFile.path;
    _initialized = true;

    await logInfo('Logger initialized', operation: 'logger:init');
  }

  Future<void> logInfo(String message, {String? operation}) {
    return _write('INFO', message, operation: operation);
  }

  Future<void> logWarning(String message, {String? operation}) {
    return _write('WARN', message, operation: operation);
  }

  Future<void> logError(
    String message, {
    String? operation,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return _write(
      'ERROR',
      message,
      operation: operation,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> _write(
    String level,
    String message, {
    String? operation,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer('$timestamp [$level]');
    if (operation != null && operation.isNotEmpty) {
      buffer.write(' <$operation>');
    }
    buffer.write(' $message');
    if (error != null) {
      buffer.write(' | error: $error');
    }
    if (stackTrace != null) {
      buffer
        ..write('\n')
        ..write(stackTrace);
    }
    buffer.write('\n');

    return _enqueueWrite(buffer.toString());
  }

  Future<void> _enqueueWrite(String payload) {
    if (!_initialized || _logFilePath == null) {
      stderr.writeln('Logger not initialized. Dropping log entry: $payload');
      return Future.value();
    }

    _pendingWrite = _pendingWrite.then((_) async {
      try {
        final file = File(_logFilePath!);
        final sink = file.openWrite(mode: FileMode.append);
        sink.write(payload);
        await sink.flush();
        await sink.close();
      } catch (err, stack) {
        stderr
          ..writeln('Failed to write log entry: $err')
          ..writeln(stack);
      }
    });

    return _pendingWrite;
  }
}
