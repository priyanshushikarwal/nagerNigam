import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../core/premium_theme.dart';
import '../models/bill.dart';
import '../services/sync_service.dart';
import '../state/database_providers.dart';

class ComprehensivePaymentFormDialog extends ConsumerStatefulWidget {
  final int billId;
  final String tnNumber;
  final double billAmount;
  final Payment? payment; // For editing existing payment
  final double? initialAmount; // Pre-fill amount (for CSD/MD payments)
  final String? initialRemarks; // Pre-fill remarks (for CSD/MD payments)

  const ComprehensivePaymentFormDialog({
    super.key,
    required this.billId,
    required this.tnNumber,
    required this.billAmount,
    this.payment,
    this.initialAmount,
    this.initialRemarks,
  });

  @override
  @override
  ConsumerState<ComprehensivePaymentFormDialog> createState() =>
      _ComprehensivePaymentFormDialogState();
}

class _ComprehensivePaymentFormDialogState
    extends ConsumerState<ComprehensivePaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _amountPaidController;
  late TextEditingController _transactionNoController;
  late TextEditingController _invoiceNoController;
  late TextEditingController _workOrderNoController;
  late TextEditingController _consignmentNameController;
  late TextEditingController _remarksController;

  // Dates
  DateTime _paymentDate = DateTime.now();
  DateTime? _paidDate;
  DateTime? _dueReleaseDate;
  DateTime? _invoiceDate;
  DateTime? _workOrderDate;

  String? _existingProofPath;
  String? _proofSourcePath;
  bool _isSaving = false;

  // Invoice dropdown state
  Bill? _selectedBillForAutoFill;
  List<Bill> _availableBills = [];
  bool _isLoadingBills = true;

  // Payment summary for selected bill
  double _netPayable = 0.0;
  double _totalPaid = 0.0;
  double _dueAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadAvailableBills();
  }

  /// Load all bills for the current tender to populate dropdown
  Future<void> _loadAvailableBills() async {
    try {
      // Get the current bill to find its tender
      final billsDao = ref.read(billsDaoProvider);
      final currentBill = await billsDao.getBillById(widget.billId);

      if (currentBill != null) {
        // Set the payment summary for the current bill
        setState(() {
          _netPayable = currentBill.netPayable;
          _totalPaid = currentBill.totalPaid;
          _dueAmount = currentBill.dueAmount;
        });

        if (currentBill.tenderId != null) {
          // Fetch all bills for this tender
          final bills = await billsDao.getBillsByTender(currentBill.tenderId!);

          // Filter bills that have invoice numbers
          setState(() {
            _availableBills =
                bills
                    .where(
                      (b) => b.invoiceNo != null && b.invoiceNo!.isNotEmpty,
                    )
                    .toList();
            _isLoadingBills = false;
          });
        } else {
          setState(() {
            _isLoadingBills = false;
          });
        }
      } else {
        setState(() {
          _isLoadingBills = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingBills = false;
      });
    }
  }

  /// Auto-fill form fields when a bill is selected from dropdown
  void _onBillSelected(Bill? bill) {
    if (bill == null) return;

    setState(() {
      _selectedBillForAutoFill = bill;

      // Calculate payment summary
      _netPayable = bill.netPayable;
      _totalPaid = bill.totalPaid;
      _dueAmount = bill.dueAmount;

      // Auto-fill Work Order Number
      if (bill.workOrderNo != null && bill.workOrderNo!.isNotEmpty) {
        _workOrderNoController.text = bill.workOrderNo!;
      }

      // Auto-fill Consignment Name
      if (bill.consignmentName != null && bill.consignmentName!.isNotEmpty) {
        _consignmentNameController.text = bill.consignmentName!;
      }

      // Auto-fill Invoice Number
      if (bill.invoiceNo != null && bill.invoiceNo!.isNotEmpty) {
        _invoiceNoController.text = bill.invoiceNo!;
      }
    });
  }

  void _initializeControllers() {
    if (widget.payment != null) {
      // Editing mode
      final p = widget.payment!;
      _amountPaidController = TextEditingController(
        text: p.amountPaid.toStringAsFixed(2),
      );
      _transactionNoController = TextEditingController(
        text: p.transactionNo ?? '',
      );
      _invoiceNoController = TextEditingController(text: p.invoiceNo ?? '');
      _workOrderNoController = TextEditingController(text: p.workOrderNo ?? '');
      _consignmentNameController = TextEditingController(
        text: p.consignmentName ?? '',
      );
      _remarksController = TextEditingController(text: p.remarks ?? '');

      _paymentDate = p.paymentDate;
      _paidDate = p.paidDate;
      _dueReleaseDate = p.dueReleaseDate;
      _invoiceDate = p.invoiceDate;
      _workOrderDate = p.workOrderDate;
      _existingProofPath = p.proofPath;
      _proofSourcePath = null;
    } else {
      // New payment mode - optionally pre-fill from initialAmount/initialRemarks
      _amountPaidController = TextEditingController(
        text:
            widget.initialAmount != null
                ? widget.initialAmount!.toStringAsFixed(2)
                : '',
      );
      _transactionNoController = TextEditingController();
      _invoiceNoController = TextEditingController();
      _workOrderNoController = TextEditingController();
      _consignmentNameController = TextEditingController();
      _remarksController = TextEditingController(
        text: widget.initialRemarks ?? '',
      );
      _existingProofPath = null;
      _proofSourcePath = null;
    }
  }

  Future<void> _pickProofFile() async {
    if (_isSaving) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    if (file.path == null) {
      await _showError('Selected file could not be accessed on disk.');
      return;
    }

    setState(() {
      _proofSourcePath = file.path;
    });
  }

  void _clearSelectedProof() {
    if (_isSaving) return;
    setState(() {
      _proofSourcePath = null;
    });
  }

  String _buildProofStatusText() {
    if (_proofSourcePath != null) {
      return 'Selected: ${p.basename(_proofSourcePath!)} (will upload on save)';
    }

    if (_existingProofPath != null && _existingProofPath!.isNotEmpty) {
      return 'Current file: ${p.basename(_existingProofPath!)}';
    }

    return 'No proof file attached yet.';
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _transactionNoController.dispose();
    _invoiceNoController.dispose();
    _workOrderNoController.dispose();
    _consignmentNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    final rawAmount = _amountPaidController.text.trim();
    if (rawAmount.isEmpty) {
      await _showError('Please enter the amount paid.');
      return;
    }

    final parsedAmount = double.tryParse(rawAmount);
    if (parsedAmount == null) {
      await _showError('Amount paid must be a valid number.');
      return;
    }

    if (parsedAmount <= 0) {
      await _showError('Amount paid must be greater than zero.');
      return;
    }

    // Validate payment amount doesn't exceed due amount (for selected bill)
    if (_selectedBillForAutoFill != null && widget.payment == null) {
      // Only validate for new payments, not edits
      if (parsedAmount > _dueAmount) {
        await _showError(
          'Payment amount (₹${parsedAmount.toStringAsFixed(2)}) cannot exceed due amount (₹${_dueAmount.toStringAsFixed(2)}).',
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final payment = Payment(
        id: widget.payment?.id,
        billId: widget.billId,
        paymentDate: _paymentDate,
        amountPaid: parsedAmount,
        proofPath: _existingProofPath,
        remarks:
            _remarksController.text.isEmpty ? null : _remarksController.text,
        lastEdited: DateTime.now(),
        createdAt: widget.payment?.createdAt ?? DateTime.now(),
        // New tracking fields
        paidDate: _paidDate,
        transactionNo:
            _transactionNoController.text.isEmpty
                ? null
                : _transactionNoController.text,
        dueReleaseDate: _dueReleaseDate,
        invoiceNo:
            _invoiceNoController.text.isEmpty
                ? null
                : _invoiceNoController.text,
        invoiceDate: _invoiceDate,
        workOrderNo:
            _workOrderNoController.text.isEmpty
                ? null
                : _workOrderNoController.text,
        workOrderDate: _workOrderDate,
        consignmentName:
            _consignmentNameController.text.isEmpty
                ? null
                : _consignmentNameController.text,
      );

      final paymentsDao = ref.read(paymentsDaoProvider);
      int? savedPaymentId;

      if (widget.payment == null) {
        // Create new payment (auto-updates bill status to "Paid")
        savedPaymentId = await paymentsDao.addPayment(
          payment: payment,
          proofSourcePath: _proofSourcePath,
        );
      } else {
        // Update existing payment
        await paymentsDao.updatePayment(
          payment: payment,
          proofSourcePath: _proofSourcePath,
        );
        savedPaymentId = widget.payment!.id;
      }

      if (savedPaymentId != null) {
        final savedPayment = await paymentsDao.getPaymentById(savedPaymentId);
        if (savedPayment != null) {
          await ref.read(syncServiceProvider.notifier).pushPayment(savedPayment);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (context) => ContentDialog(
                title: const Text('Error'),
                content: Text('Failed to save payment: ${e.toString()}'),
                actions: [
                  Button(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;
    final lastEditedFormat = DateFormat('dd MMM yyyy, h:mm a');
    final String? lastEditedLabel =
        widget.payment != null
            ? 'Last edited ${lastEditedFormat.format(widget.payment!.lastEdited.toLocal())}'
            : null;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 750),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.payment == null ? 'New Payment Entry' : 'Edit Payment',
                style: typography.title,
              ),
              if (lastEditedLabel != null) ...[
                const SizedBox(height: 2),
                Text(lastEditedLabel, style: typography.caption),
              ],
            ],
          ),
          IconButton(
            icon: const Icon(FluentIcons.chrome_close, size: 16),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bill Info Header
              Container(
                padding: const EdgeInsets.all(PremiumTheme.spacingM),
                decoration: PremiumTheme.infoCardDecoration(
                  PremiumTheme.infoBlue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill TN: ${widget.tnNumber}',
                          style: typography.body!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bill Amount: ₹${widget.billAmount.toStringAsFixed(2)}',
                          style: typography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: PremiumTheme.spacingM),

              // Payment Summary
              if (!_isLoadingBills)
                Container(
                  padding: const EdgeInsets.all(PremiumTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Summary',
                        style: typography.body!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: PremiumTheme.spacingS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Net Payable:', style: typography.caption),
                              const SizedBox(height: 2),
                              Text(
                                '₹${_netPayable.toStringAsFixed(2)}',
                                style: typography.body!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Paid:', style: typography.caption),
                              const SizedBox(height: 2),
                              Text(
                                '₹${_totalPaid.toStringAsFixed(2)}',
                                style: typography.body!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Due Amount:', style: typography.caption),
                              const SizedBox(height: 2),
                              Text(
                                '₹${_dueAmount.toStringAsFixed(2)}',
                                style: typography.body!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: PremiumTheme.spacingL),

              // Basic Payment Info
              Expander(
                initiallyExpanded: true,
                header: Text(
                  'Basic Payment Information',
                  style: typography.body!.copyWith(fontWeight: FontWeight.w600),
                ),
                content: Padding(
                  padding: const EdgeInsets.all(PremiumTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Date *',
                                  style: typography.caption,
                                ),
                                const SizedBox(height: 6),
                                DatePicker(
                                  selected: _paymentDate,
                                  onChanged: (date) {
                                    setState(() => _paymentDate = date);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: PremiumTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount Paid *',
                                  style: typography.caption,
                                ),
                                const SizedBox(height: 6),
                                TextBox(
                                  controller: _amountPaidController,
                                  placeholder: 'Enter amount',
                                  keyboardType: TextInputType.number,
                                  prefix: const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Text('₹'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: PremiumTheme.spacingM),

                      // Paid Date & Transaction Number
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Paid Date', style: typography.caption),
                                const SizedBox(height: 6),
                                DatePicker(
                                  selected: _paidDate,
                                  onChanged: (date) {
                                    setState(() => _paidDate = date);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: PremiumTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction Number',
                                  style: typography.caption,
                                ),
                                const SizedBox(height: 6),
                                TextBox(
                                  controller: _transactionNoController,
                                  placeholder: 'Enter transaction no.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: PremiumTheme.spacingM),

              // Invoice Details
              Expander(
                initiallyExpanded: true,
                header: Text(
                  'Invoice Details',
                  style: typography.body!.copyWith(fontWeight: FontWeight.w600),
                ),
                content: Padding(
                  padding: const EdgeInsets.all(PremiumTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invoice Number',
                                  style: typography.caption,
                                ),
                                const SizedBox(height: 6),
                                if (_isLoadingBills)
                                  const SizedBox(
                                    height: 32,
                                    child: Center(
                                      child: ProgressRing(strokeWidth: 2),
                                    ),
                                  )
                                else if (_availableBills.isEmpty)
                                  TextBox(
                                    controller: _invoiceNoController,
                                    placeholder: 'Enter invoice no.',
                                  )
                                else
                                  ComboBox<Bill>(
                                    placeholder: const Text(
                                      'Select or type invoice no.',
                                    ),
                                    isExpanded: true,
                                    value: _selectedBillForAutoFill,
                                    items:
                                        _availableBills.map((bill) {
                                          return ComboBoxItem<Bill>(
                                            value: bill,
                                            child: Text(
                                              bill.invoiceNo ?? 'N/A',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (Bill? selectedBill) {
                                      _onBillSelected(selectedBill);
                                      if (selectedBill != null) {
                                        _invoiceNoController.text =
                                            selectedBill.invoiceNo ?? '';
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: PremiumTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invoice Date', style: typography.caption),
                                const SizedBox(height: 6),
                                DatePicker(
                                  selected: _invoiceDate,
                                  onChanged: (date) {
                                    setState(() => _invoiceDate = date);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: PremiumTheme.spacingM),

              // Work Order Details
              Expander(
                initiallyExpanded: true,
                header: Text(
                  'Work Order Details',
                  style: typography.body!.copyWith(fontWeight: FontWeight.w600),
                ),
                content: Padding(
                  padding: const EdgeInsets.all(PremiumTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Work Order Number',
                                  style: typography.caption,
                                ),
                                const SizedBox(height: 6),
                                TextBox(
                                  controller: _workOrderNoController,
                                  placeholder: 'Enter work order no.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: PremiumTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Work Order Date',
                                  style: typography.caption,
                                ),
                                const SizedBox(height: 6),
                                DatePicker(
                                  selected: _workOrderDate,
                                  onChanged: (date) {
                                    setState(() => _workOrderDate = date);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: PremiumTheme.spacingM),

              // Consignment & Additional Info
              Expander(
                initiallyExpanded: true,
                header: Text(
                  'Consignment & Additional Info',
                  style: typography.body!.copyWith(fontWeight: FontWeight.w600),
                ),
                content: Padding(
                  padding: const EdgeInsets.all(PremiumTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Consignment Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Consignment Name', style: typography.caption),
                          const SizedBox(height: 6),
                          TextBox(
                            controller: _consignmentNameController,
                            placeholder: 'Enter consignment name',
                          ),
                        ],
                      ),

                      const SizedBox(height: PremiumTheme.spacingM),

                      // Remarks
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Remarks', style: typography.caption),
                          const SizedBox(height: 6),
                          TextBox(
                            controller: _remarksController,
                            placeholder: 'Enter any additional notes',
                            maxLines: 3,
                          ),
                        ],
                      ),

                      const SizedBox(height: PremiumTheme.spacingM),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Proof of payment', style: typography.caption),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Button(
                                onPressed: _isSaving ? null : _pickProofFile,
                                child: const Text('Upload proof'),
                              ),
                              const SizedBox(width: PremiumTheme.spacingS),
                              Expanded(
                                child: Text(
                                  _buildProofStatusText(),
                                  style: typography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_proofSourcePath != null)
                                IconButton(
                                  icon: const Icon(FluentIcons.cancel),
                                  onPressed:
                                      _isSaving ? null : _clearSelectedProof,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _savePayment,
          child:
              _isSaving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: ProgressRing(strokeWidth: 2),
                  )
                  : Text(
                    widget.payment == null
                        ? 'Create Payment'
                        : 'Update Payment',
                  ),
        ),
      ],
    );
  }

  Future<void> _showError(String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Validation'),
            content: Text(message),
            actions: [
              Button(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}
