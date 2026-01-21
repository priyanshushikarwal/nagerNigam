import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/bill.dart';
import '../models/tender.dart';
import '../state/client_firm_providers.dart';
import '../state/database_providers.dart';
import '../state/firm_providers.dart';
import '../state/tender_providers.dart';
import 'tender_form_dialog.dart';
import 'pv_bill_selector_dialog.dart';

class ComprehensiveBillFormDialog extends ConsumerStatefulWidget {
  final Bill? bill;
  final int firmId;

  const ComprehensiveBillFormDialog({
    super.key,
    this.bill,
    required this.firmId,
  });

  @override
  ConsumerState<ComprehensiveBillFormDialog> createState() =>
      _ComprehensiveBillFormDialogState();
}

class _ComprehensiveBillFormDialogState
    extends ConsumerState<ComprehensiveBillFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  late TextEditingController _amountController;
  late TextEditingController _invoiceAmountController;
  late TextEditingController _billPassAmountController;
  late TextEditingController _csdAmountController;
  late TextEditingController _scrapAmountController;
  late TextEditingController _scrapGstAmountController;
  late TextEditingController _mdLdAmountController;

  late TextEditingController _remarksController;
  // Manual amount controllers (no longer auto-calculated)
  late TextEditingController _tdsAmountController;
  late TextEditingController _tcsAmountController;
  late TextEditingController _gstTdsAmountController;
  // Payment tracking controllers
  late TextEditingController _transactionNoController;
  late TextEditingController _invoiceNoController;
  late TextEditingController _workOrderNoController;
  late TextEditingController _consignmentNameController;
  // Date manual entry controllers (auto-format ddmmyyyy -> dd-MM-yyyy)
  late TextEditingController _rrDateController;
  late TextEditingController _workOrderDateController;
  late TextEditingController _invoiceDateController;
  late TextEditingController _dueDateController;
  late TextEditingController _csdDueDateController;
  late TextEditingController _csdReleasedDateController;
  late TextEditingController _paidDateController;
  // New fields controllers
  late TextEditingController _lotNoController;
  late TextEditingController _storeNameController;
  late TextEditingController _dMeterBoxController;
  late TextEditingController _mdNpvAmountController;
  late TextEditingController _emptyOilDrumController;
  late TextEditingController _dMeterBoxRemarkController;
  late TextEditingController _mdNpvRemarkController;
  late TextEditingController _emptyOilDrumRemarkController;

  // Date fields
  DateTime _billDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _csdReleasedDate;
  DateTime? _csdDueDate;
  DateTime? _paidDate;
  DateTime? _dueReleaseDate;
  DateTime? _invoiceDate;
  DateTime? _workOrderDate;
  String? _proofPath;
  bool _isSubmitting = false;

  // Auto-calculated values

  // Add at top of state class
  List<Tender> _tenders = [];
  Tender? _selectedTender;
  int? _selectedClientFirmId;
  String? _invoiceType; // 'JOB Invoice' or 'PV Invoice'
  List<Bill> _combinedBills = []; // Bills selected for PV invoice

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTenders();

    // Initialize client firm if editing existing bill
    if (widget.bill != null && widget.bill!.clientFirmId != null) {
      _selectedClientFirmId = widget.bill!.clientFirmId;
    }
  }

  void _initializeControllers() {
    // Helper to format amount: show empty for 0, otherwise show value
    String formatAmount(double? value) {
      if (value == null || value == 0) return '';
      return value.toStringAsFixed(2);
    }

    _amountController = TextEditingController(
      text: formatAmount(widget.bill?.amount),
    );
    _invoiceAmountController = TextEditingController(
      text: formatAmount(widget.bill?.invoiceAmount),
    );
    _billPassAmountController = TextEditingController(
      text: formatAmount(widget.bill?.billPassAmount),
    );
    _csdAmountController = TextEditingController(
      text: formatAmount(widget.bill?.csdAmount),
    );
    _scrapAmountController = TextEditingController(
      text: formatAmount(widget.bill?.scrapAmount),
    );
    _scrapGstAmountController = TextEditingController(
      text: formatAmount(widget.bill?.scrapGstAmount),
    );
    _mdLdAmountController = TextEditingController(
      text: formatAmount(widget.bill?.mdLdAmount),
    );

    _remarksController = TextEditingController(
      text: widget.bill?.remarks ?? '',
    );
    // Manual amount controllers
    _tdsAmountController = TextEditingController(
      text: formatAmount(widget.bill?.tdsAmount),
    );
    _tcsAmountController = TextEditingController(
      text: formatAmount(widget.bill?.tcsAmount),
    );
    _gstTdsAmountController = TextEditingController(
      text: formatAmount(widget.bill?.gstTdsAmount),
    );
    // Payment tracking controllers
    _transactionNoController = TextEditingController(
      text: widget.bill?.transactionNo ?? '',
    );
    _invoiceNoController = TextEditingController(
      text: widget.bill?.invoiceNo ?? '',
    );
    _workOrderNoController = TextEditingController(
      text: widget.bill?.workOrderNo ?? '',
    );
    _consignmentNameController = TextEditingController(
      text: widget.bill?.consignmentName ?? '',
    );
    // New fields controllers
    _lotNoController = TextEditingController(text: widget.bill?.lotNo ?? '');
    _storeNameController = TextEditingController(
      text: widget.bill?.storeName ?? '',
    );
    _dMeterBoxController = TextEditingController(
      text: formatAmount(widget.bill?.dMeterBox),
    );
    _mdNpvAmountController = TextEditingController(
      text: formatAmount(widget.bill?.mdNpvAmount),
    );
    _emptyOilDrumController = TextEditingController(
      text: formatAmount(widget.bill?.emptyOilDrum),
    );
    _dMeterBoxRemarkController = TextEditingController(
      text: widget.bill?.dMeterBoxRemark ?? '',
    );
    _mdNpvRemarkController = TextEditingController(
      text: widget.bill?.mdNpvRemark ?? '',
    );
    _emptyOilDrumRemarkController = TextEditingController(
      text: widget.bill?.emptyOilDrumRemark ?? '',
    );

    // Date format for manual entry
    final dateFormat = DateFormat('dd-MM-yyyy');

    if (widget.bill != null) {
      _billDate = widget.bill!.billDate;
      _rrDateController = TextEditingController(
        text: dateFormat.format(widget.bill!.billDate),
      );
      _dueDate = widget.bill!.dueDate;
      _dueDateController = TextEditingController(
        text: dateFormat.format(widget.bill!.dueDate),
      );
      _csdReleasedDate = widget.bill!.csdReleasedDate;
      _csdReleasedDateController = TextEditingController(
        text:
            _csdReleasedDate != null
                ? dateFormat.format(_csdReleasedDate!)
                : '',
      );
      _csdDueDate = widget.bill!.csdDueDate;
      _csdDueDateController = TextEditingController(
        text: _csdDueDate != null ? dateFormat.format(_csdDueDate!) : '',
      );
      _paidDate = widget.bill!.paidDate;
      _paidDateController = TextEditingController(
        text: _paidDate != null ? dateFormat.format(_paidDate!) : '',
      );
      _dueReleaseDate = widget.bill!.dueReleaseDate;
      _invoiceDate = widget.bill!.invoiceDate;
      _invoiceDateController = TextEditingController(
        text: _invoiceDate != null ? dateFormat.format(_invoiceDate!) : '',
      );
      _workOrderDate = widget.bill!.workOrderDate;
      _workOrderDateController = TextEditingController(
        text: _workOrderDate != null ? dateFormat.format(_workOrderDate!) : '',
      );
      _proofPath = widget.bill!.proofPath;
      _invoiceType = widget.bill!.invoiceType;
    } else {
      // For new bills, set default due date to 45 days from today
      final today = DateTime.now();
      _billDate = today;
      _rrDateController = TextEditingController(text: '');
      _invoiceDate = today;
      _invoiceDateController = TextEditingController(
        text: dateFormat.format(today),
      );
      _dueDate = today.add(const Duration(days: 45));
      _dueDateController = TextEditingController(
        text: dateFormat.format(_dueDate),
      );
      _workOrderDateController = TextEditingController(text: '');
      _csdDueDateController = TextEditingController(text: '');
      _csdReleasedDateController = TextEditingController(text: '');
      _paidDateController = TextEditingController(text: '');
    }
  }

  Future<void> _loadTenders() async {
    final firm = ref.read(selectedFirmProvider);
    if (firm == null || firm.id == null) return;

    final tenders = await ref.read(tendersByFirmProvider.future);
    if (!mounted) return;

    setState(() {
      _tenders = tenders;

      if (_selectedTender != null) {
        _selectedTender = _findTenderById(tenders, _selectedTender!.id);
      }

      if (_selectedTender == null && widget.bill?.tenderId != null) {
        _selectedTender = _findTenderById(tenders, widget.bill!.tenderId);
      }
    });
  }

  Tender? _findTenderById(List<Tender> tenders, int? id) {
    if (id == null) return null;
    for (final tender in tenders) {
      if (tender.id == id) {
        return tender;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _invoiceAmountController.dispose();
    _billPassAmountController.dispose();
    _csdAmountController.dispose();
    _scrapAmountController.dispose();
    _scrapGstAmountController.dispose();
    _mdLdAmountController.dispose();

    _remarksController.dispose();
    _tdsAmountController.dispose();
    _tcsAmountController.dispose();
    _gstTdsAmountController.dispose();
    _transactionNoController.dispose();
    _invoiceNoController.dispose();
    _workOrderNoController.dispose();
    _consignmentNameController.dispose();
    _rrDateController.dispose();
    _workOrderDateController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _csdDueDateController.dispose();
    _csdReleasedDateController.dispose();
    _paidDateController.dispose();
    _lotNoController.dispose();
    _storeNameController.dispose();
    _dMeterBoxController.dispose();
    _mdNpvAmountController.dispose();
    _emptyOilDrumController.dispose();
    _dMeterBoxRemarkController.dispose();
    _mdNpvRemarkController.dispose();
    _emptyOilDrumRemarkController.dispose();
    super.dispose();
  }

  /// Populates form fields from combined bills for PV invoice
  void _populateFromCombinedBills(List<Bill> bills) {
    if (bills.isEmpty) return;

    // Calculate combined totals
    double totalInvoiceAmount = 0;
    double totalBillPassAmount = 0;
    double totalCsdAmount = 0;
    double totalMdLdAmount = 0;
    double totalTdsAmount = 0;
    double totalTcsAmount = 0;
    double totalGstTdsAmount = 0;
    double totalScrapAmount = 0;
    double totalScrapGstAmount = 0;
    double totalDMeterBox = 0;
    double totalMdNpvAmount = 0;
    double totalEmptyOilDrum = 0;

    for (final bill in bills) {
      totalInvoiceAmount += bill.invoiceAmount;
      totalBillPassAmount += bill.billPassAmount;
      totalCsdAmount += bill.csdAmount;
      totalMdLdAmount += bill.mdLdAmount;
      totalTdsAmount += bill.tdsAmount;
      totalTcsAmount += bill.tcsAmount;
      totalGstTdsAmount += bill.gstTdsAmount;
      totalScrapAmount += bill.scrapAmount;
      totalScrapGstAmount += bill.scrapGstAmount;
      totalDMeterBox += bill.dMeterBox;
      totalMdNpvAmount += bill.mdNpvAmount;
      totalEmptyOilDrum += bill.emptyOilDrum;
    }

    // Build combined invoice numbers
    final invoiceNos = bills
        .where((b) => b.invoiceNo != null && b.invoiceNo!.isNotEmpty)
        .map((b) => b.invoiceNo)
        .join(', ');

    // Build combined lot numbers
    final lotNos = bills
        .where((b) => b.lotNo != null && b.lotNo!.isNotEmpty)
        .map((b) => b.lotNo)
        .toSet() // Remove duplicates
        .join(', ');

    setState(() {
      _invoiceType = 'PV Invoice';
      _combinedBills = bills;

      // Populate controllers with combined values
      _invoiceAmountController.text = totalInvoiceAmount.toStringAsFixed(2);
      _billPassAmountController.text = totalBillPassAmount.toStringAsFixed(2);
      _csdAmountController.text = totalCsdAmount.toStringAsFixed(2);
      _mdLdAmountController.text = totalMdLdAmount.toStringAsFixed(2);
      _tdsAmountController.text = totalTdsAmount.toStringAsFixed(2);
      _tcsAmountController.text = totalTcsAmount.toStringAsFixed(2);
      _gstTdsAmountController.text = totalGstTdsAmount.toStringAsFixed(2);
      _scrapAmountController.text = totalScrapAmount.toStringAsFixed(2);
      _scrapGstAmountController.text = totalScrapGstAmount.toStringAsFixed(2);
      _dMeterBoxController.text = totalDMeterBox.toStringAsFixed(2);
      _mdNpvAmountController.text = totalMdNpvAmount.toStringAsFixed(2);
      _emptyOilDrumController.text = totalEmptyOilDrum.toStringAsFixed(2);

      // Set combined invoice number reference
      if (invoiceNos.isNotEmpty) {
        _invoiceNoController.text = 'PV-$invoiceNos';
      }

      // Set combined lot numbers
      if (lotNos.isNotEmpty) {
        _lotNoController.text = lotNos;
      }

      // Set remarks indicating this is a combined PV invoice
      _remarksController.text =
          'PV Invoice combining ${bills.length} bills: $invoiceNos';
    });
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (_selectedTender == null) {
      _showValidationError('Please select a TN Number');
      return;
    }

    // Validate Client Firm (required)
    if (_selectedClientFirmId == null) {
      _showValidationError('Please select a Client/Contractor Firm');
      return;
    }

    // Validate Bill No (required)
    final billNo = _invoiceNoController.text.trim();
    if (billNo.isEmpty) {
      _showValidationError('Bill No is required');
      return;
    }

    // Validate Work Order No (required)
    final workOrderNo = _workOrderNoController.text.trim();
    if (workOrderNo.isEmpty) {
      _showValidationError('Work Order No is required');
      return;
    }

    // Validate RR Date (required)
    final rrDateText = _rrDateController.text.trim();
    if (rrDateText.isEmpty) {
      _showValidationError('RR Date is required');
      return;
    }
    try {
      final dateFormat = DateFormat('dd-MM-yyyy');
      _billDate = dateFormat.parseStrict(rrDateText);
    } catch (_) {
      _showValidationError('RR Date must be in dd-MM-yyyy format');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showValidationError('Please enter a valid amount greater than 0');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bill = Bill(
        id: widget.bill?.id,
        firmId: widget.firmId,
        clientFirmId: _selectedClientFirmId,
        tenderId: _selectedTender!.id,
        tnNumber: _selectedTender!.tnNumber,
        billDate: _billDate,
        dueDate: _dueDate,
        amount: amount,
        status: widget.bill?.status ?? 'Pending',
        remarks:
            _remarksController.text.trim().isEmpty
                ? null
                : _remarksController.text.trim(),
        invoiceAmount: double.tryParse(_invoiceAmountController.text) ?? 0,
        billPassAmount: double.tryParse(_billPassAmountController.text) ?? 0,
        csdAmount: double.tryParse(_csdAmountController.text) ?? 0,
        csdReleasedDate: _csdReleasedDate,
        csdDueDate: _csdDueDate,
        csdStatus: widget.bill?.csdStatus ?? 'Pending',
        scrapAmount: double.tryParse(_scrapAmountController.text) ?? 0,
        scrapGstAmount: double.tryParse(_scrapGstAmountController.text) ?? 0,
        mdLdAmount: double.tryParse(_mdLdAmountController.text) ?? 0,
        emptyOilIssued: 0,
        emptyOilReturned: 0,
        tdsAmount: double.tryParse(_tdsAmountController.text) ?? 0.0,
        tcsAmount: double.tryParse(_tcsAmountController.text) ?? 0.0,
        gstTdsAmount: double.tryParse(_gstTdsAmountController.text) ?? 0.0,
        paidDate: _paidDate,
        transactionNo:
            _transactionNoController.text.trim().isEmpty
                ? null
                : _transactionNoController.text.trim(),
        dueReleaseDate: _dueReleaseDate,
        invoiceNo:
            _invoiceNoController.text.trim().isEmpty
                ? null
                : _invoiceNoController.text.trim(),
        invoiceDate: _invoiceDate,
        workOrderNo:
            _workOrderNoController.text.trim().isEmpty
                ? null
                : _workOrderNoController.text.trim(),
        workOrderDate: _workOrderDate,
        consignmentName:
            _consignmentNameController.text.trim().isEmpty
                ? null
                : _consignmentNameController.text.trim(),
        lotNo:
            _lotNoController.text.trim().isEmpty
                ? null
                : _lotNoController.text.trim(),
        storeName:
            _storeNameController.text.trim().isEmpty
                ? null
                : _storeNameController.text.trim(),
        dMeterBox: double.tryParse(_dMeterBoxController.text) ?? 0,
        mdNpvAmount: double.tryParse(_mdNpvAmountController.text) ?? 0,
        emptyOilDrum: double.tryParse(_emptyOilDrumController.text) ?? 0,
        dMeterBoxRemark:
            _dMeterBoxRemarkController.text.trim().isEmpty
                ? null
                : _dMeterBoxRemarkController.text.trim(),
        mdNpvRemark:
            _mdNpvRemarkController.text.trim().isEmpty
                ? null
                : _mdNpvRemarkController.text.trim(),
        emptyOilDrumRemark:
            _emptyOilDrumRemarkController.text.trim().isEmpty
                ? null
                : _emptyOilDrumRemarkController.text.trim(),
        proofPath: _proofPath,
        invoiceType: _invoiceType,
        createdAt: widget.bill?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final billsDao = ref.read(billsDaoProvider);

      int? billId;
      if (widget.bill == null) {
        billId = await billsDao.addBill(bill);
      } else {
        await billsDao.updateBill(bill);
        billId = widget.bill!.id;
      }

      final tenderId = _selectedTender!.id;
      if (tenderId != null) {
        ref.invalidate(billsByTenderProvider(tenderId));
        ref.invalidate(tenderStatsProvider(tenderId));
      }
      if (billId != null) {
        ref.invalidate(billByIdProvider(billId));
        ref.invalidate(billWithPaymentsProvider(billId));
      }
      ref.invalidate(tendersByFirmProvider);
      ref.invalidate(firmTendersProvider);

      if (mounted) {
        Navigator.pop(context, true);
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Success'),
                content: Text(
                  widget.bill == null
                      ? 'Bill created successfully'
                      : 'Bill updated successfully',
                ),
                severity: InfoBarSeverity.success,
              ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Error'),
                content: Text('Failed to save bill: $e'),
                severity: InfoBarSeverity.error,
              ),
        );
      }
    }
  }

  void _showValidationError(String message) {
    displayInfoBar(
      context,
      builder:
          (context, close) => InfoBar(
            title: const Text('Validation Error'),
            content: Text(message),
            severity: InfoBarSeverity.warning,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      title: Text(widget.bill == null ? 'Add New Bill' : 'Edit Bill'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildFinancialSection(),
              const SizedBox(height: 20),
              _buildAutoCalculatedSection(),
              const SizedBox(height: 20),
              _buildPaymentTrackingSection(),
              const SizedBox(height: 20),
              _buildRemarksSection(),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: ProgressRing(strokeWidth: 2),
                  )
                  : Text(widget.bill == null ? 'Add Bill' : 'Update Bill'),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Expander(
      header: const Text('Basic Information'),
      initiallyExpanded: true,
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Select TN Number *',
                  child: ComboBox<Tender>(
                    value: _selectedTender,
                    items:
                        _tenders.map((tender) {
                          return ComboBoxItem<Tender>(
                            value: tender,
                            child: Text(
                              '${tender.tnNumber} - ${tender.workDescription ?? ""}',
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTender = value;
                      });
                    },
                    placeholder: const Text('Select Tender Number'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Button(
                child: const Text('+ New TN'),
                onPressed: () async {
                  final firm = ref.read(selectedFirmProvider);
                  if (firm == null || firm.id == null) return;

                  // Open TN creation dialog
                  await showDialog(
                    context: context,
                    builder: (context) => TenderFormDialog(firmId: firm.id!),
                  );
                  _loadTenders(); // Reload after creation
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Client Firm Selection
          InfoLabel(
            label: 'Client/Contractor Firm *',
            child: Builder(
              builder: (context) {
                final clientFirmsAsync = ref.watch(clientFirmsProvider);
                return clientFirmsAsync.when(
                  data: (firms) {
                    return SizedBox(
                      width: double.infinity,
                      child: ComboBox<int>(
                        value: _selectedClientFirmId,
                        isExpanded: true,
                        items:
                            firms.where((firm) => firm.id != null).map((firm) {
                              return ComboBoxItem<int>(
                                value: firm.id!,
                                child: Text(firm.firmName),
                              );
                            }).toList(),
                        onChanged:
                            _isSubmitting
                                ? null
                                : (value) {
                                  setState(() {
                                    _selectedClientFirmId = value;
                                  });
                                },
                        placeholder: const Text('Select Client Firm'),
                      ),
                    );
                  },
                  loading: () => const ProgressRing(),
                  error: (err, stack) => Text('Error: $err'),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Invoice Number *',
                  child: TextBox(
                    controller: _invoiceNoController,
                    placeholder: 'Enter invoice number',
                    enabled: !_isSubmitting,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'Work Order Number *',
                  child: TextBox(
                    controller: _workOrderNoController,
                    placeholder: 'Enter work order no.',
                    enabled: !_isSubmitting,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAutoFormatDateField(
                  label: 'RR Date',
                  controller: _rrDateController,
                  isRequired: true,
                  onDateParsed: (date) {
                    if (date != null) {
                      setState(() => _billDate = date);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAutoFormatDateField(
                  label: 'Work Order Date',
                  controller: _workOrderDateController,
                  onDateParsed: (date) => setState(() => _workOrderDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Invoice Type',
                  child: ComboBox<String>(
                    value: _invoiceType,
                    items: const [
                      ComboBoxItem<String>(
                        value: 'JOB Invoice',
                        child: Text('JOB Invoice'),
                      ),
                      ComboBoxItem<String>(
                        value: 'PV Invoice',
                        child: Text('PV Invoice'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == 'PV Invoice') {
                        // Check if tender is selected first
                        if (_selectedTender == null) {
                          displayInfoBar(
                            context,
                            builder: (context, close) {
                              return InfoBar(
                                title: const Text('Select Tender First'),
                                content: const Text(
                                  'Please select a tender before creating a PV Invoice.',
                                ),
                                severity: InfoBarSeverity.warning,
                                onClose: close,
                              );
                            },
                          );
                          return;
                        }

                        // Show the PV bill selector dialog
                        await showDialog(
                          context: context,
                          builder:
                              (context) => PvBillSelectorDialog(
                                tender: _selectedTender!,
                                onBillsSelected: (selectedBills) {
                                  _populateFromCombinedBills(selectedBills);
                                },
                              ),
                        );
                      } else {
                        setState(() {
                          _invoiceType = value;
                          _combinedBills = [];
                        });
                      }
                    },
                    placeholder: const Text('Select invoice type'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Show combined bills info if PV Invoice
              Expanded(
                child:
                    _combinedBills.isNotEmpty
                        ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FluentIcons.combine,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_combinedBills.length} bills combined',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.dark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lot No and Store Name Row
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Lot No',
                  child: TextBox(
                    controller: _lotNoController,
                    placeholder: 'Enter lot number',
                    enabled: !_isSubmitting,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'Store Name',
                  child: TextBox(
                    controller: _storeNameController,
                    placeholder: 'Enter store name',
                    enabled: !_isSubmitting,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // D Meter Box, MD (NPV), Empty Oil Drum Row
          Row(
            children: [
              Expanded(
                child: _buildCurrencyField(
                  label: 'D Meter Box (₹)',
                  controller: _dMeterBoxController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCurrencyField(
                  label: 'MD (NPV) (₹)',
                  controller: _mdNpvAmountController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCurrencyField(
                  label: 'Empty Oil Drum (₹)',
                  controller: _emptyOilDrumController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Remarks Row for D Meter Box, MD (NPV), Empty Oil Drum
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'D Meter Box Remark',
                  child: TextBox(
                    controller: _dMeterBoxRemarkController,
                    placeholder: 'Optional remark',
                    enabled: !_isSubmitting,
                    maxLines: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'MD (NPV) Remark',
                  child: TextBox(
                    controller: _mdNpvRemarkController,
                    placeholder: 'Optional remark',
                    enabled: !_isSubmitting,
                    maxLines: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'Empty Oil Drum Remark',
                  child: TextBox(
                    controller: _emptyOilDrumRemarkController,
                    placeholder: 'Optional remark',
                    enabled: !_isSubmitting,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAutoFormatDateField(
                  label: 'Invoice Date',
                  controller: _invoiceDateController,
                  onDateParsed: (date) {
                    setState(() {
                      _invoiceDate = date;
                      // Auto-calculate due date as invoice date + 45 days
                      if (date != null) {
                        _dueDate = date.add(const Duration(days: 45));
                        _dueDateController.text = DateFormat(
                          'dd-MM-yyyy',
                        ).format(_dueDate);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAutoFormatDateField(
                  label: 'Due Date',
                  controller: _dueDateController,
                  isRequired: true,
                  onDateParsed: (date) {
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCurrencyField(
            label: 'Amount (₹) *',
            controller: _amountController,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSection() {
    return Expander(
      header: const Text('Financial Details'),
      initiallyExpanded: true,
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCurrencyField(
                  label: 'Invoice Amount (₹)',
                  controller: _invoiceAmountController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCurrencyField(
                  label: 'Bill Pass Amount (₹)',
                  controller: _billPassAmountController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyField(
                  label: 'CSD Amount (₹)',
                  controller: _csdAmountController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAutoFormatDateField(
                  label: 'CSD Due Date',
                  controller: _csdDueDateController,
                  onDateParsed: (date) => setState(() => _csdDueDate = date),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()), // Empty space for alignment
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyField(
                  label: 'Scrap Amount (₹)',
                  controller: _scrapAmountController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCurrencyField(
                  label: 'Scrap GST (₹)',
                  controller: _scrapGstAmountController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyField(
                  label: 'MD/LD Amount (₹)',
                  controller: _mdLdAmountController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: const SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCalculatedSection() {
    return Expander(
      header: const Text('Tax Calculations'),
      initiallyExpanded: true,
      content: Column(
        children: [
          // Manual percentage inputs
          Row(
            children: [
              Expanded(
                child: _buildCurrencyField(
                  label: 'TDS Amount (I.TAX 2%)',
                  controller: _tdsAmountController,
                  showPrefix: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCurrencyField(
                  label: 'GST TDS Amount (2%)',
                  controller: _gstTdsAmountController,
                  showPrefix: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCurrencyField(
                  label: 'TCS Amount (IN TAX 1%)',
                  controller: _tcsAmountController,
                  showPrefix: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTrackingSection() {
    return Expander(
      header: const Text('Payment Tracking'),
      initiallyExpanded: false,
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Transaction Number',
                  child: TextBox(
                    controller: _transactionNoController,
                    placeholder: 'Enter transaction no.',
                    enabled: !_isSubmitting,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAutoFormatDateField(
                  label: 'Paid Date',
                  controller: _paidDateController,
                  onDateParsed: (date) => setState(() => _paidDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Consignment Name
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Consignment Name',
                  child: TextBox(
                    controller: _consignmentNameController,
                    placeholder: 'Enter consignment name',
                    enabled: !_isSubmitting,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksSection() {
    return InfoLabel(
      label: 'Remarks',
      child: TextBox(
        controller: _remarksController,
        placeholder: 'Optional remarks',
        enabled: !_isSubmitting,
        maxLines: 3,
      ),
    );
  }

  /// Helper to build an auto-formatting date field
  /// Formats: ddmmyyyy -> dd-MM-yyyy
  Widget _buildAutoFormatDateField({
    required String label,
    required TextEditingController controller,
    required void Function(DateTime?) onDateParsed,
    bool isRequired = false,
  }) {
    return InfoLabel(
      label: '$label${isRequired ? ' *' : ''} (ddmmyyyy)',
      child: TextBox(
        controller: controller,
        placeholder: 'e.g. 17012026',
        enabled: !_isSubmitting,
        maxLength: 10,
        onChanged: (value) {
          // Auto-format: 20012005 -> 20-01-2005
          final digitsOnly = value.replaceAll('-', '');
          if (digitsOnly.length <= 8) {
            String formatted = '';
            for (int i = 0; i < digitsOnly.length; i++) {
              if (i == 2 || i == 4) {
                formatted += '-';
              }
              formatted += digitsOnly[i];
            }
            // Only update if different to avoid cursor jumping
            if (formatted != value) {
              controller.text = formatted;
              controller.selection = TextSelection.collapsed(
                offset: formatted.length,
              );
            }
          }
          // Try to parse the date when complete
          if (digitsOnly.length == 8) {
            try {
              final dateFormat = DateFormat('dd-MM-yyyy');
              final parsed = dateFormat.parseStrict(controller.text);
              onDateParsed(parsed);
            } catch (_) {
              // Invalid date, set to null
              onDateParsed(null);
            }
          } else if (digitsOnly.isEmpty) {
            onDateParsed(null);
          }
        },
      ),
    );
  }

  /// Helper to build a currency text field that selects all text on focus
  /// This allows users to easily replace "0.00" values when clicking
  Widget _buildCurrencyField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    bool showPrefix = false,
  }) {
    return InfoLabel(
      label: label,
      child: TextBox(
        controller: controller,
        placeholder: '0.00',
        enabled: enabled && !_isSubmitting,
        keyboardType: TextInputType.number,
        prefix:
            showPrefix
                ? const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('₹'),
                )
                : null,
        onTap: () {
          // Select all text when tapping on the field
          // This allows users to easily replace "0.00" or any existing value
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
      ),
    );
  }
}
