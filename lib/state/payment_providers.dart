import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_record.dart';
import 'database_providers.dart';
import 'firm_providers.dart';

class PaymentsSummary {
  const PaymentsSummary({
    required this.totalAmount,
    required this.paymentCount,
    required this.latestPayment,
    required this.upcomingReleases,
    required this.attachments,
  });

  factory PaymentsSummary.fromRecords(List<FirmPaymentRecord> records) {
    if (records.isEmpty) {
      return const PaymentsSummary(
        totalAmount: 0,
        paymentCount: 0,
        latestPayment: null,
        upcomingReleases: 0,
        attachments: 0,
      );
    }

    final totalAmount = records.fold<double>(
      0,
      (sum, record) => sum + record.payment.amountPaid,
    );
    final latestPayment = records
        .map((record) => record.payment.paymentDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final upcomingReleases =
        records.where((record) {
          final due = record.payment.dueReleaseDate;
          if (due == null) return false;
          final now = DateTime.now();
          return due.isAfter(now) &&
              due.isBefore(now.add(const Duration(days: 30)));
        }).length;
    final attachments =
        records
            .where((record) => (record.payment.proofPath ?? '').isNotEmpty)
            .length;

    return PaymentsSummary(
      totalAmount: totalAmount,
      paymentCount: records.length,
      latestPayment: latestPayment,
      upcomingReleases: upcomingReleases,
      attachments: attachments,
    );
  }

  final double totalAmount;
  final int paymentCount;
  final DateTime? latestPayment;
  final int upcomingReleases;
  final int attachments;

  double get averagePayment =>
      paymentCount == 0 ? 0 : totalAmount / paymentCount;
}

final paymentsForFirmProvider =
    FutureProvider.autoDispose<List<FirmPaymentRecord>>((ref) async {
      final firmId = ref.watch(selectedFirmIdProvider);
      if (firmId == null) {
        return const [];
      }

      final paymentsDao = ref.watch(paymentsDaoProvider);
      return paymentsDao.getPaymentsForFirm(firmId);
    });

final paymentsSummaryProvider = Provider.autoDispose<PaymentsSummary>((ref) {
  final asyncPayments = ref.watch(paymentsForFirmProvider);
  return asyncPayments.maybeWhen(
    data: PaymentsSummary.fromRecords,
    orElse:
        () => const PaymentsSummary(
          totalAmount: 0,
          paymentCount: 0,
          latestPayment: null,
          upcomingReleases: 0,
          attachments: 0,
        ),
  );
});
