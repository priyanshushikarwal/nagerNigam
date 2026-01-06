class ClientFirm {
  final int? id;
  final String firmName;
  final String? address;
  final String? contactNo;
  final String? gstNo;
  final DateTime createdAt;

  ClientFirm({
    this.id,
    required this.firmName,
    this.address,
    this.contactNo,
    this.gstNo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firm_name': firmName,
      'address': address,
      'contact_no': contactNo,
      'gst_no': gstNo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ClientFirm.fromMap(Map<String, dynamic> map) {
    return ClientFirm(
      id: map['id'] as int?,
      firmName: map['firm_name'] as String,
      address: map['address'] as String?,
      contactNo: map['contact_no'] as String?,
      gstNo: map['gst_no'] as String?,
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : DateTime.now(),
    );
  }

  ClientFirm copyWith({
    int? id,
    String? firmName,
    String? address,
    String? contactNo,
    String? gstNo,
    DateTime? createdAt,
  }) {
    return ClientFirm(
      id: id ?? this.id,
      firmName: firmName ?? this.firmName,
      address: address ?? this.address,
      contactNo: contactNo ?? this.contactNo,
      gstNo: gstNo ?? this.gstNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
