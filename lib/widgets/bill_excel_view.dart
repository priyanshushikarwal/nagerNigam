import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import '../models/bill.dart';

class BillExcelView extends StatelessWidget {
  final Bill bill;
  final Firm? firm;
  final List<Payment> payments;
  final VoidCallback? onExportPdf;

  const BillExcelView({
    super.key,
    required this.bill,
    this.firm,
    this.payments = const [],
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    if (firm == null) {
      return const Center(child: Text('Firm details not available'));
    }

    // Net Payment calculation for the table
    // Note: The logic handles nulls by default as the model fields are non-null doubles mostly, or handled.
    final netPayable =
        bill.invoiceAmount -
        bill.tdsAmount -
        bill.scrapAmount -
        bill.scrapGstAmount -
        bill.tcsAmount -
        bill.gstTdsAmount;

    final difference = bill.invoiceAmount - bill.billPassAmount;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Section
          Stack(
            alignment: Alignment.topCenter,
            children: [
              // Left: Payment Detail
              const Positioned(
                left: 0,
                top: 0,
                child: Text(
                  'Payment Detail',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Center: Firm Details
              Column(
                children: [
                  Text(
                    firm!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    firm!.address ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const material.Divider(thickness: 1, color: Colors.grey),
          const SizedBox(height: 20),

          // 2. Bill/Work Order Details Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Lot No.', bill.lotNo ?? '-'),
                    _buildDetailRow('Store', bill.storeName ?? '-'),
                    _buildDetailRow('TN', bill.tnNumber),
                  ],
                ),
              ),
              // Middle Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Work Order No.', bill.workOrderNo ?? '-'),
                    _buildDetailRow(
                      'Work Order Date',
                      bill.workOrderDate != null
                          ? dateFormat.format(bill.workOrderDate!)
                          : '-',
                    ),
                  ],
                ),
              ),
              // Right Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Nigam Name - ${bill.clientFirmName ?? '-'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 3. Bill Summary Title and Export Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill Summary - ${bill.billNo ?? bill.invoiceNo ?? '-'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bill Summary (Excel View)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              if (onExportPdf != null)
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: ButtonState.all(
                      const Color(0xFFFFF100),
                    ), // Yellow
                    foregroundColor: ButtonState.all(Colors.black),
                  ),
                  onPressed: onExportPdf,
                  child: const Text(
                    'Export in PDF',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 4. Excel View Tables
          // Table 1
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1), // Store
              1: FlexColumnWidth(0.8), // WO No
              2: FlexColumnWidth(0.8), // WO Date
              3: FlexColumnWidth(1), // Invoice Amt
              4: FlexColumnWidth(1), // Bill Pass Amt
              5: FlexColumnWidth(0.8), // Diff
              6: FlexColumnWidth(1), // CSD Amt
              7: FlexColumnWidth(0.8), // CSD Due
              8: FlexColumnWidth(0.8), // CSD Release
            },
            border: TableBorder.all(color: Colors.black, width: 1),
            children: [
              // Header Row 1
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _buildHeaderCell('Store'),
                  _buildHeaderCell('Work Order No'),
                  _buildHeaderCell('WO Date'),
                  _buildHeaderCell('Invoice Amount'),
                  _buildHeaderCell('Bill Pass Amount'),
                  _buildHeaderCell('Difference'),
                  _buildHeaderCell('CSD Amount'),
                  _buildHeaderCell('CSD Due Date'),
                  _buildHeaderCell('CSD Release Date'),
                ],
              ),
              // Data Row 1
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _buildDataCell(bill.storeName ?? '-'),
                  _buildDataCell(bill.workOrderNo ?? '-'),
                  _buildDataCell(
                    bill.workOrderDate != null
                        ? dateFormat.format(bill.workOrderDate!)
                        : '-',
                  ),
                  _buildDataCell(currencyFormat.format(bill.invoiceAmount)),
                  _buildDataCell(currencyFormat.format(bill.billPassAmount)),
                  _buildDataCell(currencyFormat.format(difference)),
                  _buildDataCell(
                    currencyFormat.format(bill.csdAmount),
                    backgroundColor:
                        bill.csdStatus == 'Released'
                            ? const Color(0xFFD4EDDA)
                            : const Color(0xFFF8D7DA),
                  ),
                  _buildDataCell(
                    bill.csdDueDate != null
                        ? dateFormat.format(bill.csdDueDate!)
                        : '-',
                  ),
                  _buildDataCell(
                    bill.csdReleasedDate != null
                        ? dateFormat.format(bill.csdReleasedDate!)
                        : '-',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8), // Small gap between tables
          // Table 2
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1), // GST TDS
              1: FlexColumnWidth(1), // MD Amount
              2: FlexColumnWidth(1), // Remark
              3: FlexColumnWidth(1), // D Meter Box
              4: FlexColumnWidth(1), // Remark
              5: FlexColumnWidth(1), // Empty Oil
              6: FlexColumnWidth(1), // Remark
              7: FlexColumnWidth(1), // MD NPV
              8: FlexColumnWidth(1), // Remark
              9: FlexColumnWidth(1.2), // Net Payable
            },
            border: TableBorder.all(color: Colors.black, width: 1),
            children: [
              // Header Row 2
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _buildHeaderCell('GST TDS'),
                  _buildHeaderCell('MD Amount'),
                  _buildHeaderCell('Remark'),
                  _buildHeaderCell('D. Meter Box'),
                  _buildHeaderCell('Remark'),
                  _buildHeaderCell('Empty Oil Drum'),
                  _buildHeaderCell('Remark'),
                  _buildHeaderCell('MD (NPV)'),
                  _buildHeaderCell('Remark'),
                  _buildHeaderCell('Net Payable Amount'),
                ],
              ),
              // Data Row 2
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _buildDataCell(currencyFormat.format(bill.gstTdsAmount)),
                  _buildDataCell(
                    currencyFormat.format(bill.mdLdAmount),
                    backgroundColor:
                        bill.mdLdStatus == 'Released'
                            ? const Color(0xFFD4EDDA)
                            : const Color(0xFFF8D7DA),
                  ),
                  _buildDataCell(
                    bill.remarks ?? '-',
                    fontSize: 10,
                  ), // General Remark
                  _buildDataCell(
                    currencyFormat.format(bill.dMeterBox),
                    backgroundColor:
                        bill.dMeterBoxStatus == 'Released'
                            ? const Color(0xFFD4EDDA)
                            : const Color(0xFFF8D7DA),
                  ),
                  _buildDataCell(bill.dMeterBoxRemark ?? '-', fontSize: 10),
                  _buildDataCell(
                    currencyFormat.format(bill.emptyOilDrum),
                    backgroundColor:
                        bill.emptyOilDrumStatus == 'Released'
                            ? const Color(0xFFD4EDDA)
                            : const Color(0xFFF8D7DA),
                  ),
                  _buildDataCell(bill.emptyOilDrumRemark ?? '-', fontSize: 10),
                  _buildDataCell(
                    currencyFormat.format(bill.mdNpvAmount),
                    backgroundColor:
                        bill.mdNpvStatus == 'Released'
                            ? const Color(0xFFD4EDDA)
                            : const Color(0xFFF8D7DA),
                  ),
                  _buildDataCell(bill.mdNpvRemark ?? '-', fontSize: 10),
                  _buildDataCell(
                    currencyFormat.format(netPayable),
                    isBold: true,
                    backgroundColor: Colors.grey[20],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 5. Payment Ledger
          const Text(
            'Payment Ledger',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentLedger(netPayable, currencyFormat, dateFormat),
          const SizedBox(height: 30),

          // 6. Signatures
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSignatureBlock('Signature', 'Verified by Accountant'),
              _buildSignatureBlock('Signature', 'Verified by 02'),
              _buildSignatureBlock('Signature', 'Verified by 03'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: '$label - ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    bool isBold = false,
    double fontSize = 11,
    Color? backgroundColor,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          fontSize: fontSize,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (backgroundColor != null) {
      return Container(color: backgroundColor, child: content);
    }
    return content;
  }

  Widget _buildPaymentLedger(
    double netPayable,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    // Sort payments by date
    final sortedPayments = List<Payment>.from(payments)
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    // Build ledger entries
    List<Map<String, dynamic>> ledgerEntries = [];

    // First entry: Bill Created
    ledgerEntries.add({
      'date': bill.createdAt,
      'type': 'Bill Created',
      'paidAmount': 0.0,
      'totalPaid': 0.0,
      'remaining': netPayable,
      'status': 'Pending',
      'remarks': '-',
    });

    double runningTotalPaid = 0;
    for (var payment in sortedPayments) {
      runningTotalPaid += payment.amountPaid;
      final remaining = netPayable - runningTotalPaid;
      // Precision handling
      final displayRemaining = remaining < 0.01 ? 0.0 : remaining;

      String status;
      if (displayRemaining <= 0.01) {
        status = 'Paid';
      } else if (runningTotalPaid > 0) {
        status = 'Partially Paid';
      } else {
        status = 'Pending';
      }

      ledgerEntries.add({
        'date': payment.paymentDate,
        'type': 'Payment Received',
        'paidAmount': payment.amountPaid,
        'totalPaid': runningTotalPaid,
        'remaining': displayRemaining,
        'status': status,
        'remarks': payment.remarks ?? '-',
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        // border: null, // Clearer view as per image
      ),
      child: material.Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2), // Date
          1: FlexColumnWidth(2), // Type
          2: FlexColumnWidth(1.5), // Amt Paid
          3: FlexColumnWidth(1.5), // Total Paid
          4: FlexColumnWidth(1.5), // Remaining
          5: FlexColumnWidth(1.2), // Status
          6: FlexColumnWidth(2.5), // Remarks
        },
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            children: [
              _buildLedgerHeader('Date'),
              _buildLedgerHeader('Type'),
              _buildLedgerHeader('Amount Paid'),
              _buildLedgerHeader('Total Paid'),
              _buildLedgerHeader('Remaining'),
              _buildLedgerHeader('Status'),
              _buildLedgerHeader('Remarks'),
            ],
          ),
          // Data
          ...ledgerEntries.map((entry) {
            return TableRow(
              children: [
                _buildLedgerCell(dateFormat.format(entry['date'])),
                _buildLedgerCell(entry['type']),
                _buildLedgerCell(currencyFormat.format(entry['paidAmount'])),
                _buildLedgerCell(currencyFormat.format(entry['totalPaid'])),
                _buildLedgerCell(
                  currencyFormat.format(entry['remaining']),
                  color:
                      (entry['remaining'] as double) <= 0.01
                          ? Colors.orange
                          : Colors.orange, // Image uses orange for remaining
                  forceColor: true,
                ),
                _buildLedgerCell(
                  entry['status'],
                  color:
                      entry['status'] == 'Pending'
                          ? Colors.orange
                          : Colors
                              .orange, // Image seems to use orange for all generic statuses or maybe light orange
                  forceColor: true,
                ),
                _buildLedgerCell(entry['remarks']),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLedgerHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildLedgerCell(
    String text, {
    Color? color,
    bool forceColor = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: forceColor ? color : Colors.black,
          fontWeight: forceColor ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSignatureBlock(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
