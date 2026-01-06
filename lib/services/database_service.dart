import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../core/app_logger.dart';
import '../core/app_paths.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static Future<Database>? _openingDbFuture;
  static const _dbFileName = 'discom_data.db';
  static const _maxRetries = 3;
  static bool _launchBackupCreated = false;

  final AppLogger _logger = AppLogger.instance;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_openingDbFuture != null) {
      return _openingDbFuture!;
    }

    final future = _initDB(_dbFileName);
    _openingDbFuture = future;

    try {
      _database = await future;
      return _database!;
    } finally {
      _openingDbFuture = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for Windows desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dataDir = await AppPaths.dataDir();
    final dbPath = p.join(dataDir, filePath);

    await _createLaunchBackup(dbPath);

    await _logger.logInfo('Opening database', operation: 'db:init');
    await _logger.logInfo('Database path: $dbPath', operation: 'db:path');

    // Ensure directory exists
    final directory = Directory(p.dirname(dbPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return await openDatabase(
      dbPath,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        await _logger.logInfo('Database opened', operation: 'db:init');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        is_admin INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Firms (DISCOMs) table
    await db.execute('''
      CREATE TABLE firms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        code TEXT UNIQUE NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tenders (TN) table
    await db.execute('''
      CREATE TABLE tenders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firm_id INTEGER NOT NULL,
        tn_number TEXT NOT NULL,
        po_number TEXT,
        work_description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (firm_id) REFERENCES firms (id) ON DELETE CASCADE,
        UNIQUE(firm_id, tn_number)
      )
    ''');

    // Bills table with comprehensive financial tracking
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firm_id INTEGER NOT NULL,
        tender_id INTEGER,
        tn_number TEXT NOT NULL,
        bill_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        remarks TEXT,
        invoice_amount REAL DEFAULT 0,
        bill_pass_amount REAL DEFAULT 0,
        csd_amount REAL DEFAULT 0,
        csd_released_date TEXT,
        scrap_amount REAL DEFAULT 0,
        md_ld_amount REAL DEFAULT 0,
        empty_oil_issued REAL DEFAULT 0,
        empty_oil_returned REAL DEFAULT 0,
        tds_percent REAL DEFAULT 2.0,
        tcs_percent REAL DEFAULT 1.0,
        gst_percent REAL DEFAULT 2.0,
        paid_date TEXT,
        transaction_no TEXT,
        due_release_date TEXT,
        invoice_no TEXT,
        invoice_date TEXT,
        work_order_no TEXT,
        work_order_date TEXT,
        consignment_name TEXT,
        proof_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (firm_id) REFERENCES firms (id) ON DELETE CASCADE,
        FOREIGN KEY (tender_id) REFERENCES tenders (id) ON DELETE SET NULL
      )
    ''');

    // Payments table with comprehensive tracking
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_id INTEGER NOT NULL,
        payment_date TEXT NOT NULL,
        amount_paid REAL NOT NULL,
        paid_date TEXT,
        transaction_no TEXT,
        due_release_date TEXT,
        invoice_no TEXT,
        invoice_date TEXT,
        work_order_no TEXT,
        work_order_date TEXT,
        consignment_name TEXT,
        proof_path TEXT,
        remarks TEXT,
        last_edited TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (bill_id) REFERENCES bills (id) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Backups table
    await db.execute('''
      CREATE TABLE backups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backup_path TEXT NOT NULL,
        backup_date TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        firm_id INTEGER,
        is_auto INTEGER DEFAULT 0,
        FOREIGN KEY (firm_id) REFERENCES firms (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_bills_firm ON bills(firm_id)');
    await db.execute('CREATE INDEX idx_bills_status ON bills(status)');
    await db.execute('CREATE INDEX idx_bills_due_date ON bills(due_date)');
    await db.execute('CREATE INDEX idx_payments_bill ON payments(bill_id)');
    await db.execute('CREATE INDEX idx_bills_tn_number ON bills(tn_number)');

    // Insert default data
    await _insertDefaultData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Add new financial tracking columns to bills table
      await db.execute(
        'ALTER TABLE bills ADD COLUMN invoice_amount REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE bills ADD COLUMN bill_pass_amount REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE bills ADD COLUMN csd_amount REAL DEFAULT 0',
      );
      await db.execute('ALTER TABLE bills ADD COLUMN csd_released_date TEXT');
      await db.execute(
        'ALTER TABLE bills ADD COLUMN scrap_amount REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE bills ADD COLUMN md_ld_amount REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE bills ADD COLUMN empty_oil_issued REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE bills ADD COLUMN empty_oil_returned REAL DEFAULT 0',
      );
    }

    if (oldVersion < 3) {
      // Add new payment tracking columns to payments table
      await db.execute('ALTER TABLE payments ADD COLUMN paid_date TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN transaction_no TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN due_release_date TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN invoice_no TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN invoice_date TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN work_order_no TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN work_order_date TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN consignment_name TEXT');
    }

    if (oldVersion < 4) {
      // Add manual TDS/TCS/GST percentages and payment tracking to bills table
      await db.execute(
        'ALTER TABLE bills ADD COLUMN tds_percent REAL DEFAULT 2.0',
      );
      await db.execute(
        'ALTER TABLE bills ADD COLUMN tcs_percent REAL DEFAULT 1.0',
      );
      await db.execute(
        'ALTER TABLE bills ADD COLUMN gst_percent REAL DEFAULT 2.0',
      );
      await db.execute('ALTER TABLE bills ADD COLUMN paid_date TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN transaction_no TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN due_release_date TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN invoice_no TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN invoice_date TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN work_order_no TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN work_order_date TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN consignment_name TEXT');
      await db.execute('ALTER TABLE bills ADD COLUMN proof_path TEXT');
    }

    if (oldVersion < 5) {
      // Create tenders table and link bills to tenders
      await db.execute('''
        CREATE TABLE tenders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firm_id INTEGER NOT NULL,
          tn_number TEXT NOT NULL,
          po_number TEXT,
          work_description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (firm_id) REFERENCES firms (id) ON DELETE CASCADE,
          UNIQUE(firm_id, tn_number)
        )
      ''');

      // Add tender_id column to bills table
      await db.execute('ALTER TABLE bills ADD COLUMN tender_id INTEGER');
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insert default admin user
    // Password: admin123 (hashed with bcrypt)
    await db.insert('users', {
      'username': 'admin',
      'password_hash':
          r'$2a$10$WIJ3I5FhTtorPCUYVym5x.EjxafLHItJkfARnkcnWKdarM0YjS4Oe', // admin123
      'is_admin': 1,
      'created_at': now,
      'updated_at': now,
    });

    // Insert DISCOMs
    await db.insert('firms', {
      'name': 'AVVNL',
      'code': 'AVVNL',
      'description': 'Ajmer Vidyut Vitran Nigam Limited',
      'created_at': now,
    });

    await db.insert('firms', {
      'name': 'JVVNL',
      'code': 'JVVNL',
      'description': 'Jaipur Vidyut Vitran Nigam Limited',
      'created_at': now,
    });

    await db.insert('firms', {
      'name': 'JDVVNL',
      'code': 'JDVVNL',
      'description': 'Jodhpur Vidyut Vitran Nigam Limited',
      'created_at': now,
    });

    // Insert default settings
    await db.insert('settings', {
      'key': 'theme_mode',
      'value': 'light',
      'updated_at': now,
    });

    await db.insert('settings', {
      'key': 'auto_backup_enabled',
      'value': 'true',
      'updated_at': now,
    });

    await db.insert('settings', {
      'key': 'auto_backup_interval_days',
      'value': '7',
      'updated_at': now,
    });

    await db.insert('settings', {
      'key': 'last_auto_backup',
      'value': now,
      'updated_at': now,
    });
  }

  // Get files directory for specific DISCOM
  Future<String> getFilesDirectory(String discomCode) async {
    return AppPaths.filesDir(discomCode);
  }

  // Get backups directory
  Future<String> getBackupsDirectory() async {
    return AppPaths.backupsDir();
  }

  // Get database file path
  Future<String> getDatabasePath() async {
    final dataDir = await AppPaths.dataDir();
    return p.join(dataDir, _dbFileName);
  }

  // Close database connection
  Future<void> close() async {
    final db = _database ?? await database;
    try {
      await db.close();
      await _logger.logInfo(
        'Database connection closed',
        operation: 'db:close',
      );
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to close database connection',
        operation: 'db:close',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _database = null;
      _openingDbFuture = null;
    }
  }

  // Execute raw query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return _runSafe(
      operation: 'db:rawQuery',
      sql: sql,
      arguments: arguments,
      action: (db) => db.rawQuery(sql, arguments),
    );
  }

  // Execute raw insert/update/delete
  Future<int> rawExecute(String sql, [List<Object?>? arguments]) async {
    return _runSafe(
      operation: 'db:rawExecute',
      sql: sql,
      arguments: arguments,
      action: (db) => db.rawUpdate(sql, arguments),
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return _runSafe(
      operation: 'db:query:$table',
      sql: where,
      arguments: whereArgs,
      action:
          (db) => db.query(
            table,
            distinct: distinct ?? false,
            columns: columns,
            where: where,
            whereArgs: whereArgs,
            groupBy: groupBy,
            having: having,
            orderBy: orderBy,
            limit: limit,
            offset: offset,
          ),
    );
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return _runSafe(
      operation: 'db:insert:$table',
      action:
          (db) => db.insert(
            table,
            values,
            nullColumnHack: nullColumnHack,
            conflictAlgorithm: conflictAlgorithm,
          ),
    );
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return _runSafe(
      operation: 'db:update:$table',
      sql: where,
      arguments: whereArgs,
      action:
          (db) => db.update(
            table,
            values,
            where: where,
            whereArgs: whereArgs,
            conflictAlgorithm: conflictAlgorithm,
          ),
    );
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return _runSafe(
      operation: 'db:delete:$table',
      sql: where,
      arguments: whereArgs,
      action: (db) => db.delete(table, where: where, whereArgs: whereArgs),
    );
  }

  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) {
    return _runSafe(
      operation: 'db:transaction',
      action: (db) => db.transaction(action, exclusive: exclusive),
    );
  }

  Future<T> _runSafe<T>({
    required String operation,
    required Future<T> Function(Database db) action,
    String? sql,
    List<Object?>? arguments,
  }) async {
    var attempt = 0;

    while (true) {
      attempt++;
      try {
        final db = await database;
        return await action(db);
      } on DatabaseException catch (error, stackTrace) {
        await _logger.logError(
          'DatabaseException during $operation (attempt $attempt)',
          operation: operation,
          error: error,
          stackTrace: stackTrace,
        );
        if (sql != null) {
          await _logger.logWarning('SQL: $sql', operation: operation);
        }
        if (arguments != null && arguments.isNotEmpty) {
          await _logger.logWarning(
            'Arguments: $arguments',
            operation: operation,
          );
        }

        if (attempt >= _maxRetries) {
          rethrow;
        }

        await _resetConnection();
        await Future<void>.delayed(Duration(milliseconds: attempt * 200));
      } catch (error, stackTrace) {
        await _logger.logError(
          'Unexpected exception during $operation',
          operation: operation,
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    }
  }

  Future<void> _resetConnection() async {
    if (_database == null) {
      return;
    }

    try {
      await _database!.close();
      await _logger.logWarning(
        'Database connection reset',
        operation: 'db:reset',
      );
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to reset database connection',
        operation: 'db:reset',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _database = null;
      _openingDbFuture = null;
    }
  }

  Future<void> _createLaunchBackup(String dbPath) async {
    if (_launchBackupCreated) {
      return;
    }

    try {
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        await _logger.logInfo(
          'Skipping launch backup; database does not exist yet',
          operation: 'db:backup',
        );
        return;
      }

      final backupsDir = await AppPaths.backupsDir();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = p.join(backupsDir, 'launch-$timestamp.db');
      await dbFile.copy(backupPath);
      await _logger.logInfo(
        'Launch backup created at $backupPath',
        operation: 'db:backup',
      );
      _launchBackupCreated = true;
    } catch (error, stackTrace) {
      await _logger.logError(
        'Failed to create launch backup',
        operation: 'db:backup',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
