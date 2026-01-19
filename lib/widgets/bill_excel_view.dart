import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../core/premium_theme.dart';

class BillExcelView extends StatefulWidget {
  final Bill bill;

  const BillExcelView({super.key, required this.bill});

  @override
  State<BillExcelView> createState() => _BillExcelViewState();
}

class _BillExcelViewState extends State<BillExcelView> {
  final _horizontalScrollController = ScrollController();
  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Net Payment calculation: Invoice Amount - Deductions (excluding CSD and MD as they are receivables)
    final netPayment =
        widget.bill.invoiceAmount -
        widget.bill.tdsAmount -
        widget.bill.scrapAmount -
        widget.bill.scrapGstAmount -
        widget.bill.tcsAmount -
        widget.bill.gstTdsAmount;

    // Calculate difference between Invoice and Bill Pass
    final difference = widget.bill.invoiceAmount - widget.bill.billPassAmount;

    return Container(
      decoration: BoxDecoration(
        color: PremiumTheme.pureWhite,
        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
        // border: Border.all(color: PremiumTheme.borderColor), // Optional in dialog
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
                          decoration: const BoxDecoration(color: Colors.white),
                          children: [
                            _buildHeaderCell('Invoice No', Colors.black),
                            _buildHeaderCell('Invoice Date', Colors.black),
                            _buildHeaderCell('RR Date', Colors.black),
                            _buildHeaderCell('Lot No', Colors.black),
                            _buildHeaderCell('Store', Colors.black),
                            _buildHeaderCell('Work Order No', Colors.black),
                            _buildHeaderCell('WO Date', Colors.black),
                            _buildHeaderCell('Invoice Amount', Colors.black),
                            _buildHeaderCell('Bill Pass Amount', Colors.black),
                            _buildHeaderCell('Difference', Colors.black),
                            _buildHeaderCell('CSD Amount', Colors.black),
                            _buildHeaderCell('CSD Due Date', Colors.black),
                            _buildHeaderCell('CSD Release Date', Colors.black),
                          ],
                        ),
                        // ROW 2: Data Row - Invoice Information
                        TableRow(
                          decoration: const BoxDecoration(color: Colors.white),
                          children: [
                            _buildDataCell(widget.bill.billNo ?? '-'),
                            _buildDataCell(
                              widget.bill.invoiceDate != null
                                  ? _dateFormat.format(widget.bill.invoiceDate!)
                                  : '-',
                            ),
                            _buildDataCell(
                              _dateFormat.format(widget.bill.billDate),
                            ),
                            _buildDataCell(widget.bill.lotNo ?? '-'),
                            _buildDataCell(widget.bill.storeName ?? '-'),
                            _buildDataCell(widget.bill.workOrderNo ?? '-'),
                            _buildDataCell(
                              widget.bill.workOrderDate != null
                                  ? _dateFormat.format(
                                    widget.bill.workOrderDate!,
                                  )
                                  : '-',
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.invoiceAmount),
                            ),
                            _buildDataCell(
                              _currencyFormat.format(
                                widget.bill.billPassAmount,
                              ),
                            ),
                            _buildDataCell(_currencyFormat.format(difference)),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.csdAmount),
                              backgroundColor:
                                  widget.bill.csdStatus == 'Released'
                                      ? const Color(0xFFD4EDDA) // Light green
                                      : const Color(0xFFF8D7DA), // Light red
                            ),
                            _buildDataCell(
                              widget.bill.csdDueDate != null
                                  ? _dateFormat.format(widget.bill.csdDueDate!)
                                  : '-',
                            ),
                            _buildDataCell(
                              widget.bill.csdReleasedDate != null
                                  ? _dateFormat.format(
                                    widget.bill.csdReleasedDate!,
                                  )
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
                          decoration: const BoxDecoration(color: Colors.white),
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
                          decoration: const BoxDecoration(color: Colors.white),
                          children: [
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.tdsAmount),
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.scrapAmount),
                            ),
                            _buildDataCell(
                              _currencyFormat.format(
                                widget.bill.scrapGstAmount,
                              ),
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.tcsAmount),
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.gstTdsAmount),
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.mdLdAmount),
                              backgroundColor:
                                  widget.bill.mdLdStatus == 'Released'
                                      ? const Color(0xFFD4EDDA) // Light green
                                      : const Color(0xFFF8D7DA), // Light red
                            ),
                            _buildDataCell(
                              widget.bill.remarks ?? '-',
                              fontSize: 10,
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.dMeterBox),
                              backgroundColor:
                                  widget.bill.dMeterBoxStatus == 'Released'
                                      ? const Color(0xFFD4EDDA) // Light green
                                      : const Color(0xFFF8D7DA), // Light red
                            ),
                            _buildDataCell(
                              widget.bill.dMeterBoxRemark ?? '-',
                              fontSize: 10,
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.emptyOilDrum),
                              backgroundColor:
                                  widget.bill.emptyOilDrumStatus == 'Released'
                                      ? const Color(0xFFD4EDDA) // Light green
                                      : const Color(0xFFF8D7DA), // Light red
                            ),
                            _buildDataCell(
                              widget.bill.emptyOilDrumRemark ?? '-',
                              fontSize: 10,
                            ),
                            _buildDataCell(
                              _currencyFormat.format(widget.bill.mdNpvAmount),
                              backgroundColor:
                                  widget.bill.mdNpvStatus == 'Released'
                                      ? const Color(0xFFD4EDDA) // Light green
                                      : const Color(0xFFF8D7DA), // Light red
                            ),
                            _buildDataCell(
                              widget.bill.mdNpvRemark ?? '-',
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
}
