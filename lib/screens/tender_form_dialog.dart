import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/premium_theme.dart';
import '../models/tender.dart';
import '../state/database_providers.dart';
import '../state/tender_providers.dart';

class TenderFormDialog extends ConsumerStatefulWidget {
  final int firmId;
  final Tender? tender; // For editing

  const TenderFormDialog({super.key, required this.firmId, this.tender});

  @override
  ConsumerState<TenderFormDialog> createState() => _TenderFormDialogState();
}

class _TenderFormDialogState extends ConsumerState<TenderFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tnNumberController;
  late TextEditingController _poNumberController;
  late TextEditingController _workDescriptionController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tnNumberController = TextEditingController(
      text: widget.tender?.tnNumber ?? '',
    );
    _poNumberController = TextEditingController(
      text: widget.tender?.poNumber ?? '',
    );
    _workDescriptionController = TextEditingController(
      text: widget.tender?.workDescription ?? '',
    );
  }

  @override
  void dispose() {
    _tnNumberController.dispose();
    _poNumberController.dispose();
    _workDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (_tnNumberController.text.trim().isEmpty) {
      _showValidationError('TN Number is required');
      return;
    }

    final dao = ref.read(tnDaoProvider);

    // Check if TN number already exists
    final exists = await dao.tnNumberExists(
      widget.firmId,
      _tnNumberController.text.trim(),
      excludeId: widget.tender?.id,
    );

    if (exists) {
      _showValidationError('TN Number already exists for this DISCOM');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tnNumber = _tnNumberController.text.trim();
      final poNumber =
          _poNumberController.text.trim().isEmpty
              ? null
              : _poNumberController.text.trim();
      final workDescription =
          _workDescriptionController.text.trim().isEmpty
              ? null
              : _workDescriptionController.text.trim();

      if (widget.tender == null) {
        await dao.createTender(
          firmId: widget.firmId,
          tnNumber: tnNumber,
          purchaseOrderNo: poNumber,
          workDescription: workDescription,
        );
      } else {
        final updatedTender = widget.tender!.copyWith(
          tnNumber: tnNumber,
          poNumber: poNumber,
          workDescription: workDescription,
          updatedAt: DateTime.now(),
        );
        await dao.updateTender(updatedTender);
      }

      ref.invalidate(tendersByFirmProvider);

      if (mounted) {
        Navigator.pop(context, true);
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Success'),
                content: Text(
                  widget.tender == null
                      ? 'TN created successfully'
                      : 'TN updated successfully',
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
                content: Text('Failed to save TN: $e'),
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
    final typography = FluentTheme.of(context).typography;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.tender == null ? 'Add New TN' : 'Edit TN',
            style: typography.title,
          ),
          IconButton(
            icon: const Icon(FluentIcons.chrome_close, size: 16),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TN Number
            InfoLabel(
              label: 'TN Number *',
              child: TextBox(
                controller: _tnNumberController,
                placeholder: 'Enter TN number (e.g., 1634)',
                enabled: !_isSubmitting,
                autofocus: true,
              ),
            ),
            const SizedBox(height: PremiumTheme.spacingM),

            // Purchase Order Number
            InfoLabel(
              label: 'Purchase Order Number',
              child: TextBox(
                controller: _poNumberController,
                placeholder: 'Enter PO number (e.g., PO/45/2024-25)',
                enabled: !_isSubmitting,
              ),
            ),
            const SizedBox(height: PremiumTheme.spacingM),

            // Work Description
            InfoLabel(
              label: 'Work Description',
              child: TextBox(
                controller: _workDescriptionController,
                placeholder: 'Enter work description',
                enabled: !_isSubmitting,
                maxLines: 4,
              ),
            ),
          ],
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
                  : Text(widget.tender == null ? 'Create TN' : 'Update TN'),
        ),
      ],
    );
  }
}
