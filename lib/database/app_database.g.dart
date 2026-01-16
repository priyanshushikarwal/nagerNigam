// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FirmsTable extends Firms with TableInfo<$FirmsTable, Firm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FirmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactNoMeta = const VerificationMeta(
    'contactNo',
  );
  @override
  late final GeneratedColumn<String> contactNo = GeneratedColumn<String>(
    'contact_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstNoMeta = const VerificationMeta('gstNo');
  @override
  late final GeneratedColumn<String> gstNo = GeneratedColumn<String>(
    'gst_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    code,
    description,
    address,
    contactNo,
    gstNo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'firms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Firm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('contact_no')) {
      context.handle(
        _contactNoMeta,
        contactNo.isAcceptableOrUnknown(data['contact_no']!, _contactNoMeta),
      );
    }
    if (data.containsKey('gst_no')) {
      context.handle(
        _gstNoMeta,
        gstNo.isAcceptableOrUnknown(data['gst_no']!, _gstNoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
    {code},
  ];
  @override
  Firm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Firm(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      code:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}code'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      contactNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_no'],
      ),
      gstNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gst_no'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $FirmsTable createAlias(String alias) {
    return $FirmsTable(attachedDatabase, alias);
  }
}

class Firm extends DataClass implements Insertable<Firm> {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? address;
  final String? contactNo;
  final String? gstNo;
  final DateTime createdAt;
  const Firm({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.address,
    this.contactNo,
    this.gstNo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || contactNo != null) {
      map['contact_no'] = Variable<String>(contactNo);
    }
    if (!nullToAbsent || gstNo != null) {
      map['gst_no'] = Variable<String>(gstNo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FirmsCompanion toCompanion(bool nullToAbsent) {
    return FirmsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      contactNo:
          contactNo == null && nullToAbsent
              ? const Value.absent()
              : Value(contactNo),
      gstNo:
          gstNo == null && nullToAbsent ? const Value.absent() : Value(gstNo),
      createdAt: Value(createdAt),
    );
  }

  factory Firm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Firm(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String?>(json['description']),
      address: serializer.fromJson<String?>(json['address']),
      contactNo: serializer.fromJson<String?>(json['contactNo']),
      gstNo: serializer.fromJson<String?>(json['gstNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String?>(description),
      'address': serializer.toJson<String?>(address),
      'contactNo': serializer.toJson<String?>(contactNo),
      'gstNo': serializer.toJson<String?>(gstNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Firm copyWith({
    int? id,
    String? name,
    String? code,
    Value<String?> description = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> contactNo = const Value.absent(),
    Value<String?> gstNo = const Value.absent(),
    DateTime? createdAt,
  }) => Firm(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    description: description.present ? description.value : this.description,
    address: address.present ? address.value : this.address,
    contactNo: contactNo.present ? contactNo.value : this.contactNo,
    gstNo: gstNo.present ? gstNo.value : this.gstNo,
    createdAt: createdAt ?? this.createdAt,
  );
  Firm copyWithCompanion(FirmsCompanion data) {
    return Firm(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      description:
          data.description.present ? data.description.value : this.description,
      address: data.address.present ? data.address.value : this.address,
      contactNo: data.contactNo.present ? data.contactNo.value : this.contactNo,
      gstNo: data.gstNo.present ? data.gstNo.value : this.gstNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Firm(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('contactNo: $contactNo, ')
          ..write('gstNo: $gstNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    description,
    address,
    contactNo,
    gstNo,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Firm &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.description == this.description &&
          other.address == this.address &&
          other.contactNo == this.contactNo &&
          other.gstNo == this.gstNo &&
          other.createdAt == this.createdAt);
}

class FirmsCompanion extends UpdateCompanion<Firm> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String?> description;
  final Value<String?> address;
  final Value<String?> contactNo;
  final Value<String?> gstNo;
  final Value<DateTime> createdAt;
  const FirmsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.contactNo = const Value.absent(),
    this.gstNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FirmsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String code,
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.contactNo = const Value.absent(),
    this.gstNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       code = Value(code);
  static Insertable<Firm> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? description,
    Expression<String>? address,
    Expression<String>? contactNo,
    Expression<String>? gstNo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (contactNo != null) 'contact_no': contactNo,
      if (gstNo != null) 'gst_no': gstNo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FirmsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? code,
    Value<String?>? description,
    Value<String?>? address,
    Value<String?>? contactNo,
    Value<String?>? gstNo,
    Value<DateTime>? createdAt,
  }) {
    return FirmsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      address: address ?? this.address,
      contactNo: contactNo ?? this.contactNo,
      gstNo: gstNo ?? this.gstNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (contactNo.present) {
      map['contact_no'] = Variable<String>(contactNo.value);
    }
    if (gstNo.present) {
      map['gst_no'] = Variable<String>(gstNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FirmsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('contactNo: $contactNo, ')
          ..write('gstNo: $gstNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ClientFirmsTable extends ClientFirms
    with TableInfo<$ClientFirmsTable, ClientFirm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientFirmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _firmNameMeta = const VerificationMeta(
    'firmName',
  );
  @override
  late final GeneratedColumn<String> firmName = GeneratedColumn<String>(
    'firm_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactNoMeta = const VerificationMeta(
    'contactNo',
  );
  @override
  late final GeneratedColumn<String> contactNo = GeneratedColumn<String>(
    'contact_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstNoMeta = const VerificationMeta('gstNo');
  @override
  late final GeneratedColumn<String> gstNo = GeneratedColumn<String>(
    'gst_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmName,
    address,
    contactNo,
    gstNo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_firms';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientFirm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_name')) {
      context.handle(
        _firmNameMeta,
        firmName.isAcceptableOrUnknown(data['firm_name']!, _firmNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firmNameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('contact_no')) {
      context.handle(
        _contactNoMeta,
        contactNo.isAcceptableOrUnknown(data['contact_no']!, _contactNoMeta),
      );
    }
    if (data.containsKey('gst_no')) {
      context.handle(
        _gstNoMeta,
        gstNo.isAcceptableOrUnknown(data['gst_no']!, _gstNoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {firmName},
  ];
  @override
  ClientFirm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientFirm(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      firmName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}firm_name'],
          )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      contactNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_no'],
      ),
      gstNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gst_no'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ClientFirmsTable createAlias(String alias) {
    return $ClientFirmsTable(attachedDatabase, alias);
  }
}

class ClientFirm extends DataClass implements Insertable<ClientFirm> {
  final int id;
  final String firmName;
  final String? address;
  final String? contactNo;
  final String? gstNo;
  final DateTime createdAt;
  const ClientFirm({
    required this.id,
    required this.firmName,
    this.address,
    this.contactNo,
    this.gstNo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['firm_name'] = Variable<String>(firmName);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || contactNo != null) {
      map['contact_no'] = Variable<String>(contactNo);
    }
    if (!nullToAbsent || gstNo != null) {
      map['gst_no'] = Variable<String>(gstNo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientFirmsCompanion toCompanion(bool nullToAbsent) {
    return ClientFirmsCompanion(
      id: Value(id),
      firmName: Value(firmName),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      contactNo:
          contactNo == null && nullToAbsent
              ? const Value.absent()
              : Value(contactNo),
      gstNo:
          gstNo == null && nullToAbsent ? const Value.absent() : Value(gstNo),
      createdAt: Value(createdAt),
    );
  }

  factory ClientFirm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientFirm(
      id: serializer.fromJson<int>(json['id']),
      firmName: serializer.fromJson<String>(json['firmName']),
      address: serializer.fromJson<String?>(json['address']),
      contactNo: serializer.fromJson<String?>(json['contactNo']),
      gstNo: serializer.fromJson<String?>(json['gstNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firmName': serializer.toJson<String>(firmName),
      'address': serializer.toJson<String?>(address),
      'contactNo': serializer.toJson<String?>(contactNo),
      'gstNo': serializer.toJson<String?>(gstNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClientFirm copyWith({
    int? id,
    String? firmName,
    Value<String?> address = const Value.absent(),
    Value<String?> contactNo = const Value.absent(),
    Value<String?> gstNo = const Value.absent(),
    DateTime? createdAt,
  }) => ClientFirm(
    id: id ?? this.id,
    firmName: firmName ?? this.firmName,
    address: address.present ? address.value : this.address,
    contactNo: contactNo.present ? contactNo.value : this.contactNo,
    gstNo: gstNo.present ? gstNo.value : this.gstNo,
    createdAt: createdAt ?? this.createdAt,
  );
  ClientFirm copyWithCompanion(ClientFirmsCompanion data) {
    return ClientFirm(
      id: data.id.present ? data.id.value : this.id,
      firmName: data.firmName.present ? data.firmName.value : this.firmName,
      address: data.address.present ? data.address.value : this.address,
      contactNo: data.contactNo.present ? data.contactNo.value : this.contactNo,
      gstNo: data.gstNo.present ? data.gstNo.value : this.gstNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientFirm(')
          ..write('id: $id, ')
          ..write('firmName: $firmName, ')
          ..write('address: $address, ')
          ..write('contactNo: $contactNo, ')
          ..write('gstNo: $gstNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, firmName, address, contactNo, gstNo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientFirm &&
          other.id == this.id &&
          other.firmName == this.firmName &&
          other.address == this.address &&
          other.contactNo == this.contactNo &&
          other.gstNo == this.gstNo &&
          other.createdAt == this.createdAt);
}

class ClientFirmsCompanion extends UpdateCompanion<ClientFirm> {
  final Value<int> id;
  final Value<String> firmName;
  final Value<String?> address;
  final Value<String?> contactNo;
  final Value<String?> gstNo;
  final Value<DateTime> createdAt;
  const ClientFirmsCompanion({
    this.id = const Value.absent(),
    this.firmName = const Value.absent(),
    this.address = const Value.absent(),
    this.contactNo = const Value.absent(),
    this.gstNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientFirmsCompanion.insert({
    this.id = const Value.absent(),
    required String firmName,
    this.address = const Value.absent(),
    this.contactNo = const Value.absent(),
    this.gstNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : firmName = Value(firmName);
  static Insertable<ClientFirm> custom({
    Expression<int>? id,
    Expression<String>? firmName,
    Expression<String>? address,
    Expression<String>? contactNo,
    Expression<String>? gstNo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmName != null) 'firm_name': firmName,
      if (address != null) 'address': address,
      if (contactNo != null) 'contact_no': contactNo,
      if (gstNo != null) 'gst_no': gstNo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientFirmsCompanion copyWith({
    Value<int>? id,
    Value<String>? firmName,
    Value<String?>? address,
    Value<String?>? contactNo,
    Value<String?>? gstNo,
    Value<DateTime>? createdAt,
  }) {
    return ClientFirmsCompanion(
      id: id ?? this.id,
      firmName: firmName ?? this.firmName,
      address: address ?? this.address,
      contactNo: contactNo ?? this.contactNo,
      gstNo: gstNo ?? this.gstNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firmName.present) {
      map['firm_name'] = Variable<String>(firmName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (contactNo.present) {
      map['contact_no'] = Variable<String>(contactNo.value);
    }
    if (gstNo.present) {
      map['gst_no'] = Variable<String>(gstNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientFirmsCompanion(')
          ..write('id: $id, ')
          ..write('firmName: $firmName, ')
          ..write('address: $address, ')
          ..write('contactNo: $contactNo, ')
          ..write('gstNo: $gstNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TendersTable extends Tenders with TableInfo<$TendersTable, Tender> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TendersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<int> firmId = GeneratedColumn<int>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES firms (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tnNumberMeta = const VerificationMeta(
    'tnNumber',
  );
  @override
  late final GeneratedColumn<String> tnNumber = GeneratedColumn<String>(
    'tn_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poNumberMeta = const VerificationMeta(
    'poNumber',
  );
  @override
  late final GeneratedColumn<String> poNumber = GeneratedColumn<String>(
    'po_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workDescriptionMeta = const VerificationMeta(
    'workDescription',
  );
  @override
  late final GeneratedColumn<String> workDescription = GeneratedColumn<String>(
    'work_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    tnNumber,
    poNumber,
    workDescription,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tender> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('tn_number')) {
      context.handle(
        _tnNumberMeta,
        tnNumber.isAcceptableOrUnknown(data['tn_number']!, _tnNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_tnNumberMeta);
    }
    if (data.containsKey('po_number')) {
      context.handle(
        _poNumberMeta,
        poNumber.isAcceptableOrUnknown(data['po_number']!, _poNumberMeta),
      );
    }
    if (data.containsKey('work_description')) {
      context.handle(
        _workDescriptionMeta,
        workDescription.isAcceptableOrUnknown(
          data['work_description']!,
          _workDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {firmId, tnNumber},
  ];
  @override
  Tender map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tender(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      firmId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}firm_id'],
          )!,
      tnNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tn_number'],
          )!,
      poNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}po_number'],
      ),
      workDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_description'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $TendersTable createAlias(String alias) {
    return $TendersTable(attachedDatabase, alias);
  }
}

class Tender extends DataClass implements Insertable<Tender> {
  final int id;
  final int firmId;
  final String tnNumber;
  final String? poNumber;
  final String? workDescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tender({
    required this.id,
    required this.firmId,
    required this.tnNumber,
    this.poNumber,
    this.workDescription,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['firm_id'] = Variable<int>(firmId);
    map['tn_number'] = Variable<String>(tnNumber);
    if (!nullToAbsent || poNumber != null) {
      map['po_number'] = Variable<String>(poNumber);
    }
    if (!nullToAbsent || workDescription != null) {
      map['work_description'] = Variable<String>(workDescription);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TendersCompanion toCompanion(bool nullToAbsent) {
    return TendersCompanion(
      id: Value(id),
      firmId: Value(firmId),
      tnNumber: Value(tnNumber),
      poNumber:
          poNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(poNumber),
      workDescription:
          workDescription == null && nullToAbsent
              ? const Value.absent()
              : Value(workDescription),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tender.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tender(
      id: serializer.fromJson<int>(json['id']),
      firmId: serializer.fromJson<int>(json['firmId']),
      tnNumber: serializer.fromJson<String>(json['tnNumber']),
      poNumber: serializer.fromJson<String?>(json['poNumber']),
      workDescription: serializer.fromJson<String?>(json['workDescription']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firmId': serializer.toJson<int>(firmId),
      'tnNumber': serializer.toJson<String>(tnNumber),
      'poNumber': serializer.toJson<String?>(poNumber),
      'workDescription': serializer.toJson<String?>(workDescription),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tender copyWith({
    int? id,
    int? firmId,
    String? tnNumber,
    Value<String?> poNumber = const Value.absent(),
    Value<String?> workDescription = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tender(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    tnNumber: tnNumber ?? this.tnNumber,
    poNumber: poNumber.present ? poNumber.value : this.poNumber,
    workDescription:
        workDescription.present ? workDescription.value : this.workDescription,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tender copyWithCompanion(TendersCompanion data) {
    return Tender(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      tnNumber: data.tnNumber.present ? data.tnNumber.value : this.tnNumber,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      workDescription:
          data.workDescription.present
              ? data.workDescription.value
              : this.workDescription,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tender(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('tnNumber: $tnNumber, ')
          ..write('poNumber: $poNumber, ')
          ..write('workDescription: $workDescription, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firmId,
    tnNumber,
    poNumber,
    workDescription,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tender &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.tnNumber == this.tnNumber &&
          other.poNumber == this.poNumber &&
          other.workDescription == this.workDescription &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TendersCompanion extends UpdateCompanion<Tender> {
  final Value<int> id;
  final Value<int> firmId;
  final Value<String> tnNumber;
  final Value<String?> poNumber;
  final Value<String?> workDescription;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TendersCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.tnNumber = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.workDescription = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TendersCompanion.insert({
    this.id = const Value.absent(),
    required int firmId,
    required String tnNumber,
    this.poNumber = const Value.absent(),
    this.workDescription = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : firmId = Value(firmId),
       tnNumber = Value(tnNumber);
  static Insertable<Tender> custom({
    Expression<int>? id,
    Expression<int>? firmId,
    Expression<String>? tnNumber,
    Expression<String>? poNumber,
    Expression<String>? workDescription,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (tnNumber != null) 'tn_number': tnNumber,
      if (poNumber != null) 'po_number': poNumber,
      if (workDescription != null) 'work_description': workDescription,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TendersCompanion copyWith({
    Value<int>? id,
    Value<int>? firmId,
    Value<String>? tnNumber,
    Value<String?>? poNumber,
    Value<String?>? workDescription,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TendersCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      tnNumber: tnNumber ?? this.tnNumber,
      poNumber: poNumber ?? this.poNumber,
      workDescription: workDescription ?? this.workDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<int>(firmId.value);
    }
    if (tnNumber.present) {
      map['tn_number'] = Variable<String>(tnNumber.value);
    }
    if (poNumber.present) {
      map['po_number'] = Variable<String>(poNumber.value);
    }
    if (workDescription.present) {
      map['work_description'] = Variable<String>(workDescription.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TendersCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('tnNumber: $tnNumber, ')
          ..write('poNumber: $poNumber, ')
          ..write('workDescription: $workDescription, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, Bill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tenderIdMeta = const VerificationMeta(
    'tenderId',
  );
  @override
  late final GeneratedColumn<int> tenderId = GeneratedColumn<int>(
    'tender_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tenders (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<int> firmId = GeneratedColumn<int>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES firms (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _supplierFirmIdMeta = const VerificationMeta(
    'supplierFirmId',
  );
  @override
  late final GeneratedColumn<int> supplierFirmId = GeneratedColumn<int>(
    'supplier_firm_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES firms (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _clientFirmIdMeta = const VerificationMeta(
    'clientFirmId',
  );
  @override
  late final GeneratedColumn<int> clientFirmId = GeneratedColumn<int>(
    'client_firm_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES client_firms (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _tnNumberMeta = const VerificationMeta(
    'tnNumber',
  );
  @override
  late final GeneratedColumn<String> tnNumber = GeneratedColumn<String>(
    'tn_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billDateMeta = const VerificationMeta(
    'billDate',
  );
  @override
  late final GeneratedColumn<DateTime> billDate = GeneratedColumn<DateTime>(
    'bill_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _invoiceAmountMeta = const VerificationMeta(
    'invoiceAmount',
  );
  @override
  late final GeneratedColumn<double> invoiceAmount = GeneratedColumn<double>(
    'invoice_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _csdAmountMeta = const VerificationMeta(
    'csdAmount',
  );
  @override
  late final GeneratedColumn<double> csdAmount = GeneratedColumn<double>(
    'csd_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _billPassAmountMeta = const VerificationMeta(
    'billPassAmount',
  );
  @override
  late final GeneratedColumn<double> billPassAmount = GeneratedColumn<double>(
    'bill_pass_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _csdReleasedDateMeta = const VerificationMeta(
    'csdReleasedDate',
  );
  @override
  late final GeneratedColumn<DateTime> csdReleasedDate =
      GeneratedColumn<DateTime>(
        'csd_released_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _csdDueDateMeta = const VerificationMeta(
    'csdDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> csdDueDate = GeneratedColumn<DateTime>(
    'csd_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _csdStatusMeta = const VerificationMeta(
    'csdStatus',
  );
  @override
  late final GeneratedColumn<String> csdStatus = GeneratedColumn<String>(
    'csd_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pending'),
  );
  static const VerificationMeta _scrapAmountMeta = const VerificationMeta(
    'scrapAmount',
  );
  @override
  late final GeneratedColumn<double> scrapAmount = GeneratedColumn<double>(
    'scrap_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _scrapGstAmountMeta = const VerificationMeta(
    'scrapGstAmount',
  );
  @override
  late final GeneratedColumn<double> scrapGstAmount = GeneratedColumn<double>(
    'scrap_gst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _mdLdAmountMeta = const VerificationMeta(
    'mdLdAmount',
  );
  @override
  late final GeneratedColumn<double> mdLdAmount = GeneratedColumn<double>(
    'md_ld_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _mdLdStatusMeta = const VerificationMeta(
    'mdLdStatus',
  );
  @override
  late final GeneratedColumn<String> mdLdStatus = GeneratedColumn<String>(
    'md_ld_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pending'),
  );
  static const VerificationMeta _mdLdReleasedDateMeta = const VerificationMeta(
    'mdLdReleasedDate',
  );
  @override
  late final GeneratedColumn<DateTime> mdLdReleasedDate =
      GeneratedColumn<DateTime>(
        'md_ld_released_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _emptyOilIssuedMeta = const VerificationMeta(
    'emptyOilIssued',
  );
  @override
  late final GeneratedColumn<double> emptyOilIssued = GeneratedColumn<double>(
    'empty_oil_issued',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _emptyOilReturnedMeta = const VerificationMeta(
    'emptyOilReturned',
  );
  @override
  late final GeneratedColumn<double> emptyOilReturned = GeneratedColumn<double>(
    'empty_oil_returned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tdsAmountMeta = const VerificationMeta(
    'tdsAmount',
  );
  @override
  late final GeneratedColumn<double> tdsAmount = GeneratedColumn<double>(
    'tds_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tcsAmountMeta = const VerificationMeta(
    'tcsAmount',
  );
  @override
  late final GeneratedColumn<double> tcsAmount = GeneratedColumn<double>(
    'tcs_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _gstTdsAmountMeta = const VerificationMeta(
    'gstTdsAmount',
  );
  @override
  late final GeneratedColumn<double> gstTdsAmount = GeneratedColumn<double>(
    'gst_tds_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalPaidMeta = const VerificationMeta(
    'totalPaid',
  );
  @override
  late final GeneratedColumn<double> totalPaid = GeneratedColumn<double>(
    'total_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dueAmountMeta = const VerificationMeta(
    'dueAmount',
  );
  @override
  late final GeneratedColumn<double> dueAmount = GeneratedColumn<double>(
    'due_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pending'),
  );
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionNoMeta = const VerificationMeta(
    'transactionNo',
  );
  @override
  late final GeneratedColumn<String> transactionNo = GeneratedColumn<String>(
    'transaction_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueReleaseDateMeta = const VerificationMeta(
    'dueReleaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueReleaseDate =
      GeneratedColumn<DateTime>(
        'due_release_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _invoiceNoMeta = const VerificationMeta(
    'invoiceNo',
  );
  @override
  late final GeneratedColumn<String> invoiceNo = GeneratedColumn<String>(
    'invoice_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
    'invoice_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workOrderNoMeta = const VerificationMeta(
    'workOrderNo',
  );
  @override
  late final GeneratedColumn<String> workOrderNo = GeneratedColumn<String>(
    'work_order_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workOrderDateMeta = const VerificationMeta(
    'workOrderDate',
  );
  @override
  late final GeneratedColumn<DateTime> workOrderDate =
      GeneratedColumn<DateTime>(
        'work_order_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _consignmentNameMeta = const VerificationMeta(
    'consignmentName',
  );
  @override
  late final GeneratedColumn<String> consignmentName = GeneratedColumn<String>(
    'consignment_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceTypeMeta = const VerificationMeta(
    'invoiceType',
  );
  @override
  late final GeneratedColumn<String> invoiceType = GeneratedColumn<String>(
    'invoice_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proofPathMeta = const VerificationMeta(
    'proofPath',
  );
  @override
  late final GeneratedColumn<String> proofPath = GeneratedColumn<String>(
    'proof_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenderId,
    firmId,
    supplierFirmId,
    clientFirmId,
    tnNumber,
    billDate,
    dueDate,
    amount,
    invoiceAmount,
    csdAmount,
    billPassAmount,
    csdReleasedDate,
    csdDueDate,
    csdStatus,
    scrapAmount,
    scrapGstAmount,
    mdLdAmount,
    mdLdStatus,
    mdLdReleasedDate,
    emptyOilIssued,
    emptyOilReturned,
    tdsAmount,
    tcsAmount,
    gstTdsAmount,
    totalPaid,
    dueAmount,
    status,
    paidDate,
    transactionNo,
    dueReleaseDate,
    invoiceNo,
    invoiceDate,
    workOrderNo,
    workOrderDate,
    consignmentName,
    invoiceType,
    proofPath,
    remarks,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tender_id')) {
      context.handle(
        _tenderIdMeta,
        tenderId.isAcceptableOrUnknown(data['tender_id']!, _tenderIdMeta),
      );
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('supplier_firm_id')) {
      context.handle(
        _supplierFirmIdMeta,
        supplierFirmId.isAcceptableOrUnknown(
          data['supplier_firm_id']!,
          _supplierFirmIdMeta,
        ),
      );
    }
    if (data.containsKey('client_firm_id')) {
      context.handle(
        _clientFirmIdMeta,
        clientFirmId.isAcceptableOrUnknown(
          data['client_firm_id']!,
          _clientFirmIdMeta,
        ),
      );
    }
    if (data.containsKey('tn_number')) {
      context.handle(
        _tnNumberMeta,
        tnNumber.isAcceptableOrUnknown(data['tn_number']!, _tnNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_tnNumberMeta);
    }
    if (data.containsKey('bill_date')) {
      context.handle(
        _billDateMeta,
        billDate.isAcceptableOrUnknown(data['bill_date']!, _billDateMeta),
      );
    } else if (isInserting) {
      context.missing(_billDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('invoice_amount')) {
      context.handle(
        _invoiceAmountMeta,
        invoiceAmount.isAcceptableOrUnknown(
          data['invoice_amount']!,
          _invoiceAmountMeta,
        ),
      );
    }
    if (data.containsKey('csd_amount')) {
      context.handle(
        _csdAmountMeta,
        csdAmount.isAcceptableOrUnknown(data['csd_amount']!, _csdAmountMeta),
      );
    }
    if (data.containsKey('bill_pass_amount')) {
      context.handle(
        _billPassAmountMeta,
        billPassAmount.isAcceptableOrUnknown(
          data['bill_pass_amount']!,
          _billPassAmountMeta,
        ),
      );
    }
    if (data.containsKey('csd_released_date')) {
      context.handle(
        _csdReleasedDateMeta,
        csdReleasedDate.isAcceptableOrUnknown(
          data['csd_released_date']!,
          _csdReleasedDateMeta,
        ),
      );
    }
    if (data.containsKey('csd_due_date')) {
      context.handle(
        _csdDueDateMeta,
        csdDueDate.isAcceptableOrUnknown(
          data['csd_due_date']!,
          _csdDueDateMeta,
        ),
      );
    }
    if (data.containsKey('csd_status')) {
      context.handle(
        _csdStatusMeta,
        csdStatus.isAcceptableOrUnknown(data['csd_status']!, _csdStatusMeta),
      );
    }
    if (data.containsKey('scrap_amount')) {
      context.handle(
        _scrapAmountMeta,
        scrapAmount.isAcceptableOrUnknown(
          data['scrap_amount']!,
          _scrapAmountMeta,
        ),
      );
    }
    if (data.containsKey('scrap_gst_amount')) {
      context.handle(
        _scrapGstAmountMeta,
        scrapGstAmount.isAcceptableOrUnknown(
          data['scrap_gst_amount']!,
          _scrapGstAmountMeta,
        ),
      );
    }
    if (data.containsKey('md_ld_amount')) {
      context.handle(
        _mdLdAmountMeta,
        mdLdAmount.isAcceptableOrUnknown(
          data['md_ld_amount']!,
          _mdLdAmountMeta,
        ),
      );
    }
    if (data.containsKey('md_ld_status')) {
      context.handle(
        _mdLdStatusMeta,
        mdLdStatus.isAcceptableOrUnknown(
          data['md_ld_status']!,
          _mdLdStatusMeta,
        ),
      );
    }
    if (data.containsKey('md_ld_released_date')) {
      context.handle(
        _mdLdReleasedDateMeta,
        mdLdReleasedDate.isAcceptableOrUnknown(
          data['md_ld_released_date']!,
          _mdLdReleasedDateMeta,
        ),
      );
    }
    if (data.containsKey('empty_oil_issued')) {
      context.handle(
        _emptyOilIssuedMeta,
        emptyOilIssued.isAcceptableOrUnknown(
          data['empty_oil_issued']!,
          _emptyOilIssuedMeta,
        ),
      );
    }
    if (data.containsKey('empty_oil_returned')) {
      context.handle(
        _emptyOilReturnedMeta,
        emptyOilReturned.isAcceptableOrUnknown(
          data['empty_oil_returned']!,
          _emptyOilReturnedMeta,
        ),
      );
    }
    if (data.containsKey('tds_amount')) {
      context.handle(
        _tdsAmountMeta,
        tdsAmount.isAcceptableOrUnknown(data['tds_amount']!, _tdsAmountMeta),
      );
    }
    if (data.containsKey('tcs_amount')) {
      context.handle(
        _tcsAmountMeta,
        tcsAmount.isAcceptableOrUnknown(data['tcs_amount']!, _tcsAmountMeta),
      );
    }
    if (data.containsKey('gst_tds_amount')) {
      context.handle(
        _gstTdsAmountMeta,
        gstTdsAmount.isAcceptableOrUnknown(
          data['gst_tds_amount']!,
          _gstTdsAmountMeta,
        ),
      );
    }
    if (data.containsKey('total_paid')) {
      context.handle(
        _totalPaidMeta,
        totalPaid.isAcceptableOrUnknown(data['total_paid']!, _totalPaidMeta),
      );
    }
    if (data.containsKey('due_amount')) {
      context.handle(
        _dueAmountMeta,
        dueAmount.isAcceptableOrUnknown(data['due_amount']!, _dueAmountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
      );
    }
    if (data.containsKey('transaction_no')) {
      context.handle(
        _transactionNoMeta,
        transactionNo.isAcceptableOrUnknown(
          data['transaction_no']!,
          _transactionNoMeta,
        ),
      );
    }
    if (data.containsKey('due_release_date')) {
      context.handle(
        _dueReleaseDateMeta,
        dueReleaseDate.isAcceptableOrUnknown(
          data['due_release_date']!,
          _dueReleaseDateMeta,
        ),
      );
    }
    if (data.containsKey('invoice_no')) {
      context.handle(
        _invoiceNoMeta,
        invoiceNo.isAcceptableOrUnknown(data['invoice_no']!, _invoiceNoMeta),
      );
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    }
    if (data.containsKey('work_order_no')) {
      context.handle(
        _workOrderNoMeta,
        workOrderNo.isAcceptableOrUnknown(
          data['work_order_no']!,
          _workOrderNoMeta,
        ),
      );
    }
    if (data.containsKey('work_order_date')) {
      context.handle(
        _workOrderDateMeta,
        workOrderDate.isAcceptableOrUnknown(
          data['work_order_date']!,
          _workOrderDateMeta,
        ),
      );
    }
    if (data.containsKey('consignment_name')) {
      context.handle(
        _consignmentNameMeta,
        consignmentName.isAcceptableOrUnknown(
          data['consignment_name']!,
          _consignmentNameMeta,
        ),
      );
    }
    if (data.containsKey('invoice_type')) {
      context.handle(
        _invoiceTypeMeta,
        invoiceType.isAcceptableOrUnknown(
          data['invoice_type']!,
          _invoiceTypeMeta,
        ),
      );
    }
    if (data.containsKey('proof_path')) {
      context.handle(
        _proofPathMeta,
        proofPath.isAcceptableOrUnknown(data['proof_path']!, _proofPathMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bill(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      tenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tender_id'],
      ),
      firmId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}firm_id'],
          )!,
      supplierFirmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supplier_firm_id'],
      ),
      clientFirmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_firm_id'],
      ),
      tnNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tn_number'],
          )!,
      billDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}bill_date'],
          )!,
      dueDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}due_date'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      invoiceAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}invoice_amount'],
          )!,
      csdAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}csd_amount'],
          )!,
      billPassAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}bill_pass_amount'],
          )!,
      csdReleasedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}csd_released_date'],
      ),
      csdDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}csd_due_date'],
      ),
      csdStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}csd_status'],
          )!,
      scrapAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}scrap_amount'],
          )!,
      scrapGstAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}scrap_gst_amount'],
          )!,
      mdLdAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}md_ld_amount'],
          )!,
      mdLdStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}md_ld_status'],
          )!,
      mdLdReleasedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}md_ld_released_date'],
      ),
      emptyOilIssued:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}empty_oil_issued'],
          )!,
      emptyOilReturned:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}empty_oil_returned'],
          )!,
      tdsAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}tds_amount'],
          )!,
      tcsAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}tcs_amount'],
          )!,
      gstTdsAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}gst_tds_amount'],
          )!,
      totalPaid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}total_paid'],
          )!,
      dueAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}due_amount'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      ),
      transactionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_no'],
      ),
      dueReleaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_release_date'],
      ),
      invoiceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_no'],
      ),
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invoice_date'],
      ),
      workOrderNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_order_no'],
      ),
      workOrderDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}work_order_date'],
      ),
      consignmentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consignment_name'],
      ),
      invoiceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_type'],
      ),
      proofPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proof_path'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class Bill extends DataClass implements Insertable<Bill> {
  final int id;
  final int? tenderId;
  final int firmId;
  final int? supplierFirmId;
  final int? clientFirmId;
  final String tnNumber;
  final DateTime billDate;
  final DateTime dueDate;
  final double amount;
  final double invoiceAmount;
  final double csdAmount;
  final double billPassAmount;
  final DateTime? csdReleasedDate;
  final DateTime? csdDueDate;
  final String csdStatus;
  final double scrapAmount;
  final double scrapGstAmount;
  final double mdLdAmount;
  final String mdLdStatus;
  final DateTime? mdLdReleasedDate;
  final double emptyOilIssued;
  final double emptyOilReturned;
  final double tdsAmount;
  final double tcsAmount;
  final double gstTdsAmount;
  final double totalPaid;
  final double dueAmount;
  final String status;
  final DateTime? paidDate;
  final String? transactionNo;
  final DateTime? dueReleaseDate;
  final String? invoiceNo;
  final DateTime? invoiceDate;
  final String? workOrderNo;
  final DateTime? workOrderDate;
  final String? consignmentName;
  final String? invoiceType;
  final String? proofPath;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Bill({
    required this.id,
    this.tenderId,
    required this.firmId,
    this.supplierFirmId,
    this.clientFirmId,
    required this.tnNumber,
    required this.billDate,
    required this.dueDate,
    required this.amount,
    required this.invoiceAmount,
    required this.csdAmount,
    required this.billPassAmount,
    this.csdReleasedDate,
    this.csdDueDate,
    required this.csdStatus,
    required this.scrapAmount,
    required this.scrapGstAmount,
    required this.mdLdAmount,
    required this.mdLdStatus,
    this.mdLdReleasedDate,
    required this.emptyOilIssued,
    required this.emptyOilReturned,
    required this.tdsAmount,
    required this.tcsAmount,
    required this.gstTdsAmount,
    required this.totalPaid,
    required this.dueAmount,
    required this.status,
    this.paidDate,
    this.transactionNo,
    this.dueReleaseDate,
    this.invoiceNo,
    this.invoiceDate,
    this.workOrderNo,
    this.workOrderDate,
    this.consignmentName,
    this.invoiceType,
    this.proofPath,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tenderId != null) {
      map['tender_id'] = Variable<int>(tenderId);
    }
    map['firm_id'] = Variable<int>(firmId);
    if (!nullToAbsent || supplierFirmId != null) {
      map['supplier_firm_id'] = Variable<int>(supplierFirmId);
    }
    if (!nullToAbsent || clientFirmId != null) {
      map['client_firm_id'] = Variable<int>(clientFirmId);
    }
    map['tn_number'] = Variable<String>(tnNumber);
    map['bill_date'] = Variable<DateTime>(billDate);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['amount'] = Variable<double>(amount);
    map['invoice_amount'] = Variable<double>(invoiceAmount);
    map['csd_amount'] = Variable<double>(csdAmount);
    map['bill_pass_amount'] = Variable<double>(billPassAmount);
    if (!nullToAbsent || csdReleasedDate != null) {
      map['csd_released_date'] = Variable<DateTime>(csdReleasedDate);
    }
    if (!nullToAbsent || csdDueDate != null) {
      map['csd_due_date'] = Variable<DateTime>(csdDueDate);
    }
    map['csd_status'] = Variable<String>(csdStatus);
    map['scrap_amount'] = Variable<double>(scrapAmount);
    map['scrap_gst_amount'] = Variable<double>(scrapGstAmount);
    map['md_ld_amount'] = Variable<double>(mdLdAmount);
    map['md_ld_status'] = Variable<String>(mdLdStatus);
    if (!nullToAbsent || mdLdReleasedDate != null) {
      map['md_ld_released_date'] = Variable<DateTime>(mdLdReleasedDate);
    }
    map['empty_oil_issued'] = Variable<double>(emptyOilIssued);
    map['empty_oil_returned'] = Variable<double>(emptyOilReturned);
    map['tds_amount'] = Variable<double>(tdsAmount);
    map['tcs_amount'] = Variable<double>(tcsAmount);
    map['gst_tds_amount'] = Variable<double>(gstTdsAmount);
    map['total_paid'] = Variable<double>(totalPaid);
    map['due_amount'] = Variable<double>(dueAmount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    if (!nullToAbsent || transactionNo != null) {
      map['transaction_no'] = Variable<String>(transactionNo);
    }
    if (!nullToAbsent || dueReleaseDate != null) {
      map['due_release_date'] = Variable<DateTime>(dueReleaseDate);
    }
    if (!nullToAbsent || invoiceNo != null) {
      map['invoice_no'] = Variable<String>(invoiceNo);
    }
    if (!nullToAbsent || invoiceDate != null) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate);
    }
    if (!nullToAbsent || workOrderNo != null) {
      map['work_order_no'] = Variable<String>(workOrderNo);
    }
    if (!nullToAbsent || workOrderDate != null) {
      map['work_order_date'] = Variable<DateTime>(workOrderDate);
    }
    if (!nullToAbsent || consignmentName != null) {
      map['consignment_name'] = Variable<String>(consignmentName);
    }
    if (!nullToAbsent || invoiceType != null) {
      map['invoice_type'] = Variable<String>(invoiceType);
    }
    if (!nullToAbsent || proofPath != null) {
      map['proof_path'] = Variable<String>(proofPath);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      tenderId:
          tenderId == null && nullToAbsent
              ? const Value.absent()
              : Value(tenderId),
      firmId: Value(firmId),
      supplierFirmId:
          supplierFirmId == null && nullToAbsent
              ? const Value.absent()
              : Value(supplierFirmId),
      clientFirmId:
          clientFirmId == null && nullToAbsent
              ? const Value.absent()
              : Value(clientFirmId),
      tnNumber: Value(tnNumber),
      billDate: Value(billDate),
      dueDate: Value(dueDate),
      amount: Value(amount),
      invoiceAmount: Value(invoiceAmount),
      csdAmount: Value(csdAmount),
      billPassAmount: Value(billPassAmount),
      csdReleasedDate:
          csdReleasedDate == null && nullToAbsent
              ? const Value.absent()
              : Value(csdReleasedDate),
      csdDueDate:
          csdDueDate == null && nullToAbsent
              ? const Value.absent()
              : Value(csdDueDate),
      csdStatus: Value(csdStatus),
      scrapAmount: Value(scrapAmount),
      scrapGstAmount: Value(scrapGstAmount),
      mdLdAmount: Value(mdLdAmount),
      mdLdStatus: Value(mdLdStatus),
      mdLdReleasedDate:
          mdLdReleasedDate == null && nullToAbsent
              ? const Value.absent()
              : Value(mdLdReleasedDate),
      emptyOilIssued: Value(emptyOilIssued),
      emptyOilReturned: Value(emptyOilReturned),
      tdsAmount: Value(tdsAmount),
      tcsAmount: Value(tcsAmount),
      gstTdsAmount: Value(gstTdsAmount),
      totalPaid: Value(totalPaid),
      dueAmount: Value(dueAmount),
      status: Value(status),
      paidDate:
          paidDate == null && nullToAbsent
              ? const Value.absent()
              : Value(paidDate),
      transactionNo:
          transactionNo == null && nullToAbsent
              ? const Value.absent()
              : Value(transactionNo),
      dueReleaseDate:
          dueReleaseDate == null && nullToAbsent
              ? const Value.absent()
              : Value(dueReleaseDate),
      invoiceNo:
          invoiceNo == null && nullToAbsent
              ? const Value.absent()
              : Value(invoiceNo),
      invoiceDate:
          invoiceDate == null && nullToAbsent
              ? const Value.absent()
              : Value(invoiceDate),
      workOrderNo:
          workOrderNo == null && nullToAbsent
              ? const Value.absent()
              : Value(workOrderNo),
      workOrderDate:
          workOrderDate == null && nullToAbsent
              ? const Value.absent()
              : Value(workOrderDate),
      consignmentName:
          consignmentName == null && nullToAbsent
              ? const Value.absent()
              : Value(consignmentName),
      invoiceType:
          invoiceType == null && nullToAbsent
              ? const Value.absent()
              : Value(invoiceType),
      proofPath:
          proofPath == null && nullToAbsent
              ? const Value.absent()
              : Value(proofPath),
      remarks:
          remarks == null && nullToAbsent
              ? const Value.absent()
              : Value(remarks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Bill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bill(
      id: serializer.fromJson<int>(json['id']),
      tenderId: serializer.fromJson<int?>(json['tenderId']),
      firmId: serializer.fromJson<int>(json['firmId']),
      supplierFirmId: serializer.fromJson<int?>(json['supplierFirmId']),
      clientFirmId: serializer.fromJson<int?>(json['clientFirmId']),
      tnNumber: serializer.fromJson<String>(json['tnNumber']),
      billDate: serializer.fromJson<DateTime>(json['billDate']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      amount: serializer.fromJson<double>(json['amount']),
      invoiceAmount: serializer.fromJson<double>(json['invoiceAmount']),
      csdAmount: serializer.fromJson<double>(json['csdAmount']),
      billPassAmount: serializer.fromJson<double>(json['billPassAmount']),
      csdReleasedDate: serializer.fromJson<DateTime?>(json['csdReleasedDate']),
      csdDueDate: serializer.fromJson<DateTime?>(json['csdDueDate']),
      csdStatus: serializer.fromJson<String>(json['csdStatus']),
      scrapAmount: serializer.fromJson<double>(json['scrapAmount']),
      scrapGstAmount: serializer.fromJson<double>(json['scrapGstAmount']),
      mdLdAmount: serializer.fromJson<double>(json['mdLdAmount']),
      mdLdStatus: serializer.fromJson<String>(json['mdLdStatus']),
      mdLdReleasedDate: serializer.fromJson<DateTime?>(
        json['mdLdReleasedDate'],
      ),
      emptyOilIssued: serializer.fromJson<double>(json['emptyOilIssued']),
      emptyOilReturned: serializer.fromJson<double>(json['emptyOilReturned']),
      tdsAmount: serializer.fromJson<double>(json['tdsAmount']),
      tcsAmount: serializer.fromJson<double>(json['tcsAmount']),
      gstTdsAmount: serializer.fromJson<double>(json['gstTdsAmount']),
      totalPaid: serializer.fromJson<double>(json['totalPaid']),
      dueAmount: serializer.fromJson<double>(json['dueAmount']),
      status: serializer.fromJson<String>(json['status']),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      transactionNo: serializer.fromJson<String?>(json['transactionNo']),
      dueReleaseDate: serializer.fromJson<DateTime?>(json['dueReleaseDate']),
      invoiceNo: serializer.fromJson<String?>(json['invoiceNo']),
      invoiceDate: serializer.fromJson<DateTime?>(json['invoiceDate']),
      workOrderNo: serializer.fromJson<String?>(json['workOrderNo']),
      workOrderDate: serializer.fromJson<DateTime?>(json['workOrderDate']),
      consignmentName: serializer.fromJson<String?>(json['consignmentName']),
      invoiceType: serializer.fromJson<String?>(json['invoiceType']),
      proofPath: serializer.fromJson<String?>(json['proofPath']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tenderId': serializer.toJson<int?>(tenderId),
      'firmId': serializer.toJson<int>(firmId),
      'supplierFirmId': serializer.toJson<int?>(supplierFirmId),
      'clientFirmId': serializer.toJson<int?>(clientFirmId),
      'tnNumber': serializer.toJson<String>(tnNumber),
      'billDate': serializer.toJson<DateTime>(billDate),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'amount': serializer.toJson<double>(amount),
      'invoiceAmount': serializer.toJson<double>(invoiceAmount),
      'csdAmount': serializer.toJson<double>(csdAmount),
      'billPassAmount': serializer.toJson<double>(billPassAmount),
      'csdReleasedDate': serializer.toJson<DateTime?>(csdReleasedDate),
      'csdDueDate': serializer.toJson<DateTime?>(csdDueDate),
      'csdStatus': serializer.toJson<String>(csdStatus),
      'scrapAmount': serializer.toJson<double>(scrapAmount),
      'scrapGstAmount': serializer.toJson<double>(scrapGstAmount),
      'mdLdAmount': serializer.toJson<double>(mdLdAmount),
      'mdLdStatus': serializer.toJson<String>(mdLdStatus),
      'mdLdReleasedDate': serializer.toJson<DateTime?>(mdLdReleasedDate),
      'emptyOilIssued': serializer.toJson<double>(emptyOilIssued),
      'emptyOilReturned': serializer.toJson<double>(emptyOilReturned),
      'tdsAmount': serializer.toJson<double>(tdsAmount),
      'tcsAmount': serializer.toJson<double>(tcsAmount),
      'gstTdsAmount': serializer.toJson<double>(gstTdsAmount),
      'totalPaid': serializer.toJson<double>(totalPaid),
      'dueAmount': serializer.toJson<double>(dueAmount),
      'status': serializer.toJson<String>(status),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'transactionNo': serializer.toJson<String?>(transactionNo),
      'dueReleaseDate': serializer.toJson<DateTime?>(dueReleaseDate),
      'invoiceNo': serializer.toJson<String?>(invoiceNo),
      'invoiceDate': serializer.toJson<DateTime?>(invoiceDate),
      'workOrderNo': serializer.toJson<String?>(workOrderNo),
      'workOrderDate': serializer.toJson<DateTime?>(workOrderDate),
      'consignmentName': serializer.toJson<String?>(consignmentName),
      'invoiceType': serializer.toJson<String?>(invoiceType),
      'proofPath': serializer.toJson<String?>(proofPath),
      'remarks': serializer.toJson<String?>(remarks),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Bill copyWith({
    int? id,
    Value<int?> tenderId = const Value.absent(),
    int? firmId,
    Value<int?> supplierFirmId = const Value.absent(),
    Value<int?> clientFirmId = const Value.absent(),
    String? tnNumber,
    DateTime? billDate,
    DateTime? dueDate,
    double? amount,
    double? invoiceAmount,
    double? csdAmount,
    double? billPassAmount,
    Value<DateTime?> csdReleasedDate = const Value.absent(),
    Value<DateTime?> csdDueDate = const Value.absent(),
    String? csdStatus,
    double? scrapAmount,
    double? scrapGstAmount,
    double? mdLdAmount,
    String? mdLdStatus,
    Value<DateTime?> mdLdReleasedDate = const Value.absent(),
    double? emptyOilIssued,
    double? emptyOilReturned,
    double? tdsAmount,
    double? tcsAmount,
    double? gstTdsAmount,
    double? totalPaid,
    double? dueAmount,
    String? status,
    Value<DateTime?> paidDate = const Value.absent(),
    Value<String?> transactionNo = const Value.absent(),
    Value<DateTime?> dueReleaseDate = const Value.absent(),
    Value<String?> invoiceNo = const Value.absent(),
    Value<DateTime?> invoiceDate = const Value.absent(),
    Value<String?> workOrderNo = const Value.absent(),
    Value<DateTime?> workOrderDate = const Value.absent(),
    Value<String?> consignmentName = const Value.absent(),
    Value<String?> invoiceType = const Value.absent(),
    Value<String?> proofPath = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Bill(
    id: id ?? this.id,
    tenderId: tenderId.present ? tenderId.value : this.tenderId,
    firmId: firmId ?? this.firmId,
    supplierFirmId:
        supplierFirmId.present ? supplierFirmId.value : this.supplierFirmId,
    clientFirmId: clientFirmId.present ? clientFirmId.value : this.clientFirmId,
    tnNumber: tnNumber ?? this.tnNumber,
    billDate: billDate ?? this.billDate,
    dueDate: dueDate ?? this.dueDate,
    amount: amount ?? this.amount,
    invoiceAmount: invoiceAmount ?? this.invoiceAmount,
    csdAmount: csdAmount ?? this.csdAmount,
    billPassAmount: billPassAmount ?? this.billPassAmount,
    csdReleasedDate:
        csdReleasedDate.present ? csdReleasedDate.value : this.csdReleasedDate,
    csdDueDate: csdDueDate.present ? csdDueDate.value : this.csdDueDate,
    csdStatus: csdStatus ?? this.csdStatus,
    scrapAmount: scrapAmount ?? this.scrapAmount,
    scrapGstAmount: scrapGstAmount ?? this.scrapGstAmount,
    mdLdAmount: mdLdAmount ?? this.mdLdAmount,
    mdLdStatus: mdLdStatus ?? this.mdLdStatus,
    mdLdReleasedDate:
        mdLdReleasedDate.present
            ? mdLdReleasedDate.value
            : this.mdLdReleasedDate,
    emptyOilIssued: emptyOilIssued ?? this.emptyOilIssued,
    emptyOilReturned: emptyOilReturned ?? this.emptyOilReturned,
    tdsAmount: tdsAmount ?? this.tdsAmount,
    tcsAmount: tcsAmount ?? this.tcsAmount,
    gstTdsAmount: gstTdsAmount ?? this.gstTdsAmount,
    totalPaid: totalPaid ?? this.totalPaid,
    dueAmount: dueAmount ?? this.dueAmount,
    status: status ?? this.status,
    paidDate: paidDate.present ? paidDate.value : this.paidDate,
    transactionNo:
        transactionNo.present ? transactionNo.value : this.transactionNo,
    dueReleaseDate:
        dueReleaseDate.present ? dueReleaseDate.value : this.dueReleaseDate,
    invoiceNo: invoiceNo.present ? invoiceNo.value : this.invoiceNo,
    invoiceDate: invoiceDate.present ? invoiceDate.value : this.invoiceDate,
    workOrderNo: workOrderNo.present ? workOrderNo.value : this.workOrderNo,
    workOrderDate:
        workOrderDate.present ? workOrderDate.value : this.workOrderDate,
    consignmentName:
        consignmentName.present ? consignmentName.value : this.consignmentName,
    invoiceType: invoiceType.present ? invoiceType.value : this.invoiceType,
    proofPath: proofPath.present ? proofPath.value : this.proofPath,
    remarks: remarks.present ? remarks.value : this.remarks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Bill copyWithCompanion(BillsCompanion data) {
    return Bill(
      id: data.id.present ? data.id.value : this.id,
      tenderId: data.tenderId.present ? data.tenderId.value : this.tenderId,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      supplierFirmId:
          data.supplierFirmId.present
              ? data.supplierFirmId.value
              : this.supplierFirmId,
      clientFirmId:
          data.clientFirmId.present
              ? data.clientFirmId.value
              : this.clientFirmId,
      tnNumber: data.tnNumber.present ? data.tnNumber.value : this.tnNumber,
      billDate: data.billDate.present ? data.billDate.value : this.billDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      invoiceAmount:
          data.invoiceAmount.present
              ? data.invoiceAmount.value
              : this.invoiceAmount,
      csdAmount: data.csdAmount.present ? data.csdAmount.value : this.csdAmount,
      billPassAmount:
          data.billPassAmount.present
              ? data.billPassAmount.value
              : this.billPassAmount,
      csdReleasedDate:
          data.csdReleasedDate.present
              ? data.csdReleasedDate.value
              : this.csdReleasedDate,
      csdDueDate:
          data.csdDueDate.present ? data.csdDueDate.value : this.csdDueDate,
      csdStatus: data.csdStatus.present ? data.csdStatus.value : this.csdStatus,
      scrapAmount:
          data.scrapAmount.present ? data.scrapAmount.value : this.scrapAmount,
      scrapGstAmount:
          data.scrapGstAmount.present
              ? data.scrapGstAmount.value
              : this.scrapGstAmount,
      mdLdAmount:
          data.mdLdAmount.present ? data.mdLdAmount.value : this.mdLdAmount,
      mdLdStatus:
          data.mdLdStatus.present ? data.mdLdStatus.value : this.mdLdStatus,
      mdLdReleasedDate:
          data.mdLdReleasedDate.present
              ? data.mdLdReleasedDate.value
              : this.mdLdReleasedDate,
      emptyOilIssued:
          data.emptyOilIssued.present
              ? data.emptyOilIssued.value
              : this.emptyOilIssued,
      emptyOilReturned:
          data.emptyOilReturned.present
              ? data.emptyOilReturned.value
              : this.emptyOilReturned,
      tdsAmount: data.tdsAmount.present ? data.tdsAmount.value : this.tdsAmount,
      tcsAmount: data.tcsAmount.present ? data.tcsAmount.value : this.tcsAmount,
      gstTdsAmount:
          data.gstTdsAmount.present
              ? data.gstTdsAmount.value
              : this.gstTdsAmount,
      totalPaid: data.totalPaid.present ? data.totalPaid.value : this.totalPaid,
      dueAmount: data.dueAmount.present ? data.dueAmount.value : this.dueAmount,
      status: data.status.present ? data.status.value : this.status,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      transactionNo:
          data.transactionNo.present
              ? data.transactionNo.value
              : this.transactionNo,
      dueReleaseDate:
          data.dueReleaseDate.present
              ? data.dueReleaseDate.value
              : this.dueReleaseDate,
      invoiceNo: data.invoiceNo.present ? data.invoiceNo.value : this.invoiceNo,
      invoiceDate:
          data.invoiceDate.present ? data.invoiceDate.value : this.invoiceDate,
      workOrderNo:
          data.workOrderNo.present ? data.workOrderNo.value : this.workOrderNo,
      workOrderDate:
          data.workOrderDate.present
              ? data.workOrderDate.value
              : this.workOrderDate,
      consignmentName:
          data.consignmentName.present
              ? data.consignmentName.value
              : this.consignmentName,
      invoiceType:
          data.invoiceType.present ? data.invoiceType.value : this.invoiceType,
      proofPath: data.proofPath.present ? data.proofPath.value : this.proofPath,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bill(')
          ..write('id: $id, ')
          ..write('tenderId: $tenderId, ')
          ..write('firmId: $firmId, ')
          ..write('supplierFirmId: $supplierFirmId, ')
          ..write('clientFirmId: $clientFirmId, ')
          ..write('tnNumber: $tnNumber, ')
          ..write('billDate: $billDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('invoiceAmount: $invoiceAmount, ')
          ..write('csdAmount: $csdAmount, ')
          ..write('billPassAmount: $billPassAmount, ')
          ..write('csdReleasedDate: $csdReleasedDate, ')
          ..write('csdDueDate: $csdDueDate, ')
          ..write('csdStatus: $csdStatus, ')
          ..write('scrapAmount: $scrapAmount, ')
          ..write('scrapGstAmount: $scrapGstAmount, ')
          ..write('mdLdAmount: $mdLdAmount, ')
          ..write('mdLdStatus: $mdLdStatus, ')
          ..write('mdLdReleasedDate: $mdLdReleasedDate, ')
          ..write('emptyOilIssued: $emptyOilIssued, ')
          ..write('emptyOilReturned: $emptyOilReturned, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('tcsAmount: $tcsAmount, ')
          ..write('gstTdsAmount: $gstTdsAmount, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('dueAmount: $dueAmount, ')
          ..write('status: $status, ')
          ..write('paidDate: $paidDate, ')
          ..write('transactionNo: $transactionNo, ')
          ..write('dueReleaseDate: $dueReleaseDate, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('workOrderNo: $workOrderNo, ')
          ..write('workOrderDate: $workOrderDate, ')
          ..write('consignmentName: $consignmentName, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('proofPath: $proofPath, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    tenderId,
    firmId,
    supplierFirmId,
    clientFirmId,
    tnNumber,
    billDate,
    dueDate,
    amount,
    invoiceAmount,
    csdAmount,
    billPassAmount,
    csdReleasedDate,
    csdDueDate,
    csdStatus,
    scrapAmount,
    scrapGstAmount,
    mdLdAmount,
    mdLdStatus,
    mdLdReleasedDate,
    emptyOilIssued,
    emptyOilReturned,
    tdsAmount,
    tcsAmount,
    gstTdsAmount,
    totalPaid,
    dueAmount,
    status,
    paidDate,
    transactionNo,
    dueReleaseDate,
    invoiceNo,
    invoiceDate,
    workOrderNo,
    workOrderDate,
    consignmentName,
    invoiceType,
    proofPath,
    remarks,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill &&
          other.id == this.id &&
          other.tenderId == this.tenderId &&
          other.firmId == this.firmId &&
          other.supplierFirmId == this.supplierFirmId &&
          other.clientFirmId == this.clientFirmId &&
          other.tnNumber == this.tnNumber &&
          other.billDate == this.billDate &&
          other.dueDate == this.dueDate &&
          other.amount == this.amount &&
          other.invoiceAmount == this.invoiceAmount &&
          other.csdAmount == this.csdAmount &&
          other.billPassAmount == this.billPassAmount &&
          other.csdReleasedDate == this.csdReleasedDate &&
          other.csdDueDate == this.csdDueDate &&
          other.csdStatus == this.csdStatus &&
          other.scrapAmount == this.scrapAmount &&
          other.scrapGstAmount == this.scrapGstAmount &&
          other.mdLdAmount == this.mdLdAmount &&
          other.mdLdStatus == this.mdLdStatus &&
          other.mdLdReleasedDate == this.mdLdReleasedDate &&
          other.emptyOilIssued == this.emptyOilIssued &&
          other.emptyOilReturned == this.emptyOilReturned &&
          other.tdsAmount == this.tdsAmount &&
          other.tcsAmount == this.tcsAmount &&
          other.gstTdsAmount == this.gstTdsAmount &&
          other.totalPaid == this.totalPaid &&
          other.dueAmount == this.dueAmount &&
          other.status == this.status &&
          other.paidDate == this.paidDate &&
          other.transactionNo == this.transactionNo &&
          other.dueReleaseDate == this.dueReleaseDate &&
          other.invoiceNo == this.invoiceNo &&
          other.invoiceDate == this.invoiceDate &&
          other.workOrderNo == this.workOrderNo &&
          other.workOrderDate == this.workOrderDate &&
          other.consignmentName == this.consignmentName &&
          other.invoiceType == this.invoiceType &&
          other.proofPath == this.proofPath &&
          other.remarks == this.remarks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BillsCompanion extends UpdateCompanion<Bill> {
  final Value<int> id;
  final Value<int?> tenderId;
  final Value<int> firmId;
  final Value<int?> supplierFirmId;
  final Value<int?> clientFirmId;
  final Value<String> tnNumber;
  final Value<DateTime> billDate;
  final Value<DateTime> dueDate;
  final Value<double> amount;
  final Value<double> invoiceAmount;
  final Value<double> csdAmount;
  final Value<double> billPassAmount;
  final Value<DateTime?> csdReleasedDate;
  final Value<DateTime?> csdDueDate;
  final Value<String> csdStatus;
  final Value<double> scrapAmount;
  final Value<double> scrapGstAmount;
  final Value<double> mdLdAmount;
  final Value<String> mdLdStatus;
  final Value<DateTime?> mdLdReleasedDate;
  final Value<double> emptyOilIssued;
  final Value<double> emptyOilReturned;
  final Value<double> tdsAmount;
  final Value<double> tcsAmount;
  final Value<double> gstTdsAmount;
  final Value<double> totalPaid;
  final Value<double> dueAmount;
  final Value<String> status;
  final Value<DateTime?> paidDate;
  final Value<String?> transactionNo;
  final Value<DateTime?> dueReleaseDate;
  final Value<String?> invoiceNo;
  final Value<DateTime?> invoiceDate;
  final Value<String?> workOrderNo;
  final Value<DateTime?> workOrderDate;
  final Value<String?> consignmentName;
  final Value<String?> invoiceType;
  final Value<String?> proofPath;
  final Value<String?> remarks;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.tenderId = const Value.absent(),
    this.firmId = const Value.absent(),
    this.supplierFirmId = const Value.absent(),
    this.clientFirmId = const Value.absent(),
    this.tnNumber = const Value.absent(),
    this.billDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.invoiceAmount = const Value.absent(),
    this.csdAmount = const Value.absent(),
    this.billPassAmount = const Value.absent(),
    this.csdReleasedDate = const Value.absent(),
    this.csdDueDate = const Value.absent(),
    this.csdStatus = const Value.absent(),
    this.scrapAmount = const Value.absent(),
    this.scrapGstAmount = const Value.absent(),
    this.mdLdAmount = const Value.absent(),
    this.mdLdStatus = const Value.absent(),
    this.mdLdReleasedDate = const Value.absent(),
    this.emptyOilIssued = const Value.absent(),
    this.emptyOilReturned = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.tcsAmount = const Value.absent(),
    this.gstTdsAmount = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.dueAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.transactionNo = const Value.absent(),
    this.dueReleaseDate = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.workOrderNo = const Value.absent(),
    this.workOrderDate = const Value.absent(),
    this.consignmentName = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.proofPath = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BillsCompanion.insert({
    this.id = const Value.absent(),
    this.tenderId = const Value.absent(),
    required int firmId,
    this.supplierFirmId = const Value.absent(),
    this.clientFirmId = const Value.absent(),
    required String tnNumber,
    required DateTime billDate,
    required DateTime dueDate,
    this.amount = const Value.absent(),
    this.invoiceAmount = const Value.absent(),
    this.csdAmount = const Value.absent(),
    this.billPassAmount = const Value.absent(),
    this.csdReleasedDate = const Value.absent(),
    this.csdDueDate = const Value.absent(),
    this.csdStatus = const Value.absent(),
    this.scrapAmount = const Value.absent(),
    this.scrapGstAmount = const Value.absent(),
    this.mdLdAmount = const Value.absent(),
    this.mdLdStatus = const Value.absent(),
    this.mdLdReleasedDate = const Value.absent(),
    this.emptyOilIssued = const Value.absent(),
    this.emptyOilReturned = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.tcsAmount = const Value.absent(),
    this.gstTdsAmount = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.dueAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.transactionNo = const Value.absent(),
    this.dueReleaseDate = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.workOrderNo = const Value.absent(),
    this.workOrderDate = const Value.absent(),
    this.consignmentName = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.proofPath = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : firmId = Value(firmId),
       tnNumber = Value(tnNumber),
       billDate = Value(billDate),
       dueDate = Value(dueDate);
  static Insertable<Bill> custom({
    Expression<int>? id,
    Expression<int>? tenderId,
    Expression<int>? firmId,
    Expression<int>? supplierFirmId,
    Expression<int>? clientFirmId,
    Expression<String>? tnNumber,
    Expression<DateTime>? billDate,
    Expression<DateTime>? dueDate,
    Expression<double>? amount,
    Expression<double>? invoiceAmount,
    Expression<double>? csdAmount,
    Expression<double>? billPassAmount,
    Expression<DateTime>? csdReleasedDate,
    Expression<DateTime>? csdDueDate,
    Expression<String>? csdStatus,
    Expression<double>? scrapAmount,
    Expression<double>? scrapGstAmount,
    Expression<double>? mdLdAmount,
    Expression<String>? mdLdStatus,
    Expression<DateTime>? mdLdReleasedDate,
    Expression<double>? emptyOilIssued,
    Expression<double>? emptyOilReturned,
    Expression<double>? tdsAmount,
    Expression<double>? tcsAmount,
    Expression<double>? gstTdsAmount,
    Expression<double>? totalPaid,
    Expression<double>? dueAmount,
    Expression<String>? status,
    Expression<DateTime>? paidDate,
    Expression<String>? transactionNo,
    Expression<DateTime>? dueReleaseDate,
    Expression<String>? invoiceNo,
    Expression<DateTime>? invoiceDate,
    Expression<String>? workOrderNo,
    Expression<DateTime>? workOrderDate,
    Expression<String>? consignmentName,
    Expression<String>? invoiceType,
    Expression<String>? proofPath,
    Expression<String>? remarks,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenderId != null) 'tender_id': tenderId,
      if (firmId != null) 'firm_id': firmId,
      if (supplierFirmId != null) 'supplier_firm_id': supplierFirmId,
      if (clientFirmId != null) 'client_firm_id': clientFirmId,
      if (tnNumber != null) 'tn_number': tnNumber,
      if (billDate != null) 'bill_date': billDate,
      if (dueDate != null) 'due_date': dueDate,
      if (amount != null) 'amount': amount,
      if (invoiceAmount != null) 'invoice_amount': invoiceAmount,
      if (csdAmount != null) 'csd_amount': csdAmount,
      if (billPassAmount != null) 'bill_pass_amount': billPassAmount,
      if (csdReleasedDate != null) 'csd_released_date': csdReleasedDate,
      if (csdDueDate != null) 'csd_due_date': csdDueDate,
      if (csdStatus != null) 'csd_status': csdStatus,
      if (scrapAmount != null) 'scrap_amount': scrapAmount,
      if (scrapGstAmount != null) 'scrap_gst_amount': scrapGstAmount,
      if (mdLdAmount != null) 'md_ld_amount': mdLdAmount,
      if (mdLdStatus != null) 'md_ld_status': mdLdStatus,
      if (mdLdReleasedDate != null) 'md_ld_released_date': mdLdReleasedDate,
      if (emptyOilIssued != null) 'empty_oil_issued': emptyOilIssued,
      if (emptyOilReturned != null) 'empty_oil_returned': emptyOilReturned,
      if (tdsAmount != null) 'tds_amount': tdsAmount,
      if (tcsAmount != null) 'tcs_amount': tcsAmount,
      if (gstTdsAmount != null) 'gst_tds_amount': gstTdsAmount,
      if (totalPaid != null) 'total_paid': totalPaid,
      if (dueAmount != null) 'due_amount': dueAmount,
      if (status != null) 'status': status,
      if (paidDate != null) 'paid_date': paidDate,
      if (transactionNo != null) 'transaction_no': transactionNo,
      if (dueReleaseDate != null) 'due_release_date': dueReleaseDate,
      if (invoiceNo != null) 'invoice_no': invoiceNo,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (workOrderNo != null) 'work_order_no': workOrderNo,
      if (workOrderDate != null) 'work_order_date': workOrderDate,
      if (consignmentName != null) 'consignment_name': consignmentName,
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (proofPath != null) 'proof_path': proofPath,
      if (remarks != null) 'remarks': remarks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BillsCompanion copyWith({
    Value<int>? id,
    Value<int?>? tenderId,
    Value<int>? firmId,
    Value<int?>? supplierFirmId,
    Value<int?>? clientFirmId,
    Value<String>? tnNumber,
    Value<DateTime>? billDate,
    Value<DateTime>? dueDate,
    Value<double>? amount,
    Value<double>? invoiceAmount,
    Value<double>? csdAmount,
    Value<double>? billPassAmount,
    Value<DateTime?>? csdReleasedDate,
    Value<DateTime?>? csdDueDate,
    Value<String>? csdStatus,
    Value<double>? scrapAmount,
    Value<double>? scrapGstAmount,
    Value<double>? mdLdAmount,
    Value<String>? mdLdStatus,
    Value<DateTime?>? mdLdReleasedDate,
    Value<double>? emptyOilIssued,
    Value<double>? emptyOilReturned,
    Value<double>? tdsAmount,
    Value<double>? tcsAmount,
    Value<double>? gstTdsAmount,
    Value<double>? totalPaid,
    Value<double>? dueAmount,
    Value<String>? status,
    Value<DateTime?>? paidDate,
    Value<String?>? transactionNo,
    Value<DateTime?>? dueReleaseDate,
    Value<String?>? invoiceNo,
    Value<DateTime?>? invoiceDate,
    Value<String?>? workOrderNo,
    Value<DateTime?>? workOrderDate,
    Value<String?>? consignmentName,
    Value<String?>? invoiceType,
    Value<String?>? proofPath,
    Value<String?>? remarks,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      tenderId: tenderId ?? this.tenderId,
      firmId: firmId ?? this.firmId,
      supplierFirmId: supplierFirmId ?? this.supplierFirmId,
      clientFirmId: clientFirmId ?? this.clientFirmId,
      tnNumber: tnNumber ?? this.tnNumber,
      billDate: billDate ?? this.billDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      csdAmount: csdAmount ?? this.csdAmount,
      billPassAmount: billPassAmount ?? this.billPassAmount,
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
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      transactionNo: transactionNo ?? this.transactionNo,
      dueReleaseDate: dueReleaseDate ?? this.dueReleaseDate,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      workOrderNo: workOrderNo ?? this.workOrderNo,
      workOrderDate: workOrderDate ?? this.workOrderDate,
      consignmentName: consignmentName ?? this.consignmentName,
      invoiceType: invoiceType ?? this.invoiceType,
      proofPath: proofPath ?? this.proofPath,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tenderId.present) {
      map['tender_id'] = Variable<int>(tenderId.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<int>(firmId.value);
    }
    if (supplierFirmId.present) {
      map['supplier_firm_id'] = Variable<int>(supplierFirmId.value);
    }
    if (clientFirmId.present) {
      map['client_firm_id'] = Variable<int>(clientFirmId.value);
    }
    if (tnNumber.present) {
      map['tn_number'] = Variable<String>(tnNumber.value);
    }
    if (billDate.present) {
      map['bill_date'] = Variable<DateTime>(billDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (invoiceAmount.present) {
      map['invoice_amount'] = Variable<double>(invoiceAmount.value);
    }
    if (csdAmount.present) {
      map['csd_amount'] = Variable<double>(csdAmount.value);
    }
    if (billPassAmount.present) {
      map['bill_pass_amount'] = Variable<double>(billPassAmount.value);
    }
    if (csdReleasedDate.present) {
      map['csd_released_date'] = Variable<DateTime>(csdReleasedDate.value);
    }
    if (csdDueDate.present) {
      map['csd_due_date'] = Variable<DateTime>(csdDueDate.value);
    }
    if (csdStatus.present) {
      map['csd_status'] = Variable<String>(csdStatus.value);
    }
    if (scrapAmount.present) {
      map['scrap_amount'] = Variable<double>(scrapAmount.value);
    }
    if (scrapGstAmount.present) {
      map['scrap_gst_amount'] = Variable<double>(scrapGstAmount.value);
    }
    if (mdLdAmount.present) {
      map['md_ld_amount'] = Variable<double>(mdLdAmount.value);
    }
    if (mdLdStatus.present) {
      map['md_ld_status'] = Variable<String>(mdLdStatus.value);
    }
    if (mdLdReleasedDate.present) {
      map['md_ld_released_date'] = Variable<DateTime>(mdLdReleasedDate.value);
    }
    if (emptyOilIssued.present) {
      map['empty_oil_issued'] = Variable<double>(emptyOilIssued.value);
    }
    if (emptyOilReturned.present) {
      map['empty_oil_returned'] = Variable<double>(emptyOilReturned.value);
    }
    if (tdsAmount.present) {
      map['tds_amount'] = Variable<double>(tdsAmount.value);
    }
    if (tcsAmount.present) {
      map['tcs_amount'] = Variable<double>(tcsAmount.value);
    }
    if (gstTdsAmount.present) {
      map['gst_tds_amount'] = Variable<double>(gstTdsAmount.value);
    }
    if (totalPaid.present) {
      map['total_paid'] = Variable<double>(totalPaid.value);
    }
    if (dueAmount.present) {
      map['due_amount'] = Variable<double>(dueAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (transactionNo.present) {
      map['transaction_no'] = Variable<String>(transactionNo.value);
    }
    if (dueReleaseDate.present) {
      map['due_release_date'] = Variable<DateTime>(dueReleaseDate.value);
    }
    if (invoiceNo.present) {
      map['invoice_no'] = Variable<String>(invoiceNo.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (workOrderNo.present) {
      map['work_order_no'] = Variable<String>(workOrderNo.value);
    }
    if (workOrderDate.present) {
      map['work_order_date'] = Variable<DateTime>(workOrderDate.value);
    }
    if (consignmentName.present) {
      map['consignment_name'] = Variable<String>(consignmentName.value);
    }
    if (invoiceType.present) {
      map['invoice_type'] = Variable<String>(invoiceType.value);
    }
    if (proofPath.present) {
      map['proof_path'] = Variable<String>(proofPath.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('tenderId: $tenderId, ')
          ..write('firmId: $firmId, ')
          ..write('supplierFirmId: $supplierFirmId, ')
          ..write('clientFirmId: $clientFirmId, ')
          ..write('tnNumber: $tnNumber, ')
          ..write('billDate: $billDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('invoiceAmount: $invoiceAmount, ')
          ..write('csdAmount: $csdAmount, ')
          ..write('billPassAmount: $billPassAmount, ')
          ..write('csdReleasedDate: $csdReleasedDate, ')
          ..write('csdDueDate: $csdDueDate, ')
          ..write('csdStatus: $csdStatus, ')
          ..write('scrapAmount: $scrapAmount, ')
          ..write('scrapGstAmount: $scrapGstAmount, ')
          ..write('mdLdAmount: $mdLdAmount, ')
          ..write('mdLdStatus: $mdLdStatus, ')
          ..write('mdLdReleasedDate: $mdLdReleasedDate, ')
          ..write('emptyOilIssued: $emptyOilIssued, ')
          ..write('emptyOilReturned: $emptyOilReturned, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('tcsAmount: $tcsAmount, ')
          ..write('gstTdsAmount: $gstTdsAmount, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('dueAmount: $dueAmount, ')
          ..write('status: $status, ')
          ..write('paidDate: $paidDate, ')
          ..write('transactionNo: $transactionNo, ')
          ..write('dueReleaseDate: $dueReleaseDate, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('workOrderNo: $workOrderNo, ')
          ..write('workOrderDate: $workOrderDate, ')
          ..write('consignmentName: $consignmentName, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('proofPath: $proofPath, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<int> billId = GeneratedColumn<int>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionNoMeta = const VerificationMeta(
    'transactionNo',
  );
  @override
  late final GeneratedColumn<String> transactionNo = GeneratedColumn<String>(
    'transaction_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueReleaseDateMeta = const VerificationMeta(
    'dueReleaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueReleaseDate =
      GeneratedColumn<DateTime>(
        'due_release_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _invoiceNoMeta = const VerificationMeta(
    'invoiceNo',
  );
  @override
  late final GeneratedColumn<String> invoiceNo = GeneratedColumn<String>(
    'invoice_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
    'invoice_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workOrderNoMeta = const VerificationMeta(
    'workOrderNo',
  );
  @override
  late final GeneratedColumn<String> workOrderNo = GeneratedColumn<String>(
    'work_order_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workOrderDateMeta = const VerificationMeta(
    'workOrderDate',
  );
  @override
  late final GeneratedColumn<DateTime> workOrderDate =
      GeneratedColumn<DateTime>(
        'work_order_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _consignmentNameMeta = const VerificationMeta(
    'consignmentName',
  );
  @override
  late final GeneratedColumn<String> consignmentName = GeneratedColumn<String>(
    'consignment_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proofPathMeta = const VerificationMeta(
    'proofPath',
  );
  @override
  late final GeneratedColumn<String> proofPath = GeneratedColumn<String>(
    'proof_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastEditedMeta = const VerificationMeta(
    'lastEdited',
  );
  @override
  late final GeneratedColumn<DateTime> lastEdited = GeneratedColumn<DateTime>(
    'last_edited',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    billId,
    paymentDate,
    amountPaid,
    paidDate,
    transactionNo,
    dueReleaseDate,
    invoiceNo,
    invoiceDate,
    workOrderNo,
    workOrderDate,
    consignmentName,
    proofPath,
    remarks,
    lastEdited,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
      );
    }
    if (data.containsKey('transaction_no')) {
      context.handle(
        _transactionNoMeta,
        transactionNo.isAcceptableOrUnknown(
          data['transaction_no']!,
          _transactionNoMeta,
        ),
      );
    }
    if (data.containsKey('due_release_date')) {
      context.handle(
        _dueReleaseDateMeta,
        dueReleaseDate.isAcceptableOrUnknown(
          data['due_release_date']!,
          _dueReleaseDateMeta,
        ),
      );
    }
    if (data.containsKey('invoice_no')) {
      context.handle(
        _invoiceNoMeta,
        invoiceNo.isAcceptableOrUnknown(data['invoice_no']!, _invoiceNoMeta),
      );
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    }
    if (data.containsKey('work_order_no')) {
      context.handle(
        _workOrderNoMeta,
        workOrderNo.isAcceptableOrUnknown(
          data['work_order_no']!,
          _workOrderNoMeta,
        ),
      );
    }
    if (data.containsKey('work_order_date')) {
      context.handle(
        _workOrderDateMeta,
        workOrderDate.isAcceptableOrUnknown(
          data['work_order_date']!,
          _workOrderDateMeta,
        ),
      );
    }
    if (data.containsKey('consignment_name')) {
      context.handle(
        _consignmentNameMeta,
        consignmentName.isAcceptableOrUnknown(
          data['consignment_name']!,
          _consignmentNameMeta,
        ),
      );
    }
    if (data.containsKey('proof_path')) {
      context.handle(
        _proofPathMeta,
        proofPath.isAcceptableOrUnknown(data['proof_path']!, _proofPathMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('last_edited')) {
      context.handle(
        _lastEditedMeta,
        lastEdited.isAcceptableOrUnknown(data['last_edited']!, _lastEditedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      billId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}bill_id'],
          )!,
      paymentDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}payment_date'],
          )!,
      amountPaid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount_paid'],
          )!,
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      ),
      transactionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_no'],
      ),
      dueReleaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_release_date'],
      ),
      invoiceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_no'],
      ),
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invoice_date'],
      ),
      workOrderNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_order_no'],
      ),
      workOrderDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}work_order_date'],
      ),
      consignmentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consignment_name'],
      ),
      proofPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proof_path'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      lastEdited:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_edited'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int billId;
  final DateTime paymentDate;
  final double amountPaid;
  final DateTime? paidDate;
  final String? transactionNo;
  final DateTime? dueReleaseDate;
  final String? invoiceNo;
  final DateTime? invoiceDate;
  final String? workOrderNo;
  final DateTime? workOrderDate;
  final String? consignmentName;
  final String? proofPath;
  final String? remarks;
  final DateTime lastEdited;
  final DateTime createdAt;
  const Payment({
    required this.id,
    required this.billId,
    required this.paymentDate,
    required this.amountPaid,
    this.paidDate,
    this.transactionNo,
    this.dueReleaseDate,
    this.invoiceNo,
    this.invoiceDate,
    this.workOrderNo,
    this.workOrderDate,
    this.consignmentName,
    this.proofPath,
    this.remarks,
    required this.lastEdited,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_id'] = Variable<int>(billId);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['amount_paid'] = Variable<double>(amountPaid);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    if (!nullToAbsent || transactionNo != null) {
      map['transaction_no'] = Variable<String>(transactionNo);
    }
    if (!nullToAbsent || dueReleaseDate != null) {
      map['due_release_date'] = Variable<DateTime>(dueReleaseDate);
    }
    if (!nullToAbsent || invoiceNo != null) {
      map['invoice_no'] = Variable<String>(invoiceNo);
    }
    if (!nullToAbsent || invoiceDate != null) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate);
    }
    if (!nullToAbsent || workOrderNo != null) {
      map['work_order_no'] = Variable<String>(workOrderNo);
    }
    if (!nullToAbsent || workOrderDate != null) {
      map['work_order_date'] = Variable<DateTime>(workOrderDate);
    }
    if (!nullToAbsent || consignmentName != null) {
      map['consignment_name'] = Variable<String>(consignmentName);
    }
    if (!nullToAbsent || proofPath != null) {
      map['proof_path'] = Variable<String>(proofPath);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['last_edited'] = Variable<DateTime>(lastEdited);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      billId: Value(billId),
      paymentDate: Value(paymentDate),
      amountPaid: Value(amountPaid),
      paidDate:
          paidDate == null && nullToAbsent
              ? const Value.absent()
              : Value(paidDate),
      transactionNo:
          transactionNo == null && nullToAbsent
              ? const Value.absent()
              : Value(transactionNo),
      dueReleaseDate:
          dueReleaseDate == null && nullToAbsent
              ? const Value.absent()
              : Value(dueReleaseDate),
      invoiceNo:
          invoiceNo == null && nullToAbsent
              ? const Value.absent()
              : Value(invoiceNo),
      invoiceDate:
          invoiceDate == null && nullToAbsent
              ? const Value.absent()
              : Value(invoiceDate),
      workOrderNo:
          workOrderNo == null && nullToAbsent
              ? const Value.absent()
              : Value(workOrderNo),
      workOrderDate:
          workOrderDate == null && nullToAbsent
              ? const Value.absent()
              : Value(workOrderDate),
      consignmentName:
          consignmentName == null && nullToAbsent
              ? const Value.absent()
              : Value(consignmentName),
      proofPath:
          proofPath == null && nullToAbsent
              ? const Value.absent()
              : Value(proofPath),
      remarks:
          remarks == null && nullToAbsent
              ? const Value.absent()
              : Value(remarks),
      lastEdited: Value(lastEdited),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      billId: serializer.fromJson<int>(json['billId']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      transactionNo: serializer.fromJson<String?>(json['transactionNo']),
      dueReleaseDate: serializer.fromJson<DateTime?>(json['dueReleaseDate']),
      invoiceNo: serializer.fromJson<String?>(json['invoiceNo']),
      invoiceDate: serializer.fromJson<DateTime?>(json['invoiceDate']),
      workOrderNo: serializer.fromJson<String?>(json['workOrderNo']),
      workOrderDate: serializer.fromJson<DateTime?>(json['workOrderDate']),
      consignmentName: serializer.fromJson<String?>(json['consignmentName']),
      proofPath: serializer.fromJson<String?>(json['proofPath']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      lastEdited: serializer.fromJson<DateTime>(json['lastEdited']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'billId': serializer.toJson<int>(billId),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'transactionNo': serializer.toJson<String?>(transactionNo),
      'dueReleaseDate': serializer.toJson<DateTime?>(dueReleaseDate),
      'invoiceNo': serializer.toJson<String?>(invoiceNo),
      'invoiceDate': serializer.toJson<DateTime?>(invoiceDate),
      'workOrderNo': serializer.toJson<String?>(workOrderNo),
      'workOrderDate': serializer.toJson<DateTime?>(workOrderDate),
      'consignmentName': serializer.toJson<String?>(consignmentName),
      'proofPath': serializer.toJson<String?>(proofPath),
      'remarks': serializer.toJson<String?>(remarks),
      'lastEdited': serializer.toJson<DateTime>(lastEdited),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith({
    int? id,
    int? billId,
    DateTime? paymentDate,
    double? amountPaid,
    Value<DateTime?> paidDate = const Value.absent(),
    Value<String?> transactionNo = const Value.absent(),
    Value<DateTime?> dueReleaseDate = const Value.absent(),
    Value<String?> invoiceNo = const Value.absent(),
    Value<DateTime?> invoiceDate = const Value.absent(),
    Value<String?> workOrderNo = const Value.absent(),
    Value<DateTime?> workOrderDate = const Value.absent(),
    Value<String?> consignmentName = const Value.absent(),
    Value<String?> proofPath = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    DateTime? lastEdited,
    DateTime? createdAt,
  }) => Payment(
    id: id ?? this.id,
    billId: billId ?? this.billId,
    paymentDate: paymentDate ?? this.paymentDate,
    amountPaid: amountPaid ?? this.amountPaid,
    paidDate: paidDate.present ? paidDate.value : this.paidDate,
    transactionNo:
        transactionNo.present ? transactionNo.value : this.transactionNo,
    dueReleaseDate:
        dueReleaseDate.present ? dueReleaseDate.value : this.dueReleaseDate,
    invoiceNo: invoiceNo.present ? invoiceNo.value : this.invoiceNo,
    invoiceDate: invoiceDate.present ? invoiceDate.value : this.invoiceDate,
    workOrderNo: workOrderNo.present ? workOrderNo.value : this.workOrderNo,
    workOrderDate:
        workOrderDate.present ? workOrderDate.value : this.workOrderDate,
    consignmentName:
        consignmentName.present ? consignmentName.value : this.consignmentName,
    proofPath: proofPath.present ? proofPath.value : this.proofPath,
    remarks: remarks.present ? remarks.value : this.remarks,
    lastEdited: lastEdited ?? this.lastEdited,
    createdAt: createdAt ?? this.createdAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      billId: data.billId.present ? data.billId.value : this.billId,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      amountPaid:
          data.amountPaid.present ? data.amountPaid.value : this.amountPaid,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      transactionNo:
          data.transactionNo.present
              ? data.transactionNo.value
              : this.transactionNo,
      dueReleaseDate:
          data.dueReleaseDate.present
              ? data.dueReleaseDate.value
              : this.dueReleaseDate,
      invoiceNo: data.invoiceNo.present ? data.invoiceNo.value : this.invoiceNo,
      invoiceDate:
          data.invoiceDate.present ? data.invoiceDate.value : this.invoiceDate,
      workOrderNo:
          data.workOrderNo.present ? data.workOrderNo.value : this.workOrderNo,
      workOrderDate:
          data.workOrderDate.present
              ? data.workOrderDate.value
              : this.workOrderDate,
      consignmentName:
          data.consignmentName.present
              ? data.consignmentName.value
              : this.consignmentName,
      proofPath: data.proofPath.present ? data.proofPath.value : this.proofPath,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      lastEdited:
          data.lastEdited.present ? data.lastEdited.value : this.lastEdited,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('transactionNo: $transactionNo, ')
          ..write('dueReleaseDate: $dueReleaseDate, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('workOrderNo: $workOrderNo, ')
          ..write('workOrderDate: $workOrderDate, ')
          ..write('consignmentName: $consignmentName, ')
          ..write('proofPath: $proofPath, ')
          ..write('remarks: $remarks, ')
          ..write('lastEdited: $lastEdited, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    billId,
    paymentDate,
    amountPaid,
    paidDate,
    transactionNo,
    dueReleaseDate,
    invoiceNo,
    invoiceDate,
    workOrderNo,
    workOrderDate,
    consignmentName,
    proofPath,
    remarks,
    lastEdited,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.billId == this.billId &&
          other.paymentDate == this.paymentDate &&
          other.amountPaid == this.amountPaid &&
          other.paidDate == this.paidDate &&
          other.transactionNo == this.transactionNo &&
          other.dueReleaseDate == this.dueReleaseDate &&
          other.invoiceNo == this.invoiceNo &&
          other.invoiceDate == this.invoiceDate &&
          other.workOrderNo == this.workOrderNo &&
          other.workOrderDate == this.workOrderDate &&
          other.consignmentName == this.consignmentName &&
          other.proofPath == this.proofPath &&
          other.remarks == this.remarks &&
          other.lastEdited == this.lastEdited &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> billId;
  final Value<DateTime> paymentDate;
  final Value<double> amountPaid;
  final Value<DateTime?> paidDate;
  final Value<String?> transactionNo;
  final Value<DateTime?> dueReleaseDate;
  final Value<String?> invoiceNo;
  final Value<DateTime?> invoiceDate;
  final Value<String?> workOrderNo;
  final Value<DateTime?> workOrderDate;
  final Value<String?> consignmentName;
  final Value<String?> proofPath;
  final Value<String?> remarks;
  final Value<DateTime> lastEdited;
  final Value<DateTime> createdAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.billId = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.transactionNo = const Value.absent(),
    this.dueReleaseDate = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.workOrderNo = const Value.absent(),
    this.workOrderDate = const Value.absent(),
    this.consignmentName = const Value.absent(),
    this.proofPath = const Value.absent(),
    this.remarks = const Value.absent(),
    this.lastEdited = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int billId,
    required DateTime paymentDate,
    this.amountPaid = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.transactionNo = const Value.absent(),
    this.dueReleaseDate = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.workOrderNo = const Value.absent(),
    this.workOrderDate = const Value.absent(),
    this.consignmentName = const Value.absent(),
    this.proofPath = const Value.absent(),
    this.remarks = const Value.absent(),
    this.lastEdited = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : billId = Value(billId),
       paymentDate = Value(paymentDate);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? billId,
    Expression<DateTime>? paymentDate,
    Expression<double>? amountPaid,
    Expression<DateTime>? paidDate,
    Expression<String>? transactionNo,
    Expression<DateTime>? dueReleaseDate,
    Expression<String>? invoiceNo,
    Expression<DateTime>? invoiceDate,
    Expression<String>? workOrderNo,
    Expression<DateTime>? workOrderDate,
    Expression<String>? consignmentName,
    Expression<String>? proofPath,
    Expression<String>? remarks,
    Expression<DateTime>? lastEdited,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billId != null) 'bill_id': billId,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (paidDate != null) 'paid_date': paidDate,
      if (transactionNo != null) 'transaction_no': transactionNo,
      if (dueReleaseDate != null) 'due_release_date': dueReleaseDate,
      if (invoiceNo != null) 'invoice_no': invoiceNo,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (workOrderNo != null) 'work_order_no': workOrderNo,
      if (workOrderDate != null) 'work_order_date': workOrderDate,
      if (consignmentName != null) 'consignment_name': consignmentName,
      if (proofPath != null) 'proof_path': proofPath,
      if (remarks != null) 'remarks': remarks,
      if (lastEdited != null) 'last_edited': lastEdited,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? billId,
    Value<DateTime>? paymentDate,
    Value<double>? amountPaid,
    Value<DateTime?>? paidDate,
    Value<String?>? transactionNo,
    Value<DateTime?>? dueReleaseDate,
    Value<String?>? invoiceNo,
    Value<DateTime?>? invoiceDate,
    Value<String?>? workOrderNo,
    Value<DateTime?>? workOrderDate,
    Value<String?>? consignmentName,
    Value<String?>? proofPath,
    Value<String?>? remarks,
    Value<DateTime>? lastEdited,
    Value<DateTime>? createdAt,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      paymentDate: paymentDate ?? this.paymentDate,
      amountPaid: amountPaid ?? this.amountPaid,
      paidDate: paidDate ?? this.paidDate,
      transactionNo: transactionNo ?? this.transactionNo,
      dueReleaseDate: dueReleaseDate ?? this.dueReleaseDate,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      workOrderNo: workOrderNo ?? this.workOrderNo,
      workOrderDate: workOrderDate ?? this.workOrderDate,
      consignmentName: consignmentName ?? this.consignmentName,
      proofPath: proofPath ?? this.proofPath,
      remarks: remarks ?? this.remarks,
      lastEdited: lastEdited ?? this.lastEdited,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<int>(billId.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (transactionNo.present) {
      map['transaction_no'] = Variable<String>(transactionNo.value);
    }
    if (dueReleaseDate.present) {
      map['due_release_date'] = Variable<DateTime>(dueReleaseDate.value);
    }
    if (invoiceNo.present) {
      map['invoice_no'] = Variable<String>(invoiceNo.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (workOrderNo.present) {
      map['work_order_no'] = Variable<String>(workOrderNo.value);
    }
    if (workOrderDate.present) {
      map['work_order_date'] = Variable<DateTime>(workOrderDate.value);
    }
    if (consignmentName.present) {
      map['consignment_name'] = Variable<String>(consignmentName.value);
    }
    if (proofPath.present) {
      map['proof_path'] = Variable<String>(proofPath.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (lastEdited.present) {
      map['last_edited'] = Variable<DateTime>(lastEdited.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('transactionNo: $transactionNo, ')
          ..write('dueReleaseDate: $dueReleaseDate, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('workOrderNo: $workOrderNo, ')
          ..write('workOrderDate: $workOrderDate, ')
          ..write('consignmentName: $consignmentName, ')
          ..write('proofPath: $proofPath, ')
          ..write('remarks: $remarks, ')
          ..write('lastEdited: $lastEdited, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FirmsTable firms = $FirmsTable(this);
  late final $ClientFirmsTable clientFirms = $ClientFirmsTable(this);
  late final $TendersTable tenders = $TendersTable(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    firms,
    clientFirms,
    tenders,
    bills,
    payments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'firms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tenders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tenders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bills', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'firms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bills', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'firms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bills', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'client_firms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bills', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bills',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FirmsTableCreateCompanionBuilder =
    FirmsCompanion Function({
      Value<int> id,
      required String name,
      required String code,
      Value<String?> description,
      Value<String?> address,
      Value<String?> contactNo,
      Value<String?> gstNo,
      Value<DateTime> createdAt,
    });
typedef $$FirmsTableUpdateCompanionBuilder =
    FirmsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> code,
      Value<String?> description,
      Value<String?> address,
      Value<String?> contactNo,
      Value<String?> gstNo,
      Value<DateTime> createdAt,
    });

final class $$FirmsTableReferences
    extends BaseReferences<_$AppDatabase, $FirmsTable, Firm> {
  $$FirmsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TendersTable, List<Tender>> _tendersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tenders,
    aliasName: $_aliasNameGenerator(db.firms.id, db.tenders.firmId),
  );

  $$TendersTableProcessedTableManager get tendersRefs {
    final manager = $$TendersTableTableManager(
      $_db,
      $_db.tenders,
    ).filter((f) => f.firmId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tendersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FirmsTableFilterComposer extends Composer<_$AppDatabase, $FirmsTable> {
  $$FirmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNo => $composableBuilder(
    column: $table.contactNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstNo => $composableBuilder(
    column: $table.gstNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tendersRefs(
    Expression<bool> Function($$TendersTableFilterComposer f) f,
  ) {
    final $$TendersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tenders,
      getReferencedColumn: (t) => t.firmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TendersTableFilterComposer(
            $db: $db,
            $table: $db.tenders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FirmsTableOrderingComposer
    extends Composer<_$AppDatabase, $FirmsTable> {
  $$FirmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNo => $composableBuilder(
    column: $table.contactNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstNo => $composableBuilder(
    column: $table.gstNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FirmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FirmsTable> {
  $$FirmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get contactNo =>
      $composableBuilder(column: $table.contactNo, builder: (column) => column);

  GeneratedColumn<String> get gstNo =>
      $composableBuilder(column: $table.gstNo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tendersRefs<T extends Object>(
    Expression<T> Function($$TendersTableAnnotationComposer a) f,
  ) {
    final $$TendersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tenders,
      getReferencedColumn: (t) => t.firmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TendersTableAnnotationComposer(
            $db: $db,
            $table: $db.tenders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FirmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FirmsTable,
          Firm,
          $$FirmsTableFilterComposer,
          $$FirmsTableOrderingComposer,
          $$FirmsTableAnnotationComposer,
          $$FirmsTableCreateCompanionBuilder,
          $$FirmsTableUpdateCompanionBuilder,
          (Firm, $$FirmsTableReferences),
          Firm,
          PrefetchHooks Function({bool tendersRefs})
        > {
  $$FirmsTableTableManager(_$AppDatabase db, $FirmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FirmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FirmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FirmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> contactNo = const Value.absent(),
                Value<String?> gstNo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FirmsCompanion(
                id: id,
                name: name,
                code: code,
                description: description,
                address: address,
                contactNo: contactNo,
                gstNo: gstNo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String code,
                Value<String?> description = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> contactNo = const Value.absent(),
                Value<String?> gstNo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FirmsCompanion.insert(
                id: id,
                name: name,
                code: code,
                description: description,
                address: address,
                contactNo: contactNo,
                gstNo: gstNo,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$FirmsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({tendersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tendersRefs) db.tenders],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tendersRefs)
                    await $_getPrefetchedData<Firm, $FirmsTable, Tender>(
                      currentTable: table,
                      referencedTable: $$FirmsTableReferences._tendersRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$FirmsTableReferences(db, table, p0).tendersRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.firmId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FirmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FirmsTable,
      Firm,
      $$FirmsTableFilterComposer,
      $$FirmsTableOrderingComposer,
      $$FirmsTableAnnotationComposer,
      $$FirmsTableCreateCompanionBuilder,
      $$FirmsTableUpdateCompanionBuilder,
      (Firm, $$FirmsTableReferences),
      Firm,
      PrefetchHooks Function({bool tendersRefs})
    >;
typedef $$ClientFirmsTableCreateCompanionBuilder =
    ClientFirmsCompanion Function({
      Value<int> id,
      required String firmName,
      Value<String?> address,
      Value<String?> contactNo,
      Value<String?> gstNo,
      Value<DateTime> createdAt,
    });
typedef $$ClientFirmsTableUpdateCompanionBuilder =
    ClientFirmsCompanion Function({
      Value<int> id,
      Value<String> firmName,
      Value<String?> address,
      Value<String?> contactNo,
      Value<String?> gstNo,
      Value<DateTime> createdAt,
    });

final class $$ClientFirmsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientFirmsTable, ClientFirm> {
  $$ClientFirmsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BillsTable, List<Bill>> _billsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bills,
    aliasName: $_aliasNameGenerator(db.clientFirms.id, db.bills.clientFirmId),
  );

  $$BillsTableProcessedTableManager get billsRefs {
    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.clientFirmId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_billsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientFirmsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientFirmsTable> {
  $$ClientFirmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmName => $composableBuilder(
    column: $table.firmName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNo => $composableBuilder(
    column: $table.contactNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstNo => $composableBuilder(
    column: $table.gstNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> billsRefs(
    Expression<bool> Function($$BillsTableFilterComposer f) f,
  ) {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.clientFirmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientFirmsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientFirmsTable> {
  $$ClientFirmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmName => $composableBuilder(
    column: $table.firmName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNo => $composableBuilder(
    column: $table.contactNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstNo => $composableBuilder(
    column: $table.gstNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientFirmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientFirmsTable> {
  $$ClientFirmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmName =>
      $composableBuilder(column: $table.firmName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get contactNo =>
      $composableBuilder(column: $table.contactNo, builder: (column) => column);

  GeneratedColumn<String> get gstNo =>
      $composableBuilder(column: $table.gstNo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> billsRefs<T extends Object>(
    Expression<T> Function($$BillsTableAnnotationComposer a) f,
  ) {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.clientFirmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientFirmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientFirmsTable,
          ClientFirm,
          $$ClientFirmsTableFilterComposer,
          $$ClientFirmsTableOrderingComposer,
          $$ClientFirmsTableAnnotationComposer,
          $$ClientFirmsTableCreateCompanionBuilder,
          $$ClientFirmsTableUpdateCompanionBuilder,
          (ClientFirm, $$ClientFirmsTableReferences),
          ClientFirm,
          PrefetchHooks Function({bool billsRefs})
        > {
  $$ClientFirmsTableTableManager(_$AppDatabase db, $ClientFirmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ClientFirmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ClientFirmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ClientFirmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> firmName = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> contactNo = const Value.absent(),
                Value<String?> gstNo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClientFirmsCompanion(
                id: id,
                firmName: firmName,
                address: address,
                contactNo: contactNo,
                gstNo: gstNo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String firmName,
                Value<String?> address = const Value.absent(),
                Value<String?> contactNo = const Value.absent(),
                Value<String?> gstNo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClientFirmsCompanion.insert(
                id: id,
                firmName: firmName,
                address: address,
                contactNo: contactNo,
                gstNo: gstNo,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ClientFirmsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({billsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (billsRefs) db.bills],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (billsRefs)
                    await $_getPrefetchedData<
                      ClientFirm,
                      $ClientFirmsTable,
                      Bill
                    >(
                      currentTable: table,
                      referencedTable: $$ClientFirmsTableReferences
                          ._billsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ClientFirmsTableReferences(
                                db,
                                table,
                                p0,
                              ).billsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.clientFirmId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClientFirmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientFirmsTable,
      ClientFirm,
      $$ClientFirmsTableFilterComposer,
      $$ClientFirmsTableOrderingComposer,
      $$ClientFirmsTableAnnotationComposer,
      $$ClientFirmsTableCreateCompanionBuilder,
      $$ClientFirmsTableUpdateCompanionBuilder,
      (ClientFirm, $$ClientFirmsTableReferences),
      ClientFirm,
      PrefetchHooks Function({bool billsRefs})
    >;
typedef $$TendersTableCreateCompanionBuilder =
    TendersCompanion Function({
      Value<int> id,
      required int firmId,
      required String tnNumber,
      Value<String?> poNumber,
      Value<String?> workDescription,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TendersTableUpdateCompanionBuilder =
    TendersCompanion Function({
      Value<int> id,
      Value<int> firmId,
      Value<String> tnNumber,
      Value<String?> poNumber,
      Value<String?> workDescription,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TendersTableReferences
    extends BaseReferences<_$AppDatabase, $TendersTable, Tender> {
  $$TendersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FirmsTable _firmIdTable(_$AppDatabase db) => db.firms.createAlias(
    $_aliasNameGenerator(db.tenders.firmId, db.firms.id),
  );

  $$FirmsTableProcessedTableManager get firmId {
    final $_column = $_itemColumn<int>('firm_id')!;

    final manager = $$FirmsTableTableManager(
      $_db,
      $_db.firms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_firmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BillsTable, List<Bill>> _billsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bills,
    aliasName: $_aliasNameGenerator(db.tenders.id, db.bills.tenderId),
  );

  $$BillsTableProcessedTableManager get billsRefs {
    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.tenderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_billsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TendersTableFilterComposer
    extends Composer<_$AppDatabase, $TendersTable> {
  $$TendersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tnNumber => $composableBuilder(
    column: $table.tnNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poNumber => $composableBuilder(
    column: $table.poNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workDescription => $composableBuilder(
    column: $table.workDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FirmsTableFilterComposer get firmId {
    final $$FirmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableFilterComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> billsRefs(
    Expression<bool> Function($$BillsTableFilterComposer f) f,
  ) {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.tenderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TendersTableOrderingComposer
    extends Composer<_$AppDatabase, $TendersTable> {
  $$TendersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tnNumber => $composableBuilder(
    column: $table.tnNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poNumber => $composableBuilder(
    column: $table.poNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workDescription => $composableBuilder(
    column: $table.workDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FirmsTableOrderingComposer get firmId {
    final $$FirmsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableOrderingComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TendersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TendersTable> {
  $$TendersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tnNumber =>
      $composableBuilder(column: $table.tnNumber, builder: (column) => column);

  GeneratedColumn<String> get poNumber =>
      $composableBuilder(column: $table.poNumber, builder: (column) => column);

  GeneratedColumn<String> get workDescription => $composableBuilder(
    column: $table.workDescription,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FirmsTableAnnotationComposer get firmId {
    final $$FirmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableAnnotationComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> billsRefs<T extends Object>(
    Expression<T> Function($$BillsTableAnnotationComposer a) f,
  ) {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.tenderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TendersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TendersTable,
          Tender,
          $$TendersTableFilterComposer,
          $$TendersTableOrderingComposer,
          $$TendersTableAnnotationComposer,
          $$TendersTableCreateCompanionBuilder,
          $$TendersTableUpdateCompanionBuilder,
          (Tender, $$TendersTableReferences),
          Tender,
          PrefetchHooks Function({bool firmId, bool billsRefs})
        > {
  $$TendersTableTableManager(_$AppDatabase db, $TendersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TendersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TendersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TendersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> firmId = const Value.absent(),
                Value<String> tnNumber = const Value.absent(),
                Value<String?> poNumber = const Value.absent(),
                Value<String?> workDescription = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TendersCompanion(
                id: id,
                firmId: firmId,
                tnNumber: tnNumber,
                poNumber: poNumber,
                workDescription: workDescription,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int firmId,
                required String tnNumber,
                Value<String?> poNumber = const Value.absent(),
                Value<String?> workDescription = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TendersCompanion.insert(
                id: id,
                firmId: firmId,
                tnNumber: tnNumber,
                poNumber: poNumber,
                workDescription: workDescription,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TendersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({firmId = false, billsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (billsRefs) db.bills],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (firmId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.firmId,
                            referencedTable: $$TendersTableReferences
                                ._firmIdTable(db),
                            referencedColumn:
                                $$TendersTableReferences._firmIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (billsRefs)
                    await $_getPrefetchedData<Tender, $TendersTable, Bill>(
                      currentTable: table,
                      referencedTable: $$TendersTableReferences._billsRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$TendersTableReferences(db, table, p0).billsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.tenderId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TendersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TendersTable,
      Tender,
      $$TendersTableFilterComposer,
      $$TendersTableOrderingComposer,
      $$TendersTableAnnotationComposer,
      $$TendersTableCreateCompanionBuilder,
      $$TendersTableUpdateCompanionBuilder,
      (Tender, $$TendersTableReferences),
      Tender,
      PrefetchHooks Function({bool firmId, bool billsRefs})
    >;
typedef $$BillsTableCreateCompanionBuilder =
    BillsCompanion Function({
      Value<int> id,
      Value<int?> tenderId,
      required int firmId,
      Value<int?> supplierFirmId,
      Value<int?> clientFirmId,
      required String tnNumber,
      required DateTime billDate,
      required DateTime dueDate,
      Value<double> amount,
      Value<double> invoiceAmount,
      Value<double> csdAmount,
      Value<double> billPassAmount,
      Value<DateTime?> csdReleasedDate,
      Value<DateTime?> csdDueDate,
      Value<String> csdStatus,
      Value<double> scrapAmount,
      Value<double> scrapGstAmount,
      Value<double> mdLdAmount,
      Value<String> mdLdStatus,
      Value<DateTime?> mdLdReleasedDate,
      Value<double> emptyOilIssued,
      Value<double> emptyOilReturned,
      Value<double> tdsAmount,
      Value<double> tcsAmount,
      Value<double> gstTdsAmount,
      Value<double> totalPaid,
      Value<double> dueAmount,
      Value<String> status,
      Value<DateTime?> paidDate,
      Value<String?> transactionNo,
      Value<DateTime?> dueReleaseDate,
      Value<String?> invoiceNo,
      Value<DateTime?> invoiceDate,
      Value<String?> workOrderNo,
      Value<DateTime?> workOrderDate,
      Value<String?> consignmentName,
      Value<String?> invoiceType,
      Value<String?> proofPath,
      Value<String?> remarks,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BillsTableUpdateCompanionBuilder =
    BillsCompanion Function({
      Value<int> id,
      Value<int?> tenderId,
      Value<int> firmId,
      Value<int?> supplierFirmId,
      Value<int?> clientFirmId,
      Value<String> tnNumber,
      Value<DateTime> billDate,
      Value<DateTime> dueDate,
      Value<double> amount,
      Value<double> invoiceAmount,
      Value<double> csdAmount,
      Value<double> billPassAmount,
      Value<DateTime?> csdReleasedDate,
      Value<DateTime?> csdDueDate,
      Value<String> csdStatus,
      Value<double> scrapAmount,
      Value<double> scrapGstAmount,
      Value<double> mdLdAmount,
      Value<String> mdLdStatus,
      Value<DateTime?> mdLdReleasedDate,
      Value<double> emptyOilIssued,
      Value<double> emptyOilReturned,
      Value<double> tdsAmount,
      Value<double> tcsAmount,
      Value<double> gstTdsAmount,
      Value<double> totalPaid,
      Value<double> dueAmount,
      Value<String> status,
      Value<DateTime?> paidDate,
      Value<String?> transactionNo,
      Value<DateTime?> dueReleaseDate,
      Value<String?> invoiceNo,
      Value<DateTime?> invoiceDate,
      Value<String?> workOrderNo,
      Value<DateTime?> workOrderDate,
      Value<String?> consignmentName,
      Value<String?> invoiceType,
      Value<String?> proofPath,
      Value<String?> remarks,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BillsTableReferences
    extends BaseReferences<_$AppDatabase, $BillsTable, Bill> {
  $$BillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TendersTable _tenderIdTable(_$AppDatabase db) => db.tenders
      .createAlias($_aliasNameGenerator(db.bills.tenderId, db.tenders.id));

  $$TendersTableProcessedTableManager? get tenderId {
    final $_column = $_itemColumn<int>('tender_id');
    if ($_column == null) return null;
    final manager = $$TendersTableTableManager(
      $_db,
      $_db.tenders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FirmsTable _firmIdTable(_$AppDatabase db) =>
      db.firms.createAlias($_aliasNameGenerator(db.bills.firmId, db.firms.id));

  $$FirmsTableProcessedTableManager get firmId {
    final $_column = $_itemColumn<int>('firm_id')!;

    final manager = $$FirmsTableTableManager(
      $_db,
      $_db.firms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_firmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FirmsTable _supplierFirmIdTable(_$AppDatabase db) => db.firms
      .createAlias($_aliasNameGenerator(db.bills.supplierFirmId, db.firms.id));

  $$FirmsTableProcessedTableManager? get supplierFirmId {
    final $_column = $_itemColumn<int>('supplier_firm_id');
    if ($_column == null) return null;
    final manager = $$FirmsTableTableManager(
      $_db,
      $_db.firms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierFirmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClientFirmsTable _clientFirmIdTable(_$AppDatabase db) =>
      db.clientFirms.createAlias(
        $_aliasNameGenerator(db.bills.clientFirmId, db.clientFirms.id),
      );

  $$ClientFirmsTableProcessedTableManager? get clientFirmId {
    final $_column = $_itemColumn<int>('client_firm_id');
    if ($_column == null) return null;
    final manager = $$ClientFirmsTableTableManager(
      $_db,
      $_db.clientFirms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientFirmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(db.bills.id, db.payments.billId),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.billId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tnNumber => $composableBuilder(
    column: $table.tnNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get invoiceAmount => $composableBuilder(
    column: $table.invoiceAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get csdAmount => $composableBuilder(
    column: $table.csdAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get billPassAmount => $composableBuilder(
    column: $table.billPassAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get csdReleasedDate => $composableBuilder(
    column: $table.csdReleasedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get csdDueDate => $composableBuilder(
    column: $table.csdDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get csdStatus => $composableBuilder(
    column: $table.csdStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrapAmount => $composableBuilder(
    column: $table.scrapAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrapGstAmount => $composableBuilder(
    column: $table.scrapGstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mdLdAmount => $composableBuilder(
    column: $table.mdLdAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mdLdStatus => $composableBuilder(
    column: $table.mdLdStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get mdLdReleasedDate => $composableBuilder(
    column: $table.mdLdReleasedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get emptyOilIssued => $composableBuilder(
    column: $table.emptyOilIssued,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get emptyOilReturned => $composableBuilder(
    column: $table.emptyOilReturned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tcsAmount => $composableBuilder(
    column: $table.tcsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstTdsAmount => $composableBuilder(
    column: $table.gstTdsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPaid => $composableBuilder(
    column: $table.totalPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dueAmount => $composableBuilder(
    column: $table.dueAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueReleaseDate => $composableBuilder(
    column: $table.dueReleaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNo => $composableBuilder(
    column: $table.invoiceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workOrderNo => $composableBuilder(
    column: $table.workOrderNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get workOrderDate => $composableBuilder(
    column: $table.workOrderDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consignmentName => $composableBuilder(
    column: $table.consignmentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proofPath => $composableBuilder(
    column: $table.proofPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TendersTableFilterComposer get tenderId {
    final $$TendersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenderId,
      referencedTable: $db.tenders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TendersTableFilterComposer(
            $db: $db,
            $table: $db.tenders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FirmsTableFilterComposer get firmId {
    final $$FirmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableFilterComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FirmsTableFilterComposer get supplierFirmId {
    final $$FirmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierFirmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableFilterComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientFirmsTableFilterComposer get clientFirmId {
    final $$ClientFirmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientFirmId,
      referencedTable: $db.clientFirms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientFirmsTableFilterComposer(
            $db: $db,
            $table: $db.clientFirms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tnNumber => $composableBuilder(
    column: $table.tnNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get invoiceAmount => $composableBuilder(
    column: $table.invoiceAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get csdAmount => $composableBuilder(
    column: $table.csdAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get billPassAmount => $composableBuilder(
    column: $table.billPassAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get csdReleasedDate => $composableBuilder(
    column: $table.csdReleasedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get csdDueDate => $composableBuilder(
    column: $table.csdDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get csdStatus => $composableBuilder(
    column: $table.csdStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrapAmount => $composableBuilder(
    column: $table.scrapAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrapGstAmount => $composableBuilder(
    column: $table.scrapGstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mdLdAmount => $composableBuilder(
    column: $table.mdLdAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mdLdStatus => $composableBuilder(
    column: $table.mdLdStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get mdLdReleasedDate => $composableBuilder(
    column: $table.mdLdReleasedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get emptyOilIssued => $composableBuilder(
    column: $table.emptyOilIssued,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get emptyOilReturned => $composableBuilder(
    column: $table.emptyOilReturned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tcsAmount => $composableBuilder(
    column: $table.tcsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstTdsAmount => $composableBuilder(
    column: $table.gstTdsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPaid => $composableBuilder(
    column: $table.totalPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dueAmount => $composableBuilder(
    column: $table.dueAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueReleaseDate => $composableBuilder(
    column: $table.dueReleaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNo => $composableBuilder(
    column: $table.invoiceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workOrderNo => $composableBuilder(
    column: $table.workOrderNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get workOrderDate => $composableBuilder(
    column: $table.workOrderDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consignmentName => $composableBuilder(
    column: $table.consignmentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proofPath => $composableBuilder(
    column: $table.proofPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TendersTableOrderingComposer get tenderId {
    final $$TendersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenderId,
      referencedTable: $db.tenders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TendersTableOrderingComposer(
            $db: $db,
            $table: $db.tenders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FirmsTableOrderingComposer get firmId {
    final $$FirmsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableOrderingComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FirmsTableOrderingComposer get supplierFirmId {
    final $$FirmsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierFirmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableOrderingComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientFirmsTableOrderingComposer get clientFirmId {
    final $$ClientFirmsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientFirmId,
      referencedTable: $db.clientFirms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientFirmsTableOrderingComposer(
            $db: $db,
            $table: $db.clientFirms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tnNumber =>
      $composableBuilder(column: $table.tnNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get billDate =>
      $composableBuilder(column: $table.billDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get invoiceAmount => $composableBuilder(
    column: $table.invoiceAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get csdAmount =>
      $composableBuilder(column: $table.csdAmount, builder: (column) => column);

  GeneratedColumn<double> get billPassAmount => $composableBuilder(
    column: $table.billPassAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get csdReleasedDate => $composableBuilder(
    column: $table.csdReleasedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get csdDueDate => $composableBuilder(
    column: $table.csdDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get csdStatus =>
      $composableBuilder(column: $table.csdStatus, builder: (column) => column);

  GeneratedColumn<double> get scrapAmount => $composableBuilder(
    column: $table.scrapAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scrapGstAmount => $composableBuilder(
    column: $table.scrapGstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mdLdAmount => $composableBuilder(
    column: $table.mdLdAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mdLdStatus => $composableBuilder(
    column: $table.mdLdStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get mdLdReleasedDate => $composableBuilder(
    column: $table.mdLdReleasedDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get emptyOilIssued => $composableBuilder(
    column: $table.emptyOilIssued,
    builder: (column) => column,
  );

  GeneratedColumn<double> get emptyOilReturned => $composableBuilder(
    column: $table.emptyOilReturned,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tdsAmount =>
      $composableBuilder(column: $table.tdsAmount, builder: (column) => column);

  GeneratedColumn<double> get tcsAmount =>
      $composableBuilder(column: $table.tcsAmount, builder: (column) => column);

  GeneratedColumn<double> get gstTdsAmount => $composableBuilder(
    column: $table.gstTdsAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalPaid =>
      $composableBuilder(column: $table.totalPaid, builder: (column) => column);

  GeneratedColumn<double> get dueAmount =>
      $composableBuilder(column: $table.dueAmount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueReleaseDate => $composableBuilder(
    column: $table.dueReleaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceNo =>
      $composableBuilder(column: $table.invoiceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workOrderNo => $composableBuilder(
    column: $table.workOrderNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get workOrderDate => $composableBuilder(
    column: $table.workOrderDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consignmentName => $composableBuilder(
    column: $table.consignmentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proofPath =>
      $composableBuilder(column: $table.proofPath, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TendersTableAnnotationComposer get tenderId {
    final $$TendersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenderId,
      referencedTable: $db.tenders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TendersTableAnnotationComposer(
            $db: $db,
            $table: $db.tenders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FirmsTableAnnotationComposer get firmId {
    final $$FirmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableAnnotationComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FirmsTableAnnotationComposer get supplierFirmId {
    final $$FirmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierFirmId,
      referencedTable: $db.firms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FirmsTableAnnotationComposer(
            $db: $db,
            $table: $db.firms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientFirmsTableAnnotationComposer get clientFirmId {
    final $$ClientFirmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientFirmId,
      referencedTable: $db.clientFirms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientFirmsTableAnnotationComposer(
            $db: $db,
            $table: $db.clientFirms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          Bill,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (Bill, $$BillsTableReferences),
          Bill,
          PrefetchHooks Function({
            bool tenderId,
            bool firmId,
            bool supplierFirmId,
            bool clientFirmId,
            bool paymentsRefs,
          })
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tenderId = const Value.absent(),
                Value<int> firmId = const Value.absent(),
                Value<int?> supplierFirmId = const Value.absent(),
                Value<int?> clientFirmId = const Value.absent(),
                Value<String> tnNumber = const Value.absent(),
                Value<DateTime> billDate = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> invoiceAmount = const Value.absent(),
                Value<double> csdAmount = const Value.absent(),
                Value<double> billPassAmount = const Value.absent(),
                Value<DateTime?> csdReleasedDate = const Value.absent(),
                Value<DateTime?> csdDueDate = const Value.absent(),
                Value<String> csdStatus = const Value.absent(),
                Value<double> scrapAmount = const Value.absent(),
                Value<double> scrapGstAmount = const Value.absent(),
                Value<double> mdLdAmount = const Value.absent(),
                Value<String> mdLdStatus = const Value.absent(),
                Value<DateTime?> mdLdReleasedDate = const Value.absent(),
                Value<double> emptyOilIssued = const Value.absent(),
                Value<double> emptyOilReturned = const Value.absent(),
                Value<double> tdsAmount = const Value.absent(),
                Value<double> tcsAmount = const Value.absent(),
                Value<double> gstTdsAmount = const Value.absent(),
                Value<double> totalPaid = const Value.absent(),
                Value<double> dueAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String?> transactionNo = const Value.absent(),
                Value<DateTime?> dueReleaseDate = const Value.absent(),
                Value<String?> invoiceNo = const Value.absent(),
                Value<DateTime?> invoiceDate = const Value.absent(),
                Value<String?> workOrderNo = const Value.absent(),
                Value<DateTime?> workOrderDate = const Value.absent(),
                Value<String?> consignmentName = const Value.absent(),
                Value<String?> invoiceType = const Value.absent(),
                Value<String?> proofPath = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                tenderId: tenderId,
                firmId: firmId,
                supplierFirmId: supplierFirmId,
                clientFirmId: clientFirmId,
                tnNumber: tnNumber,
                billDate: billDate,
                dueDate: dueDate,
                amount: amount,
                invoiceAmount: invoiceAmount,
                csdAmount: csdAmount,
                billPassAmount: billPassAmount,
                csdReleasedDate: csdReleasedDate,
                csdDueDate: csdDueDate,
                csdStatus: csdStatus,
                scrapAmount: scrapAmount,
                scrapGstAmount: scrapGstAmount,
                mdLdAmount: mdLdAmount,
                mdLdStatus: mdLdStatus,
                mdLdReleasedDate: mdLdReleasedDate,
                emptyOilIssued: emptyOilIssued,
                emptyOilReturned: emptyOilReturned,
                tdsAmount: tdsAmount,
                tcsAmount: tcsAmount,
                gstTdsAmount: gstTdsAmount,
                totalPaid: totalPaid,
                dueAmount: dueAmount,
                status: status,
                paidDate: paidDate,
                transactionNo: transactionNo,
                dueReleaseDate: dueReleaseDate,
                invoiceNo: invoiceNo,
                invoiceDate: invoiceDate,
                workOrderNo: workOrderNo,
                workOrderDate: workOrderDate,
                consignmentName: consignmentName,
                invoiceType: invoiceType,
                proofPath: proofPath,
                remarks: remarks,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tenderId = const Value.absent(),
                required int firmId,
                Value<int?> supplierFirmId = const Value.absent(),
                Value<int?> clientFirmId = const Value.absent(),
                required String tnNumber,
                required DateTime billDate,
                required DateTime dueDate,
                Value<double> amount = const Value.absent(),
                Value<double> invoiceAmount = const Value.absent(),
                Value<double> csdAmount = const Value.absent(),
                Value<double> billPassAmount = const Value.absent(),
                Value<DateTime?> csdReleasedDate = const Value.absent(),
                Value<DateTime?> csdDueDate = const Value.absent(),
                Value<String> csdStatus = const Value.absent(),
                Value<double> scrapAmount = const Value.absent(),
                Value<double> scrapGstAmount = const Value.absent(),
                Value<double> mdLdAmount = const Value.absent(),
                Value<String> mdLdStatus = const Value.absent(),
                Value<DateTime?> mdLdReleasedDate = const Value.absent(),
                Value<double> emptyOilIssued = const Value.absent(),
                Value<double> emptyOilReturned = const Value.absent(),
                Value<double> tdsAmount = const Value.absent(),
                Value<double> tcsAmount = const Value.absent(),
                Value<double> gstTdsAmount = const Value.absent(),
                Value<double> totalPaid = const Value.absent(),
                Value<double> dueAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String?> transactionNo = const Value.absent(),
                Value<DateTime?> dueReleaseDate = const Value.absent(),
                Value<String?> invoiceNo = const Value.absent(),
                Value<DateTime?> invoiceDate = const Value.absent(),
                Value<String?> workOrderNo = const Value.absent(),
                Value<DateTime?> workOrderDate = const Value.absent(),
                Value<String?> consignmentName = const Value.absent(),
                Value<String?> invoiceType = const Value.absent(),
                Value<String?> proofPath = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                tenderId: tenderId,
                firmId: firmId,
                supplierFirmId: supplierFirmId,
                clientFirmId: clientFirmId,
                tnNumber: tnNumber,
                billDate: billDate,
                dueDate: dueDate,
                amount: amount,
                invoiceAmount: invoiceAmount,
                csdAmount: csdAmount,
                billPassAmount: billPassAmount,
                csdReleasedDate: csdReleasedDate,
                csdDueDate: csdDueDate,
                csdStatus: csdStatus,
                scrapAmount: scrapAmount,
                scrapGstAmount: scrapGstAmount,
                mdLdAmount: mdLdAmount,
                mdLdStatus: mdLdStatus,
                mdLdReleasedDate: mdLdReleasedDate,
                emptyOilIssued: emptyOilIssued,
                emptyOilReturned: emptyOilReturned,
                tdsAmount: tdsAmount,
                tcsAmount: tcsAmount,
                gstTdsAmount: gstTdsAmount,
                totalPaid: totalPaid,
                dueAmount: dueAmount,
                status: status,
                paidDate: paidDate,
                transactionNo: transactionNo,
                dueReleaseDate: dueReleaseDate,
                invoiceNo: invoiceNo,
                invoiceDate: invoiceDate,
                workOrderNo: workOrderNo,
                workOrderDate: workOrderDate,
                consignmentName: consignmentName,
                invoiceType: invoiceType,
                proofPath: proofPath,
                remarks: remarks,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$BillsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            tenderId = false,
            firmId = false,
            supplierFirmId = false,
            clientFirmId = false,
            paymentsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (tenderId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.tenderId,
                            referencedTable: $$BillsTableReferences
                                ._tenderIdTable(db),
                            referencedColumn:
                                $$BillsTableReferences._tenderIdTable(db).id,
                          )
                          as T;
                }
                if (firmId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.firmId,
                            referencedTable: $$BillsTableReferences
                                ._firmIdTable(db),
                            referencedColumn:
                                $$BillsTableReferences._firmIdTable(db).id,
                          )
                          as T;
                }
                if (supplierFirmId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierFirmId,
                            referencedTable: $$BillsTableReferences
                                ._supplierFirmIdTable(db),
                            referencedColumn:
                                $$BillsTableReferences
                                    ._supplierFirmIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (clientFirmId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.clientFirmId,
                            referencedTable: $$BillsTableReferences
                                ._clientFirmIdTable(db),
                            referencedColumn:
                                $$BillsTableReferences
                                    ._clientFirmIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<Bill, $BillsTable, Payment>(
                      currentTable: table,
                      referencedTable: $$BillsTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$BillsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.billId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      Bill,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (Bill, $$BillsTableReferences),
      Bill,
      PrefetchHooks Function({
        bool tenderId,
        bool firmId,
        bool supplierFirmId,
        bool clientFirmId,
        bool paymentsRefs,
      })
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      required int billId,
      required DateTime paymentDate,
      Value<double> amountPaid,
      Value<DateTime?> paidDate,
      Value<String?> transactionNo,
      Value<DateTime?> dueReleaseDate,
      Value<String?> invoiceNo,
      Value<DateTime?> invoiceDate,
      Value<String?> workOrderNo,
      Value<DateTime?> workOrderDate,
      Value<String?> consignmentName,
      Value<String?> proofPath,
      Value<String?> remarks,
      Value<DateTime> lastEdited,
      Value<DateTime> createdAt,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      Value<int> billId,
      Value<DateTime> paymentDate,
      Value<double> amountPaid,
      Value<DateTime?> paidDate,
      Value<String?> transactionNo,
      Value<DateTime?> dueReleaseDate,
      Value<String?> invoiceNo,
      Value<DateTime?> invoiceDate,
      Value<String?> workOrderNo,
      Value<DateTime?> workOrderDate,
      Value<String?> consignmentName,
      Value<String?> proofPath,
      Value<String?> remarks,
      Value<DateTime> lastEdited,
      Value<DateTime> createdAt,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BillsTable _billIdTable(_$AppDatabase db) => db.bills.createAlias(
    $_aliasNameGenerator(db.payments.billId, db.bills.id),
  );

  $$BillsTableProcessedTableManager get billId {
    final $_column = $_itemColumn<int>('bill_id')!;

    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_billIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueReleaseDate => $composableBuilder(
    column: $table.dueReleaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNo => $composableBuilder(
    column: $table.invoiceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workOrderNo => $composableBuilder(
    column: $table.workOrderNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get workOrderDate => $composableBuilder(
    column: $table.workOrderDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consignmentName => $composableBuilder(
    column: $table.consignmentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proofPath => $composableBuilder(
    column: $table.proofPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastEdited => $composableBuilder(
    column: $table.lastEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueReleaseDate => $composableBuilder(
    column: $table.dueReleaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNo => $composableBuilder(
    column: $table.invoiceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workOrderNo => $composableBuilder(
    column: $table.workOrderNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get workOrderDate => $composableBuilder(
    column: $table.workOrderDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consignmentName => $composableBuilder(
    column: $table.consignmentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proofPath => $composableBuilder(
    column: $table.proofPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastEdited => $composableBuilder(
    column: $table.lastEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueReleaseDate => $composableBuilder(
    column: $table.dueReleaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceNo =>
      $composableBuilder(column: $table.invoiceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workOrderNo => $composableBuilder(
    column: $table.workOrderNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get workOrderDate => $composableBuilder(
    column: $table.workOrderDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consignmentName => $composableBuilder(
    column: $table.consignmentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proofPath =>
      $composableBuilder(column: $table.proofPath, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<DateTime> get lastEdited => $composableBuilder(
    column: $table.lastEdited,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BillsTableAnnotationComposer get billId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool billId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> billId = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String?> transactionNo = const Value.absent(),
                Value<DateTime?> dueReleaseDate = const Value.absent(),
                Value<String?> invoiceNo = const Value.absent(),
                Value<DateTime?> invoiceDate = const Value.absent(),
                Value<String?> workOrderNo = const Value.absent(),
                Value<DateTime?> workOrderDate = const Value.absent(),
                Value<String?> consignmentName = const Value.absent(),
                Value<String?> proofPath = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<DateTime> lastEdited = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                billId: billId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                paidDate: paidDate,
                transactionNo: transactionNo,
                dueReleaseDate: dueReleaseDate,
                invoiceNo: invoiceNo,
                invoiceDate: invoiceDate,
                workOrderNo: workOrderNo,
                workOrderDate: workOrderDate,
                consignmentName: consignmentName,
                proofPath: proofPath,
                remarks: remarks,
                lastEdited: lastEdited,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int billId,
                required DateTime paymentDate,
                Value<double> amountPaid = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String?> transactionNo = const Value.absent(),
                Value<DateTime?> dueReleaseDate = const Value.absent(),
                Value<String?> invoiceNo = const Value.absent(),
                Value<DateTime?> invoiceDate = const Value.absent(),
                Value<String?> workOrderNo = const Value.absent(),
                Value<DateTime?> workOrderDate = const Value.absent(),
                Value<String?> consignmentName = const Value.absent(),
                Value<String?> proofPath = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<DateTime> lastEdited = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                billId: billId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                paidDate: paidDate,
                transactionNo: transactionNo,
                dueReleaseDate: dueReleaseDate,
                invoiceNo: invoiceNo,
                invoiceDate: invoiceDate,
                workOrderNo: workOrderNo,
                workOrderDate: workOrderDate,
                consignmentName: consignmentName,
                proofPath: proofPath,
                remarks: remarks,
                lastEdited: lastEdited,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PaymentsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({billId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (billId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.billId,
                            referencedTable: $$PaymentsTableReferences
                                ._billIdTable(db),
                            referencedColumn:
                                $$PaymentsTableReferences._billIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool billId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FirmsTableTableManager get firms =>
      $$FirmsTableTableManager(_db, _db.firms);
  $$ClientFirmsTableTableManager get clientFirms =>
      $$ClientFirmsTableTableManager(_db, _db.clientFirms);
  $$TendersTableTableManager get tenders =>
      $$TendersTableTableManager(_db, _db.tenders);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
}
