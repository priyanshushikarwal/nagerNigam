import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../screens/comprehensive_bill_form.dart';
import '../state/firm_providers.dart';
import '../state/database_providers.dart';
import '../state/tender_providers.dart';
import '../state/client_firm_providers.dart';
import '../services/sync_service.dart';

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Bill> _bills = [];
  List<Bill> _filteredBills = [];
  Set<int> _selectedBillIds = {}; // Multi-select
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'All';
  int? _selectedClientFirmId; // Client firm filter

  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    final selectedFirm = ref.read(selectedFirmProvider);
    if (selectedFirm == null) {
      context.go('/discom-selection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final billsDao = ref.read(billsDaoProvider);
      final bills = await billsDao.getBillsByFirm(selectedFirm.id!);
      setState(() {
        _bills = bills;
        _selectedBillIds.clear(); // Clear selection when reloading
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Error'),
                content: Text('Failed to load bills: $e'),
                severity: InfoBarSeverity.error,
              ),
        );
      }
    }
  }

  void _applyFilters() {
    List<Bill> filtered = _bills;

    // Apply status filter
    if (_statusFilter != 'All') {
      if (_statusFilter == 'Due Soon') {
        filtered =
            filtered.where((b) => b.isDueSoon && b.status != 'Paid').toList();
      } else if (_statusFilter == 'Overdue') {
        filtered = filtered.where((b) => b.isOverdue).toList();
      } else {
        filtered = filtered.where((b) => b.status == _statusFilter).toList();
      }
    }

    // Apply client firm filter
    if (_selectedClientFirmId != null) {
      filtered =
          filtered
              .where((b) => b.clientFirmId == _selectedClientFirmId)
              .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (b) =>
                    b.tnNumber.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (b.remarks?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    setState(() => _filteredBills = filtered);
  }

  // Get list of selected bills
  List<Bill> get _selectedBills =>
      _filteredBills.where((b) => _selectedBillIds.contains(b.id)).toList();

  // Calculate totals for selected bills
  Map<String, double> get _selectedTotals {
    final bills = _selectedBills;
    return {
      'billAmount': bills.fold(0.0, (sum, b) => sum + b.invoiceAmount),
      'csdAmount': bills.fold(0.0, (sum, b) => sum + b.csdAmount),
      'scrapAmount': bills.fold(
        0.0,
        (sum, b) => sum + (b.scrapAmount + b.scrapGstAmount),
      ),
      'tdsAmount': bills.fold(0.0, (sum, b) => sum + b.tdsAmount),
      'totalPaid': bills.fold(0.0, (sum, b) => sum + b.totalPaid),
      'dueAmount': bills.fold(0.0, (sum, b) => sum + b.dueAmount),
    };
  }

  // Toggle bill selection
  void _toggleBillSelection(int billId, bool selected) {
    setState(() {
      if (selected) {
        _selectedBillIds.add(billId);
      } else {
        _selectedBillIds.remove(billId);
      }
    });
  }

  // Toggle select all
  void _toggleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedBillIds = _filteredBills.map((b) => b.id!).toSet();
      } else {
        _selectedBillIds.clear();
      }
    });
  }

  // Update CSD Status

  Future<void> _handleSearch(String query) async {
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  void _handleFilterChange(String? filter) {
    if (filter != null) {
      setState(() => _statusFilter = filter);
      _applyFilters();
    }
  }

  Future<void> _showAddBillDialog() async {
    final selectedFirm = ref.read(selectedFirmProvider);
    if (selectedFirm == null) return;

    await showDialog<void>(
      context: context,
      builder:
          (context) => ComprehensiveBillFormDialog(firmId: selectedFirm.id!),
    );

    _loadBills(); // Refresh list
  }

  Future<void> _showEditBillDialog(Bill bill) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) =>
              ComprehensiveBillFormDialog(bill: bill, firmId: bill.firmId),
    );

    _loadBills(); // Refresh list
  }

  Future<void> _deleteBill(Bill bill) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Delete Bill'),
            content: Text(
              'Are you sure you want to delete bill ${bill.tnNumber}?',
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
          ),
    );

    if (result == true) {
      try {
        final billsDao = ref.read(billsDaoProvider);
        final wasDeleted = await billsDao.deleteBill(bill.id!);

        if (!wasDeleted) {
          if (mounted) {
            displayInfoBar(
              context,
              builder:
                  (context, close) => InfoBar(
                    title: const Text('Warning'),
                    content: const Text(
                      'Bill not found or could not be deleted',
                    ),
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

        if (mounted) {
          displayInfoBar(
            context,
            builder:
                (context, close) => InfoBar(
                  title: const Text('Success'),
                  content: const Text('Bill deleted successfully'),
                  severity: InfoBarSeverity.success,
                ),
          );
        }
        _loadBills();
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Bills Management',
                  style: FluentTheme.of(context).typography.title,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _showAddBillDialog,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.add, size: 16),
                      const SizedBox(width: 6),
                      const Text('Add New Bill'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters and Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Status Filter
                SizedBox(
                  width: 180,
                  child: ComboBox<String>(
                    value: _statusFilter,
                    items:
                        [
                              'All',
                              'Pending',
                              'Partially Paid',
                              'Paid',
                              'Overdue',
                              'Due Soon',
                            ]
                            .map(
                              (status) => ComboBoxItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                    onChanged: _handleFilterChange,
                  ),
                ),
                const SizedBox(width: 12),

                // Client Firm Filter
                SizedBox(
                  width: 220,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final clientFirmsAsync = ref.watch(clientFirmsProvider);
                      return clientFirmsAsync.when(
                        data: (firms) {
                          return ComboBox<int?>(
                            value: _selectedClientFirmId,
                            isExpanded: true,
                            placeholder: const Text('All Client Firms'),
                            items: [
                              const ComboBoxItem<int?>(
                                value: null,
                                child: Text('All Client Firms'),
                              ),
                              ...firms
                                  .where((f) => f.id != null)
                                  .map(
                                    (firm) => ComboBoxItem<int?>(
                                      value: firm.id,
                                      child: Text(firm.firmName),
                                    ),
                                  ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedClientFirmId = value;
                              });
                              _applyFilters();
                            },
                          );
                        },
                        loading: () => const ProgressRing(),
                        error: (err, stack) => const Text('Error'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Search
                Expanded(
                  child: TextBox(
                    controller: _searchController,
                    placeholder: 'Search by TN Number or Remarks...',
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(FluentIcons.search, size: 16),
                    ),
                    onChanged: _handleSearch,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bills Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: _buildBillsTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsTable() {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_filteredBills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.inbox, size: 48, color: Colors.grey[60]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty && _statusFilter == 'All'
                  ? 'No bills found'
                  : 'No matching bills',
              style: FluentTheme.of(context).typography.bodyLarge,
            ),
          ],
        ),
      );
    }

    final allSelected =
        _filteredBills.isNotEmpty &&
        _filteredBills.every((b) => _selectedBillIds.contains(b.id));
    final someSelected = _selectedBillIds.isNotEmpty;

    return Column(
      children: [
        // Selection Summary Bar (shown when bills are selected)
        if (someSelected)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: FluentTheme.of(context).accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: FluentTheme.of(
                  context,
                ).accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${_selectedBillIds.length} bills selected',
                  style: FluentTheme.of(context).typography.bodyStrong,
                ),
                const SizedBox(width: 24),
                _buildTotalChip('Bill Amount', _selectedTotals['billAmount']!),
                _buildTotalChip('CSD Amount', _selectedTotals['csdAmount']!),
                _buildTotalChip(
                  'Scrap Amount',
                  _selectedTotals['scrapAmount']!,
                ),
                _buildTotalChip('Due Amount', _selectedTotals['dueAmount']!),
                const Spacer(),
                Button(
                  onPressed: () => _toggleSelectAll(false),
                  child: const Text('Clear Selection'),
                ),
              ],
            ),
          ),

        // Table
        Expanded(
          child: ListView(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    // Select All Checkbox with square style
                    Container(
                      width: 48,
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _toggleSelectAll(!allSelected),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                allSelected
                                    ? FluentTheme.of(context).accentColor
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  allSelected
                                      ? FluentTheme.of(context).accentColor
                                      : Colors.grey[80]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child:
                              allSelected
                                  ? const Icon(
                                    FluentIcons.check_mark,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('TN Number', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Invoice No', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Bill Date', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Due Date', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Amount', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Due Amount', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Status', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('CSD Status', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Remarks', style: _headerStyle()),
                    ),
                    const SizedBox(width: 120),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Table Rows
              ..._filteredBills.map((bill) => _buildBillRow(bill)),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for total chips in summary bar
  Widget _buildTotalChip(String label, double amount) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[40]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FluentTheme.of(
              context,
            ).typography.caption?.copyWith(color: Colors.grey[100]),
          ),
          Text(
            _currencyFormat.format(amount),
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(Bill bill) {
    Color statusColor = Colors.grey;
    if (bill.status == 'Paid') statusColor = Colors.green;
    if (bill.status == 'Partially Paid') statusColor = Colors.orange;
    if (bill.status == 'Pending' && bill.isDueSoon) statusColor = Colors.orange;
    if (bill.isOverdue) statusColor = Colors.red;

    final isSelected = _selectedBillIds.contains(bill.id);

    return HoverButton(
      onPressed: () => context.go('/bills/${bill.id}'),
      builder: (context, states) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? FluentTheme.of(
                      context,
                    ).accentColor.withValues(alpha: 0.08)
                    : states.isHovering
                    ? FluentTheme.of(
                      context,
                    ).accentColor.withValues(alpha: 0.05)
                    : FluentTheme.of(context).cardColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  isSelected
                      ? FluentTheme.of(
                        context,
                      ).accentColor.withValues(alpha: 0.4)
                      : states.isHovering
                      ? FluentTheme.of(
                        context,
                      ).accentColor.withValues(alpha: 0.2)
                      : FluentTheme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: Row(
            children: [
              // Checkbox with square style and margin
              Container(
                width: 48,
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _toggleBillSelection(bill.id!, !isSelected),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? FluentTheme.of(context).accentColor
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected
                                ? FluentTheme.of(context).accentColor
                                : Colors.grey[60]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              FluentIcons.check_mark,
                              size: 14,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ),
              ),
              Expanded(flex: 2, child: Text(bill.tnNumber)),
              Expanded(
                flex: 2,
                child: Text(
                  bill.invoiceNo ?? '-',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(flex: 2, child: Text(_dateFormat.format(bill.billDate))),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dateFormat.format(bill.dueDate)),
                    if (bill.isDueSoon || bill.isOverdue)
                      Text(
                        bill.isOverdue
                            ? 'Overdue by ${bill.daysUntilDue.abs()} days'
                            : 'Due in ${bill.daysUntilDue} days',
                        style: FluentTheme.of(
                          context,
                        ).typography.caption?.copyWith(
                          color: bill.isOverdue ? Colors.red : Colors.orange,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(_currencyFormat.format(bill.amount)),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currencyFormat.format(bill.dueAmount)),
                    if (bill.status == 'Partially Paid')
                      Text(
                        'Paid: ${_currencyFormat.format(bill.totalPaid)}',
                        style: FluentTheme.of(
                          context,
                        ).typography.caption?.copyWith(color: Colors.green),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bill.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // CSD Status Column with styled chip
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          bill.csdStatus == 'Released'
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            bill.csdStatus == 'Released'
                                ? Colors.green.withValues(alpha: 0.5)
                                : Colors.orange.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bill.csdStatus == 'Released'
                              ? FluentIcons.check_mark
                              : FluentIcons.clock,
                          size: 12,
                          color:
                              bill.csdStatus == 'Released'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bill.csdStatus,
                          style: TextStyle(
                            color:
                                bill.csdStatus == 'Released'
                                    ? Colors.green
                                    : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  bill.remarks ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ),
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(FluentIcons.view, size: 16),
                      onPressed: () => context.go('/bills/${bill.id}'),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.edit, size: 16),
                      onPressed: () => _showEditBillDialog(bill),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.delete, size: 16),
                      onPressed: () => _deleteBill(bill),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle? _headerStyle() {
    return FluentTheme.of(context).typography.bodyStrong;
  }
}

// Bill Form Dialog
