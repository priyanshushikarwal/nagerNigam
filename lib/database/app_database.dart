import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Firms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get code => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get contactNo => text().named('contact_no').nullable()();
  TextColumn get gstNo => text().named('gst_no').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
    {code},
  ];
}

// Client/Contractor Firms - User's own companies
class ClientFirms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firmName =>
      text().named('firm_name').withLength(min: 1, max: 120)();
  TextColumn get address => text().nullable()();
  TextColumn get contactNo => text().named('contact_no').nullable()();
  TextColumn get gstNo => text().named('gst_no').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {firmName},
  ];
}

class Tenders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get firmId =>
      integer().references(Firms, #id, onDelete: KeyAction.cascade)();
  TextColumn get tnNumber => text().withLength(min: 1, max: 80)();
  TextColumn get poNumber => text().named('po_number').nullable()();
  TextColumn get workDescription =>
      text().named('work_description').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {firmId, tnNumber},
  ];
}

class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tenderId =>
      integer()
          .named('tender_id')
          .nullable()
          .references(Tenders, #id, onDelete: KeyAction.setNull)();
  IntColumn get firmId =>
      integer().references(Firms, #id, onDelete: KeyAction.cascade)();
  IntColumn get supplierFirmId =>
      integer()
          .named('supplier_firm_id')
          .nullable()
          .references(Firms, #id, onDelete: KeyAction.setNull)();
  IntColumn get clientFirmId =>
      integer()
          .named('client_firm_id')
          .nullable()
          .references(ClientFirms, #id, onDelete: KeyAction.setNull)();
  TextColumn get tnNumber => text().withLength(min: 1, max: 80)();
  DateTimeColumn get billDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  RealColumn get invoiceAmount => real().withDefault(const Constant(0.0))();
  RealColumn get csdAmount => real().withDefault(const Constant(0.0))();
  RealColumn get billPassAmount =>
      real().named('bill_pass_amount').withDefault(const Constant(0.0))();
  DateTimeColumn get csdReleasedDate =>
      dateTime().named('csd_released_date').nullable()();
  DateTimeColumn get csdDueDate =>
      dateTime().named('csd_due_date').nullable()();
  TextColumn get csdStatus =>
      text().named('csd_status').withDefault(const Constant('Pending'))();
  RealColumn get scrapAmount => real().withDefault(const Constant(0.0))();
  RealColumn get scrapGstAmount =>
      real().named('scrap_gst_amount').withDefault(const Constant(0.0))();
  TextColumn get scrapInvoiceNo => text().named('scrap_invoice_no').nullable()();
  DateTimeColumn get scrapInvoiceDate =>
      dateTime().named('scrap_invoice_date').nullable()();
  RealColumn get mdLdAmount =>
      real().named('md_ld_amount').withDefault(const Constant(0.0))();
  TextColumn get mdLdStatus =>
      text().named('md_ld_status').withDefault(const Constant('Pending'))();
  DateTimeColumn get mdLdReleasedDate =>
      dateTime().named('md_ld_released_date').nullable()();
  RealColumn get emptyOilIssued =>
      real().named('empty_oil_issued').withDefault(const Constant(0.0))();
  RealColumn get emptyOilReturned =>
      real().named('empty_oil_returned').withDefault(const Constant(0.0))();
  RealColumn get tdsAmount =>
      real().named('tds_amount').withDefault(const Constant(0.0))();
  RealColumn get tcsAmount =>
      real().named('tcs_amount').withDefault(const Constant(0.0))();
  RealColumn get gstTdsAmount =>
      real().named('gst_tds_amount').withDefault(const Constant(0.0))();
  RealColumn get totalPaid =>
      real().named('total_paid').withDefault(const Constant(0.0))();
  RealColumn get dueAmount =>
      real().named('due_amount').withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('Pending'))();
  DateTimeColumn get paidDate => dateTime().named('paid_date').nullable()();
  TextColumn get transactionNo => text().nullable()();
  DateTimeColumn get dueReleaseDate => dateTime().nullable()();
  TextColumn get invoiceNo => text().nullable()();
  DateTimeColumn get invoiceDate => dateTime().nullable()();
  TextColumn get workOrderNo => text().nullable()();
  DateTimeColumn get workOrderDate => dateTime().nullable()();
  TextColumn get consignmentName => text().nullable()();
  TextColumn get lotNo => text().named('lot_no').nullable()();
  TextColumn get storeName => text().named('store_name').nullable()();
  RealColumn get dMeterBox =>
      real().named('d_meter_box').withDefault(const Constant(0.0))();
  RealColumn get mdNpvAmount =>
      real().named('md_npv_amount').withDefault(const Constant(0.0))();
  RealColumn get emptyOilDrum =>
      real().named('empty_oil_drum').withDefault(const Constant(0.0))();

  // New Status Columns for Receivables
  TextColumn get dMeterBoxStatus =>
      text()
          .named('d_meter_box_status')
          .withDefault(const Constant('Pending'))();
  DateTimeColumn get dMeterBoxReleasedDate =>
      dateTime().named('d_meter_box_released_date').nullable()();

  TextColumn get mdNpvStatus =>
      text().named('md_npv_status').withDefault(const Constant('Pending'))();
  DateTimeColumn get mdNpvReleasedDate =>
      dateTime().named('md_npv_released_date').nullable()();

  TextColumn get emptyOilDrumStatus =>
      text()
          .named('empty_oil_drum_status')
          .withDefault(const Constant('Pending'))();
  DateTimeColumn get emptyOilDrumReleasedDate =>
      dateTime().named('empty_oil_drum_released_date').nullable()();

  // Remark columns for individual receivables
  TextColumn get dMeterBoxRemark =>
      text().named('d_meter_box_remark').nullable()();
  TextColumn get mdNpvRemark => text().named('md_npv_remark').nullable()();
  TextColumn get emptyOilDrumRemark =>
      text().named('empty_oil_drum_remark').nullable()();

  TextColumn get invoiceType => text().named('invoice_type').nullable()();
  TextColumn get proofPath => text().named('proof_path').nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get billId =>
      integer().references(Bills, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get paymentDate => dateTime()();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  DateTimeColumn get paidDate => dateTime().nullable()();
  TextColumn get transactionNo => text().nullable()();
  DateTimeColumn get dueReleaseDate => dateTime().nullable()();
  TextColumn get invoiceNo => text().nullable()();
  DateTimeColumn get invoiceDate => dateTime().nullable()();
  TextColumn get workOrderNo => text().nullable()();
  DateTimeColumn get workOrderDate => dateTime().nullable()();
  TextColumn get consignmentName => text().nullable()();
  TextColumn get proofPath => text().named('proof_path').nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get lastEdited =>
      dateTime().named('last_edited').withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Firms, ClientFirms, Tenders, Bills, Payments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 16;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.deleteTable('payments');
        await m.deleteTable('bills');
        await m.deleteTable('tns');
        await m.deleteTable('firms');
        await m.createAll();
        await _seed();
      }
      if (from < 3) {
        await m.addColumn(bills, bills.scrapGstAmount);
        await m.addColumn(bills, bills.gstTdsAmount);
      }
      if (from < 4) {
        await m.addColumn(bills, bills.invoiceType);
        // Set default value for existing rows
        await customStatement(
          "UPDATE bills SET invoice_type = 'JOB Invoice' WHERE invoice_type IS NULL",
        );
      }
      if (from < 5) {
        // Add new firm columns using raw SQL since Drift requires generated columns
        await customStatement('ALTER TABLE firms ADD COLUMN address TEXT');
        await customStatement('ALTER TABLE firms ADD COLUMN contact_no TEXT');
        await customStatement('ALTER TABLE firms ADD COLUMN gst_no TEXT');
      }
      if (from < 6) {
        // Add supplier_firm_id column to bills table
        await customStatement(
          'ALTER TABLE bills ADD COLUMN supplier_firm_id INTEGER REFERENCES firms(id) ON DELETE SET NULL',
        );
      }
      if (from < 7) {
        // Create client_firms table
        await customStatement('''
          CREATE TABLE IF NOT EXISTS client_firms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firm_name TEXT NOT NULL UNIQUE,
            address TEXT,
            contact_no TEXT,
            gst_no TEXT,
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
          )
        ''');

        // Add client_firm_id column to bills table
        await customStatement(
          'ALTER TABLE bills ADD COLUMN client_firm_id INTEGER REFERENCES client_firms(id) ON DELETE SET NULL',
        );

        // Seed client firms
        await _seedClientFirms();
      }
      if (from < 8) {
        // Migrate from percentage-based to amount-based TDS/TCS
        // Check if tds_amount column exists
        final tdsAmountExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='tds_amount'",
            ).getSingle();
        if (tdsAmountExists.data['count'] == 0) {
          await customStatement(
            'ALTER TABLE bills ADD COLUMN tds_amount REAL NOT NULL DEFAULT 0.0',
          );
        }

        // Check if tcs_amount column exists
        final tcsAmountExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='tcs_amount'",
            ).getSingle();
        if (tcsAmountExists.data['count'] == 0) {
          await customStatement(
            'ALTER TABLE bills ADD COLUMN tcs_amount REAL NOT NULL DEFAULT 0.0',
          );
        }

        // Migrate existing data: calculate amounts from percentages
        await customStatement('''
          UPDATE bills SET 
            tds_amount = invoice_amount * (COALESCE(tds_percent, 2.0) / 100.0),
            tcs_amount = invoice_amount * (COALESCE(tcs_percent, 1.0) / 100.0)
          WHERE invoice_amount > 0
        ''');

        // Drop old percentage columns (note: SQLite doesn't support DROP COLUMN easily)
        // We'll leave them but not use them in the model
      }
      if (from < 9) {
        // Add partial payment tracking fields (check if columns exist first)
        // Check if total_paid column exists
        final totalPaidExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='total_paid'",
            ).getSingle();
        if (totalPaidExists.data['count'] == 0) {
          await customStatement(
            'ALTER TABLE bills ADD COLUMN total_paid REAL NOT NULL DEFAULT 0.0',
          );
        }

        // Check if due_amount column exists
        final dueAmountExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='due_amount'",
            ).getSingle();
        if (dueAmountExists.data['count'] == 0) {
          await customStatement(
            'ALTER TABLE bills ADD COLUMN due_amount REAL NOT NULL DEFAULT 0.0',
          );
        }

        // Check if status column exists
        final statusExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='status'",
            ).getSingle();
        if (statusExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN status TEXT NOT NULL DEFAULT 'Pending'",
          );
        }

        // Migrate existing bills: calculate totalPaid from payments
        await customStatement('''
          UPDATE bills SET 
            total_paid = (
              SELECT COALESCE(SUM(amount_paid), 0.0)
              FROM payments
              WHERE payments.bill_id = bills.id
            )
        ''');

        // Calculate dueAmount: netPayable - totalPaid
        // netPayable = invoiceAmount - (tdsAmount + gstTdsAmount + tcsAmount + scrapGstAmount + mdLdAmount)
        await customStatement('''
          UPDATE bills SET 
            due_amount = (
              invoice_amount - 
              COALESCE(tds_amount, 0.0) - 
              COALESCE(gst_tds_amount, 0.0) - 
              COALESCE(tcs_amount, 0.0) - 
              COALESCE(scrap_gst_amount, 0.0) - 
              COALESCE(md_ld_amount, 0.0)
            ) - total_paid
        ''');

        // Calculate status based on payment rules
        await customStatement('''
          UPDATE bills SET 
            status = CASE
              WHEN total_paid = 0 THEN 'Pending'
              WHEN total_paid > 0 AND total_paid < (
                invoice_amount - 
                COALESCE(tds_amount, 0.0) - 
                COALESCE(gst_tds_amount, 0.0) - 
                COALESCE(tcs_amount, 0.0) - 
                COALESCE(scrap_gst_amount, 0.0) - 
                COALESCE(md_ld_amount, 0.0)
              ) THEN 'Partially Paid'
              ELSE 'Paid'
            END
        ''');
      }
      if (from < 10) {
        // Add csd_status column to bills table
        final csdStatusExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='csd_status'",
            ).getSingle();
        if (csdStatusExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN csd_status TEXT NOT NULL DEFAULT 'Pending'",
          );
        }
      }
      if (from < 11) {
        // Add csd_due_date column to bills table
        final csdDueDateExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='csd_due_date'",
            ).getSingle();
        if (csdDueDateExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN csd_due_date INTEGER",
          );
        }
      }
      if (from < 12) {
        // Add md_ld_status column to bills table
        final mdLdStatusExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='md_ld_status'",
            ).getSingle();
        if (mdLdStatusExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN md_ld_status TEXT NOT NULL DEFAULT 'Pending'",
          );
        }

        // Add md_ld_released_date column to bills table
        final mdLdReleasedDateExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='md_ld_released_date'",
            ).getSingle();
        if (mdLdReleasedDateExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN md_ld_released_date INTEGER",
          );
        }
      }
      if (from < 13) {
        // Add lot_no column
        final lotNoExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='lot_no'",
            ).getSingle();
        if (lotNoExists.data['count'] == 0) {
          await customStatement("ALTER TABLE bills ADD COLUMN lot_no TEXT");
        }

        // Add store_name column
        final storeNameExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='store_name'",
            ).getSingle();
        if (storeNameExists.data['count'] == 0) {
          await customStatement("ALTER TABLE bills ADD COLUMN store_name TEXT");
        }

        // Add d_meter_box column
        final dMeterBoxExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='d_meter_box'",
            ).getSingle();
        if (dMeterBoxExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN d_meter_box REAL NOT NULL DEFAULT 0.0",
          );
        }

        // Add md_npv_amount column
        final mdNpvAmountExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='md_npv_amount'",
            ).getSingle();
        if (mdNpvAmountExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN md_npv_amount REAL NOT NULL DEFAULT 0.0",
          );
        }

        // Add empty_oil_drum column
        final emptyOilDrumExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='empty_oil_drum'",
            ).getSingle();
        if (emptyOilDrumExists.data['count'] == 0) {
          await customStatement(
            "ALTER TABLE bills ADD COLUMN empty_oil_drum REAL NOT NULL DEFAULT 0.0",
          );
        }
      }
      if (from < 14) {
        // Helper inline function to safely add column
        Future<void> addSafe(String col, String def) async {
          final res =
              await customSelect(
                "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='$col'",
              ).getSingle();
          if (res.data['count'] == 0) {
            await customStatement("ALTER TABLE bills ADD COLUMN $col $def");
          }
        }

        await addSafe('d_meter_box_status', "TEXT NOT NULL DEFAULT 'Pending'");
        await addSafe('d_meter_box_released_date', "INTEGER");

        await addSafe('md_npv_status', "TEXT NOT NULL DEFAULT 'Pending'");
        await addSafe('md_npv_released_date', "INTEGER");

        await addSafe(
          'empty_oil_drum_status',
          "TEXT NOT NULL DEFAULT 'Pending'",
        );
        await addSafe('empty_oil_drum_released_date', "INTEGER");
      }
      if (from < 15) {
        // Helper inline function to safely add column
        Future<void> addSafe(String col, String def) async {
          final res =
              await customSelect(
                "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='$col'",
              ).getSingle();
          if (res.data['count'] == 0) {
            await customStatement("ALTER TABLE bills ADD COLUMN $col $def");
          }
        }

        await addSafe('d_meter_box_remark', "TEXT");
        await addSafe('md_npv_remark', "TEXT");
        await addSafe('empty_oil_drum_remark', "TEXT");
      }
      if (from < 16) {
        Future<void> addSafe(String col, String def) async {
          final res =
              await customSelect(
                "SELECT COUNT(*) as count FROM pragma_table_info('bills') WHERE name='$col'",
              ).getSingle();
          if (res.data['count'] == 0) {
            await customStatement("ALTER TABLE bills ADD COLUMN $col $def");
          }
        }

        await addSafe('scrap_invoice_no', "TEXT");
        await addSafe('scrap_invoice_date', "INTEGER");
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await _seed();
      }
    },
  );

  Future<void> _seed() async {
    // Insert DISCOM firms (utilities)
    await batch((batch) {
      batch.insertAll(firms, [
        FirmsCompanion.insert(
          name: 'AVVNL',
          code: 'AVVNL',
          description: const Value('Ajmer Vidyut Vitran Nigam Limited'),
        ),
        FirmsCompanion.insert(
          name: 'JVVNL',
          code: 'JVVNL',
          description: const Value('Jaipur Vidyut Vitran Nigam Limited'),
        ),
        FirmsCompanion.insert(
          name: 'JDVVNL',
          code: 'JDVVNL',
          description: const Value('Jodhpur Vidyut Vitran Nigam Limited'),
        ),
      ]);
    });

    // Insert supplier firms (for bills)
    await batch((batch) {
      batch.insertAll(firms, [
        FirmsCompanion.insert(
          name: 'Doon Infrapower Projects Pvt Ltd',
          code: 'DIPP',
          description: const Value('Supplier - Power Infrastructure'),
        ),
        FirmsCompanion.insert(
          name: 'B Hi Tech Power Transformer',
          code: 'BHPT',
          description: const Value('Supplier - Transformers'),
        ),
        FirmsCompanion.insert(
          name: 'Doon Electrical Industries',
          code: 'DEI',
          description: const Value('Supplier - Electrical Equipment'),
        ),
      ]);
    });

    final avvnl =
        await (select(firms)
          ..where((tbl) => tbl.name.equals('AVVNL'))).getSingle();
    final now = DateTime.now();

    final tenderId = await into(tenders).insert(
      TendersCompanion.insert(
        firmId: avvnl.id,
        tnNumber: 'TN-001',
        poNumber: const Value('PO-45/2025'),
        workDescription: const Value('Three Transformer Repairing'),
      ),
    );

    final billId = await into(bills).insert(
      BillsCompanion.insert(
        tenderId: Value(tenderId),
        firmId: avvnl.id,
        tnNumber: 'TN-001',
        billDate: now.subtract(const Duration(days: 20)),
        dueDate: now.add(const Duration(days: 10)),
        amount: const Value(250000.0),
        invoiceAmount: const Value(250000.0),
        csdAmount: const Value(25000.0),
        billPassAmount: const Value(200000.0),
        csdReleasedDate: Value(now.subtract(const Duration(days: 15))),
        scrapAmount: const Value(0.0),
        scrapGstAmount: const Value(0.0),
        mdLdAmount: const Value(0.0),
        emptyOilIssued: const Value(10.0),
        emptyOilReturned: const Value(6.0),
        tdsAmount: const Value(5000.0),
        tcsAmount: const Value(2500.0),
        gstTdsAmount: const Value(5000.0),
        dueReleaseDate: Value(now.add(const Duration(days: 5))),
        invoiceNo: const Value('INV-8801'),
        invoiceDate: Value(now.subtract(const Duration(days: 25))),
        workOrderNo: const Value('WO-5521'),
        workOrderDate: Value(now.subtract(const Duration(days: 30))),
        consignmentName: const Value('Transformer Consignment'),
        remarks: const Value('Initial seeded bill'),
      ),
    );

    await into(payments).insert(
      PaymentsCompanion.insert(
        billId: billId,
        paymentDate: now.subtract(const Duration(days: 6)),
        amountPaid: const Value(200000.0),
        paidDate: Value(now.subtract(const Duration(days: 5))),
        transactionNo: const Value('TXN-87234'),
        invoiceNo: const Value('INV-8801'),
        invoiceDate: Value(now.subtract(const Duration(days: 25))),
        workOrderNo: const Value('WO-5521'),
        workOrderDate: Value(now.subtract(const Duration(days: 30))),
        consignmentName: const Value('Transformer Consignment'),
        remarks: const Value('Initial seed payment'),
      ),
    );
  }

  Future<void> _seedClientFirms() async {
    // Insert client/contractor firms (user's own companies)
    await batch((batch) {
      batch.insertAll(clientFirms, [
        ClientFirmsCompanion.insert(
          firmName: 'Doon Infrapower Projects Pvt Ltd',
          address: const Value('Industrial Area, Dehradun, Uttarakhand'),
          contactNo: const Value('+91-9876543210'),
          gstNo: const Value('05AAACD1234E1Z5'),
        ),
        ClientFirmsCompanion.insert(
          firmName: 'B Hi Tech Power Transformer',
          address: const Value('SIDCUL, Haridwar, Uttarakhand'),
          contactNo: const Value('+91-9876543211'),
          gstNo: const Value('05BBBCD5678F2Z6'),
        ),
        ClientFirmsCompanion.insert(
          firmName: 'Doon Electrical Industries',
          address: const Value('Patel Nagar, Dehradun, Uttarakhand'),
          contactNo: const Value('+91-9876543212'),
          gstNo: const Value('05CCCCD9012G3Z7'),
        ),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final envPath = Platform.environment['APPDATA'];
    String basePath;

    if (envPath != null && envPath.isNotEmpty) {
      basePath = p.join(envPath, 'DISCOMBillManager');
    } else {
      final supportDir = await getApplicationSupportDirectory();
      basePath = p.join(supportDir.path, 'DISCOMBillManager');
    }

    final dbFile = File(p.join(basePath, 'data.db'));

    if (!await dbFile.parent.exists()) {
      await dbFile.parent.create(recursive: true);
    }

    return NativeDatabase.createInBackground(dbFile);
  });
}
