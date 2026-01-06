import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bill.dart';
import '../models/tender.dart';
import '../state/client_firm_providers.dart';
import '../state/database_providers.dart';
import '../state/firm_providers.dart';
import '../state/tender_providers.dart';
import 'tender_form_dialog.dart';

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
    _amountController = TextEditingController(
      text: widget.bill?.amount.toStringAsFixed(2) ?? '',
    );
    _invoiceAmountController = TextEditingController(
      text: widget.bill?.invoiceAmount.toStringAsFixed(2) ?? '0.00',
    );
    _billPassAmountController = TextEditingController(
      text: widget.bill?.billPassAmount.toStringAsFixed(2) ?? '0.00',
    );
    _csdAmountController = TextEditingController(
      text: widget.bill?.csdAmount.toStringAsFixed(2) ?? '0.00',
    );
    _scrapAmountController = TextEditingController(
      text: widget.bill?.scrapAmount.toStringAsFixed(2) ?? '0.00',
    );
    _scrapGstAmountController = TextEditingController(
      text: widget.bill?.scrapGstAmount.toStringAsFixed(2) ?? '0.00',
    );
    _mdLdAmountController = TextEditingController(
      text: widget.bill?.mdLdAmount.toStringAsFixed(2) ?? '0.00',
    );

    _remarksController = TextEditingController(
      text: widget.bill?.remarks ?? '',
    );
    // Manual amount controllers
    _tdsAmountController = TextEditingController(
      text: widget.bill?.tdsAmount.toStringAsFixed(2) ?? '0.00',
    );
    _tcsAmountController = TextEditingController(
      text: widget.bill?.tcsAmount.toStringAsFixed(2) ?? '0.00',
    );
    _gstTdsAmountController = TextEditingController(
      text: widget.bill?.gstTdsAmount.toStringAsFixed(2) ?? '0.00',
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

    if (widget.bill != null) {
      _billDate = widget.bill!.billDate;
      _dueDate = widget.bill!.dueDate;
      _csdReleasedDate = widget.bill!.csdReleasedDate;
      _csdDueDate = widget.bill!.csdDueDate;
      _paidDate = widget.bill!.paidDate;
      _dueReleaseDate = widget.bill!.dueReleaseDate;
      _invoiceDate = widget.bill!.invoiceDate;
      _workOrderDate = widget.bill!.workOrderDate;
      _proofPath = widget.bill!.proofPath;
      _invoiceType = widget.bill!.invoiceType;
    } else {
      // For new bills, set default due date to 45 days from today
      final today = DateTime.now();
      _invoiceDate = today;
      _dueDate = today.add(const Duration(days: 45));
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
    super.dispose();
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
        csdStatus: _csdReleasedDate != null ? 'Released' : 'Pending',
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
                child: InfoLabel(
                  label: 'Bill Date *',
                  child: DatePicker(
                    selected: _billDate,
                    onChanged: (date) => setState(() => _billDate = date),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'Work Order Date',
                  child: DatePicker(
                    selected: _workOrderDate,
                    onChanged: (date) => setState(() => _workOrderDate = date),
                  ),
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
                    onChanged: (value) {
                      setState(() {
                        _invoiceType = value;
                      });
                    },
                    placeholder: const Text('Select invoice type'),
                  ),
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
                child: InfoLabel(
                  label: 'Invoice Date',
                  child: DatePicker(
                    selected: _invoiceDate,
                    onChanged: (date) {
                      setState(() {
                        _invoiceDate = date;
                        // Auto-calculate due date as invoice date + 45 days
                        _dueDate = date.add(const Duration(days: 45));
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'Due Date *',
                  child: DatePicker(
                    selected: _dueDate,
                    onChanged: (date) => setState(() => _dueDate = date),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoLabel(
            label: 'Amount (₹) *',
            child: TextBox(
              controller: _amountController,
              placeholder: '0.00',
              enabled: !_isSubmitting,
              keyboardType: TextInputType.number,
            ),
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
                child: InfoLabel(
                  label: 'Invoice Amount (₹)',
                  child: TextBox(
                    controller: _invoiceAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'Bill Pass Amount (₹)',
                  child: TextBox(
                    controller: _billPassAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'CSD Amount (₹)',
                  child: TextBox(
                    controller: _csdAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'CSD Due Date',
                  child: DatePicker(
                    selected: _csdDueDate,
                    onChanged: (date) => setState(() => _csdDueDate = date),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'CSD Released Date',
                  child: DatePicker(
                    selected: _csdReleasedDate,
                    onChanged:
                        (date) => setState(() => _csdReleasedDate = date),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Scrap Amount (₹)',
                  child: TextBox(
                    controller: _scrapAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'Scrap GST (₹)',
                  child: TextBox(
                    controller: _scrapGstAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'MD/LD Amount (₹)',
                  child: TextBox(
                    controller: _mdLdAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                  ),
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
                child: InfoLabel(
                  label: 'TDS Amount (I.TAX 2%)',
                  child: TextBox(
                    controller: _tdsAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('₹'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'GST TDS Amount (2%)',
                  child: TextBox(
                    controller: _gstTdsAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('₹'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoLabel(
                  label: 'TCS Amount (IN TAX 1%)',
                  child: TextBox(
                    controller: _tcsAmountController,
                    placeholder: '0.00',
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.number,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('₹'),
                    ),
                  ),
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
                child: InfoLabel(
                  label: 'Paid Date',
                  child: DatePicker(
                    selected: _paidDate,
                    onChanged: (date) => setState(() => _paidDate = date),
                  ),
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
}
