class Bill {
  final int? id;
  final int firmId;
  final int? supplierFirmId; // Foreign key to supplier firms table
  final int? clientFirmId; // Foreign key to client firms table
  final int? tenderId; // Foreign key to tenders table
  final String tnNumber;
  final DateTime billDate;
  final DateTime dueDate;
  final double amount;
  final String status; // Pending, Paid, Overdue
  final String? remarks;

  // Financial tracking fields
  final double invoiceAmount;
  final double billPassAmount;
  final double csdAmount;
  final DateTime? csdReleasedDate;
  final DateTime? csdDueDate;
  final String csdStatus; // 'Pending' or 'Released'
  final double scrapAmount;
  final double scrapGstAmount;
  final double mdLdAmount;
  final String mdLdStatus; // 'Pending' or 'Released'
  final DateTime? mdLdReleasedDate;
  final double emptyOilIssued;
  final double emptyOilReturned;

  // Manual TDS/TCS/GST TDS amounts (no longer percentage-based)
  final double tdsAmount;
  final double tcsAmount;
  final double gstTdsAmount;

  // Partial payment tracking
  final double totalPaid;
  final double dueAmount;

  // Payment tracking fields
  final DateTime? paidDate;
  final String? transactionNo;
  final DateTime? dueReleaseDate;
  final String? invoiceNo;
  final DateTime? invoiceDate;
  final String? workOrderNo;
  final DateTime? workOrderDate;
  final String? consignmentName;
  final String? lotNo;
  final String? storeName;
  final double dMeterBox;
  final double mdNpvAmount;
  final double emptyOilDrum;
  final String dMeterBoxStatus;
  final DateTime? dMeterBoxReleasedDate;
  final String mdNpvStatus;
  final DateTime? mdNpvReleasedDate;
  final String emptyOilDrumStatus;
  final DateTime? emptyOilDrumReleasedDate;
  final String? dMeterBoxRemark;
  final String? mdNpvRemark;
  final String? emptyOilDrumRemark;
  final String? proofPath;
  final String? invoiceType; // 'JOB Invoice' or 'PV Invoice'

  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  String? firmName;
  String? supplierFirmName;
  String? clientFirmName;
  List<Payment>? payments;

  Bill({
    this.id,
    required this.firmId,
    this.supplierFirmId,
    this.clientFirmId,
    this.tenderId,
    required this.tnNumber,
    required this.billDate,
    required this.dueDate,
    required this.amount,
    required this.status,
    this.remarks,
    this.invoiceAmount = 0,
    this.billPassAmount = 0,
    this.csdAmount = 0,
    this.csdReleasedDate,
    this.csdDueDate,
    this.csdStatus = 'Pending',
    this.scrapAmount = 0,
    this.scrapGstAmount = 0,
    this.mdLdAmount = 0,
    this.mdLdStatus = 'Pending',
    this.mdLdReleasedDate,
    this.emptyOilIssued = 0,
    this.emptyOilReturned = 0,
    this.tdsAmount = 0,
    this.tcsAmount = 0,
    this.gstTdsAmount = 0,
    this.totalPaid = 0,
    this.dueAmount = 0,
    this.paidDate,
    this.transactionNo,
    this.dueReleaseDate,
    this.invoiceNo,
    this.invoiceDate,
    this.workOrderNo,
    this.workOrderDate,
    this.consignmentName,
    this.lotNo,
    this.storeName,
    this.dMeterBox = 0,
    this.mdNpvAmount = 0,
    this.emptyOilDrum = 0,
    this.dMeterBoxStatus = 'Pending',
    this.dMeterBoxReleasedDate,
    this.mdNpvStatus = 'Pending',
    this.mdNpvReleasedDate,
    this.emptyOilDrumStatus = 'Pending',
    this.emptyOilDrumReleasedDate,
    this.dMeterBoxRemark,
    this.mdNpvRemark,
    this.emptyOilDrumRemark,
    this.proofPath,
    this.invoiceType,
    required this.createdAt,
    required this.updatedAt,
    this.firmName,
    this.supplierFirmName,
    this.clientFirmName,
    List<Payment>? payments,
  }) : payments = payments ?? const [];

  // Check if bill is due soon (within 7 days)
  bool get isDueSoon {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff >= 0 && diff <= 7 && status != 'Paid';
  }

  // Check if bill is overdue
  bool get isOverdue {
    final now = DateTime.now();
    return dueDate.isBefore(now) && status != 'Paid';
  }

  // Days until/past due
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // Auto-calculated fields
  double get difference => invoiceAmount - billPassAmount;

  double get netOilBalance => emptyOilIssued - emptyOilReturned;

  // Calculate total deductions: CSD + TDS + GST TDS + TCS + Scrap + Scrap GST + MD/LD
  double get totalDeductions =>
      csdAmount +
      tdsAmount +
      gstTdsAmount +
      tcsAmount +
      scrapAmount +
      scrapGstAmount +
      mdLdAmount;

  // Net payable amount: Bill Pass Amount - Total Deductions
  double get netPayable => billPassAmount - totalDeductions;

  String? get billNo => invoiceNo;

  // Convert from database map
  factory Bill.fromMap(Map<String, dynamic> map) {
    final dueDate = DateTime.parse(map['due_date'] as String);
    final invoiceAmount = (map['invoice_amount'] as num?)?.toDouble() ?? 0;
    final billPassAmount = (map['bill_pass_amount'] as num?)?.toDouble() ?? 0;
    final payments = <Payment>[];

    final baseBill = Bill(
      id: map['id'] as int?,
      firmId: map['firm_id'] as int,
      supplierFirmId: map['supplier_firm_id'] as int?,
      clientFirmId: map['client_firm_id'] as int?,
      tenderId: map['tender_id'] as int?,
      tnNumber: map['tn_number'] as String,
      billDate: DateTime.parse(map['bill_date'] as String),
      dueDate: dueDate,
      amount: (map['amount'] as num).toDouble(),
      status: (map['status'] as String?) ?? 'Pending',
      remarks: map['remarks'] as String?,
      invoiceAmount: invoiceAmount,
      billPassAmount: billPassAmount,
      csdAmount: (map['csd_amount'] as num?)?.toDouble() ?? 0,
      csdReleasedDate:
          map['csd_released_date'] != null
              ? DateTime.parse(map['csd_released_date'] as String)
              : null,
      csdDueDate:
          map['csd_due_date'] != null
              ? DateTime.parse(map['csd_due_date'] as String)
              : null,
      csdStatus: (map['csd_status'] as String?) ?? 'Pending',
      scrapAmount: (map['scrap_amount'] as num?)?.toDouble() ?? 0,
      scrapGstAmount: (map['scrap_gst_amount'] as num?)?.toDouble() ?? 0,
      mdLdAmount: (map['md_ld_amount'] as num?)?.toDouble() ?? 0,
      mdLdStatus: (map['md_ld_status'] as String?) ?? 'Pending',
      mdLdReleasedDate:
          map['md_ld_released_date'] != null
              ? DateTime.parse(map['md_ld_released_date'] as String)
              : null,
      emptyOilIssued: (map['empty_oil_issued'] as num?)?.toDouble() ?? 0,
      emptyOilReturned: (map['empty_oil_returned'] as num?)?.toDouble() ?? 0,
      tdsAmount: (map['tds_amount'] as num?)?.toDouble() ?? 0,
      tcsAmount: (map['tcs_amount'] as num?)?.toDouble() ?? 0,
      gstTdsAmount: (map['gst_tds_amount'] as num?)?.toDouble() ?? 0,
      totalPaid: (map['total_paid'] as num?)?.toDouble() ?? 0,
      dueAmount: (map['due_amount'] as num?)?.toDouble() ?? 0,
      paidDate:
          map['paid_date'] != null
              ? DateTime.parse(map['paid_date'] as String)
              : null,
      transactionNo: map['transaction_no'] as String?,
      dueReleaseDate:
          map['due_release_date'] != null
              ? DateTime.parse(map['due_release_date'] as String)
              : null,
      invoiceNo: map['invoice_no'] as String?,
      invoiceDate:
          map['invoice_date'] != null
              ? DateTime.parse(map['invoice_date'] as String)
              : null,
      workOrderNo: map['work_order_no'] as String?,
      workOrderDate:
          map['work_order_date'] != null
              ? DateTime.parse(map['work_order_date'] as String)
              : null,
      consignmentName: map['consignment_name'] as String?,
      lotNo: map['lot_no'] as String?,
      storeName: map['store_name'] as String?,
      dMeterBox: (map['d_meter_box'] as num?)?.toDouble() ?? 0,
      mdNpvAmount: (map['md_npv_amount'] as num?)?.toDouble() ?? 0,
      emptyOilDrum: (map['empty_oil_drum'] as num?)?.toDouble() ?? 0,
      dMeterBoxStatus: (map['d_meter_box_status'] as String?) ?? 'Pending',
      dMeterBoxReleasedDate:
          map['d_meter_box_released_date'] != null
              ? DateTime.parse(map['d_meter_box_released_date'] as String)
              : null,
      mdNpvStatus: (map['md_npv_status'] as String?) ?? 'Pending',
      mdNpvReleasedDate:
          map['md_npv_released_date'] != null
              ? DateTime.parse(map['md_npv_released_date'] as String)
              : null,
      emptyOilDrumStatus:
          (map['empty_oil_drum_status'] as String?) ?? 'Pending',
      emptyOilDrumReleasedDate:
          map['empty_oil_drum_released_date'] != null
              ? DateTime.parse(map['empty_oil_drum_released_date'] as String)
              : null,
      dMeterBoxRemark: map['d_meter_box_remark'] as String?,
      mdNpvRemark: map['md_npv_remark'] as String?,
      emptyOilDrumRemark: map['empty_oil_drum_remark'] as String?,
      proofPath: map['proof_path'] as String?,
      invoiceType: map['invoice_type'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      firmName: map['firm_name'] as String?,
      supplierFirmName: map['supplier_firm_name'] as String?,
      clientFirmName: map['client_firm_name'] as String?,
      payments: payments,
    );

    final computedStatus = calculateStatus(baseBill, payments);
    return baseBill.copyWith(status: computedStatus, payments: payments);
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'firm_id': firmId,
      'supplier_firm_id': supplierFirmId,
      'client_firm_id': clientFirmId,
      'tender_id': tenderId,
      'tn_number': tnNumber,
      'bill_date': billDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'amount': amount,
      'status': status,
      'remarks': remarks,
      'invoice_amount': invoiceAmount,
      'bill_pass_amount': billPassAmount,
      'csd_amount': csdAmount,
      'csd_released_date': csdReleasedDate?.toIso8601String(),
      'csd_due_date': csdDueDate?.toIso8601String(),
      'csd_status': csdStatus,
      'scrap_amount': scrapAmount,
      'scrap_gst_amount': scrapGstAmount,
      'md_ld_amount': mdLdAmount,
      'md_ld_status': mdLdStatus,
      'md_ld_released_date': mdLdReleasedDate?.toIso8601String(),
      'empty_oil_issued': emptyOilIssued,
      'empty_oil_returned': emptyOilReturned,
      'tds_amount': tdsAmount,
      'tcs_amount': tcsAmount,
      'gst_tds_amount': gstTdsAmount,
      'total_paid': totalPaid,
      'due_amount': dueAmount,
      'paid_date': paidDate?.toIso8601String(),
      'transaction_no': transactionNo,
      'due_release_date': dueReleaseDate?.toIso8601String(),
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate?.toIso8601String(),
      'work_order_no': workOrderNo,
      'work_order_date': workOrderDate?.toIso8601String(),
      'consignment_name': consignmentName,
      'lot_no': lotNo,
      'store_name': storeName,
      'd_meter_box': dMeterBox,
      'md_npv_amount': mdNpvAmount,
      'empty_oil_drum': emptyOilDrum,
      'd_meter_box_status': dMeterBoxStatus,
      'd_meter_box_released_date': dMeterBoxReleasedDate?.toIso8601String(),
      'md_npv_status': mdNpvStatus,
      'md_npv_released_date': mdNpvReleasedDate?.toIso8601String(),
      'empty_oil_drum_status': emptyOilDrumStatus,
      'empty_oil_drum_released_date':
          emptyOilDrumReleasedDate?.toIso8601String(),
      'd_meter_box_remark': dMeterBoxRemark,
      'md_npv_remark': mdNpvRemark,
      'empty_oil_drum_remark': emptyOilDrumRemark,
      'proof_path': proofPath,
      'invoice_type': invoiceType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Bill copyWith({
    int? id,
    int? firmId,
    int? supplierFirmId,
    int? clientFirmId,
    int? tenderId,
    String? tnNumber,
    DateTime? billDate,
    DateTime? dueDate,
    double? amount,
    String? status,
    String? remarks,
    double? invoiceAmount,
    double? billPassAmount,
    double? csdAmount,
    DateTime? csdReleasedDate,
    DateTime? csdDueDate,
    String? csdStatus,
    double? scrapAmount,
    double? scrapGstAmount,
    double? mdLdAmount,
    String? mdLdStatus,
    DateTime? mdLdReleasedDate,
    double? emptyOilIssued,
    double? emptyOilReturned,
    double? tdsAmount,
    double? tcsAmount,
    double? gstTdsAmount,
    double? totalPaid,
    double? dueAmount,
    DateTime? paidDate,
    String? transactionNo,
    DateTime? dueReleaseDate,
    String? invoiceNo,
    DateTime? invoiceDate,
    String? workOrderNo,
    DateTime? workOrderDate,
    String? consignmentName,
    String? proofPath,
    String? invoiceType,
    String? lotNo,
    String? storeName,
    double? dMeterBox,
    double? mdNpvAmount,
    double? emptyOilDrum,
    String? dMeterBoxStatus,
    DateTime? dMeterBoxReleasedDate,
    String? mdNpvStatus,
    DateTime? mdNpvReleasedDate,
    String? emptyOilDrumStatus,
    DateTime? emptyOilDrumReleasedDate,
    String? dMeterBoxRemark,
    String? mdNpvRemark,
    String? emptyOilDrumRemark,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firmName,
    String? supplierFirmName,
    String? clientFirmName,
    List<Payment>? payments,
  }) {
    return Bill(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      supplierFirmId: supplierFirmId ?? this.supplierFirmId,
      clientFirmId: clientFirmId ?? this.clientFirmId,
      tenderId: tenderId ?? this.tenderId,
      tnNumber: tnNumber ?? this.tnNumber,
      billDate: billDate ?? this.billDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      billPassAmount: billPassAmount ?? this.billPassAmount,
      csdAmount: csdAmount ?? this.csdAmount,
      csdReleasedDate: csdReleasedDate ?? this.csdReleasedDate,
      csdDueDate: csdDueDate ?? this.csdDueDate,
      csdStatus: csdStatus ?? this.csdStatus,
      scrapAmount: scrapAmount ?? this.scrapAmount,
      scrapGstAmount: scrapGstAmount ?? this.scrapGstAmount,
      mdLdAmount: mdLdAmount ?? this.mdLdAmount,
      mdLdStatus: mdLdStatus ?? this.mdLdStatus,
      mdLdReleasedDate: mdLdReleasedDate ?? this.mdLdReleasedDate,
      emptyOilIssued: emptyOilIssued ?? this.emptyOilIssued,
      emptyOilReturned: emptyOilReturned ?? this.emptyOilReturned,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      tcsAmount: tcsAmount ?? this.tcsAmount,
      gstTdsAmount: gstTdsAmount ?? this.gstTdsAmount,
      totalPaid: totalPaid ?? this.totalPaid,
      dueAmount: dueAmount ?? this.dueAmount,
      paidDate: paidDate ?? this.paidDate,
      transactionNo: transactionNo ?? this.transactionNo,
      dueReleaseDate: dueReleaseDate ?? this.dueReleaseDate,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      workOrderNo: workOrderNo ?? this.workOrderNo,
      workOrderDate: workOrderDate ?? this.workOrderDate,
      consignmentName: consignmentName ?? this.consignmentName,
      lotNo: lotNo ?? this.lotNo,
      storeName: storeName ?? this.storeName,
      dMeterBox: dMeterBox ?? this.dMeterBox,
      mdNpvAmount: mdNpvAmount ?? this.mdNpvAmount,
      emptyOilDrum: emptyOilDrum ?? this.emptyOilDrum,
      dMeterBoxStatus: dMeterBoxStatus ?? this.dMeterBoxStatus,
      dMeterBoxReleasedDate:
          dMeterBoxReleasedDate ?? this.dMeterBoxReleasedDate,
      mdNpvStatus: mdNpvStatus ?? this.mdNpvStatus,
      mdNpvReleasedDate: mdNpvReleasedDate ?? this.mdNpvReleasedDate,
      emptyOilDrumStatus: emptyOilDrumStatus ?? this.emptyOilDrumStatus,
      emptyOilDrumReleasedDate:
          emptyOilDrumReleasedDate ?? this.emptyOilDrumReleasedDate,
      dMeterBoxRemark: dMeterBoxRemark ?? this.dMeterBoxRemark,
      mdNpvRemark: mdNpvRemark ?? this.mdNpvRemark,
      emptyOilDrumRemark: emptyOilDrumRemark ?? this.emptyOilDrumRemark,
      proofPath: proofPath ?? this.proofPath,
      invoiceType: invoiceType ?? this.invoiceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firmName: firmName ?? this.firmName,
      supplierFirmName: supplierFirmName ?? this.supplierFirmName,
      clientFirmName: clientFirmName ?? this.clientFirmName,
      payments: payments ?? this.payments,
    );
  }

  static String calculateStatus(Bill bill, List<Payment> payments) {
    const double epsilon = 100.0;
    final totalPaid = payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amountPaid,
    );

    // Calculate net payable from invoice amount
    // Note: CSD and MD/LD are NOT deducted - they are receivables that will be paid back
    final netPayable =
        bill.invoiceAmount -
        (bill.tdsAmount +
            bill.gstTdsAmount +
            bill.tcsAmount +
            bill.scrapAmount +
            bill.scrapGstAmount);

    // Payment-based status logic
    if (totalPaid == 0) {
      return 'Pending';
    }

    // Check if remaining amount is greater than epsilon (100)
    // If remaining amount is <= 100, consider it Paid
    if (netPayable - totalPaid > epsilon) {
      return 'Partially Paid';
    }

    return 'Paid';
  }

  // Helper method to get total paid from payments list
  static double calculateTotalPaid(List<Payment> payments) {
    return payments.fold<double>(0, (sum, payment) => sum + payment.amountPaid);
  }

  // Helper method to calculate due amount
  static double calculateDueAmount(Bill bill, List<Payment> payments) {
    // Net payable from invoice amount, excluding CSD and MD (they are receivables)
    final netPayable =
        bill.invoiceAmount -
        (bill.tdsAmount +
            bill.gstTdsAmount +
            bill.tcsAmount +
            bill.scrapAmount +
            bill.scrapGstAmount);
    final totalPaid = calculateTotalPaid(payments);
    return netPayable - totalPaid;
  }
}

class Payment {
  final int? id;
  final int billId;
  final DateTime paymentDate;
  final double amountPaid;
  final String? proofPath;
  final String? remarks;
  final DateTime lastEdited;
  final DateTime createdAt;
  // New tracking fields
  final DateTime? paidDate;
  final String? transactionNo;
  final DateTime? dueReleaseDate;
  final String? invoiceNo;
  final DateTime? invoiceDate;
  final String? workOrderNo;
  final DateTime? workOrderDate;
  final String? consignmentName;

  Payment({
    this.id,
    required this.billId,
    required this.paymentDate,
    required this.amountPaid,
    this.proofPath,
    this.remarks,
    required this.lastEdited,
    required this.createdAt,
    this.paidDate,
    this.transactionNo,
    this.dueReleaseDate,
    this.invoiceNo,
    this.invoiceDate,
    this.workOrderNo,
    this.workOrderDate,
    this.consignmentName,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      billId: map['bill_id'] as int,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      amountPaid: (map['amount_paid'] as num).toDouble(),
      proofPath: map['proof_path'] as String?,
      remarks: map['remarks'] as String?,
      lastEdited: DateTime.parse(map['last_edited'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      paidDate:
          map['paid_date'] != null
              ? DateTime.parse(map['paid_date'] as String)
              : null,
      transactionNo: map['transaction_no'] as String?,
      dueReleaseDate:
          map['due_release_date'] != null
              ? DateTime.parse(map['due_release_date'] as String)
              : null,
      invoiceNo: map['invoice_no'] as String?,
      invoiceDate:
          map['invoice_date'] != null
              ? DateTime.parse(map['invoice_date'] as String)
              : null,
      workOrderNo: map['work_order_no'] as String?,
      workOrderDate:
          map['work_order_date'] != null
              ? DateTime.parse(map['work_order_date'] as String)
              : null,
      consignmentName: map['consignment_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bill_id': billId,
      'payment_date': paymentDate.toIso8601String(),
      'amount_paid': amountPaid,
      'proof_path': proofPath,
      'remarks': remarks,
      'last_edited': lastEdited.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'transaction_no': transactionNo,
      'due_release_date': dueReleaseDate?.toIso8601String(),
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate?.toIso8601String(),
      'work_order_no': workOrderNo,
      'work_order_date': workOrderDate?.toIso8601String(),
      'consignment_name': consignmentName,
    };
  }
}

class Firm {
  final int? id;
  final String name;
  final String code;
  final String? description;
  final String? address;
  final String? contactNo;
  final String? gstNo;
  final DateTime createdAt;

  Firm({
    this.id,
    required this.name,
    required this.code,
    this.description,
    this.address,
    this.contactNo,
    this.gstNo,
    required this.createdAt,
  });

  factory Firm.fromMap(Map<String, dynamic> map) {
    return Firm(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String,
      description: map['description'] as String?,
      address: map['address'] as String?,
      contactNo: map['contact_no'] as String?,
      gstNo: map['gst_no'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'description': description,
      'address': address,
      'contact_no': contactNo,
      'gst_no': gstNo,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DashboardStats {
  final int totalBills;
  final int dueSoonBills;
  final int overdueBills;
  final int paidBills;
  final int partiallyPaidBills;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;

  DashboardStats({
    required this.totalBills,
    required this.dueSoonBills,
    required this.overdueBills,
    required this.paidBills,
    required this.partiallyPaidBills,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
  });
}

/// Combined model for a bill with all its associated payments
class BillWithPayments {
  final Bill bill;
  final List<Payment> payments;

  BillWithPayments({required this.bill, required this.payments});

  /// Calculate total amount paid from all payments
  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amountPaid);

  /// Get the bill's current status based on payments
  String get status => Bill.calculateStatus(bill, payments);
}
