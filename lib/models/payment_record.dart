import 'package:meta/meta.dart';

import 'bill.dart';

@immutable
class FirmPaymentRecord {
  const FirmPaymentRecord({
    required this.payment,
    required this.billId,
    required this.tnNumber,
    required this.billAmount,
    required this.invoiceAmount,
    required this.billPassAmount,
    required this.billDate,
    required this.dueDate,
    this.csdAmount = 0,
    this.tdsAmount = 0,
    this.gstTdsAmount = 0,
    this.tcsAmount = 0,
    this.scrapAmount = 0,
    this.scrapGstAmount = 0,
    this.mdLdAmount = 0,
  });

  final Payment payment;
  final int billId;
  final String tnNumber;
  final double billAmount;
  final double invoiceAmount;
  final double billPassAmount;
  final DateTime billDate;
  final DateTime dueDate;
  // Deduction fields
  final double csdAmount;
  final double tdsAmount;
  final double gstTdsAmount;
  final double tcsAmount;
  final double scrapAmount;
  final double scrapGstAmount;
  final double mdLdAmount;

  /// Net payable = billPassAmount - all deductions
  double get netPayable {
    final base =
        billPassAmount > 0
            ? billPassAmount
            : (invoiceAmount > 0 ? invoiceAmount : billAmount);
    return base -
        csdAmount -
        tdsAmount -
        gstTdsAmount -
        tcsAmount -
        scrapAmount -
        scrapGstAmount -
        mdLdAmount;
  }

  /// Target amount for display (net payable)
  double get targetAmount => netPayable;
}
