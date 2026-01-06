import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/premium_theme.dart';
import 'core/router.dart';
import 'core/app_logger.dart';
import 'services/database_service.dart';
import 'services/supabase_service.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final logger = AppLogger.instance;
      await logger.init();

      FlutterError.onError = (details) async {
        FlutterError.presentError(details);
        await logger.logError(
          'Flutter framework error',
          operation: 'flutter:error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      // Initialize SQLite FFI for Windows
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      // Initialize database
      final dbService = DatabaseService.instance;
      await dbService.database; // This will trigger database initialization

      // Initialize Supabase (if configured)
      await SupabaseService.instance.initialize();

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) async {
      final logger = AppLogger.instance;
      await logger.logError(
        'Uncaught zone error',
        operation: 'flutter:zone',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return FluentApp.router(
      title: 'DISCOM Bill Manager',
      theme: PremiumTheme.lightTheme,
      routerConfig: router,
    );
  }
}
