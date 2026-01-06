import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bill.dart';
import '../models/tender.dart';
import '../models/tn_bill_stats.dart';
import 'database_providers.dart';
import 'firm_providers.dart';

/// Loads all tenders (TN) for the currently selected firm.
final firmTendersProvider = FutureProvider.autoDispose<List<Tender>>((
  ref,
) async {
  final firmId = ref.watch(selectedFirmIdProvider);
  if (firmId == null) {
    return const [];
  }

  final repository = ref.watch(tnDaoProvider);
  return repository.getTendersByFirm(firmId);
});

/// Alias to keep compatibility with existing UI references.
final tendersByFirmProvider = firmTendersProvider;

/// Computes bill statistics for a given tender.
final tenderStatsProvider = FutureProvider.autoDispose.family<TNBillStats, int>(
  (ref, tenderId) async {
    final repository = ref.watch(tnDaoProvider);
    return repository.getTenderStats(tenderId);
  },
);

/// Retrieves the list of bills linked to a tender.
final billsByTenderProvider = FutureProvider.autoDispose
    .family<List<Bill>, int>((ref, tenderId) async {
      final repository = ref.watch(billsDaoProvider);
      return repository.getBillsByTender(tenderId);
    });
