class Tender {
  final int? id;
  final int firmId;
  final String tnNumber;
  final String? poNumber;
  final String? workDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  String? firmName;
  int? totalBills;
  int? paidBills;
  int? pendingBills;
  int? overdueBills;

  Tender({
    this.id,
    required this.firmId,
    required this.tnNumber,
    this.poNumber,
    this.workDescription,
    required this.createdAt,
    required this.updatedAt,
    this.firmName,
    this.totalBills,
    this.paidBills,
    this.pendingBills,
    this.overdueBills,
  });

  factory Tender.fromMap(Map<String, dynamic> map) {
    return Tender(
      id: map['id'] as int?,
      firmId: map['firm_id'] as int,
      tnNumber: map['tn_number'] as String,
      poNumber: map['po_number'] as String?,
      workDescription: map['work_description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      firmName: map['firm_name'] as String?,
      totalBills: map['total_bills'] as int?,
      paidBills: map['paid_bills'] as int?,
      pendingBills: map['pending_bills'] as int?,
      overdueBills: map['overdue_bills'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'firm_id': firmId,
      'tn_number': tnNumber,
      'po_number': poNumber,
      'work_description': workDescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Tender copyWith({
    int? id,
    int? firmId,
    String? tnNumber,
    String? poNumber,
    String? workDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firmName,
    int? totalBills,
    int? paidBills,
    int? pendingBills,
    int? overdueBills,
  }) {
    return Tender(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      tnNumber: tnNumber ?? this.tnNumber,
      poNumber: poNumber ?? this.poNumber,
      workDescription: workDescription ?? this.workDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firmName: firmName ?? this.firmName,
      totalBills: totalBills ?? this.totalBills,
      paidBills: paidBills ?? this.paidBills,
      pendingBills: pendingBills ?? this.pendingBills,
      overdueBills: overdueBills ?? this.overdueBills,
    );
  }
}
