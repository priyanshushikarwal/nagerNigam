import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/premium_theme.dart';
import '../models/bill.dart';
import '../models/tender.dart';
import '../state/database_providers.dart';
import '../state/firm_providers.dart';
import '../state/tender_providers.dart';
import '../state/service_providers.dart';
import '../services/sync_service.dart';
import '../widgets/widgets.dart';
import 'comprehensive_bill_form.dart';
import 'tender_form_dialog.dart';

class BillListScreen extends ConsumerStatefulWidget {
  final int tenderId;
  final Tender? tender;

  const BillListScreen({super.key, required this.tenderId, this.tender});

  @override
  ConsumerState<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends ConsumerState<BillListScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final _dateFormat = DateFormat('dd-MM-yyyy');
  bool _isExporting = false;
  static const int _tnFlex = 2;
  static const int _invoiceNoFlex = 2;
  static const int _billDateFlex = 2;
  static const int _workOrderNoFlex = 2;
  static const int _workOrderDateFlex = 2;
  static const int _invoiceAmountFlex = 2;
  static const int _statusFlex = 2;

  Tender? _resolveTender() {
    Tender? resolved = widget.tender;
    final tenders = ref.watch(firmTendersProvider).asData?.value;
    if (resolved == null && tenders != null) {
      for (final tender in tenders) {
        if (tender.id == widget.tenderId) {
          resolved = tender;
          break;
        }
      }
    }
    return resolved;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Overdue':
        return Colors.red;
      case 'DueSoon':
        return Colors.orange;
      case 'Release':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spacingM,
        vertical: PremiumTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'DueSoon':
        return 'Due Soon';
      default:
        return status;
    }
  }

  Widget _buildSummaryChip(String label, int value, {Color? color}) {
    final chipColor = color ?? FluentTheme.of(context).accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spacingM,
        vertical: PremiumTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.pureWhite,
        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
        border: Border.all(color: chipColor.withOpacity(0.2), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumTheme.spacingS,
              vertical: PremiumTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: chipColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: chipColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: PremiumTheme.spacingS),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: PremiumTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBillDialog({Bill? bill}) async {
    final firm = ref.read(selectedFirmProvider);
    if (firm == null || firm.id == null) {
      _showInfoBar(
        'Please select a DISCOM before managing bills.',
        InfoBarSeverity.warning,
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder:
          (context) =>
              ComprehensiveBillFormDialog(firmId: firm.id!, bill: bill),
    );

    ref.invalidate(billsByTenderProvider(widget.tenderId));
    ref.invalidate(tenderStatsProvider(widget.tenderId));
    ref.invalidate(firmTendersProvider);
  }

  void _showInfoBar(String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder:
          (context, close) => InfoBar(
            title: const Text('Notice'),
            content: Text(message),
            severity: severity,
          ),
    );
  }

  Future<void> _exportTenderSummary() async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final path = await pdfService.exportTenderSummaryPdf(
        tenderId: widget.tenderId,
      );
      _showInfoBar('TN summary exported to\n$path', InfoBarSeverity.success);
    } catch (e) {
      _showInfoBar('Failed to export TN summary: $e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportPaymentDetails() async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final path = await pdfService.exportPaymentDetailsPdf(
        tenderId: widget.tenderId,
      );
      _showInfoBar(
        'Payment details exported to\n$path',
        InfoBarSeverity.success,
      );
    } catch (e) {
      _showInfoBar(
        'Failed to export payment details: $e',
        InfoBarSeverity.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _generateOfficialPdf({Bill? bill}) async {
    if (bill != null && bill.id == null) {
      _showInfoBar(
        'Please save the bill before exporting.',
        InfoBarSeverity.warning,
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final path = await pdfService.generateBillPdf(
        billId: bill?.id,
        tenderId: bill == null ? widget.tenderId : null,
      );
      _showInfoBar('Bill PDF ready. Saved to\n$path', InfoBarSeverity.success);
    } catch (e) {
      _showInfoBar('Failed to generate bill PDF: $e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _editTender() async {
    final tender = _resolveTender();
    if (tender == null || tender.id == null) {
      _showInfoBar('Tender not found', InfoBarSeverity.error);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => TenderFormDialog(firmId: tender.firmId, tender: tender),
    );

    if (result == true) {
      // Refresh the tender data
      ref.invalidate(firmTendersProvider);
      _showInfoBar('TN updated successfully', InfoBarSeverity.success);
    }
  }

  Future<void> _deleteTender() async {
    final tender = _resolveTender();
    if (tender == null || tender.id == null) {
      _showInfoBar('Tender not found', InfoBarSeverity.error);
      return;
    }

    // Check if there are any bills
    final billsAsync = ref.read(billsByTenderProvider(widget.tenderId));
    final bills = billsAsync.asData?.value ?? [];

    if (bills.isNotEmpty) {
      _showInfoBar(
        'Cannot delete TN with existing bills. Please delete all bills first.',
        InfoBarSeverity.warning,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Delete TN'),
            content: Text(
              'Are you sure you want to delete TN ${tender.tnNumber}?\n\nThis action cannot be undone.',
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: ButtonStyle(
                  backgroundColor: ButtonState.all(Colors.red),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      final tnDao = ref.read(tnDaoProvider);
      final wasDeleted = await tnDao.deleteTender(tender.id!);

      if (!wasDeleted) {
        _showInfoBar(
          'TN not found or could not be deleted',
          InfoBarSeverity.warning,
        );
        return;
      }

      // Also delete from Supabase cloud
      await ref
          .read(syncServiceProvider.notifier)
          .deleteTenderFromCloud(tender.id!);

      ref.invalidate(firmTendersProvider);

      if (mounted) {
        _showInfoBar('TN deleted successfully', InfoBarSeverity.success);
        // Navigate back to tenders list
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/tenders');
        }
      }
    } catch (e) {
      _showInfoBar('Failed to delete TN: $e', InfoBarSeverity.error);
    }
  }

  Widget _buildBillsTable(List<Bill> bills, Tender? tender) {
    if (bills.isEmpty) {
      return Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: Center(
              child: Text(
                'No bills recorded for this TN yet.',
                style: FluentTheme.of(context).typography.body,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTableHeader(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(
              left: 0,
              right: 0,
              top: PremiumTheme.spacingXS,
              bottom: PremiumTheme.spacingL,
            ),
            itemBuilder: (context, index) {
              final bill = bills[index];
              final tnNumber = tender?.tnNumber ?? bill.tnNumber;
              return _buildTableRow(bill, tnNumber: tnNumber);
            },
            separatorBuilder:
                (_, __) => const SizedBox(height: PremiumTheme.spacingM),
            itemCount: bills.length,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PremiumTheme.spacingL,
        PremiumTheme.spacingM,
        PremiumTheme.spacingL,
        PremiumTheme.spacingS,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumTheme.spacingM,
          vertical: PremiumTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: PremiumTheme.cardBackground,
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
          border: Border.all(color: PremiumTheme.borderColor, width: 1),
        ),
        child: Row(
          children: [
            _headerCell('TN Number', flex: _tnFlex),
            _headerCell('Invoice No', flex: _invoiceNoFlex),
            _headerCell('Bill Date', flex: _billDateFlex),
            _headerCell('Work Order No', flex: _workOrderNoFlex),
            _headerCell('Work Order Date', flex: _workOrderDateFlex),
            _headerCell(
              'Invoice Amount',
              flex: _invoiceAmountFlex,
              align: TextAlign.right,
            ),
            _headerCell('Status', flex: _statusFlex),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(Bill bill, {required String tnNumber}) {
    final invoiceValue = bill.invoiceAmount;
    final status = Bill.calculateStatus(bill, bill.payments ?? const []);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spacingL),
      child: GestureDetector(
        onTap: () {
          // Navigate to bill details screen
          if (bill.id != null) {
            context.push('/bills/${bill.id}');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PremiumTheme.spacingM,
            vertical: PremiumTheme.spacingM,
          ),
          decoration: BoxDecoration(
            color: PremiumTheme.pureWhite,
            borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
            border: Border.all(color: PremiumTheme.borderColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _dataCell(tnNumber, flex: _tnFlex),
              _dataCell(_formatOptional(bill.invoiceNo), flex: _invoiceNoFlex),
              _dataCell(_dateFormat.format(bill.billDate), flex: _billDateFlex),
              _dataCell(
                _formatOptional(bill.workOrderNo),
                flex: _workOrderNoFlex,
              ),
              _dataCell(
                _formatDateValue(bill.workOrderDate),
                flex: _workOrderDateFlex,
              ),
              _dataCell(
                _currencyFormat.format(invoiceValue),
                flex: _invoiceAmountFlex,
                align: TextAlign.right,
              ),
              _statusCell(status, flex: _statusFlex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(
    String label, {
    required int flex,
    TextAlign align = TextAlign.left,
  }) {
    final baseStyle =
        FluentTheme.of(context).typography.bodyStrong ??
        const TextStyle(fontWeight: FontWeight.w600);
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spacingXS),
        child: Text(
          label,
          style: baseStyle.copyWith(color: PremiumTheme.textSecondary),
          textAlign: align,
        ),
      ),
    );
  }

  Widget _dataCell(
    String value, {
    required int flex,
    TextAlign align = TextAlign.left,
  }) {
    final textStyle =
        FluentTheme.of(context).typography.body ??
        const TextStyle(fontSize: 14);
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spacingXS),
        child: Text(
          value,
          style: textStyle,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _statusCell(String status, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spacingXS),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _buildStatusBadge(status),
        ),
      ),
    );
  }

  String _formatOptional(String? value) {
    if (value == null) {
      return '-';
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? '-' : trimmed;
  }

  String _formatDateValue(DateTime? value) {
    return value != null ? _dateFormat.format(value) : '-';
  }

  @override
  Widget build(BuildContext context) {
    final tender = _resolveTender();
    final statsAsync = ref.watch(tenderStatsProvider(widget.tenderId));
    final billsAsync = ref.watch(billsByTenderProvider(widget.tenderId));

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Breadcrumbs
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumTheme.spacingL,
              vertical: PremiumTheme.spacingS,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border(
                bottom: BorderSide(color: PremiumTheme.borderColor, width: 1),
              ),
            ),
            child: AppBreadcrumbs(
              items: [
                AppBreadcrumbItem(label: 'Dashboard', route: '/dashboard'),
                AppBreadcrumbItem(label: 'Tenders', route: '/tenders'),
                AppBreadcrumbItem(
                  label:
                      tender != null
                          ? 'TN ${tender.tnNumber}'
                          : 'TN ${widget.tenderId}',
                  route: '/tenders/${widget.tenderId}/bills',
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(PremiumTheme.spacingL),
            decoration: const BoxDecoration(
              color: PremiumTheme.pureWhite,
              border: Border(
                bottom: BorderSide(color: PremiumTheme.borderColor, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(FluentIcons.back, size: 20),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/tenders');
                        }
                      },
                    ),
                    const SizedBox(width: PremiumTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tender != null
                                      ? 'TN ${tender.tnNumber}'
                                      : 'TN ${widget.tenderId}',
                                  style:
                                      FluentTheme.of(context).typography.title,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(FluentIcons.edit, size: 18),
                                onPressed: _editTender,
                                style: ButtonStyle(
                                  backgroundColor: ButtonState.resolveWith((
                                    states,
                                  ) {
                                    if (states.isHovering) {
                                      return Colors.blue.withOpacity(0.1);
                                    }
                                    return Colors.transparent;
                                  }),
                                ),
                              ),
                              const SizedBox(width: PremiumTheme.spacingS),
                              IconButton(
                                icon: const Icon(FluentIcons.delete, size: 18),
                                onPressed: _deleteTender,
                                style: ButtonStyle(
                                  backgroundColor: ButtonState.resolveWith((
                                    states,
                                  ) {
                                    if (states.isHovering) {
                                      return Colors.red.withOpacity(0.1);
                                    }
                                    return Colors.transparent;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          if (tender?.poNumber != null &&
                              tender!.poNumber!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: PremiumTheme.spacingXS,
                              ),
                              child: Text(
                                'PO: ${tender.poNumber}',
                                style: FluentTheme.of(
                                  context,
                                ).typography.caption?.copyWith(
                                  color: PremiumTheme.textSecondary,
                                ),
                              ),
                            ),
                          if (tender?.workDescription != null &&
                              tender!.workDescription!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: PremiumTheme.spacingXS,
                              ),
                              child: Text(
                                tender.workDescription!,
                                style: FluentTheme.of(
                                  context,
                                ).typography.body!.copyWith(
                                  color: PremiumTheme.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PremiumTheme.spacingM),
                Wrap(
                  spacing: PremiumTheme.spacingM,
                  runSpacing: PremiumTheme.spacingS,
                  alignment: WrapAlignment.end,
                  children: [
                    Button(
                      onPressed: _isExporting ? null : _exportTenderSummary,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(FluentIcons.pdf, size: 16),
                          SizedBox(width: PremiumTheme.spacingXS),
                          Text('Export TN PDF'),
                        ],
                      ),
                    ),
                    Button(
                      onPressed: _isExporting ? null : _exportPaymentDetails,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(FluentIcons.payment_card, size: 16),
                          SizedBox(width: PremiumTheme.spacingXS),
                          Text('Print Payment Details'),
                        ],
                      ),
                    ),
                    Button(
                      onPressed: _isExporting ? null : _generateOfficialPdf,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(FluentIcons.print, size: 16),
                          SizedBox(width: PremiumTheme.spacingXS),
                          Text('Print Bill Format'),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _openBillDialog(),
                      child: const Text('Add Bill'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spacingL),
            decoration: const BoxDecoration(
              color: PremiumTheme.surfaceLight,
              border: Border(
                bottom: BorderSide(color: PremiumTheme.borderColor, width: 1),
              ),
            ),
            child: statsAsync.when(
              data: (stats) {
                return Wrap(
                  spacing: PremiumTheme.spacingM,
                  runSpacing: PremiumTheme.spacingM,
                  children: [
                    _buildSummaryChip('Total', stats.totalBills),
                    _buildSummaryChip(
                      'Paid',
                      stats.paidBills,
                      color: Colors.green,
                    ),
                    _buildSummaryChip(
                      'Pending',
                      stats.pendingBills,
                      color: Colors.orange,
                    ),
                    _buildSummaryChip(
                      'Overdue',
                      stats.overdueBills,
                      color: Colors.red,
                    ),
                    _buildSummaryChip(
                      'Due Soon',
                      stats.dueSoonBills,
                      color: Colors.teal,
                    ),
                  ],
                );
              },
              loading: () => const ProgressRing(),
              error:
                  (error, _) => InfoBar(
                    title: const Text('Failed to load stats'),
                    content: Text('$error'),
                    severity: InfoBarSeverity.error,
                  ),
            ),
          ),
          Expanded(
            child: billsAsync.when(
              data: (bills) => _buildBillsTable(bills, tender),
              loading: () => const Center(child: ProgressRing()),
              error:
                  (error, _) => InfoBar(
                    title: const Text('Failed to load bills'),
                    content: Text('$error'),
                    severity: InfoBarSeverity.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
