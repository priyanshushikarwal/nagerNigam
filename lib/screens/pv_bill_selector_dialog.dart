import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/bill.dart';
import '../models/tender.dart';
import '../state/database_providers.dart';

/// Dialog to select multiple bills from the same tender to combine into a PV invoice
class PvBillSelectorDialog extends ConsumerStatefulWidget {
  final Tender tender;
  final Function(List<Bill> selectedBills) onBillsSelected;

  const PvBillSelectorDialog({
    super.key,
    required this.tender,
    required this.onBillsSelected,
  });

  @override
  ConsumerState<PvBillSelectorDialog> createState() =>
      _PvBillSelectorDialogState();
}

class _PvBillSelectorDialogState extends ConsumerState<PvBillSelectorDialog> {
  List<Bill> _availableBills = [];
  final Set<int> _selectedBillIds = {};
  bool _isLoading = true;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _loadBillsForTender();
  }

  Future<void> _loadBillsForTender() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final billsDao = ref.read(billsDaoProvider);
      final bills = await billsDao.getBillsByTender(widget.tender.id!);

      // Filter to only include JOB invoices (not PV invoices)
      final jobBills =
          bills
              .where(
                (bill) =>
                    bill.invoiceType == null ||
                    bill.invoiceType == 'JOB Invoice' ||
                    bill.invoiceType!.isEmpty,
              )
              .toList();

      setState(() {
        _availableBills = jobBills;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double get _totalInvoiceAmount {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .fold(0.0, (sum, bill) => sum + bill.invoiceAmount);
  }

  double get _totalBillPassAmount {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .fold(0.0, (sum, bill) => sum + bill.billPassAmount);
  }

  double get _totalCsdAmount {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .fold(0.0, (sum, bill) => sum + bill.csdAmount);
  }

  double get _totalMdLdAmount {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .fold(0.0, (sum, bill) => sum + bill.mdLdAmount);
  }

  double get _totalTdsAmount {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .fold(0.0, (sum, bill) => sum + bill.tdsAmount);
  }

  double get _totalTcsAmount {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .fold(0.0, (sum, bill) => sum + bill.tcsAmount);
  }

  double get _totalGstTdsAmount {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .fold(0.0, (sum, bill) => sum + bill.gstTdsAmount);
  }

  List<Bill> get _selectedBills {
    return _availableBills
        .where((bill) => _selectedBillIds.contains(bill.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Row(
        children: [
          Icon(FluentIcons.combine, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Select Bills for PV Invoice',
              style: FluentTheme.of(context).typography.subtitle,
            ),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tender info header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(FluentIcons.folder, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tender: ${widget.tender.tnNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.tender.workDescription ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[100]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          const Text(
            'Select the bills you want to combine into a single PV Invoice:',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Bills list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: ProgressRing())
                    : _availableBills.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.document,
                            size: 48,
                            color: Colors.grey[80],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No JOB invoices found for this tender',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[100],
                            ),
                          ),
                        ],
                      ),
                    )
                    : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[40]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _availableBills.length,
                        separatorBuilder:
                            (_, __) =>
                                Divider(size: 1, style: DividerThemeData()),
                        itemBuilder: (context, index) {
                          final bill = _availableBills[index];
                          final isSelected = _selectedBillIds.contains(bill.id);

                          return Container(
                            color:
                                isSelected
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : null,
                            child: ListTile(
                              leading: Checkbox(
                                checked: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedBillIds.add(bill.id!);
                                    } else {
                                      _selectedBillIds.remove(bill.id);
                                    }
                                  });
                                },
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Invoice: ${bill.invoiceNo ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Lot: ${bill.lotNo ?? 'N/A'} | Store: ${bill.storeName ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[100],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      bill.billDate != null
                                          ? _dateFormat.format(bill.billDate!)
                                          : '-',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      _currencyFormat.format(
                                        bill.invoiceAmount,
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.green.dark,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_selectedBillIds.contains(bill.id)) {
                                    _selectedBillIds.remove(bill.id);
                                  } else {
                                    _selectedBillIds.add(bill.id!);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
          ),

          // Summary section
          if (_selectedBillIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FluentIcons.calculator,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Combined Totals (${_selectedBillIds.length} bills selected)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green.dark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSummaryItem('Invoice Amount', _totalInvoiceAmount),
                      _buildSummaryItem('Bill Pass', _totalBillPassAmount),
                      _buildSummaryItem('CSD', _totalCsdAmount),
                      _buildSummaryItem('MD/LD', _totalMdLdAmount),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSummaryItem('TDS', _totalTdsAmount),
                      _buildSummaryItem('TCS', _totalTcsAmount),
                      _buildSummaryItem('GST TDS', _totalGstTdsAmount),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              _selectedBillIds.isEmpty
                  ? null
                  : () {
                    widget.onBillsSelected(_selectedBills);
                    Navigator.of(context).pop();
                  },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.combine, size: 16),
              const SizedBox(width: 6),
              Text('Combine ${_selectedBillIds.length} Bills'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[100])),
          Text(
            _currencyFormat.format(value),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
