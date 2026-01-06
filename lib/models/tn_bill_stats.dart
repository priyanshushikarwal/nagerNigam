class TNBillStats {
  final int totalBills;
  final int paidBills;
  final int partiallyPaidBills;
  final int overdueBills;
  final int pendingBills;
  final int dueSoonBills;

  const TNBillStats({
    required this.totalBills,
    required this.paidBills,
    required this.partiallyPaidBills,
    required this.overdueBills,
    required this.pendingBills,
    required this.dueSoonBills,
  });

  /// Derived helper that reports how many bills are still outstanding.
  int get outstandingBills => totalBills - paidBills;

  TNBillStats copyWith({
    int? totalBills,
    int? paidBills,
    int? partiallyPaidBills,
    int? overdueBills,
    int? pendingBills,
    int? dueSoonBills,
  }) {
    return TNBillStats(
      totalBills: totalBills ?? this.totalBills,
      paidBills: paidBills ?? this.paidBills,
      partiallyPaidBills: partiallyPaidBills ?? this.partiallyPaidBills,
      overdueBills: overdueBills ?? this.overdueBills,
      pendingBills: pendingBills ?? this.pendingBills,
      dueSoonBills: dueSoonBills ?? this.dueSoonBills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBills': totalBills,
      'paidBills': paidBills,
      'partiallyPaidBills': partiallyPaidBills,
      'overdueBills': overdueBills,
      'pendingBills': pendingBills,
      'dueSoonBills': dueSoonBills,
    };
  }

  factory TNBillStats.fromJson(Map<String, dynamic> json) {
    return TNBillStats(
      totalBills: json['totalBills'] as int? ?? 0,
      paidBills: json['paidBills'] as int? ?? 0,
      partiallyPaidBills: json['partiallyPaidBills'] as int? ?? 0,
      overdueBills: json['overdueBills'] as int? ?? 0,
      pendingBills: json['pendingBills'] as int? ?? 0,
      dueSoonBills: json['dueSoonBills'] as int? ?? 0,
    );
  }
}
