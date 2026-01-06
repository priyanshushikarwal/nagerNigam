import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/premium_theme.dart';
import '../models/bill.dart';
import '../models/payment_record.dart';
import '../state/database_providers.dart';
import '../state/firm_providers.dart';
import '../state/payment_providers.dart';
import 'comprehensive_payment_form.dart';

enum PaymentFilterRange { all, last30Days, last6Months }

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  PaymentFilterRange _selectedRange = PaymentFilterRange.all;
  bool _isBusy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firm = ref.watch(selectedFirmProvider);
    final paymentsAsync = ref.watch(paymentsForFirmProvider);
    final summary = ref.watch(paymentsSummaryProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Payments'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Add Payment'),
              onPressed: _isBusy ? null : () => _openAddPayment(),
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('Refresh'),
              onPressed: _isBusy ? null : _refresh,
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(PremiumTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (firm == null)
              Expanded(
                child: _buildPlaceholder(
                  'Select a DISCOM to view its payments.'
                  ' Use the top navigation to choose a firm first.',
                ),
              )
            else ...[
              _buildSummaryRow(summary),
              const SizedBox(height: PremiumTheme.spacingL),
              _buildFilters(),
              const SizedBox(height: PremiumTheme.spacingM),
              Expanded(
                child: paymentsAsync.when(
                  data: (records) {
                    final filtered = _applyFilters(records);
                    return _buildPaymentsList(filtered);
                  },
                  loading: () => const Center(child: ProgressRing()),
                  error:
                      (error, _) => Center(
                        child: InfoBar(
                          title: const Text('Unable to load payments'),
                          content: Text('$error'),
                          severity: InfoBarSeverity.error,
                        ),
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.money, size: 48, color: Colors.grey[100]),
          const SizedBox(height: PremiumTheme.spacingM),
          SizedBox(
            width: 420,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: FluentTheme.of(context).typography.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(PaymentsSummary summary) {
    return Wrap(
      spacing: PremiumTheme.spacingL,
      runSpacing: PremiumTheme.spacingL,
      children: [
        _buildSummaryCard(
          title: 'Total Paid',
          value: _currencyFormat.format(summary.totalAmount),
          icon: FluentIcons.calculator,
          color: Colors.green,
          subtitle:
              summary.paymentCount == 0
                  ? 'No payments yet'
                  : '${summary.paymentCount} payments recorded',
        ),
        _buildSummaryCard(
          title: 'Average Payment',
          value: _currencyFormat.format(summary.averagePayment),
          icon: FluentIcons.calculator_multiply,
          color: Colors.blue,
          subtitle: 'Across ${summary.paymentCount} entries',
        ),
        _buildSummaryCard(
          title: 'Upcoming Releases',
          value: '${summary.upcomingReleases}',
          icon: FluentIcons.timer,
          color: Colors.orange,
          subtitle: 'Due within next 30 days',
        ),
        _buildSummaryCard(
          title: 'Attachments',
          value: '${summary.attachments}',
          icon: FluentIcons.attach,
          color: Colors.teal,
          subtitle: 'Payments with proof files',
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(PremiumTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: PremiumTheme.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumTheme.spacingS),
          Text(
            value,
            style: FluentTheme.of(context).typography.subtitle?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: PremiumTheme.spacingXS),
            Text(
              subtitle,
              style: FluentTheme.of(
                context,
              ).typography.caption?.copyWith(color: Colors.grey[110]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextBox(
            controller: _searchController,
            placeholder: 'Search by TN, transaction, invoice or remarks',
            onChanged: (_) => setState(() {}),
            suffix: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed:
                  _searchController.text.isEmpty
                      ? null
                      : () {
                        _searchController.clear();
                        setState(() {});
                      },
            ),
          ),
        ),
        const SizedBox(width: PremiumTheme.spacingM),
        ComboBox<PaymentFilterRange>(
          value: _selectedRange,
          items: const [
            ComboBoxItem(
              value: PaymentFilterRange.all,
              child: Text('All time'),
            ),
            ComboBoxItem(
              value: PaymentFilterRange.last30Days,
              child: Text('Last 30 days'),
            ),
            ComboBoxItem(
              value: PaymentFilterRange.last6Months,
              child: Text('Last 6 months'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedRange = value);
          },
        ),
      ],
    );
  }

  List<FirmPaymentRecord> _applyFilters(List<FirmPaymentRecord> records) {
    var filtered = records;

    switch (_selectedRange) {
      case PaymentFilterRange.all:
        break;
      case PaymentFilterRange.last30Days:
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        filtered =
            filtered
                .where((record) => record.payment.paymentDate.isAfter(cutoff))
                .toList();
        break;
      case PaymentFilterRange.last6Months:
        final cutoff = DateTime.now().subtract(const Duration(days: 182));
        filtered =
            filtered
                .where((record) => record.payment.paymentDate.isAfter(cutoff))
                .toList();
        break;
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return filtered;
    }

    return filtered.where((record) {
      final payment = record.payment;
      return record.tnNumber.toLowerCase().contains(query) ||
          (payment.transactionNo ?? '').toLowerCase().contains(query) ||
          (payment.invoiceNo ?? '').toLowerCase().contains(query) ||
          (payment.remarks ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildPaymentsList(List<FirmPaymentRecord> records) {
    if (records.isEmpty) {
      return _buildPlaceholder(
        'No payments recorded for the selected filters.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: PremiumTheme.spacingL),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(PremiumTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TN ${record.tnNumber}',
                            style:
                                FluentTheme.of(context).typography.bodyStrong,
                          ),
                          const SizedBox(height: PremiumTheme.spacingXS),
                          Text(
                            'Payment date: ${_dateFormat.format(record.payment.paymentDate)}',
                            style: FluentTheme.of(context).typography.caption,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currencyFormat.format(record.payment.amountPaid),
                          style: FluentTheme.of(context).typography.bodyStrong,
                        ),
                        const SizedBox(height: PremiumTheme.spacingXS),
                        Text(
                          'Bill target: ${_currencyFormat.format(record.targetAmount)}',
                          style: FluentTheme.of(context).typography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: PremiumTheme.spacingM),
                Wrap(
                  spacing: PremiumTheme.spacingM,
                  runSpacing: PremiumTheme.spacingS,
                  children: [
                    if ((record.payment.transactionNo ?? '').isNotEmpty)
                      _buildDetailChip(
                        icon: FluentIcons.payment_card,
                        label: 'Txn',
                        value: record.payment.transactionNo!,
                      ),
                    if ((record.payment.invoiceNo ?? '').isNotEmpty)
                      _buildDetailChip(
                        icon: FluentIcons.document_set,
                        label: 'Invoice',
                        value: record.payment.invoiceNo!,
                      ),
                    if (record.payment.dueReleaseDate != null)
                      _buildDetailChip(
                        icon: FluentIcons.timer,
                        label: 'Due Release',
                        value: _dateFormat.format(
                          record.payment.dueReleaseDate!,
                        ),
                      ),
                    if ((record.payment.remarks ?? '').isNotEmpty)
                      _buildDetailChip(
                        icon: FluentIcons.comment,
                        label: 'Remarks',
                        value: record.payment.remarks!,
                      ),
                    _buildDetailChip(
                      icon: FluentIcons.calendar_reply,
                      label: 'Bill date',
                      value: _dateFormat.format(record.billDate),
                    ),
                    _buildDetailChip(
                      icon: FluentIcons.reminder_person,
                      label: 'Bill due',
                      value: _dateFormat.format(record.dueDate),
                    ),
                  ],
                ),
                const SizedBox(height: PremiumTheme.spacingM),
                Row(
                  children: [
                    if ((record.payment.proofPath ?? '').isNotEmpty)
                      InfoLabel(
                        label: 'Proof file',
                        child: Text(
                          record.payment.proofPath!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    Button(
                      onPressed:
                          _isBusy ? null : () => _openEditPayment(record),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: PremiumTheme.spacingS),
                    FilledButton(
                      onPressed: _isBusy ? null : () => _confirmDelete(record),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder:
          (_, __) => const SizedBox(height: PremiumTheme.spacingM),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spacingS,
        vertical: PremiumTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[10],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[120]),
          const SizedBox(width: PremiumTheme.spacingXS),
          Text(
            '$label: $value',
            style: FluentTheme.of(
              context,
            ).typography.caption?.copyWith(color: Colors.grey[140]),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(paymentsForFirmProvider);
  }

  Future<void> _openAddPayment() async {
    final firm = ref.read(selectedFirmProvider);
    if (firm?.id == null) {
      _showInfoBar(
        'Select DISCOM',
        'Choose a DISCOM before creating payments.',
        InfoBarSeverity.warning,
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      final billsDao = ref.read(billsDaoProvider);
      final bills =
          (await billsDao.getBillsByFirm(
            firm!.id!,
          )).where((bill) => bill.id != null).toList();

      if (bills.isEmpty) {
        _showInfoBar(
          'No bills found',
          'Create a bill first before recording payments.',
          InfoBarSeverity.info,
        );
        return;
      }

      final selectedBill = await _selectBill(bills);
      if (selectedBill == null) {
        return;
      }

      final result = await showDialog<bool>(
        context: context,
        builder:
            (context) => ComprehensivePaymentFormDialog(
              billId: selectedBill.id!,
              tnNumber: selectedBill.tnNumber,
              billAmount:
                  selectedBill.billPassAmount > 0
                      ? selectedBill.billPassAmount
                      : (selectedBill.invoiceAmount > 0
                          ? selectedBill.invoiceAmount
                          : selectedBill.amount),
            ),
      );

      if (result == true) {
        _showInfoBar(
          'Payment saved',
          'The payment entry has been created successfully.',
          InfoBarSeverity.success,
        );
        _refresh();
      }
    } catch (e) {
      _showInfoBar('Failed to create payment', '$e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<Bill?> _selectBill(List<Bill> bills) async {
    Bill? tempSelection = bills.first;

    return showDialog<Bill>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ContentDialog(
              title: const Text('Select Bill'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Choose the bill to attach this payment to:'),
                    const SizedBox(height: PremiumTheme.spacingM),
                    ComboBox<Bill>(
                      value: tempSelection,
                      items:
                          bills
                              .map(
                                (bill) => ComboBoxItem(
                                  value: bill,
                                  child: Text(
                                    '${bill.tnNumber} • ${_dateFormat.format(bill.dueDate)}',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => tempSelection = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed:
                      tempSelection == null
                          ? null
                          : () => Navigator.pop(context, tempSelection),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openEditPayment(FirmPaymentRecord record) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ComprehensivePaymentFormDialog(
            billId: record.billId,
            tnNumber: record.tnNumber,
            billAmount: record.targetAmount,
            payment: record.payment,
          ),
    );

    if (result == true) {
      _showInfoBar(
        'Payment updated',
        'Changes have been saved successfully.',
        InfoBarSeverity.success,
      );
      _refresh();
    }
  }

  Future<void> _confirmDelete(FirmPaymentRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Delete Payment'),
            content: Text(
              'Are you sure you want to delete the payment of '
              '${_currencyFormat.format(record.payment.amountPaid)} '
              'recorded on ${_dateFormat.format(record.payment.paymentDate)}?',
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

    if (confirmed != true) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      final paymentsDao = ref.read(paymentsDaoProvider);
      await paymentsDao.deletePayment(record.payment.id!);
      _showInfoBar(
        'Payment removed',
        'The payment entry has been deleted.',
        InfoBarSeverity.success,
      );
      _refresh();
    } catch (e) {
      _showInfoBar('Failed to delete payment', '$e', InfoBarSeverity.error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showInfoBar(String title, String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder:
          (context, close) => InfoBar(
            title: Text(title),
            content: Text(message),
            severity: severity,
            onClose: close,
          ),
    );
  }
}
