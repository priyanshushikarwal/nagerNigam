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
import 'csd_payment_dialog.dart';
import 'mdld_payment_dialog.dart';
import 'generic_receivable_payment_dialog.dart';

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

  Future<void> _addPayment(
    Bill bill, {
    double? initialAmount,
    String? initialRemarks,
  }) async {
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
            initialAmount: initialAmount,
            initialRemarks: initialRemarks,
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

  /// Builds an Excel-style table with bill details and deductions
  /// Two-row layout: Row 1 (Invoice Info), Row 2 (Deductions & Extras)
  /// All white background with clean borders
  Widget _buildExcelStyleTable(Bill bill, List<Payment> payments) {
    // Net Payment calculation: Invoice Amount - Deductions (excluding CSD and MD as they are receivables)
    final netPayment =
        bill.invoiceAmount -
        bill.tdsAmount -
        bill.scrapAmount -
        bill.scrapGstAmount -
        bill.tcsAmount -
        bill.gstTdsAmount;

    // Calculate difference between Invoice and Bill Pass
    final difference = bill.invoiceAmount - bill.billPassAmount;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ===== TABLE 1: Invoice Information (Row 1 & 2) =====
                      Table(
                        defaultColumnWidth: const FixedColumnWidth(
                          120,
                        ), // Match Table 2 width
                        border: TableBorder.all(color: Colors.black, width: 1),
                        children: [
                          // ROW 1: Header Row - Invoice Information
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [
                              _buildHeaderCell('Invoice No', Colors.black),
                              _buildHeaderCell('Invoice Date', Colors.black),
                              _buildHeaderCell('RR Date', Colors.black),
                              _buildHeaderCell('Lot No', Colors.black),
                              _buildHeaderCell('Store', Colors.black),
                              _buildHeaderCell('Work Order No', Colors.black),
                              _buildHeaderCell('WO Date', Colors.black),
                              _buildHeaderCell('Invoice Amount', Colors.black),
                              _buildHeaderCell(
                                'Bill Pass Amount',
                                Colors.black,
                              ),
                              _buildHeaderCell('Difference', Colors.black),
                              _buildHeaderCell('CSD Amount', Colors.black),
                              _buildHeaderCell('CSD Due Date', Colors.black),
                              _buildHeaderCell(
                                'CSD Release Date',
                                Colors.black,
                              ),
                            ],
                          ),
                          // ROW 2: Data Row - Invoice Information
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [
                              _buildDataCell(bill.billNo ?? '-'),
                              _buildDataCell(
                                bill.invoiceDate != null
                                    ? _dateFormat.format(bill.invoiceDate!)
                                    : '-',
                              ),
                              _buildDataCell(_dateFormat.format(bill.billDate)),
                              _buildDataCell(bill.lotNo ?? '-'),
                              _buildDataCell(bill.storeName ?? '-'),
                              _buildDataCell(bill.workOrderNo ?? '-'),
                              _buildDataCell(
                                bill.workOrderDate != null
                                    ? _dateFormat.format(bill.workOrderDate!)
                                    : '-',
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.invoiceAmount),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.billPassAmount),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(difference),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.csdAmount),
                                backgroundColor:
                                    bill.csdStatus == 'Released'
                                        ? const Color(0xFFD4EDDA) // Light green
                                        : const Color(0xFFF8D7DA), // Light red
                              ),
                              _buildDataCell(
                                bill.csdDueDate != null
                                    ? _dateFormat.format(bill.csdDueDate!)
                                    : '-',
                              ),
                              _buildDataCell(
                                bill.csdReleasedDate != null
                                    ? _dateFormat.format(bill.csdReleasedDate!)
                                    : '-',
                              ),
                            ],
                          ),
                        ],
                      ),

                      // GAP between Invoice section and Deductions section
                      const SizedBox(height: 8),

                      // ===== TABLE 2: Deductions & Additional Info (Row 3 & 4) =====
                      Table(
                        defaultColumnWidth: const FixedColumnWidth(
                          120,
                        ), // All columns same width
                        border: TableBorder.all(color: Colors.black, width: 1),
                        children: [
                          // ROW 3: Header Row - Deductions & Additional Info
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [
                              _buildHeaderCell('TDS Amount', Colors.black),
                              _buildHeaderCell('Scrap Amount', Colors.black),
                              _buildHeaderCell('Scrap GST', Colors.black),
                              _buildHeaderCell('TCS Amount', Colors.black),
                              _buildHeaderCell('GST TDS', Colors.black),
                              _buildHeaderCell('MD Amount', Colors.black),
                              _buildHeaderCell('Remark', Colors.black),
                              _buildHeaderCell('D. Meter Box', Colors.black),
                              _buildHeaderCell('Remark', Colors.black),
                              _buildHeaderCell('Empty Oil Drum', Colors.black),
                              _buildHeaderCell('Remark', Colors.black),
                              _buildHeaderCell('MD (NPV)', Colors.black),
                              _buildHeaderCell('Remark', Colors.black),
                              _buildHeaderCell(
                                'Net Payable Amount',
                                Colors.black,
                              ),
                            ],
                          ),
                          // ROW 4: Data Row - Deductions & Additional Info
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [
                              _buildDataCell(
                                _currencyFormat.format(bill.tdsAmount),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.scrapAmount),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.scrapGstAmount),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.tcsAmount),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.gstTdsAmount),
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.mdLdAmount),
                                backgroundColor:
                                    bill.mdLdStatus == 'Released'
                                        ? const Color(0xFFD4EDDA) // Light green
                                        : const Color(0xFFF8D7DA), // Light red
                              ),
                              _buildDataCell(bill.remarks ?? '-', fontSize: 10),
                              _buildDataCell(
                                _currencyFormat.format(bill.dMeterBox),
                                backgroundColor:
                                    bill.dMeterBoxStatus == 'Released'
                                        ? const Color(0xFFD4EDDA) // Light green
                                        : const Color(0xFFF8D7DA), // Light red
                              ),
                              _buildDataCell(
                                bill.dMeterBoxRemark ?? '-',
                                fontSize: 10,
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.emptyOilDrum),
                                backgroundColor:
                                    bill.emptyOilDrumStatus == 'Released'
                                        ? const Color(0xFFD4EDDA) // Light green
                                        : const Color(0xFFF8D7DA), // Light red
                              ),
                              _buildDataCell(
                                bill.emptyOilDrumRemark ?? '-',
                                fontSize: 10,
                              ),
                              _buildDataCell(
                                _currencyFormat.format(bill.mdNpvAmount),
                                backgroundColor:
                                    bill.mdNpvStatus == 'Released'
                                        ? const Color(0xFFD4EDDA) // Light green
                                        : const Color(0xFFF8D7DA), // Light red
                              ),
                              _buildDataCell(
                                bill.mdNpvRemark ?? '-',
                                fontSize: 10,
                              ),
                              _buildDataCell(
                                _currencyFormat.format(netPayment),
                                isBold: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds a header cell with custom text color
  Widget _buildHeaderCell(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds a data cell with optional styling
  Widget _buildDataCell(
    String text, {
    bool isBold = false,
    Color? textColor,
    double fontSize = 11,
    Color? backgroundColor,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          fontSize: fontSize,
          color: textColor ?? PremiumTheme.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (backgroundColor != null) {
      return Container(color: backgroundColor, child: content);
    }
    return content;
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
    final totalReceivables =
        csdAmount +
        invoiceDifference +
        mdLdAmount +
        bill.mdNpvAmount +
        bill.dMeterBox +
        bill.emptyOilDrum;

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
            if (csdAmount > 0) ...[
              _buildCsdRow(bill),
              const SizedBox(height: 8),
              // Add Payment button for CSD - uses specialized dialog
              // Only show if CSD is not yet released
              if (bill.csdStatus != 'Released')
                Row(
                  children: [
                    Button(
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => CsdPaymentDialog(bill: bill),
                        );
                        if (result == true) {
                          // Refresh the UI
                          ref.invalidate(billByIdProvider(widget.billId));
                          ref.invalidate(
                            billWithPaymentsProvider(widget.billId),
                          );
                          ref.invalidate(paymentsByBillProvider(widget.billId));
                          _showInfoBar(
                            'CSD Payment recorded successfully',
                            InfoBarSeverity.success,
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.money, size: 14),
                          const SizedBox(width: 6),
                          const Text('Add CSD Payment'),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FluentIcons.completed_solid,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CSD Already Released',
                            style: TextStyle(
                              color: Colors.green.dark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: PremiumTheme.spacingM),
            ],

            if (mdLdAmount > 0) ...[
              _buildMdLdRow(bill),
              const SizedBox(height: 8),
              // Add Payment button for MD/LD - uses specialized dialog
              // Only show if MD/LD is not yet released
              if (bill.mdLdStatus != 'Released')
                Row(
                  children: [
                    Button(
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => MdLdPaymentDialog(bill: bill),
                        );
                        if (result == true) {
                          // Refresh the UI
                          ref.invalidate(billByIdProvider(widget.billId));
                          ref.invalidate(
                            billWithPaymentsProvider(widget.billId),
                          );
                          ref.invalidate(paymentsByBillProvider(widget.billId));
                          _showInfoBar(
                            'MD/LD Payment recorded successfully',
                            InfoBarSeverity.success,
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.money, size: 14),
                          const SizedBox(width: 6),
                          const Text('Add MD/LD Payment'),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FluentIcons.completed_solid,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'MD/LD Already Released',
                            style: TextStyle(
                              color: Colors.green.dark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: PremiumTheme.spacingM),
            ],

            if (bill.mdNpvAmount > 0) ...[
              const SizedBox(height: PremiumTheme.spacingM),
              _buildMdNpvRow(bill),
              if (bill.mdNpvStatus != 'Released')
                Row(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder:
                              (context) => GenericReceivablePaymentDialog(
                                bill: bill,
                                title: 'Add MD(NPV) Payment',
                                amount: bill.mdNpvAmount,
                                remarks: 'MD(NPV) Payment Received',
                                onSuccess: (date) async {
                                  final dao = ref.read(billsDaoProvider);
                                  await dao.updateMdNpvStatus(
                                    bill.id!,
                                    'Released',
                                  );
                                  await dao.updateMdNpvReleasedDate(
                                    bill.id!,
                                    date,
                                  );
                                  ref.invalidate(
                                    billByIdProvider(widget.billId),
                                  );
                                  ref.invalidate(
                                    billWithPaymentsProvider(widget.billId),
                                  );
                                  ref.invalidate(
                                    paymentsByBillProvider(widget.billId),
                                  );
                                  _showInfoBar(
                                    'MD(NPV) Payment recorded successfully',
                                    InfoBarSeverity.success,
                                  );
                                },
                              ),
                        );
                      },
                      child: const Text('Add MD(NPV) Payment'),
                    ),
                  ],
                ),
            ],
            if (bill.dMeterBox > 0) ...[
              const SizedBox(height: PremiumTheme.spacingM),
              _buildDMeterBoxRow(bill),
              if (bill.dMeterBoxStatus != 'Released')
                Row(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder:
                              (context) => GenericReceivablePaymentDialog(
                                bill: bill,
                                title: 'Add D. Meter Box Payment',
                                amount: bill.dMeterBox,
                                remarks: 'D. Meter Box Payment Received',
                                onSuccess: (date) async {
                                  final dao = ref.read(billsDaoProvider);
                                  await dao.updateDMeterBoxStatus(
                                    bill.id!,
                                    'Released',
                                  );
                                  await dao.updateDMeterBoxReleasedDate(
                                    bill.id!,
                                    date,
                                  );
                                  ref.invalidate(
                                    billByIdProvider(widget.billId),
                                  );
                                  ref.invalidate(
                                    billWithPaymentsProvider(widget.billId),
                                  );
                                  ref.invalidate(
                                    paymentsByBillProvider(widget.billId),
                                  );
                                  _showInfoBar(
                                    'D. Meter Box Payment recorded successfully',
                                    InfoBarSeverity.success,
                                  );
                                },
                              ),
                        );
                      },
                      child: const Text('Add D. Meter Box Payment'),
                    ),
                  ],
                ),
            ],
            if (bill.emptyOilDrum > 0) ...[
              const SizedBox(height: PremiumTheme.spacingM),
              _buildEmptyOilDrumRow(bill),
              if (bill.emptyOilDrumStatus != 'Released')
                Row(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder:
                              (context) => GenericReceivablePaymentDialog(
                                bill: bill,
                                title: 'Add Empty Oil Drum Payment',
                                amount: bill.emptyOilDrum,
                                remarks: 'Empty Oil Drum Payment Received',
                                onSuccess: (date) async {
                                  final dao = ref.read(billsDaoProvider);
                                  await dao.updateEmptyOilDrumStatus(
                                    bill.id!,
                                    'Released',
                                  );
                                  await dao.updateEmptyOilDrumReleasedDate(
                                    bill.id!,
                                    date,
                                  );
                                  ref.invalidate(
                                    billByIdProvider(widget.billId),
                                  );
                                  ref.invalidate(
                                    billWithPaymentsProvider(widget.billId),
                                  );
                                  ref.invalidate(
                                    paymentsByBillProvider(widget.billId),
                                  );
                                  _showInfoBar(
                                    'Empty Oil Drum Payment recorded successfully',
                                    InfoBarSeverity.success,
                                  );
                                },
                              ),
                        );
                      },
                      child: const Text('Add Empty Oil Drum Payment'),
                    ),
                  ],
                ),
            ],

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
                    if (bill.csdDueDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${_dateFormat.format(bill.csdDueDate!)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.dark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // CSD Status (Read-only - changes only via CSD Payment)
              Expanded(
                flex: 2,
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

              const SizedBox(width: 16),
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
                          '-',
                          style: TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
              ),

              // Edit button placeholder for consistent spacing
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMdLdRow(Bill bill) {
    final mdLdStatusColor =
        bill.mdLdStatus == 'Released' ? Colors.green : Colors.purple;

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
                  'MD/LD Status',
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
                  'MD/LD Release Date',
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
              // MD/LD Amount
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MD/LD Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PremiumTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(bill.mdLdAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.purple.dark,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Minimum Demand / Liquidated Damages',
                      style: TextStyle(
                        fontSize: 10,
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // MD/LD Status (Read-only - changes only via MD/LD Payment)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: mdLdStatusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: mdLdStatusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        bill.mdLdStatus == 'Released'
                            ? FluentIcons.check_mark
                            : FluentIcons.clock,
                        size: 14,
                        color: mdLdStatusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bill.mdLdStatus == 'Released' ? 'Released' : 'Pending',
                        style: TextStyle(
                          color: mdLdStatusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),
              // MD/LD Release Date
              Expanded(
                flex: 2,
                child:
                    bill.mdLdReleasedDate != null
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
                            'Released: ${_dateFormat.format(bill.mdLdReleasedDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.dark,
                            ),
                          ),
                        )
                        : const Text(
                          '-',
                          style: TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
              ),

              // Action button to edit bill
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

  Widget _buildMdNpvRow(Bill bill) {
    final statusColor =
        bill.mdNpvStatus == 'Released' ? Colors.green : Colors.orange;

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
          // Header row
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
                  'Status',
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
                  'Release Date',
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
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MD (NPV) Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PremiumTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(bill.mdNpvAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.purple.dark,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Net Present Value',
                      style: TextStyle(
                        fontSize: 10,
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        bill.mdNpvStatus == 'Released'
                            ? FluentIcons.check_mark
                            : FluentIcons.clock,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bill.mdNpvStatus == 'Released' ? 'Released' : 'Pending',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child:
                    bill.mdNpvReleasedDate != null
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
                            'Released: ${_dateFormat.format(bill.mdNpvReleasedDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.dark,
                            ),
                          ),
                        )
                        : const Text(
                          '-',
                          style: TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDMeterBoxRow(Bill bill) {
    final statusColor =
        bill.dMeterBoxStatus == 'Released' ? Colors.green : Colors.orange;

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
          // Header row
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
                  'Status',
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
                  'Release Date',
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
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'D. Meter Box',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PremiumTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(bill.dMeterBox),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.dark,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Double Meter Box Charges',
                      style: TextStyle(
                        fontSize: 10,
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        bill.dMeterBoxStatus == 'Released'
                            ? FluentIcons.check_mark
                            : FluentIcons.clock,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bill.dMeterBoxStatus == 'Released'
                            ? 'Released'
                            : 'Pending',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child:
                    bill.dMeterBoxReleasedDate != null
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
                            'Released: ${_dateFormat.format(bill.dMeterBoxReleasedDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.dark,
                            ),
                          ),
                        )
                        : const Text(
                          '-',
                          style: TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOilDrumRow(Bill bill) {
    final statusColor =
        bill.emptyOilDrumStatus == 'Released' ? Colors.green : Colors.orange;

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
          // Header row
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
                  'Status',
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
                  'Release Date',
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
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Empty Oil Drum',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PremiumTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(bill.emptyOilDrum),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.dark,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Oil Drum Charges',
                      style: TextStyle(
                        fontSize: 10,
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        bill.emptyOilDrumStatus == 'Released'
                            ? FluentIcons.check_mark
                            : FluentIcons.clock,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bill.emptyOilDrumStatus == 'Released'
                            ? 'Released'
                            : 'Pending',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child:
                    bill.emptyOilDrumReleasedDate != null
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
                            'Released: ${_dateFormat.format(bill.emptyOilDrumReleasedDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.dark,
                            ),
                          ),
                        )
                        : const Text(
                          '-',
                          style: TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
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
