import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/premium_theme.dart';
import '../models/bill.dart';
import '../state/database_providers.dart';

/// A simple dialog for recording MD/LD (Minimum Demand / Liquidated Damages) payments.
/// - Amount is read-only and auto-filled from the bill's MD/LD amount.
/// - User only selects the date when MD/LD was received.
/// - On save: creates a payment record, updates MD/LD status to "Released",
///   and sets the MD/LD release date.
class MdLdPaymentDialog extends ConsumerStatefulWidget {
  final Bill bill;

  const MdLdPaymentDialog({super.key, required this.bill});

  @override
  ConsumerState<MdLdPaymentDialog> createState() => _MdLdPaymentDialogState();
}

class _MdLdPaymentDialogState extends ConsumerState<MdLdPaymentDialog> {
  DateTime _receivedDate = DateTime.now();
  bool _isSaving = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  Future<void> _saveMdLdPayment() async {
    setState(() => _isSaving = true);

    try {
      final bill = widget.bill;
      final paymentsDao = ref.read(paymentsDaoProvider);
      final billsDao = ref.read(billsDaoProvider);

      // 1. Create the payment record
      final payment = Payment(
        billId: bill.id!,
        paymentDate: _receivedDate,
        amountPaid: bill.mdLdAmount,
        remarks: 'MD/LD Released',
        createdAt: DateTime.now(),
        lastEdited: DateTime.now(),
      );

      await paymentsDao.addPayment(payment: payment);

      // 2. Update MD/LD status to "Released" and set release date
      await billsDao.updateMdLdStatus(bill.id!, 'Released');
      await billsDao.updateMdLdReleaseDate(bill.id!, _receivedDate);

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
                content: Text('Failed to save MD/LD payment: $e'),
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
              Text('Add MD/LD Payment', style: typography.title),
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
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(FluentIcons.info, size: 16, color: Colors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recording MD/LD payment will:\n• Mark MD/LD status as "Released"\n• Set the MD/LD Release Date\n• Add a payment record',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.darker,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: PremiumTheme.spacingL),

            // MD/LD Amount (Read-only)
            Text('MD/LD Amount', style: typography.caption),
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
                      _currencyFormat.format(bill.mdLdAmount),
                      style: typography.body?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.dark,
                      ),
                    ),
                  ),
                  Icon(FluentIcons.lock, size: 14, color: Colors.grey[100]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount is fixed based on bill MD/LD',
              style: typography.caption?.copyWith(
                color: PremiumTheme.textSecondary,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: PremiumTheme.spacingL),

            // Received Date
            Text('MD/LD Received Date *', style: typography.caption),
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
          onPressed: _isSaving ? null : _saveMdLdPayment,
          child:
              _isSaving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: ProgressRing(strokeWidth: 2),
                  )
                  : const Text('Save MD/LD Payment'),
        ),
      ],
    );
  }
}
