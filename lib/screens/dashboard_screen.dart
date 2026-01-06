import 'dart:io';
import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/tn_bill_stats.dart';
import '../screens/comprehensive_bill_form.dart';
import '../models/tender.dart';
import '../state/firm_providers.dart';
import '../state/database_providers.dart';
import '../state/service_providers.dart';
import '../state/client_firm_providers.dart';
import '../state/tender_providers.dart';
import '../services/sync_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, Future<TNBillStats>> _tnStatsCache = {};

  DashboardStats? _stats;
  List<Bill> _bills = [];
  bool _isLoading = true;
  bool _isExporting = false;
  Timer? _refreshTimer;
  DateTime? _lastRefresh;
  int? _selectedClientFirmId; // Filter by client firm

  List<Tender> _tenders = [];

  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final _dateFormat = DateFormat('dd-MM-yyyy');
  final _timeFormat = DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    // Auto-refresh every 5 minutes to update due soon/overdue status
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final firm = ref.read(selectedFirmProvider);
      if (firm == null || firm.id == null) return;

      final billsDao = ref.read(billsDaoProvider);
      final tnDao = ref.read(tnDaoProvider);

      final stats = await billsDao.getDashboardStats(firm.id!);
      final bills = await billsDao.getBillsByFirm(firm.id!);
      final tenders = await tnDao.getTendersByFirm(firm.id!);

      if (mounted) {
        setState(() {
          _stats = stats;
          _bills = bills;
          _tenders = tenders;
          _isLoading = false;
          _lastRefresh = DateTime.now();
          _tnStatsCache.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Error loading data'),
                content: Text(e.toString()),
                severity: InfoBarSeverity.error,
              ),
        );
      }
    }
  }

  Future<void> _exportToCSV() async {
    final selectedFirm = ref.read(selectedFirmProvider);
    if (selectedFirm == null) return;

    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final filePath = await exportService.exportBillsToCSV(
        firmId: selectedFirm.id!,
      );

      if (mounted) {
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Export Successful'),
                content: Text('Bills exported to:\n$filePath'),
                severity: InfoBarSeverity.success,
                action: Button(
                  child: const Text('Open Folder'),
                  onPressed: () {
                    // Open the exports folder
                    final dir = filePath.substring(
                      0,
                      filePath.lastIndexOf('\\'),
                    );
                    Process.run('explorer.exe', [dir]);
                  },
                ),
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Export Failed'),
                content: Text('Error: $e'),
                severity: InfoBarSeverity.error,
              ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPDF() async {
    final selectedFirm = ref.read(selectedFirmProvider);
    if (selectedFirm == null) return;

    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final filePath = await exportService.generateBillsReport(
        firmId: selectedFirm.id!,
      );

      if (mounted) {
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Report Generated'),
                content: Text('PDF report saved to:\n$filePath'),
                severity: InfoBarSeverity.success,
                action: Button(
                  child: const Text('Open Folder'),
                  onPressed: () {
                    // Open the exports folder
                    final dir = filePath.substring(
                      0,
                      filePath.lastIndexOf('\\'),
                    );
                    Process.run('explorer.exe', [dir]);
                  },
                ),
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Export Failed'),
                content: Text('Error: $e'),
                severity: InfoBarSeverity.error,
              ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showEditDialog(Bill bill) {
    showDialog(
      context: context,
      builder: (context) {
        return ComprehensiveBillFormDialog(
          bill: bill,
          firmId: ref.read(selectedFirmProvider)!.id!,
        );
      },
    ).then((result) {
      if (result == true) {
        _loadData(); // Reload data after edit
      }
    });
  }

  Future<void> _confirmDelete(Bill bill) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Delete Bill'),
          content: Text(
            'Are you sure you want to delete bill ${bill.tnNumber}?\n\nThis action cannot be undone.',
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final repository = ref.read(billsDaoProvider);
        final wasDeleted = await repository.deleteBill(bill.id!);

        if (!wasDeleted) {
          if (mounted) {
            displayInfoBar(
              context,
              builder:
                  (context, close) => const InfoBar(
                    title: Text('Warning'),
                    content: Text('Bill not found or could not be deleted'),
                    severity: InfoBarSeverity.warning,
                  ),
            );
          }
          return;
        }

        // Also delete from Supabase cloud
        await ref
            .read(syncServiceProvider.notifier)
            .deleteBillFromCloud(bill.id!);

        // Invalidate tender-related providers for proper UI refresh
        if (bill.tenderId != null) {
          ref.invalidate(billsByTenderProvider(bill.tenderId!));
          ref.invalidate(tenderStatsProvider(bill.tenderId!));
        }
        ref.invalidate(firmTendersProvider);

        _loadData(); // Reload data
        if (mounted) {
          displayInfoBar(
            context,
            builder:
                (context, close) => const InfoBar(
                  title: Text('Bill Deleted'),
                  content: Text('Bill deleted successfully'),
                  severity: InfoBarSeverity.success,
                ),
          );
        }
      } catch (e) {
        if (mounted) {
          displayInfoBar(
            context,
            builder:
                (context, close) => InfoBar(
                  title: const Text('Error'),
                  content: Text('Failed to delete bill: $e'),
                  severity: InfoBarSeverity.error,
                ),
          );
        }
      }
    }
  }

  Widget _buildResponsiveHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDE - Dashboard title and metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: FluentTheme.of(context).typography.title,
                ),
                if (_lastRefresh != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Last updated: ${_timeFormat.format(_lastRefresh!)}',
                        style: FluentTheme.of(context).typography.caption,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Auto-refreshes every 5 min',
                        style: FluentTheme.of(
                          context,
                        ).typography.caption?.copyWith(color: Colors.grey[100]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),

          // RIGHT SIDE - Wrapping action buttons
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  icon: FluentIcons.refresh,
                  label: 'Refresh',
                  onPressed: _isLoading ? null : _loadData,
                ),
                _buildActionButton(
                  icon: FluentIcons.save_as,
                  label: 'Export CSV',
                  onPressed:
                      _isLoading || _isExporting
                          ? null
                          : () {
                            _exportToCSV();
                          },
                ),
                _buildActionButton(
                  icon: FluentIcons.document_management,
                  label: 'Export PDF',
                  onPressed:
                      _isLoading || _isExporting
                          ? null
                          : () {
                            _exportToPDF();
                          },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: _buildResponsiveHeader(),
      children: [
        // Statistics Cards
        _buildStatsCards(),
        const SizedBox(height: 24),

        // TN List Section
        _buildTNListSection(),
        const SizedBox(height: 24),

        // Due Bills Reminder Section
        _buildDueBillsSection(),
      ],
    );
  }

  Widget _buildTNListSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 25,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tender Numbers (TN)',
                style: FluentTheme.of(context).typography.subtitle,
              ),
              FilledButton(
                onPressed: () => context.go('/tenders'),
                child: const Text('View All TNs'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_tenders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      FluentIcons.completed_solid,
                      size: 48,
                      color: Colors.grey[100],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tenders created yet',
                      style: FluentTheme.of(context).typography.body,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => context.go('/tenders'),
                      child: const Text('Create First TN'),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children:
                  _tenders
                      .take(5)
                      .map((tender) => _buildTenderCard(tender))
                      .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTenderCard(Tender tender) {
    void openDetails() {
      if (tender.id != null) {
        context.go('/tenders/${tender.id}/bills');
      }
    }

    final subtitleStyle = FluentTheme.of(
      context,
    ).typography.body?.copyWith(color: Colors.grey[110]);

    final billsRepository = ref.read(billsDaoProvider);
    final future =
        tender.id != null
            ? _tnStatsCache.putIfAbsent(
              tender.id!,
              () => billsRepository.getTNStats(tender.id!),
            )
            : null;

    return FutureBuilder<TNBillStats>(
      future: future,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final totalBills = stats?.totalBills ?? tender.totalBills ?? 0;
        final paidBills = stats?.paidBills ?? tender.paidBills ?? 0;
        final partiallyPaidBills = stats?.partiallyPaidBills ?? 0;
        final pendingBills = stats?.pendingBills ?? tender.pendingBills ?? 0;
        final overdueBills = stats?.overdueBills ?? tender.overdueBills ?? 0;
        final isLoadingStats =
            snapshot.connectionState == ConnectionState.waiting &&
            stats == null;

        return GestureDetector(
          onTap: tender.id == null ? null : openDetails,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tender.tnNumber,
                        style: FluentTheme.of(context).typography.subtitle
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if ((tender.poNumber ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tender.poNumber!,
                          style: FluentTheme.of(context).typography.caption,
                        ),
                      ],
                      if ((tender.workDescription ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(tender.workDescription!, style: subtitleStyle),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.end,
                  children: [
                    _buildStatusPill(
                      label: 'Bills',
                      count: totalBills,
                      background: const Color(0xFFF5F5F5),
                      textColor: Colors.grey[160],
                    ),
                    _buildStatusPill(
                      label: 'Paid',
                      count: paidBills,
                      background: const Color(0xFFE8F7EA),
                      textColor: const Color(0xFF1C7A33),
                    ),
                    if (partiallyPaidBills > 0)
                      _buildStatusPill(
                        label: 'Partial',
                        count: partiallyPaidBills,
                        background: const Color(0xFFFFF8E1),
                        textColor: const Color(0xFFFF8F00),
                      ),
                    _buildStatusPill(
                      label: 'Pending',
                      count: pendingBills,
                      background: const Color(0xFFF0F0F0),
                      textColor: Colors.black,
                    ),
                    _buildStatusPill(
                      label: 'Overdue',
                      count: overdueBills,
                      background: const Color(0xFFFFECEC),
                      textColor: const Color(0xFFB3261E),
                    ),
                    if (isLoadingStats)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: ProgressRing(),
                      ),
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(
                          const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: tender.id == null ? null : openDetails,
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusPill({
    required String label,
    required int count,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: Button(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildClientFirmFilterDropdown({
    double width = 240,
    bool useWhiteStyle = false,
  }) {
    final textStyle =
        useWhiteStyle
            ? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            : null;

    final placeholder =
        useWhiteStyle
            ? const Text(
              '          Filter by Client Firm',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 251, 251, 252),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            )
            : const Text(
              'Filter by Client Firm',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Builder(
        builder: (context) {
          final clientFirmsAsync = ref.watch(clientFirmsProvider);
          return clientFirmsAsync.when(
            data: (firms) {
              return ComboBox<int?>(
                value: _selectedClientFirmId,
                placeholder: placeholder,
                isExpanded: true,
                items: [
                  ComboBoxItem<int?>(
                    value: null,
                    child: Text(
                      'All Client Firms',
                      style: textStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...firms.where((firm) => firm.id != null).map((firm) {
                    return ComboBoxItem<int?>(
                      value: firm.id,
                      child: Text(
                        firm.firmName,
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedClientFirmId = value;
                  });
                },
              );
            },
            loading: () => const ProgressRing(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildDueBillsSection() {
    // Filter bills by client firm if selected
    final filteredBills =
        _selectedClientFirmId == null
            ? _bills
            : _bills
                .where((bill) => bill.clientFirmId == _selectedClientFirmId)
                .toList();

    final dueBills =
        filteredBills.where((bill) => bill.status != 'Paid').toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final highlighted = dueBills.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 25,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due Bills Reminder',
                style: FluentTheme.of(context).typography.subtitle,
              ),
              // Client Firm Filter
              _buildClientFirmFilterDropdown(width: 250, useWhiteStyle: true),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: ProgressRing())
          else if (highlighted.isEmpty)
            Column(
              children: [
                Icon(FluentIcons.check_mark, size: 42, color: Colors.green),
                const SizedBox(height: 12),
                Text(
                  'No pending or overdue bills. Great job!',
                  style: FluentTheme.of(context).typography.body,
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'TN Number',
                        style: FluentTheme.of(context).typography.bodyStrong,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Due Date',
                        style: FluentTheme.of(context).typography.bodyStrong,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        style: FluentTheme.of(context).typography.bodyStrong,
                      ),
                    ),
                    const SizedBox(width: 64),
                  ],
                ),
                const SizedBox(height: 12),
                ...highlighted.map(_buildDueBillRow),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => context.go('/bills'),
                    child: const Text('Open Bills Page'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDueBillRow(Bill bill) {
    final isOverdue = bill.isOverdue;
    final isDueSoon = bill.isDueSoon && !isOverdue;
    final statusColor =
        isOverdue
            ? Colors.red
            : isDueSoon
            ? Colors.orange
            : Colors.grey;
    final label =
        isOverdue
            ? 'Overdue by ${bill.daysUntilDue.abs()} days'
            : isDueSoon
            ? 'Due in ${bill.daysUntilDue} days'
            : bill.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              bill.tnNumber,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _dateFormat.format(bill.dueDate),
              style: FluentTheme.of(context).typography.body,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(FluentIcons.edit, size: 16),
                  onPressed: () => _showEditDialog(bill),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.delete, size: 16),
                  onPressed: () => _confirmDelete(bill),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    // Calculate unique client firms with bills
    final uniqueClientFirms =
        _bills
            .where((b) => b.clientFirmId != null)
            .map((b) => b.clientFirmId)
            .toSet()
            .length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Bills',
                _stats?.totalBills.toString() ?? '0',
                FluentIcons.bill,
                Colors.blue,
                subtitle: _currencyFormat.format(_stats?.totalAmount ?? 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Due Soon',
                _stats?.dueSoonBills.toString() ?? '0',
                FluentIcons.warning,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Overdue',
                _stats?.overdueBills.toString() ?? '0',
                FluentIcons.error,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Paid',
                _stats?.paidBills.toString() ?? '0',
                FluentIcons.completed,
                Colors.green,
                subtitle: _currencyFormat.format(_stats?.paidAmount ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Partially Paid',
                _stats?.partiallyPaidBills.toString() ?? '0',
                FluentIcons.progress_ring_dots,
                const Color(0xFFFF8F00),
                subtitle: 'Bills with partial payments',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Client Firms',
                uniqueClientFirms.toString(),
                FluentIcons.company_directory,
                Colors.purple,
                subtitle: 'Active firms with bills',
              ),
            ),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: FluentTheme.of(context).typography.title?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: FluentTheme.of(context).typography.caption),
          ],
        ],
      ),
    );
  }
}
