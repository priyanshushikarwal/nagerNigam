import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/premium_theme.dart';
import '../state/database_providers.dart';
import '../state/tender_providers.dart';

class AddTnDialog extends ConsumerStatefulWidget {
  final int firmId;

  const AddTnDialog({super.key, required this.firmId});

  @override
  ConsumerState<AddTnDialog> createState() => _AddTnDialogState();
}

class _AddTnDialogState extends ConsumerState<AddTnDialog> {
  final _tnNumberController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tnNumberController.dispose();
    _poNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final tnNumber = _tnNumberController.text.trim();
    final poNumber =
        _poNumberController.text.trim().isEmpty
            ? null
            : _poNumberController.text.trim();
    final description =
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim();

    if (tnNumber.isEmpty) {
      _showInfoBar('TN Number is required', InfoBarSeverity.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    final repository = ref.read(tnDaoProvider);
    try {
      final exists = await repository.tnNumberExists(widget.firmId, tnNumber);
      if (exists) {
        setState(() => _isSubmitting = false);
        _showInfoBar(
          'TN Number already exists for this DISCOM',
          InfoBarSeverity.warning,
        );
        return;
      }

      await repository.createTender(
        firmId: widget.firmId,
        tnNumber: tnNumber,
        purchaseOrderNo: poNumber,
        workDescription: description,
      );

      ref.invalidate(firmTendersProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      setState(() => _isSubmitting = false);
      _showInfoBar('Failed to create TN: $error', InfoBarSeverity.error);
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

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 540),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Add New TN', style: typography.title),
          IconButton(
            icon: const Icon(FluentIcons.chrome_close, size: 16),
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          InfoLabel(
            label: 'Purchase Order Number',
            child: TextBox(
              controller: _poNumberController,
              placeholder: 'Enter PO number',
              enabled: !_isSubmitting,
            ),
          ),
          const SizedBox(height: PremiumTheme.spacingM),
          InfoLabel(
            label: 'Work Description',
            child: TextBox(
              controller: _descriptionController,
              placeholder: 'Enter work description',
              maxLines: 3,
              enabled: !_isSubmitting,
            ),
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child:
              _isSubmitting
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: ProgressRing(strokeWidth: 2),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}
