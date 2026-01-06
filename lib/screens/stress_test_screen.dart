import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/database_providers.dart';
import '../utils/stress_test_generator.dart';

class StressTestScreen extends ConsumerStatefulWidget {
  const StressTestScreen({super.key});

  @override
  ConsumerState<StressTestScreen> createState() => _StressTestScreenState();
}

class _StressTestScreenState extends ConsumerState<StressTestScreen> {
  int _tnCount = 500;
  int _minBillsPerTn = 3;
  int _maxBillsPerTn = 7;
  int _minPaymentsPerBill = 0;
  int _maxPaymentsPerBill = 3;

  bool _isGenerating = false;
  String _progressMessage = '';
  double _progress = 0.0;
  StressTestResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Stress Test Data Generator'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.back),
              label: const Text('Back'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningCard(),
            const SizedBox(height: 24),
            _buildConfigurationCard(),
            const SizedBox(height: 24),
            _buildActionsCard(),
            if (_lastResult != null) ...[
              const SizedBox(height: 24),
              _buildResultsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return InfoBar(
      title: const Text('⚠️ Warning'),
      content: const Text(
        'This tool generates large amounts of test data for performance testing. '
        'Use only in development/testing environments. Back up your database before proceeding.',
      ),
      severity: InfoBarSeverity.warning,
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration',
              style: FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 16),
            InfoLabel(
              label: 'Number of TNs to Generate:',
              child: NumberBox<int>(
                value: _tnCount,
                onChanged:
                    _isGenerating
                        ? null
                        : (value) {
                          if (value != null && value > 0 && value <= 10000) {
                            setState(() => _tnCount = value);
                          }
                        },
                min: 1,
                max: 10000,
                mode: SpinButtonPlacementMode.inline,
              ),
            ),
            const SizedBox(height: 12),
            InfoLabel(
              label: 'Bills per TN (Range):',
              child: Row(
                children: [
                  Expanded(
                    child: NumberBox<int>(
                      value: _minBillsPerTn,
                      onChanged:
                          _isGenerating
                              ? null
                              : (value) {
                                if (value != null &&
                                    value > 0 &&
                                    value <= _maxBillsPerTn) {
                                  setState(() => _minBillsPerTn = value);
                                }
                              },
                      min: 1,
                      max: 50,
                      mode: SpinButtonPlacementMode.inline,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: NumberBox<int>(
                      value: _maxBillsPerTn,
                      onChanged:
                          _isGenerating
                              ? null
                              : (value) {
                                if (value != null &&
                                    value >= _minBillsPerTn &&
                                    value <= 50) {
                                  setState(() => _maxBillsPerTn = value);
                                }
                              },
                      min: 1,
                      max: 50,
                      mode: SpinButtonPlacementMode.inline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InfoLabel(
              label: 'Payments per Bill (Range):',
              child: Row(
                children: [
                  Expanded(
                    child: NumberBox<int>(
                      value: _minPaymentsPerBill,
                      onChanged:
                          _isGenerating
                              ? null
                              : (value) {
                                if (value != null &&
                                    value >= 0 &&
                                    value <= _maxPaymentsPerBill) {
                                  setState(() => _minPaymentsPerBill = value);
                                }
                              },
                      min: 0,
                      max: 20,
                      mode: SpinButtonPlacementMode.inline,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: NumberBox<int>(
                      value: _maxPaymentsPerBill,
                      onChanged:
                          _isGenerating
                              ? null
                              : (value) {
                                if (value != null &&
                                    value >= _minPaymentsPerBill &&
                                    value <= 20) {
                                  setState(() => _maxPaymentsPerBill = value);
                                }
                              },
                      min: 0,
                      max: 20,
                      mode: SpinButtonPlacementMode.inline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Estimated data: ~${_tnCount * ((_minBillsPerTn + _maxBillsPerTn) / 2).round()} bills, '
              '~${(_tnCount * ((_minBillsPerTn + _maxBillsPerTn) / 2) * ((_minPaymentsPerBill + _maxPaymentsPerBill) / 2)).round()} payments',
              style: FluentTheme.of(context).typography.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isGenerating) ...[
              Text(
                _progressMessage,
                style: FluentTheme.of(context).typography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ProgressBar(value: _progress * 100),
              const SizedBox(height: 12),
              Text(
                '${(_progress * 100).toStringAsFixed(1)}% Complete',
                style: FluentTheme.of(context).typography.caption,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              FilledButton(
                onPressed: _generateData,
                child: const Text('🚀 Generate Stress Test Data'),
              ),
              const SizedBox(height: 12),
              Button(
                onPressed: _clearAllData,
                child: const Text('🗑️ Clear ALL Data (Danger!)'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _lastResult!.success
                      ? FluentIcons.completed
                      : FluentIcons.error,
                  color: _lastResult!.success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last Test Result',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _lastResult.toString(),
              style: FluentTheme.of(context).typography.body,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateData() async {
    setState(() {
      _isGenerating = true;
      _progressMessage = 'Initializing...';
      _progress = 0.0;
    });

    final database = ref.read(appDatabaseProvider);
    final billsDao = ref.read(billsDaoProvider);
    final tnDao = ref.read(tnDaoProvider);
    final paymentsDao = ref.read(paymentsDaoProvider);

    final generator = StressTestGenerator(
      database: database,
      billsDao: billsDao,
      tnDao: tnDao,
      paymentsDao: paymentsDao,
    );

    final result = await generator.generateData(
      tnCount: _tnCount,
      minBillsPerTn: _minBillsPerTn,
      maxBillsPerTn: _maxBillsPerTn,
      minPaymentsPerBill: _minPaymentsPerBill,
      maxPaymentsPerBill: _maxPaymentsPerBill,
      progressCallback: (message, progress) {
        setState(() {
          _progressMessage = message;
          _progress = progress;
        });
      },
    );

    setState(() {
      _isGenerating = false;
      _lastResult = result;
    });

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder:
            (context) => ContentDialog(
              title: Text(result.success ? '✅ Success!' : '❌ Failed'),
              content: Text(result.toString()),
              actions: [
                FilledButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('⚠️ Confirm Data Deletion'),
            content: const Text(
              'This will DELETE ALL tenders, bills, and payments from the database. '
              'This action CANNOT be undone. Are you absolutely sure?',
            ),
            actions: [
              Button(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              FilledButton(
                child: const Text('Yes, Delete Everything'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isGenerating = true;
      _progressMessage = 'Clearing all data...';
      _progress = 0.0;
    });

    final database = ref.read(appDatabaseProvider);
    final billsDao = ref.read(billsDaoProvider);
    final tnDao = ref.read(tnDaoProvider);
    final paymentsDao = ref.read(paymentsDaoProvider);

    final generator = StressTestGenerator(
      database: database,
      billsDao: billsDao,
      tnDao: tnDao,
      paymentsDao: paymentsDao,
    );

    await generator.clearAllData(
      progressCallback: (message) {
        setState(() => _progressMessage = message);
      },
    );

    setState(() {
      _isGenerating = false;
      _progressMessage = 'All data cleared successfully!';
      _lastResult = null;
    });

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder:
            (context) => ContentDialog(
              title: const Text('✅ Data Cleared'),
              content: const Text(
                'All test data has been removed from the database.',
              ),
              actions: [
                FilledButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }
}
