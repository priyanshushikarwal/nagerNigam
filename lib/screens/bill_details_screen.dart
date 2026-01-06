import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/premium_theme.dart';
import '../models/bill.dart';
import '../state/database_providers.dart';
import '../state/service_providers.dart';
import '../state/firm_providers.dart';
import '../state/tender_providers.dart';
import '../services/sync_service.dart';
import 'comprehensive_payment_form.dart';
import 'comprehensive_bill_form.dart';

class BillDetailsScreen extends ConsumerStatefulWidget {
  final int billId;

  const BillDetailsScreen({super.key, required this.billId});

  @override
  ConsumerState<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends ConsumerState<BillDetailsScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  final _dateFormat = DateFormat('dd-MM-yyyy');
  bool _isExporting = false;

  Future<void> _exportBillPdf() async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final path = await pdfService.generateBillPdf(billId: widget.billId);
      if (mounted) {
        _showInfoBar('Bill PDF exported to\n$path', InfoBarSeverity.success);
      }
    } catch (e) {
      if (mounted) {
        _showInfoBar('Failed to export bill PDF: $e', InfoBarSeverity.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportPaymentDetailsPdf() async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfServiceProvider);

      // Export payment details for this specific bill only
      final path = await pdfService.exportSingleBillPaymentDetailsPdf(
        billId: widget.billId,
      );
      if (mounted) {
        _showInfoBar(
          'Payment details exported to\n$path',
          InfoBarSeverity.success,
        );
      }
    } catch (e) {
      if (mounted) {
        _showInfoBar(
          'Failed to export payment details: $e',
          InfoBarSeverity.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _addPayment(Bill bill) async {
    final billAmount =
        bill.billPassAmount > 0
            ? bill.billPassAmount
            : (bill.invoiceAmount > 0 ? bill.invoiceAmount : bill.amount);

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ComprehensivePaymentFormDialog(
            billId: bill.id!,
            tnNumber: bill.tnNumber,
            billAmount: billAmount,
          ),
    );

    if (result == true) {
      // Invalidate all related providers to refresh the UI
      ref.invalidate(billByIdProvider(widget.billId));
      ref.invalidate(billWithPaymentsProvider(widget.billId));
      ref.invalidate(paymentsByBillProvider(widget.billId));

      _showInfoBar('Payment added successfully', InfoBarSeverity.success);
    }
  }

  Future<void> _deletePayment(Payment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Delete Payment'),
            content: Text(
              'Are you sure you want to delete this payment of ${_currencyFormat.format(payment.amountPaid)} recorded on ${_dateFormat.format(payment.paymentDate)}?\n\nThis action cannot be undone.',
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
      final paymentsDao = ref.read(paymentsDaoProvider);
      await paymentsDao.deletePayment(payment.id!);

      // Invalidate all related providers to refresh the UI
      ref.invalidate(billByIdProvider(widget.billId));
      ref.invalidate(billWithPaymentsProvider(widget.billId));
      ref.invalidate(paymentsByBillProvider(widget.billId));

      if (mounted) {
        _showInfoBar('Payment deleted successfully', InfoBarSeverity.success);
      }
    } catch (e) {
      _showInfoBar('Failed to delete payment: $e', InfoBarSeverity.error);
    }
  }

  Future<void> _editPayment(Payment payment, Bill bill) async {
    final billAmount =
        bill.billPassAmount > 0
            ? bill.billPassAmount
            : (bill.invoiceAmount > 0 ? bill.invoiceAmount : bill.amount);

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ComprehensivePaymentFormDialog(
            billId: bill.id!,
            tnNumber: bill.tnNumber,
            billAmount: billAmount,
            payment: payment,
          ),
    );

    if (result == true) {
      // Invalidate all related providers to refresh the UI
      ref.invalidate(billByIdProvider(widget.billId));
      ref.invalidate(billWithPaymentsProvider(widget.billId));
      ref.invalidate(paymentsByBillProvider(widget.billId));

      _showInfoBar('Payment updated successfully', InfoBarSeverity.success);
    }
  }

  Future<void> _editBill(Bill bill) async {
    final firm = ref.read(selectedFirmProvider);
    if (firm == null || firm.id == null) {
      _showInfoBar('Firm information not available', InfoBarSeverity.warning);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) =>
              ComprehensiveBillFormDialog(firmId: firm.id!, bill: bill),
    );

    // Refresh the bill data if the dialog returned success
    if (result == true) {
      ref.invalidate(billByIdProvider(widget.billId));
      ref.invalidate(billWithPaymentsProvider(widget.billId));
    }
  }

  Future<void> _deleteBill(Bill bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Delete Bill'),
            content: Text(
              'Are you sure you want to delete Bill ${bill.billNo ?? "this bill"}?\n\nThis action cannot be undone and will also delete all associated payment records.',
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
      final billsDao = ref.read(billsDaoProvider);
      final wasDeleted = await billsDao.deleteBill(bill.id!);

      if (!wasDeleted) {
        _showInfoBar(
          'Bill not found or could not be deleted',
          InfoBarSeverity.warning,
        );
        return;
      }

      // Also delete from Supabase cloud
      await ref
          .read(syncServiceProvider.notifier)
          .deleteBillFromCloud(bill.id!);

      // Invalidate all related providers to refresh the UI across screens
      ref.invalidate(billByIdProvider(widget.billId));
      ref.invalidate(billWithPaymentsProvider(widget.billId));
      ref.invalidate(paymentsByBillProvider(widget.billId));

      // Invalidate tender-related providers so parent screens refresh
      if (bill.tenderId != null) {
        ref.invalidate(billsByTenderProvider(bill.tenderId!));
        ref.invalidate(tenderStatsProvider(bill.tenderId!));
      }
      ref.invalidate(firmTendersProvider);

      if (mounted) {
        _showInfoBar('Bill deleted successfully', InfoBarSeverity.success);
        // Navigate back
        context.pop();
      }
    } catch (e) {
      _showInfoBar('Failed to delete bill: $e', InfoBarSeverity.error);
    }
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

  String _statusLabel(String status) {
    switch (status) {
      case 'DueSoon':
        return 'Due Soon';
      default:
        return status;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PremiumTheme.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: PremiumTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: PremiumTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an Excel-style table with bill details, deductions, and dynamic payment history
  Widget _buildExcelStyleTable(Bill bill, List<Payment> payments) {
    // Sort payments by date
    final sortedPayments = List<Payment>.from(payments)
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    // Net Payment calculation: Invoice Amount - Deductions (excluding CSD and MD as they are receivables)
    final netPayment =
        bill.invoiceAmount -
        bill.tdsAmount -
        bill.scrapAmount -
        bill.scrapGstAmount -
        bill.tcsAmount -
        bill.gstTdsAmount;

    // CSD dates - use actual values from bill, with fallbacks
    final csdDueDate =
        bill.csdDueDate ?? bill.billDate.add(const Duration(days: 45));
    final csdReleasedDate =
        bill.csdReleasedDate ?? bill.billDate.add(const Duration(days: 365));

    // Calculate running balance for payments
    List<double> remainingAmounts = [];
    double runningBalance = netPayment;
    for (var payment in sortedPayments) {
      runningBalance -= payment.amountPaid;
      remainingAmounts.add(runningBalance);
    }

    // Build fixed headers - removed "Difference", "RR Date", "Due Date" as per client request
    final fixedHeaders = [
      'Sr No',
      'Bill No',
      'Date',
      'Lot No',
      'Work Order No',
      'WO Date',
      'Invoice Amount',
      'Bill Pass Amount',
      'MD', // Shown but NOT deducted from net payment (receivable)
      'CSD', // Shown but NOT deducted from net payment (receivable)
      'CSD Due Date',
      'CSD Released Date',
      'TDS',
      'Scrap',
      'Scrap GST',
      'TCS',
      'MD (NPW)',
      'GST TDS',
      'Net Payment',
    ];

    // Build dynamic payment headers - 3 columns per payment
    final paymentHeaders = <String>[];
    for (int i = 0; i < sortedPayments.length; i++) {
      final suffix = _getOrdinalSuffix(i + 1);
      paymentHeaders.add('${i + 1}$suffix Payment');
      paymentHeaders.add('Date');
      paymentHeaders.add('Remaining');
    }

    // All headers combined
    final allHeaders = [...fixedHeaders, ...paymentHeaders];

    // Build fixed data cells - removed "Difference", "RR Date", "Due Date" values
    final fixedDataValues = [
      '1', // Sr No
      bill.billNo ?? '-',
      _dateFormat.format(bill.billDate),
      bill.tnNumber,
      bill.workOrderNo ?? '-',
      bill.workOrderDate != null
          ? _dateFormat.format(bill.workOrderDate!)
          : '-',
      _currencyFormat.format(bill.invoiceAmount),
      _currencyFormat.format(bill.billPassAmount),
      _currencyFormat.format(bill.mdLdAmount), // MD - shown as receivable
      _currencyFormat.format(bill.csdAmount), // CSD - shown as receivable
      bill.csdDueDate != null ? _dateFormat.format(csdDueDate) : '-',
      bill.csdReleasedDate != null ? _dateFormat.format(csdReleasedDate) : '-',
      _currencyFormat.format(bill.tdsAmount),
      _currencyFormat.format(bill.scrapAmount),
      _currencyFormat.format(bill.scrapGstAmount),
      _currencyFormat.format(bill.tcsAmount),
      '-', // MD (NPW) - placeholder
      _currencyFormat.format(bill.gstTdsAmount),
      _currencyFormat.format(netPayment),
    ];

    // Build payment data cells - 3 values per payment (Amount, Date, Remaining)
    final paymentDataValues = <String>[];
    for (int i = 0; i < sortedPayments.length; i++) {
      final payment = sortedPayments[i];
      paymentDataValues.add(_currencyFormat.format(payment.amountPaid));
      paymentDataValues.add(_dateFormat.format(payment.paymentDate));
      paymentDataValues.add(_currencyFormat.format(remainingAmounts[i]));
    }

    // All data values combined
    final allDataValues = [...fixedDataValues, ...paymentDataValues];

    // Calculate total paid
    final totalPaid = sortedPayments.fold(0.0, (sum, p) => sum + p.amountPaid);

    // Build total row values - matching your Excel screenshot (show all financial values)
    final totalRowValues = <String>[];
    for (int i = 0; i < fixedHeaders.length; i++) {
      final header = fixedHeaders[i];
      switch (header) {
        case 'Sr No':
          totalRowValues.add('TOTAL');
          break;
        case 'Invoice Amount':
          totalRowValues.add(_currencyFormat.format(bill.invoiceAmount));
          break;
        case 'Bill Pass Amount':
          totalRowValues.add(_currencyFormat.format(bill.billPassAmount));
          break;
        case 'MD':
          totalRowValues.add(_currencyFormat.format(bill.mdLdAmount));
          break;
        case 'TDS':
          totalRowValues.add(_currencyFormat.format(bill.tdsAmount));
          break;
        case 'Scrap':
          totalRowValues.add(_currencyFormat.format(bill.scrapAmount));
          break;
        case 'Scrap GST':
          totalRowValues.add(_currencyFormat.format(bill.scrapGstAmount));
          break;
        case 'TCS':
          totalRowValues.add(_currencyFormat.format(bill.tcsAmount));
          break;
        case 'GST TDS':
          totalRowValues.add(_currencyFormat.format(bill.gstTdsAmount));
          break;
        case 'Net Payment':
          totalRowValues.add(_currencyFormat.format(netPayment));
          break;
        default:
          totalRowValues.add('');
      }
    }
    // Add payment totals - 3 cells per payment (Total Paid, empty date, Final Remaining)
    for (int i = 0; i < sortedPayments.length; i++) {
      if (i == sortedPayments.length - 1) {
        // Last payment - show totals
        totalRowValues.add(_currencyFormat.format(totalPaid));
        totalRowValues.add('');
        totalRowValues.add(
          _currencyFormat.format(
            remainingAmounts.isNotEmpty ? remainingAmounts.last : netPayment,
          ),
        );
      } else {
        // Other payments - empty cells
        totalRowValues.add('');
        totalRowValues.add('');
        totalRowValues.add('');
      }
    }

    return Expander(
      header: const Text(
        'Bill Summary Table (Excel View)',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      initiallyExpanded: true,
      content: Container(
        decoration: BoxDecoration(
          color: PremiumTheme.pureWhite,
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
          border: Border.all(color: PremiumTheme.borderColor),
        ),
        child: material.Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(110),
              border: TableBorder.all(
                color: PremiumTheme.borderColor,
                width: 1,
              ),
              children: [
                // Header Row
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5), // Light gray like Excel
                  ),
                  children:
                      allHeaders
                          .map((header) => _buildTableHeaderCell(header))
                          .toList(),
                ),
                // Data Row
                TableRow(
                  decoration: const BoxDecoration(
                    color: PremiumTheme.pureWhite,
                  ),
                  children: List.generate(allDataValues.length, (index) {
                    return _buildTableCell(allDataValues[index]);
                  }),
                ),
                // Total Row
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5), // Light gray like Excel
                  ),
                  children: List.generate(totalRowValues.length, (index) {
                    final value = totalRowValues[index];
                    final isBold = value.isNotEmpty;
                    return _buildTableCell(value, isBold: isBold);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a header cell for the Excel-style table
  Widget _buildTableHeaderCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: PremiumTheme.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds a data cell for the Excel-style table
  Widget _buildTableCell(String text, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          fontSize: 11,
          color: textColor ?? PremiumTheme.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Returns ordinal suffix (st, nd, rd, th)
  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Widget _buildBillInformation(Bill bill) {
    // Total deductions shown in deductions section (excluding CSD and MD which are receivables)
    final totalDeductions =
        bill.tdsAmount +
        bill.gstTdsAmount +
        bill.tcsAmount +
        bill.scrapAmount +
        bill.scrapGstAmount;
    // Net Payable from invoice amount, excluding CSD and MD (they are receivables)
    final netPayable = bill.invoiceAmount - totalDeductions;

    return Expander(
      header: const Text(
        'Bill Information',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      initiallyExpanded: true,
      content: Container(
        padding: const EdgeInsets.all(PremiumTheme.spacingM),
        decoration: BoxDecoration(
          color: PremiumTheme.pureWhite,
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
          border: Border.all(color: PremiumTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('TN Number', bill.tnNumber),
            _buildInfoRow('Client Firm', bill.clientFirmName ?? 'N/A'),
            _buildInfoRow('Bill No', bill.billNo ?? '-'),
            _buildInfoRow('Bill Date', _dateFormat.format(bill.billDate)),
            _buildInfoRow(
              'Work Order No',
              bill.workOrderNo?.isNotEmpty == true ? bill.workOrderNo! : '-',
            ),
            _buildInfoRow(
              'Work Order Date',
              bill.workOrderDate != null
                  ? _dateFormat.format(bill.workOrderDate!)
                  : '-',
            ),
            _buildInfoRow(
              'Invoice Amount',
              _currencyFormat.format(bill.invoiceAmount),
            ),
            _buildInfoRow(
              'Bill Pass Amount',
              _currencyFormat.format(bill.billPassAmount),
            ),
            const Divider(),
            const Text(
              'Deductions (Applied)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: PremiumTheme.spacingS),
            _buildInfoRow('TDS', _currencyFormat.format(bill.tdsAmount)),
            _buildInfoRow('GST TDS', _currencyFormat.format(bill.gstTdsAmount)),
            _buildInfoRow('TCS', _currencyFormat.format(bill.tcsAmount)),
            _buildInfoRow('Scrap', _currencyFormat.format(bill.scrapAmount)),
            _buildInfoRow(
              'Scrap GST',
              _currencyFormat.format(bill.scrapGstAmount),
            ),
            _buildInfoRow(
              'Total Deductions',
              _currencyFormat.format(totalDeductions),
            ),
            const Divider(),
            const Text(
              'Receivables (To be received back)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: PremiumTheme.spacingS),
            _buildInfoRow('CSD', _currencyFormat.format(bill.csdAmount)),
            _buildInfoRow('MD/LD', _currencyFormat.format(bill.mdLdAmount)),
            const Divider(),
            _buildInfoRow('Net Payable', _currencyFormat.format(netPayable)),
            const Divider(),
            _buildInfoRow(
              'Invoice Type',
              bill.invoiceType?.isNotEmpty == true ? bill.invoiceType! : '-',
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: PremiumTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumTheme.spacingM,
                      vertical: PremiumTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(bill.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _statusLabel(bill.status),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _statusColor(bill.status),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivablesSection(Bill bill) {
    // These amounts are receivable (will be received back)
    final invoiceDifference = bill.invoiceAmount - bill.billPassAmount;
    final csdAmount = bill.csdAmount;
    final mdLdAmount = bill.mdLdAmount;
    final totalReceivables = csdAmount + invoiceDifference + mdLdAmount;

    // Check if there are any receivables
    if (totalReceivables <= 0) {
      return const SizedBox.shrink();
    }

    return Expander(
      header: Row(
        children: [
          Icon(FluentIcons.money, size: 18, color: Colors.teal),
          const SizedBox(width: PremiumTheme.spacingS),
          const Text(
            'Receivables (Due Back)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumTheme.spacingM,
              vertical: PremiumTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _currencyFormat.format(totalReceivables),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.teal.dark,
              ),
            ),
          ),
        ],
      ),
      initiallyExpanded: true,
      content: Container(
        padding: const EdgeInsets.all(PremiumTheme.spacingM),
        decoration: BoxDecoration(
          color: PremiumTheme.pureWhite,
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
          border: Border.all(color: PremiumTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info text
            Container(
              padding: const EdgeInsets.all(PremiumTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(
                  PremiumTheme.borderRadiusSmall,
                ),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(FluentIcons.info, size: 16, color: Colors.teal.dark),
                  const SizedBox(width: PremiumTheme.spacingS),
                  Expanded(
                    child: Text(
                      'These amounts are deducted initially but will be received back/refunded.',
                      style: TextStyle(color: Colors.teal.darker, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PremiumTheme.spacingM),

            // CSD Row with all details
            if (csdAmount > 0) _buildCsdRow(bill),

            if (mdLdAmount > 0)
              _buildReceivableRow(
                'MD/LD Amount',
                mdLdAmount,
                'Minimum Demand / Liquidated Damages',
                'To be recovered',
                Colors.purple,
              ),

            const Divider(),

            // Total row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: const Text(
                    'TOTAL RECEIVABLES',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: PremiumTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _currencyFormat.format(totalReceivables),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.teal.dark,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCsdRow(Bill bill) {
    final csdStatusColor =
        bill.csdStatus == 'Released' ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spacingM),
      margin: const EdgeInsets.only(bottom: PremiumTheme.spacingM),
      decoration: BoxDecoration(
        color: PremiumTheme.cardBackground,
        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
        border: Border.all(color: Colors.grey[30]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with columns
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'CSD Due Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'CSD Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'CSD Release Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
          const SizedBox(height: PremiumTheme.spacingS),
          // Data row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CSD Amount
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CSD Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PremiumTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(bill.csdAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.teal.dark,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Security deposit to be released',
                      style: TextStyle(
                        fontSize: 10,
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // CSD Due Date
              Expanded(
                flex: 2,
                child:
                    bill.csdDueDate != null
                        ? Text(
                          _dateFormat.format(bill.csdDueDate!),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: PremiumTheme.textPrimary,
                          ),
                        )
                        : const Text(
                          'Not Applicable',
                          style: TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
              ),

              // CSD Status (Toggle)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    final newStatus =
                        bill.csdStatus == 'Released' ? 'Pending' : 'Released';
                    final billsDao = ref.read(billsDaoProvider);
                    await billsDao.updateCsdStatus(bill.id!, newStatus);
                    // Trigger refresh
                    ref.invalidate(billWithPaymentsProvider(bill.id!));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: csdStatusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: csdStatusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bill.csdStatus == 'Released'
                              ? FluentIcons.check_mark
                              : FluentIcons.clock,
                          size: 14,
                          color: csdStatusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bill.csdStatus == 'Released' ? 'Released' : 'Pending',
                          style: TextStyle(
                            color: csdStatusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 16,
              ), // Spacing between status and release date
              // CSD Release Date
              Expanded(
                flex: 2,
                child:
                    bill.csdReleasedDate != null
                        ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Released: ${_dateFormat.format(bill.csdReleasedDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.dark,
                            ),
                          ),
                        )
                        : const Text(
                          '(manually add date)',
                          style: TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
              ),

              // Action button to edit dates
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(
                    FluentIcons.edit,
                    size: 14,
                    color: Colors.grey[80],
                  ),
                  onPressed: () => _editBill(bill),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceivableRow(
    String label,
    double amount,
    String description,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _currencyFormat.format(amount),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: PremiumTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    // Get bill info to calculate net payable (target)
    final billAsync = ref.read(billByIdProvider(widget.billId));
    final bill = billAsync.asData?.value;

    // Calculate net payable from invoice amount
    // CSD and MD are NOT deducted - they are receivables
    double netPayable = 0;
    DateTime? billCreatedDate;
    if (bill != null) {
      netPayable =
          bill.invoiceAmount -
          bill.tdsAmount -
          bill.gstTdsAmount -
          bill.tcsAmount -
          bill.scrapAmount -
          bill.scrapGstAmount;
      billCreatedDate = bill.createdAt;
    }

    // Sort payments by date
    final sortedPayments = List<Payment>.from(payments)
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    // Build ledger entries with payment reference
    List<_LedgerEntryWithPayment> ledgerEntries = [];

    // First entry: Bill Created
    ledgerEntries.add(
      _LedgerEntryWithPayment(
        date: billCreatedDate ?? DateTime.now(),
        type: 'Bill Created',
        target: netPayable,
        before: 0,
        paid: 0,
        totalPaid: 0,
        remaining: netPayable,
        status: 'Pending',
        remarks: '-',
        payment: null,
      ),
    );

    // Add payment entries
    double runningTotalPaid = 0;
    double previousRemaining = netPayable;
    for (var payment in sortedPayments) {
      runningTotalPaid += payment.amountPaid;
      final remaining = netPayable - runningTotalPaid;

      String status;
      if (remaining <= 0.01) {
        status = 'Paid';
      } else if (runningTotalPaid > 0) {
        status = 'Partially Paid';
      } else {
        status = 'Pending';
      }

      ledgerEntries.add(
        _LedgerEntryWithPayment(
          date: payment.paymentDate,
          type: 'Payment',
          target: netPayable,
          before: previousRemaining,
          paid: payment.amountPaid,
          totalPaid: runningTotalPaid,
          remaining: remaining,
          status: status,
          remarks: payment.remarks ?? '-',
          payment: payment,
        ),
      );

      previousRemaining = remaining;
    }

    return Expander(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Payment Ledger (Computed View)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            'Records: ${ledgerEntries.length}',
            style: const TextStyle(
              color: PremiumTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
      initiallyExpanded: true,
      content: Container(
        decoration: BoxDecoration(
          color: PremiumTheme.pureWhite,
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
          border: Border.all(color: PremiumTheme.borderColor),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: material.DataTable(
            headingRowColor: WidgetStateProperty.all(
              PremiumTheme.primaryAccent.withValues(alpha: 0.08),
            ),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              color: PremiumTheme.textPrimary,
              fontSize: 13,
            ),
            dataTextStyle: const TextStyle(
              color: PremiumTheme.textPrimary,
              fontSize: 13,
            ),
            columnSpacing: 24,
            horizontalMargin: 16,
            columns: const [
              material.DataColumn(label: Text('Date')),
              material.DataColumn(label: Text('Type')),
              material.DataColumn(label: Text('Target')),
              material.DataColumn(label: Text('Before')),
              material.DataColumn(label: Text('Paid')),
              material.DataColumn(label: Text('Total Paid')),
              material.DataColumn(label: Text('Remaining')),
              material.DataColumn(label: Text('Status')),
              material.DataColumn(label: Text('Remarks')),
              material.DataColumn(label: Text('Actions')),
            ],
            rows:
                ledgerEntries.map((entry) {
                  return material.DataRow(
                    cells: [
                      material.DataCell(Text(_dateFormat.format(entry.date))),
                      material.DataCell(
                        Text(
                          entry.type,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                entry.type == 'Payment'
                                    ? Colors.green.dark
                                    : PremiumTheme.textPrimary,
                          ),
                        ),
                      ),
                      material.DataCell(
                        Text(_currencyFormat.format(entry.target)),
                      ),
                      material.DataCell(
                        Text(_currencyFormat.format(entry.before)),
                      ),
                      material.DataCell(
                        Text(
                          _currencyFormat.format(entry.paid),
                          style: TextStyle(
                            fontWeight:
                                entry.paid > 0
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                            color:
                                entry.paid > 0
                                    ? Colors.green.dark
                                    : PremiumTheme.textPrimary,
                          ),
                        ),
                      ),
                      material.DataCell(
                        Text(_currencyFormat.format(entry.totalPaid)),
                      ),
                      material.DataCell(
                        Text(
                          _currencyFormat.format(entry.remaining),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                entry.remaining <= 0.01
                                    ? Colors.green.dark
                                    : Colors.orange.dark,
                          ),
                        ),
                      ),
                      material.DataCell(
                        Text(
                          entry.status,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(entry.status),
                          ),
                        ),
                      ),
                      material.DataCell(Text(entry.remarks)),
                      // Actions column - only show for payment entries
                      material.DataCell(
                        entry.payment != null && bill != null
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    FluentIcons.edit,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  onPressed:
                                      () => _editPayment(entry.payment!, bill),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(
                                    FluentIcons.delete,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _deletePayment(entry.payment!),
                                ),
                              ],
                            )
                            : const Text('-'),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.dark;
      case 'Partially Paid':
        return Colors.orange.dark;
      case 'Pending':
        return Colors.blue;
      default:
        return PremiumTheme.textPrimary;
    }
  }

  /// Returns ordinal number string (1st, 2nd, 3rd, etc.)
  String _getOrdinalNumber(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final billWithPaymentsAsync = ref.watch(
      billWithPaymentsProvider(widget.billId),
    );

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: billWithPaymentsAsync.when(
        data: (billWithPayments) {
          if (billWithPayments == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bill not found'),
                  const SizedBox(height: PremiumTheme.spacingM),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final bill = billWithPayments.bill;
          final payments = billWithPayments.payments;

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(PremiumTheme.spacingL),
                decoration: const BoxDecoration(
                  color: PremiumTheme.pureWhite,
                  border: Border(
                    bottom: BorderSide(
                      color: PremiumTheme.borderColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(FluentIcons.back, size: 20),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.go('/bills');
                            }
                          },
                        ),
                        const SizedBox(width: PremiumTheme.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bill Details',
                                style: FluentTheme.of(context).typography.title,
                              ),
                              const SizedBox(height: PremiumTheme.spacingXS),
                              Text(
                                'Bill No: ${bill.billNo ?? "-"} • TN: ${bill.tnNumber}',
                                style: FluentTheme.of(
                                  context,
                                ).typography.caption?.copyWith(
                                  color: PremiumTheme.textSecondary,
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
                          onPressed: () => _editBill(bill),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(FluentIcons.edit, size: 16),
                              SizedBox(width: PremiumTheme.spacingXS),
                              Text('Edit Bill'),
                            ],
                          ),
                        ),
                        Button(
                          onPressed: () => _deleteBill(bill),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(FluentIcons.delete, size: 16),
                              SizedBox(width: PremiumTheme.spacingXS),
                              Text('Delete Bill'),
                            ],
                          ),
                        ),
                        Button(
                          onPressed: _isExporting ? null : _exportBillPdf,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(FluentIcons.print, size: 16),
                              SizedBox(width: PremiumTheme.spacingXS),
                              Text('Print Bill Format'),
                            ],
                          ),
                        ),
                        Button(
                          onPressed:
                              _isExporting ? null : _exportPaymentDetailsPdf,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(FluentIcons.payment_card, size: 16),
                              SizedBox(width: PremiumTheme.spacingXS),
                              Text('Print Payment Details'),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () => _addPayment(bill),
                          child: const Text('Add Payment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(PremiumTheme.spacingL),
                  children: [
                    _buildExcelStyleTable(bill, payments),
                    const SizedBox(height: PremiumTheme.spacingL),
                    _buildBillInformation(bill),
                    const SizedBox(height: PremiumTheme.spacingL),
                    _buildReceivablesSection(bill),
                    const SizedBox(height: PremiumTheme.spacingL),
                    _buildPaymentsList(payments),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: ProgressRing()),
        error:
            (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InfoBar(
                    title: const Text('Error loading bill'),
                    content: Text('$error'),
                    severity: InfoBarSeverity.error,
                  ),
                  const SizedBox(height: PremiumTheme.spacingM),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

/// Helper class for Payment Ledger entries with payment reference
class _LedgerEntryWithPayment {
  final DateTime date;
  final String type;
  final double target;
  final double before;
  final double paid;
  final double totalPaid;
  final double remaining;
  final String status;
  final String remarks;
  final Payment? payment; // Reference to original payment for edit/delete

  const _LedgerEntryWithPayment({
    required this.date,
    required this.type,
    required this.target,
    required this.before,
    required this.paid,
    required this.totalPaid,
    required this.remaining,
    required this.status,
    required this.remarks,
    this.payment,
  });
}
