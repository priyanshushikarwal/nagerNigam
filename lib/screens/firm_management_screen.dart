import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/premium_theme.dart';
import '../models/bill.dart';
import '../state/database_providers.dart';
import '../state/firm_providers.dart';

class FirmManagementScreen extends ConsumerStatefulWidget {
  const FirmManagementScreen({super.key});

  @override
  ConsumerState<FirmManagementScreen> createState() =>
      _FirmManagementScreenState();
}

class _FirmManagementScreenState extends ConsumerState<FirmManagementScreen> {
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

  Future<void> _addFirm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const FirmFormDialog(),
    );

    if (result == true) {
      // Force refresh all firm providers
      ref.invalidate(supplierFirmsProvider);
      ref.invalidate(allFirmsProvider);
      ref.invalidate(discomFirmsProvider);

      // Wait a moment for the invalidation to complete
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        _showInfoBar('Firm added successfully', InfoBarSeverity.success);
      }
    }
  }

  Future<void> _editFirm(Firm firm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => FirmFormDialog(firm: firm),
    );

    if (result == true) {
      // Force refresh all firm providers
      ref.invalidate(supplierFirmsProvider);
      ref.invalidate(allFirmsProvider);
      ref.invalidate(discomFirmsProvider);

      // Wait a moment for the invalidation to complete
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        _showInfoBar('Firm updated successfully', InfoBarSeverity.success);
      }
    }
  }

  Future<void> _deleteFirm(Firm firm) async {
    if (firm.id == null) return;

    // Check if firm has data
    final firmsDao = ref.read(firmsDaoProvider);
    final hasData = await firmsDao.firmHasData(firm.id!);

    if (hasData) {
      _showInfoBar(
        'Cannot delete firm with existing tenders/bills. Please delete all related data first.',
        InfoBarSeverity.warning,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Delete Firm'),
            content: Text(
              'Are you sure you want to delete "${firm.name}"?\n\nThis action cannot be undone.',
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
      await firmsDao.deleteFirm(firm.id!);

      // Force refresh all firm providers
      ref.invalidate(supplierFirmsProvider);
      ref.invalidate(allFirmsProvider);
      ref.invalidate(discomFirmsProvider);

      // Wait a moment for the invalidation to complete
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        _showInfoBar('Firm deleted successfully', InfoBarSeverity.success);
      }
    } catch (e) {
      if (mounted) {
        _showInfoBar('Failed to delete firm: $e', InfoBarSeverity.error);
      }
    }
  }

  Widget _buildFirmCard(Firm firm) {
    return Container(
      margin: const EdgeInsets.only(bottom: PremiumTheme.spacingM),
      padding: const EdgeInsets.all(PremiumTheme.spacingM),
      decoration: BoxDecoration(
        color: PremiumTheme.pureWhite,
        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
        border: Border.all(color: PremiumTheme.borderColor),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firm.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PremiumTheme.spacingXS),
                Text(
                  'Code: ${firm.code}',
                  style: const TextStyle(
                    color: PremiumTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (firm.description != null && firm.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: PremiumTheme.spacingXS),
                    child: Text(
                      firm.description!,
                      style: const TextStyle(
                        color: PremiumTheme.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (firm.address != null && firm.address!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: PremiumTheme.spacingXS),
                    child: Row(
                      children: [
                        const Icon(
                          FluentIcons.location,
                          size: 12,
                          color: PremiumTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            firm.address!,
                            style: const TextStyle(
                              color: PremiumTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (firm.contactNo != null && firm.contactNo!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: PremiumTheme.spacingXS),
                    child: Row(
                      children: [
                        const Icon(
                          FluentIcons.phone,
                          size: 12,
                          color: PremiumTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          firm.contactNo!,
                          style: const TextStyle(
                            color: PremiumTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (firm.gstNo != null && firm.gstNo!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: PremiumTheme.spacingXS),
                    child: Text(
                      'GST: ${firm.gstNo}',
                      style: const TextStyle(
                        color: PremiumTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: PremiumTheme.spacingM),
          IconButton(
            icon: const Icon(FluentIcons.edit, size: 16),
            onPressed: () => _editFirm(firm),
          ),
          const SizedBox(width: PremiumTheme.spacingS),
          IconButton(
            icon: const Icon(FluentIcons.delete, size: 16),
            onPressed: () => _deleteFirm(firm),
            style: ButtonStyle(
              backgroundColor: ButtonState.resolveWith((states) {
                if (states.isHovering) {
                  return Colors.red.withOpacity(0.1);
                }
                return Colors.transparent;
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firmsAsync = ref.watch(supplierFirmsProvider);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spacingL),
            decoration: const BoxDecoration(
              color: PremiumTheme.pureWhite,
              border: Border(
                bottom: BorderSide(color: PremiumTheme.borderColor, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Supplier Firm Management',
                  style: FluentTheme.of(context).typography.title,
                ),
                FilledButton(
                  onPressed: _addFirm,
                  child: const Text('Add Supplier Firm'),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: firmsAsync.when(
              data: (firms) {
                if (firms.isEmpty) {
                  return const Center(
                    child: Text(
                      'No supplier firms found. Add one to get started.',
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(PremiumTheme.spacingL),
                  children: firms.map(_buildFirmCard).toList(),
                );
              },
              loading: () => const Center(child: ProgressRing()),
              error:
                  (error, _) => Center(
                    child: InfoBar(
                      title: const Text('Error loading firms'),
                      content: Text('$error'),
                      severity: InfoBarSeverity.error,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class FirmFormDialog extends ConsumerStatefulWidget {
  final Firm? firm;

  const FirmFormDialog({super.key, this.firm});

  @override
  ConsumerState<FirmFormDialog> createState() => _FirmFormDialogState();
}

class _FirmFormDialogState extends ConsumerState<FirmFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _contactNoController;
  late TextEditingController _gstNoController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.firm?.name ?? '');
    _codeController = TextEditingController(text: widget.firm?.code ?? '');
    _descriptionController = TextEditingController(
      text: widget.firm?.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.firm?.address ?? '',
    );
    _contactNoController = TextEditingController(
      text: widget.firm?.contactNo ?? '',
    );
    _gstNoController = TextEditingController(text: widget.firm?.gstNo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactNoController.dispose();
    _gstNoController.dispose();
    super.dispose();
  }

  Future<void> _saveFirm() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    print('Starting to save firm...');
    setState(() => _isSaving = true);

    try {
      final firmsDao = ref.read(firmsDaoProvider);
      final name = _nameController.text.trim();
      final code = _codeController.text.trim();

      print('Firm name: $name, code: $code');

      // Check for duplicate name or code
      final allFirms = await firmsDao.getAllFirms();

      if (widget.firm == null) {
        // Adding new firm - check for duplicates
        final duplicateName = allFirms.any(
          (f) => f.name.toLowerCase() == name.toLowerCase(),
        );
        final duplicateCode = allFirms.any(
          (f) => f.code.toLowerCase() == code.toLowerCase(),
        );

        if (duplicateName) {
          throw Exception(
            'A firm with this name already exists. Please use a different name.',
          );
        }
        if (duplicateCode) {
          throw Exception(
            'A firm with this code already exists. Please use a different code.',
          );
        }
      } else {
        // Editing existing firm - check for duplicates excluding current firm
        final duplicateName = allFirms.any(
          (f) =>
              f.id != widget.firm!.id &&
              f.name.toLowerCase() == name.toLowerCase(),
        );
        final duplicateCode = allFirms.any(
          (f) =>
              f.id != widget.firm!.id &&
              f.code.toLowerCase() == code.toLowerCase(),
        );

        if (duplicateName) {
          throw Exception(
            'Another firm with this name already exists. Please use a different name.',
          );
        }
        if (duplicateCode) {
          throw Exception(
            'Another firm with this code already exists. Please use a different code.',
          );
        }
      }

      if (widget.firm != null && widget.firm!.id != null) {
        // Update existing firm
        final updated = await firmsDao.updateFirm(
          id: widget.firm!.id!,
          name: name,
          code: code,
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          address:
              _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
          contactNo:
              _contactNoController.text.trim().isEmpty
                  ? null
                  : _contactNoController.text.trim(),
          gstNo:
              _gstNoController.text.trim().isEmpty
                  ? null
                  : _gstNoController.text.trim(),
        );

        if (!updated) {
          throw Exception('Failed to update firm. Please try again.');
        }
      } else {
        // Insert new firm
        print('Inserting new firm...');
        final id = await firmsDao.insertFirm(
          name: name,
          code: code,
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          address:
              _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
          contactNo:
              _contactNoController.text.trim().isEmpty
                  ? null
                  : _contactNoController.text.trim(),
          gstNo:
              _gstNoController.text.trim().isEmpty
                  ? null
                  : _gstNoController.text.trim(),
        );

        print('Firm inserted with ID: $id');

        if (id <= 0) {
          throw Exception('Failed to add firm. Please try again.');
        }
      }

      print('Firm saved successfully, closing dialog');
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      print('Error saving firm: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() => _isSaving = false);

        // Extract user-friendly error message
        String errorMessage = e.toString();
        if (errorMessage.contains('UNIQUE constraint failed')) {
          errorMessage =
              'A firm with this name or code already exists. Please use different values.';
        } else if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(
            11,
          ); // Remove "Exception: " prefix
        }

        await showDialog(
          context: context,
          builder:
              (ctx) => ContentDialog(
                title: const Text('Cannot Save Firm'),
                content: Text(errorMessage),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.firm != null ? 'Edit Firm' : 'Add Firm'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoLabel(
                label: 'Firm Name *',
                child: TextFormBox(
                  controller: _nameController,
                  placeholder: 'Enter firm name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Firm name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: PremiumTheme.spacingM),
              InfoLabel(
                label: 'Firm Code *',
                child: TextFormBox(
                  controller: _codeController,
                  placeholder: 'Enter firm code (e.g., DIPP)',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Firm code is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: PremiumTheme.spacingM),
              InfoLabel(
                label: 'Description',
                child: TextFormBox(
                  controller: _descriptionController,
                  placeholder: 'Enter description (optional)',
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: PremiumTheme.spacingM),
              InfoLabel(
                label: 'Address',
                child: TextFormBox(
                  controller: _addressController,
                  placeholder: 'Enter address (optional)',
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: PremiumTheme.spacingM),
              InfoLabel(
                label: 'Contact Number',
                child: TextFormBox(
                  controller: _contactNoController,
                  placeholder: 'Enter contact number (optional)',
                ),
              ),
              const SizedBox(height: PremiumTheme.spacingM),
              InfoLabel(
                label: 'GST Number',
                child: TextFormBox(
                  controller: _gstNoController,
                  placeholder: 'Enter GST number (optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveFirm,
          child:
              _isSaving
                  ? const SizedBox(width: 16, height: 16, child: ProgressRing())
                  : const Text('Save'),
        ),
      ],
    );
  }
}
