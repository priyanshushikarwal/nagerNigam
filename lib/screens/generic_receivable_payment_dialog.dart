import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/premium_theme.dart';
import '../models/bill.dart';
import '../state/database_providers.dart';

/// A generic dialog for recording receivable payments (e.g., D.Meter Box, MD(NPV), Empty Oil Drum).
/// - Amount is read-only and passed in.
/// - User only selects the date when payment was received.
/// - On save: creates a payment record and calls the onSuccess callback.
class GenericReceivablePaymentDialog extends ConsumerStatefulWidget {
  final Bill bill;
  final String title;
  final double amount;
  final String remarks;
  final Future<void> Function(DateTime date) onSuccess;

  const GenericReceivablePaymentDialog({
    super.key,
    required this.bill,
    required this.title,
    required this.amount,
    required this.remarks,
    required this.onSuccess,
  });

  @override
  ConsumerState<GenericReceivablePaymentDialog> createState() =>
      _GenericReceivablePaymentDialogState();
}

class _GenericReceivablePaymentDialogState
    extends ConsumerState<GenericReceivablePaymentDialog> {
  DateTime _receivedDate = DateTime.now();
  bool _isSaving = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  Future<void> _savePayment() async {
    setState(() => _isSaving = true);

    try {
      final bill = widget.bill;
      final paymentsDao = ref.read(paymentsDaoProvider);

      // 1. Create the payment record
      final payment = Payment(
        billId: bill.id!,
        paymentDate: _receivedDate,
        amountPaid: widget.amount,
        remarks: widget.remarks,
        createdAt: DateTime.now(),
        lastEdited: DateTime.now(),
      );

      await paymentsDao.addPayment(payment: payment);

      // 2. Call success callback (updates specific status/date)
      await widget.onSuccess(_receivedDate);

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (context) => ContentDialog(
                title: const Text('Error'),
                content: Text('Failed to save payment: $e'),
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
    final bill = widget.bill;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 450, maxHeight: 500),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: typography.title),
              const SizedBox(height: 4),
              Text(
                'Bill: ${bill.billNo ?? bill.tnNumber}',
                style: typography.caption,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(FluentIcons.chrome_close, size: 16),
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(PremiumTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(FluentIcons.info, size: 16, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recording payment will:\n• Mark status as "Released"\n• Set the Release Date\n• Add a payment record',
                      style: TextStyle(fontSize: 12, color: Colors.teal.darker),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: PremiumTheme.spacingL),

            // Amount (Read-only)
            Text('Amount', style: typography.caption),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[20],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: PremiumTheme.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currencyFormat.format(widget.amount),
                      style: typography.body?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.dark,
                      ),
                    ),
                  ),
                  Icon(FluentIcons.lock, size: 14, color: Colors.grey[100]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount is fixed',
              style: typography.caption?.copyWith(
                color: PremiumTheme.textSecondary,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: PremiumTheme.spacingL),

            // Received Date
            Text('Received Date *', style: typography.caption),
            const SizedBox(height: 6),
            DatePicker(
              selected: _receivedDate,
              onChanged: (date) {
                setState(() => _receivedDate = date);
              },
            ),
          ],
        ),
      ),
      actions: [
        Button(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
                  : const Text('Save Payment'),
        ),
      ],
    );
  }
}
