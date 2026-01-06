import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bill.dart';
import 'database_providers.dart';
import 'firm_providers.dart';

final _emptyDashboardStats = DashboardStats(
  totalBills: 0,
  dueSoonBills: 0,
  overdueBills: 0,
  paidBills: 0,
  partiallyPaidBills: 0,
  totalAmount: 0,
  paidAmount: 0,
  pendingAmount: 0,
);

/// Aggregated dashboard statistics for the currently selected firm.
final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  final firmId = ref.watch(selectedFirmIdProvider);
  if (firmId == null) {
    return _emptyDashboardStats;
  }

  final billsDao = ref.watch(billsDaoProvider);
  try {
    return await billsDao.getDashboardStats(firmId);
  } catch (_) {
    return _emptyDashboardStats;
  }
});

/// All bills for the selected firm, sorted by due date descending.
final billsByFirmProvider = FutureProvider.autoDispose<List<Bill>>((ref) async {
  final firmId = ref.watch(selectedFirmIdProvider);
  if (firmId == null) {
    return const [];
  }

  final billsDao = ref.watch(billsDaoProvider);
  return billsDao.getBillsByFirm(firmId);
});
