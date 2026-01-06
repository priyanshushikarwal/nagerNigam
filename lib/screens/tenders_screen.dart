import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tender.dart';
import '../services/tender_service.dart';
import '../core/premium_theme.dart';
import 'tender_form_dialog.dart';
import 'tender_bills_screen.dart';
import '../state/firm_providers.dart';
import '../state/client_firm_providers.dart';
import '../state/database_providers.dart';
import '../services/sync_service.dart';

class TendersScreen extends ConsumerStatefulWidget {
  const TendersScreen({super.key});

  @override
  ConsumerState<TendersScreen> createState() => _TendersScreenState();
}

class _TendersScreenState extends ConsumerState<TendersScreen> {
  final TenderService _tenderService = TenderService();
  List<Tender> _tenders = [];
  List<Tender> _filteredTenders = [];
  bool _isLoading = true;
  int? _selectedClientFirmId; // Client firm filter

  @override
  void initState() {
    super.initState();
    _loadTenders();
  }

  Future<void> _loadTenders() async {
    final firm = ref.read(selectedFirmProvider);
    if (firm == null || firm.id == null) return;

    setState(() => _isLoading = true);
    try {
      final tenders = await _tenderService.getTendersByFirm(firm.id!);
      if (!mounted) return;

      setState(() => _tenders = tenders);
      await _applyFilters();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Error'),
                content: Text('Failed to load tenders: $e'),
                severity: InfoBarSeverity.error,
              ),
        );
      }
    }
  }

  Future<void> _applyFilters() async {
    if (_selectedClientFirmId == null) {
      setState(() => _filteredTenders = _tenders);
      return;
    }

    // Get all bills for this firm and check which tenders have bills with the selected client firm
    final firm = ref.read(selectedFirmProvider);
    if (firm == null || firm.id == null) return;

    final billsDao = ref.read(billsDaoProvider);
    final allBills = await billsDao.getBillsByFirm(firm.id!);

    final tenderIds =
        allBills
            .where((b) => b.clientFirmId == _selectedClientFirmId)
            .map((b) => b.tenderId)
            .whereType<int>()
            .toSet();

    setState(() {
      _filteredTenders =
          _tenders.where((t) => tenderIds.contains(t.id)).toList();
    });
  }

  Future<void> _showTenderFormDialog({Tender? tender}) async {
    final firm = ref.read(selectedFirmProvider);
    if (firm == null || firm.id == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TenderFormDialog(firmId: firm.id!, tender: tender),
    );

    if (result == true) {
      _loadTenders();
    }
  }

  Future<void> _handleDelete(Tender tender) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete TN "${tender.tnNumber}"?\n\n'
              'This will not delete associated bills, but will unlink them from this TN.',
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

    if (confirmed == true) {
      try {
        final wasDeleted = await _tenderService.deleteTender(tender.id!);

        if (!wasDeleted) {
          if (mounted) {
            displayInfoBar(
              context,
              builder:
                  (context, close) => InfoBar(
                    title: const Text('Warning'),
                    content: const Text('TN not found or could not be deleted'),
                    severity: InfoBarSeverity.warning,
                  ),
            );
          }
          return;
        }

        // Also delete from Supabase cloud
        await ref
            .read(syncServiceProvider.notifier)
            .deleteTenderFromCloud(tender.id!);

        _loadTenders();
        if (mounted) {
          displayInfoBar(
            context,
            builder:
                (context, close) => InfoBar(
                  title: const Text('Success'),
                  content: const Text('TN deleted successfully'),
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
                  content: Text('Failed to delete TN: $e'),
                  severity: InfoBarSeverity.error,
                ),
          );
        }
      }
    }
  }

  void _navigateToTenderBills(Tender tender) {
    if (tender.id == null) return;

    Navigator.push(
      context,
      FluentPageRoute(
        builder: (context) => TenderBillsScreen(tenderId: tender.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firm = ref.watch(selectedFirmProvider);
    if (firm == null) {
      return const ScaffoldPage(
        content: Center(child: Text('No DISCOM selected')),
      );
    }

    final typography = FluentTheme.of(context).typography;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spacingL),
            decoration: const BoxDecoration(
              color: PremiumTheme.pureWhite,
              border: Border(
                bottom: BorderSide(color: PremiumTheme.borderColor, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tender Numbers (TN)', style: typography.title),
                    const SizedBox(height: PremiumTheme.spacingXS),
                    Text(
                      firm.name,
                      style: typography.body?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () => _showTenderFormDialog(),
                  child: const Row(
                    children: [
                      Icon(FluentIcons.add, size: 16),
                      SizedBox(width: PremiumTheme.spacingXS),
                      Text('Add TN'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumTheme.spacingL,
              vertical: PremiumTheme.spacingM,
            ),
            child: Row(
              children: [
                // Client Firm Filter
                Text(
                  'Filter by Client Firm:',
                  style: FluentTheme.of(context).typography.bodyStrong,
                ),
                const SizedBox(width: PremiumTheme.spacingM),
                SizedBox(
                  width: 250,
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
                        error:
                            (err, stack) => const Text('Error loading firms'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                _isLoading
                    ? const Center(child: ProgressRing())
                    : _filteredTenders.isEmpty
                    ? _buildEmptyState()
                    : _buildTenderTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FluentIcons.document,
            size: 48,
            color: PremiumTheme.textSecondary,
          ),
          const SizedBox(height: PremiumTheme.spacingM),
          Text(
            'No tenders found',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          const SizedBox(height: PremiumTheme.spacingS),
          Text(
            'Click "Add TN" to create your first tender',
            style: FluentTheme.of(
              context,
            ).typography.body?.copyWith(color: PremiumTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTenderTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumTheme.spacingL),
      child: Container(
        decoration: BoxDecoration(
          color: PremiumTheme.pureWhite,
          border: Border.all(color: PremiumTheme.borderColor),
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadius),
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5), // TN Number
            1: FlexColumnWidth(2.0), // PO Number
            2: FlexColumnWidth(3.0), // Work Description
            3: FlexColumnWidth(0.8), // Bills
            4: FlexColumnWidth(0.8), // Paid
            5: FlexColumnWidth(0.8), // Pending
            6: FlexColumnWidth(0.8), // Overdue
            7: FlexColumnWidth(1.5), // Actions
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: PremiumTheme.borderColor),
          ),
          children: [
            _buildTableHeader(),
            ..._filteredTenders.map((tender) => _buildTableRow(tender)),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    final headerStyle = FluentTheme.of(
      context,
    ).typography.bodyStrong?.copyWith(color: PremiumTheme.textPrimary);

    return TableRow(
      decoration: const BoxDecoration(color: PremiumTheme.cardBackground),
      children: [
        _buildHeaderCell('TN Number', headerStyle),
        _buildHeaderCell('PO Number', headerStyle),
        _buildHeaderCell('Work Description', headerStyle),
        _buildHeaderCell('Bills', headerStyle),
        _buildHeaderCell('Paid', headerStyle),
        _buildHeaderCell('Pending', headerStyle),
        _buildHeaderCell('Overdue', headerStyle),
        _buildHeaderCell('Actions', headerStyle),
      ],
    );
  }

  Widget _buildHeaderCell(String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spacingM),
      child: Text(text, style: style),
    );
  }

  TableRow _buildTableRow(Tender tender) {
    final cellStyle = FluentTheme.of(context).typography.body;

    return TableRow(
      children: [
        _buildDataCell(tender.tnNumber, cellStyle),
        _buildDataCell(tender.poNumber ?? '-', cellStyle),
        _buildDataCell(tender.workDescription ?? '-', cellStyle, maxLines: 2),
        _buildCountCell(tender.totalBills ?? 0, cellStyle),
        _buildCountCell(
          tender.paidBills ?? 0,
          cellStyle,
          color: PremiumTheme.successGreen,
        ),
        _buildCountCell(
          tender.pendingBills ?? 0,
          cellStyle,
          color: PremiumTheme.infoBlue,
        ),
        _buildCountCell(
          tender.overdueBills ?? 0,
          cellStyle,
          color: PremiumTheme.errorRed,
        ),
        _buildActionsCell(tender),
      ],
    );
  }

  Widget _buildDataCell(String text, TextStyle? style, {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spacingM),
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      ),
    );
  }

  Widget _buildCountCell(int count, TextStyle? style, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spacingM),
      child: Text(
        count.toString(),
        style: style?.copyWith(
          color: color,
          fontWeight: color != null ? FontWeight.w600 : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionsCell(Tender tender) {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spacingS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button(
            onPressed: () => _navigateToTenderBills(tender),
            child: const Text('View'),
          ),
          const SizedBox(width: PremiumTheme.spacingXS),
          IconButton(
            icon: const Icon(FluentIcons.edit, size: 16),
            onPressed: () => _showTenderFormDialog(tender: tender),
          ),
          const SizedBox(width: PremiumTheme.spacingXS),
          IconButton(
            icon: const Icon(
              FluentIcons.delete,
              size: 16,
              color: PremiumTheme.errorRed,
            ),
            onPressed: () => _handleDelete(tender),
          ),
        ],
      ),
    );
  }
}
