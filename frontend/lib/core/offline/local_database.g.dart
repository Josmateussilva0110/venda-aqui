// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalProductsTable extends LocalProducts with TableInfo<$LocalProductsTable, LocalProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta('searchKey');
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbUrlMeta = const VerificationMeta('thumbUrl');
  @override
  late final GeneratedColumn<String> thumbUrl = GeneratedColumn<String>(
    'thumb_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salePriceCentsMeta = const VerificationMeta('salePriceCents');
  @override
  late final GeneratedColumn<int> salePriceCents = GeneratedColumn<int>(
    'sale_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceCentsMeta = const VerificationMeta('costPriceCents');
  @override
  late final GeneratedColumn<int> costPriceCents = GeneratedColumn<int>(
    'cost_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soldByWeightMeta = const VerificationMeta('soldByWeight');
  @override
  late final GeneratedColumn<bool> soldByWeight = GeneratedColumn<bool>(
    'sold_by_weight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("sold_by_weight" IN (0, 1))'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, searchKey, photoUrl, thumbUrl, salePriceCents, costPriceCents, quantity, soldByWeight];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_products';
  @override
  VerificationContext validateIntegrity(Insertable<LocalProduct> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(_searchKeyMeta, searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta));
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta, photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('thumb_url')) {
      context.handle(_thumbUrlMeta, thumbUrl.isAcceptableOrUnknown(data['thumb_url']!, _thumbUrlMeta));
    }
    if (data.containsKey('sale_price_cents')) {
      context.handle(_salePriceCentsMeta, salePriceCents.isAcceptableOrUnknown(data['sale_price_cents']!, _salePriceCentsMeta));
    } else if (isInserting) {
      context.missing(_salePriceCentsMeta);
    }
    if (data.containsKey('cost_price_cents')) {
      context.handle(_costPriceCentsMeta, costPriceCents.isAcceptableOrUnknown(data['cost_price_cents']!, _costPriceCentsMeta));
    } else if (isInserting) {
      context.missing(_costPriceCentsMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta, quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('sold_by_weight')) {
      context.handle(_soldByWeightMeta, soldByWeight.isAcceptableOrUnknown(data['sold_by_weight']!, _soldByWeightMeta));
    } else if (isInserting) {
      context.missing(_soldByWeightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProduct(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      searchKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}search_key'])!,
      photoUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      thumbUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}thumb_url']),
      salePriceCents: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sale_price_cents'])!,
      costPriceCents: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cost_price_cents'])!,
      quantity: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      soldByWeight: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}sold_by_weight'])!,
    );
  }

  @override
  $LocalProductsTable createAlias(String alias) {
    return $LocalProductsTable(attachedDatabase, alias);
  }
}

class LocalProduct extends DataClass implements Insertable<LocalProduct> {
  final String id;
  final String name;

  /// Nome em minúsculas, para a busca sem diferenciar maiúsculas (como o `ilike` do servidor).
  final String searchKey;
  final String? photoUrl;
  final String? thumbUrl;
  final int salePriceCents;
  final int costPriceCents;
  final double quantity;
  final bool soldByWeight;
  const LocalProduct({
    required this.id,
    required this.name,
    required this.searchKey,
    this.photoUrl,
    this.thumbUrl,
    required this.salePriceCents,
    required this.costPriceCents,
    required this.quantity,
    required this.soldByWeight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['search_key'] = Variable<String>(searchKey);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || thumbUrl != null) {
      map['thumb_url'] = Variable<String>(thumbUrl);
    }
    map['sale_price_cents'] = Variable<int>(salePriceCents);
    map['cost_price_cents'] = Variable<int>(costPriceCents);
    map['quantity'] = Variable<double>(quantity);
    map['sold_by_weight'] = Variable<bool>(soldByWeight);
    return map;
  }

  LocalProductsCompanion toCompanion(bool nullToAbsent) {
    return LocalProductsCompanion(
      id: Value(id),
      name: Value(name),
      searchKey: Value(searchKey),
      photoUrl: photoUrl == null && nullToAbsent ? const Value.absent() : Value(photoUrl),
      thumbUrl: thumbUrl == null && nullToAbsent ? const Value.absent() : Value(thumbUrl),
      salePriceCents: Value(salePriceCents),
      costPriceCents: Value(costPriceCents),
      quantity: Value(quantity),
      soldByWeight: Value(soldByWeight),
    );
  }

  factory LocalProduct.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProduct(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      thumbUrl: serializer.fromJson<String?>(json['thumbUrl']),
      salePriceCents: serializer.fromJson<int>(json['salePriceCents']),
      costPriceCents: serializer.fromJson<int>(json['costPriceCents']),
      quantity: serializer.fromJson<double>(json['quantity']),
      soldByWeight: serializer.fromJson<bool>(json['soldByWeight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'searchKey': serializer.toJson<String>(searchKey),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'thumbUrl': serializer.toJson<String?>(thumbUrl),
      'salePriceCents': serializer.toJson<int>(salePriceCents),
      'costPriceCents': serializer.toJson<int>(costPriceCents),
      'quantity': serializer.toJson<double>(quantity),
      'soldByWeight': serializer.toJson<bool>(soldByWeight),
    };
  }

  LocalProduct copyWith({
    String? id,
    String? name,
    String? searchKey,
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> thumbUrl = const Value.absent(),
    int? salePriceCents,
    int? costPriceCents,
    double? quantity,
    bool? soldByWeight,
  }) => LocalProduct(
    id: id ?? this.id,
    name: name ?? this.name,
    searchKey: searchKey ?? this.searchKey,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    thumbUrl: thumbUrl.present ? thumbUrl.value : this.thumbUrl,
    salePriceCents: salePriceCents ?? this.salePriceCents,
    costPriceCents: costPriceCents ?? this.costPriceCents,
    quantity: quantity ?? this.quantity,
    soldByWeight: soldByWeight ?? this.soldByWeight,
  );
  LocalProduct copyWithCompanion(LocalProductsCompanion data) {
    return LocalProduct(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      thumbUrl: data.thumbUrl.present ? data.thumbUrl.value : this.thumbUrl,
      salePriceCents: data.salePriceCents.present ? data.salePriceCents.value : this.salePriceCents,
      costPriceCents: data.costPriceCents.present ? data.costPriceCents.value : this.costPriceCents,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      soldByWeight: data.soldByWeight.present ? data.soldByWeight.value : this.soldByWeight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProduct(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('salePriceCents: $salePriceCents, ')
          ..write('costPriceCents: $costPriceCents, ')
          ..write('quantity: $quantity, ')
          ..write('soldByWeight: $soldByWeight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, searchKey, photoUrl, thumbUrl, salePriceCents, costPriceCents, quantity, soldByWeight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProduct &&
          other.id == this.id &&
          other.name == this.name &&
          other.searchKey == this.searchKey &&
          other.photoUrl == this.photoUrl &&
          other.thumbUrl == this.thumbUrl &&
          other.salePriceCents == this.salePriceCents &&
          other.costPriceCents == this.costPriceCents &&
          other.quantity == this.quantity &&
          other.soldByWeight == this.soldByWeight);
}

class LocalProductsCompanion extends UpdateCompanion<LocalProduct> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> searchKey;
  final Value<String?> photoUrl;
  final Value<String?> thumbUrl;
  final Value<int> salePriceCents;
  final Value<int> costPriceCents;
  final Value<double> quantity;
  final Value<bool> soldByWeight;
  final Value<int> rowid;
  const LocalProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.thumbUrl = const Value.absent(),
    this.salePriceCents = const Value.absent(),
    this.costPriceCents = const Value.absent(),
    this.quantity = const Value.absent(),
    this.soldByWeight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProductsCompanion.insert({
    required String id,
    required String name,
    required String searchKey,
    this.photoUrl = const Value.absent(),
    this.thumbUrl = const Value.absent(),
    required int salePriceCents,
    required int costPriceCents,
    required double quantity,
    required bool soldByWeight,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchKey = Value(searchKey),
       salePriceCents = Value(salePriceCents),
       costPriceCents = Value(costPriceCents),
       quantity = Value(quantity),
       soldByWeight = Value(soldByWeight);
  static Insertable<LocalProduct> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? searchKey,
    Expression<String>? photoUrl,
    Expression<String>? thumbUrl,
    Expression<int>? salePriceCents,
    Expression<int>? costPriceCents,
    Expression<double>? quantity,
    Expression<bool>? soldByWeight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (searchKey != null) 'search_key': searchKey,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (thumbUrl != null) 'thumb_url': thumbUrl,
      if (salePriceCents != null) 'sale_price_cents': salePriceCents,
      if (costPriceCents != null) 'cost_price_cents': costPriceCents,
      if (quantity != null) 'quantity': quantity,
      if (soldByWeight != null) 'sold_by_weight': soldByWeight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? searchKey,
    Value<String?>? photoUrl,
    Value<String?>? thumbUrl,
    Value<int>? salePriceCents,
    Value<int>? costPriceCents,
    Value<double>? quantity,
    Value<bool>? soldByWeight,
    Value<int>? rowid,
  }) {
    return LocalProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      searchKey: searchKey ?? this.searchKey,
      photoUrl: photoUrl ?? this.photoUrl,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      salePriceCents: salePriceCents ?? this.salePriceCents,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      quantity: quantity ?? this.quantity,
      soldByWeight: soldByWeight ?? this.soldByWeight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (thumbUrl.present) {
      map['thumb_url'] = Variable<String>(thumbUrl.value);
    }
    if (salePriceCents.present) {
      map['sale_price_cents'] = Variable<int>(salePriceCents.value);
    }
    if (costPriceCents.present) {
      map['cost_price_cents'] = Variable<int>(costPriceCents.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (soldByWeight.present) {
      map['sold_by_weight'] = Variable<bool>(soldByWeight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('salePriceCents: $salePriceCents, ')
          ..write('costPriceCents: $costPriceCents, ')
          ..write('quantity: $quantity, ')
          ..write('soldByWeight: $soldByWeight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCustomersTable extends LocalCustomers with TableInfo<$LocalCustomersTable, LocalCustomer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta('searchKey');
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceCentsMeta = const VerificationMeta('balanceCents');
  @override
  late final GeneratedColumn<int> balanceCents = GeneratedColumn<int>(
    'balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditDueDateMeta = const VerificationMeta('creditDueDate');
  @override
  late final GeneratedColumn<String> creditDueDate = GeneratedColumn<String>(
    'credit_due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, searchKey, phone, balanceCents, creditDueDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_customers';
  @override
  VerificationContext validateIntegrity(Insertable<LocalCustomer> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(_searchKeyMeta, searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta));
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(_phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('balance_cents')) {
      context.handle(_balanceCentsMeta, balanceCents.isAcceptableOrUnknown(data['balance_cents']!, _balanceCentsMeta));
    } else if (isInserting) {
      context.missing(_balanceCentsMeta);
    }
    if (data.containsKey('credit_due_date')) {
      context.handle(_creditDueDateMeta, creditDueDate.isAcceptableOrUnknown(data['credit_due_date']!, _creditDueDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCustomer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCustomer(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      searchKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}search_key'])!,
      phone: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      balanceCents: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}balance_cents'])!,
      creditDueDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}credit_due_date']),
    );
  }

  @override
  $LocalCustomersTable createAlias(String alias) {
    return $LocalCustomersTable(attachedDatabase, alias);
  }
}

class LocalCustomer extends DataClass implements Insertable<LocalCustomer> {
  final String id;
  final String name;
  final String searchKey;
  final String phone;
  final int balanceCents;

  /// "AAAA-MM-DD", como a API manda: guardar como data mudaria o dia em outro fuso.
  final String? creditDueDate;
  const LocalCustomer({
    required this.id,
    required this.name,
    required this.searchKey,
    required this.phone,
    required this.balanceCents,
    this.creditDueDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['search_key'] = Variable<String>(searchKey);
    map['phone'] = Variable<String>(phone);
    map['balance_cents'] = Variable<int>(balanceCents);
    if (!nullToAbsent || creditDueDate != null) {
      map['credit_due_date'] = Variable<String>(creditDueDate);
    }
    return map;
  }

  LocalCustomersCompanion toCompanion(bool nullToAbsent) {
    return LocalCustomersCompanion(
      id: Value(id),
      name: Value(name),
      searchKey: Value(searchKey),
      phone: Value(phone),
      balanceCents: Value(balanceCents),
      creditDueDate: creditDueDate == null && nullToAbsent ? const Value.absent() : Value(creditDueDate),
    );
  }

  factory LocalCustomer.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCustomer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      phone: serializer.fromJson<String>(json['phone']),
      balanceCents: serializer.fromJson<int>(json['balanceCents']),
      creditDueDate: serializer.fromJson<String?>(json['creditDueDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'searchKey': serializer.toJson<String>(searchKey),
      'phone': serializer.toJson<String>(phone),
      'balanceCents': serializer.toJson<int>(balanceCents),
      'creditDueDate': serializer.toJson<String?>(creditDueDate),
    };
  }

  LocalCustomer copyWith({
    String? id,
    String? name,
    String? searchKey,
    String? phone,
    int? balanceCents,
    Value<String?> creditDueDate = const Value.absent(),
  }) => LocalCustomer(
    id: id ?? this.id,
    name: name ?? this.name,
    searchKey: searchKey ?? this.searchKey,
    phone: phone ?? this.phone,
    balanceCents: balanceCents ?? this.balanceCents,
    creditDueDate: creditDueDate.present ? creditDueDate.value : this.creditDueDate,
  );
  LocalCustomer copyWithCompanion(LocalCustomersCompanion data) {
    return LocalCustomer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      phone: data.phone.present ? data.phone.value : this.phone,
      balanceCents: data.balanceCents.present ? data.balanceCents.value : this.balanceCents,
      creditDueDate: data.creditDueDate.present ? data.creditDueDate.value : this.creditDueDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCustomer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('phone: $phone, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('creditDueDate: $creditDueDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, searchKey, phone, balanceCents, creditDueDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCustomer &&
          other.id == this.id &&
          other.name == this.name &&
          other.searchKey == this.searchKey &&
          other.phone == this.phone &&
          other.balanceCents == this.balanceCents &&
          other.creditDueDate == this.creditDueDate);
}

class LocalCustomersCompanion extends UpdateCompanion<LocalCustomer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> searchKey;
  final Value<String> phone;
  final Value<int> balanceCents;
  final Value<String?> creditDueDate;
  final Value<int> rowid;
  const LocalCustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.phone = const Value.absent(),
    this.balanceCents = const Value.absent(),
    this.creditDueDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCustomersCompanion.insert({
    required String id,
    required String name,
    required String searchKey,
    required String phone,
    required int balanceCents,
    this.creditDueDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchKey = Value(searchKey),
       phone = Value(phone),
       balanceCents = Value(balanceCents);
  static Insertable<LocalCustomer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? searchKey,
    Expression<String>? phone,
    Expression<int>? balanceCents,
    Expression<String>? creditDueDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (searchKey != null) 'search_key': searchKey,
      if (phone != null) 'phone': phone,
      if (balanceCents != null) 'balance_cents': balanceCents,
      if (creditDueDate != null) 'credit_due_date': creditDueDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? searchKey,
    Value<String>? phone,
    Value<int>? balanceCents,
    Value<String?>? creditDueDate,
    Value<int>? rowid,
  }) {
    return LocalCustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      searchKey: searchKey ?? this.searchKey,
      phone: phone ?? this.phone,
      balanceCents: balanceCents ?? this.balanceCents,
      creditDueDate: creditDueDate ?? this.creditDueDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (balanceCents.present) {
      map['balance_cents'] = Variable<int>(balanceCents.value);
    }
    if (creditDueDate.present) {
      map['credit_due_date'] = Variable<String>(creditDueDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('phone: $phone, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('creditDueDate: $creditDueDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMarksTable extends SyncMarks with TableInfo<$SyncMarksTable, SyncMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_marks';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMark> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMark(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncMarksTable createAlias(String alias) {
    return $SyncMarksTable(attachedDatabase, alias);
  }
}

class SyncMark extends DataClass implements Insertable<SyncMark> {
  final String key;
  final String value;
  const SyncMark({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMarksCompanion toCompanion(bool nullToAbsent) {
    return SyncMarksCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMark.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMark(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SyncMark copyWith({String? key, String? value}) => SyncMark(key: key ?? this.key, value: value ?? this.value);
  SyncMark copyWithCompanion(SyncMarksCompanion data) {
    return SyncMark(key: data.key.present ? data.key.value : this.key, value: data.value.present ? data.value.value : this.value);
  }

  @override
  String toString() {
    return (StringBuffer('SyncMark(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is SyncMark && other.key == this.key && other.value == this.value);
}

class SyncMarksCompanion extends UpdateCompanion<SyncMark> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMarksCompanion({this.key = const Value.absent(), this.value = const Value.absent(), this.rowid = const Value.absent()});
  SyncMarksCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SyncMark> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({if (key != null) 'key': key, if (value != null) 'value': value, if (rowid != null) 'rowid': rowid});
  }

  SyncMarksCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncMarksCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMarksCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rejectedMeta = const VerificationMeta('rejected');
  @override
  late final GeneratedColumn<bool> rejected = GeneratedColumn<bool>(
    'rejected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("rejected" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ownerId, kind, payload, createdAt, sequence, attempts, rejected, lastError];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta, ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta, sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta, attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('rejected')) {
      context.handle(_rejectedMeta, rejected.isAcceptableOrUnknown(data['rejected']!, _rejectedMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta, lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payload: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      sequence: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      attempts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      rejected: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}rejected'])!,
      lastError: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  /// Gerado no aparelho e enviado ao servidor: reenviar a mesma alteração não a duplica.
  final String id;

  /// Comércio que fez a alteração: com outra conta no aparelho, ela espera o dono voltar.
  final String ownerId;

  /// Que tipo de alteração é (ex.: venda); decide quem envia.
  final String kind;

  /// Corpo da requisição, em JSON, exatamente como vai ao servidor.
  final String payload;
  final DateTime createdAt;

  /// Desempate da ordem: [createdAt] é guardado em segundos, e uma venda fiado seguida do pagamento do
  /// mesmo cliente no mesmo segundo não pode subir invertida (o pagamento seria recusado).
  final int sequence;
  final int attempts;

  /// Recusada pelo servidor (ex.: produto apagado): não é tentada de novo sozinha.
  final bool rejected;

  /// Motivo da recusa, já pronto para mostrar ao comerciante.
  final String? lastError;
  const OutboxEntry({
    required this.id,
    required this.ownerId,
    required this.kind,
    required this.payload,
    required this.createdAt,
    required this.sequence,
    required this.attempts,
    required this.rejected,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sequence'] = Variable<int>(sequence);
    map['attempts'] = Variable<int>(attempts);
    map['rejected'] = Variable<bool>(rejected);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      kind: Value(kind),
      payload: Value(payload),
      createdAt: Value(createdAt),
      sequence: Value(sequence),
      attempts: Value(attempts),
      rejected: Value(rejected),
      lastError: lastError == null && nullToAbsent ? const Value.absent() : Value(lastError),
    );
  }

  factory OutboxEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sequence: serializer.fromJson<int>(json['sequence']),
      attempts: serializer.fromJson<int>(json['attempts']),
      rejected: serializer.fromJson<bool>(json['rejected']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sequence': serializer.toJson<int>(sequence),
      'attempts': serializer.toJson<int>(attempts),
      'rejected': serializer.toJson<bool>(rejected),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntry copyWith({
    String? id,
    String? ownerId,
    String? kind,
    String? payload,
    DateTime? createdAt,
    int? sequence,
    int? attempts,
    bool? rejected,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxEntry(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    sequence: sequence ?? this.sequence,
    attempts: attempts ?? this.attempts,
    rejected: rejected ?? this.rejected,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      rejected: data.rejected.present ? data.rejected.value : this.rejected,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('sequence: $sequence, ')
          ..write('attempts: $attempts, ')
          ..write('rejected: $rejected, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, kind, payload, createdAt, sequence, attempts, rejected, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.kind == this.kind &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.sequence == this.sequence &&
          other.attempts == this.attempts &&
          other.rejected == this.rejected &&
          other.lastError == this.lastError);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> kind;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> sequence;
  final Value<int> attempts;
  final Value<bool> rejected;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sequence = const Value.absent(),
    this.attempts = const Value.absent(),
    this.rejected = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    required String id,
    required String ownerId,
    required String kind,
    required String payload,
    required DateTime createdAt,
    this.sequence = const Value.absent(),
    this.attempts = const Value.absent(),
    this.rejected = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       kind = Value(kind),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? sequence,
    Expression<int>? attempts,
    Expression<bool>? rejected,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (sequence != null) 'sequence': sequence,
      if (attempts != null) 'attempts': attempts,
      if (rejected != null) 'rejected': rejected,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? kind,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? sequence,
    Value<int>? attempts,
    Value<bool>? rejected,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      sequence: sequence ?? this.sequence,
      attempts: attempts ?? this.attempts,
      rejected: rejected ?? this.rejected,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (rejected.present) {
      map['rejected'] = Variable<bool>(rejected.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('sequence: $sequence, ')
          ..write('attempts: $attempts, ')
          ..write('rejected: $rejected, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $LocalProductsTable localProducts = $LocalProductsTable(this);
  late final $LocalCustomersTable localCustomers = $LocalCustomersTable(this);
  late final $SyncMarksTable syncMarks = $SyncMarksTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final Index localProductsSearchKey = Index(
    'local_products_search_key',
    'CREATE INDEX local_products_search_key ON local_products (search_key)',
  );
  late final Index localCustomersSearchKey = Index(
    'local_customers_search_key',
    'CREATE INDEX local_customers_search_key ON local_customers (search_key)',
  );
  late final Index outboxOwnerCreated = Index(
    'outbox_owner_created',
    'CREATE INDEX outbox_owner_created ON outbox_entries (owner_id, created_at, sequence)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localProducts,
    localCustomers,
    syncMarks,
    outboxEntries,
    localProductsSearchKey,
    localCustomersSearchKey,
    outboxOwnerCreated,
  ];
}

typedef $$LocalProductsTableCreateCompanionBuilder = LocalProductsCompanion Function({
  required String id,
  required String name,
  required String searchKey,
  Value<String?> photoUrl,
  Value<String?> thumbUrl,
  required int salePriceCents,
  required int costPriceCents,
  required double quantity,
  required bool soldByWeight,
  Value<int> rowid,
});
typedef $$LocalProductsTableUpdateCompanionBuilder = LocalProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> searchKey,
  Value<String?> photoUrl,
  Value<String?> thumbUrl,
  Value<int> salePriceCents,
  Value<int> costPriceCents,
  Value<double> quantity,
  Value<bool> soldByWeight,
  Value<int> rowid,
});

class $$LocalProductsTableFilterComposer extends Composer<_$LocalDatabase, $LocalProductsTable> {
  $$LocalProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchKey => $composableBuilder(column: $table.searchKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbUrl => $composableBuilder(column: $table.thumbUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get salePriceCents => $composableBuilder(column: $table.salePriceCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get costPriceCents => $composableBuilder(column: $table.costPriceCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get soldByWeight => $composableBuilder(column: $table.soldByWeight, builder: (column) => ColumnFilters(column));
}

class $$LocalProductsTableOrderingComposer extends Composer<_$LocalDatabase, $LocalProductsTable> {
  $$LocalProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchKey => $composableBuilder(column: $table.searchKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbUrl => $composableBuilder(column: $table.thumbUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get salePriceCents =>
      $composableBuilder(column: $table.salePriceCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get costPriceCents =>
      $composableBuilder(column: $table.costPriceCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get soldByWeight => $composableBuilder(column: $table.soldByWeight, builder: (column) => ColumnOrderings(column));
}

class $$LocalProductsTableAnnotationComposer extends Composer<_$LocalDatabase, $LocalProductsTable> {
  $$LocalProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchKey => $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<String> get photoUrl => $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbUrl => $composableBuilder(column: $table.thumbUrl, builder: (column) => column);

  GeneratedColumn<int> get salePriceCents => $composableBuilder(column: $table.salePriceCents, builder: (column) => column);

  GeneratedColumn<int> get costPriceCents => $composableBuilder(column: $table.costPriceCents, builder: (column) => column);

  GeneratedColumn<double> get quantity => $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get soldByWeight => $composableBuilder(column: $table.soldByWeight, builder: (column) => column);
}

class $$LocalProductsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalProductsTable,
          LocalProduct,
          $$LocalProductsTableFilterComposer,
          $$LocalProductsTableOrderingComposer,
          $$LocalProductsTableAnnotationComposer,
          $$LocalProductsTableCreateCompanionBuilder,
          $$LocalProductsTableUpdateCompanionBuilder,
          (LocalProduct, BaseReferences<_$LocalDatabase, $LocalProductsTable, LocalProduct>),
          LocalProduct,
          PrefetchHooks Function()
        > {
  $$LocalProductsTableTableManager(_$LocalDatabase db, $LocalProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LocalProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LocalProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LocalProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> thumbUrl = const Value.absent(),
                Value<int> salePriceCents = const Value.absent(),
                Value<int> costPriceCents = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<bool> soldByWeight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductsCompanion(
                id: id,
                name: name,
                searchKey: searchKey,
                photoUrl: photoUrl,
                thumbUrl: thumbUrl,
                salePriceCents: salePriceCents,
                costPriceCents: costPriceCents,
                quantity: quantity,
                soldByWeight: soldByWeight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String searchKey,
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> thumbUrl = const Value.absent(),
                required int salePriceCents,
                required int costPriceCents,
                required double quantity,
                required bool soldByWeight,
                Value<int> rowid = const Value.absent(),
              }) => LocalProductsCompanion.insert(
                id: id,
                name: name,
                searchKey: searchKey,
                photoUrl: photoUrl,
                thumbUrl: thumbUrl,
                salePriceCents: salePriceCents,
                costPriceCents: costPriceCents,
                quantity: quantity,
                soldByWeight: soldByWeight,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProductsTable, LocalProduct>(table),
                  BaseReferences<_$LocalDatabase, $LocalProductsTable, LocalProduct>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalProductsTable,
      LocalProduct,
      $$LocalProductsTableFilterComposer,
      $$LocalProductsTableOrderingComposer,
      $$LocalProductsTableAnnotationComposer,
      $$LocalProductsTableCreateCompanionBuilder,
      $$LocalProductsTableUpdateCompanionBuilder,
      (LocalProduct, BaseReferences<_$LocalDatabase, $LocalProductsTable, LocalProduct>),
      LocalProduct,
      PrefetchHooks Function()
    >;
typedef $$LocalCustomersTableCreateCompanionBuilder = LocalCustomersCompanion Function({
  required String id,
  required String name,
  required String searchKey,
  required String phone,
  required int balanceCents,
  Value<String?> creditDueDate,
  Value<int> rowid,
});
typedef $$LocalCustomersTableUpdateCompanionBuilder = LocalCustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> searchKey,
  Value<String> phone,
  Value<int> balanceCents,
  Value<String?> creditDueDate,
  Value<int> rowid,
});

class $$LocalCustomersTableFilterComposer extends Composer<_$LocalDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchKey => $composableBuilder(column: $table.searchKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceCents => $composableBuilder(column: $table.balanceCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creditDueDate => $composableBuilder(column: $table.creditDueDate, builder: (column) => ColumnFilters(column));
}

class $$LocalCustomersTableOrderingComposer extends Composer<_$LocalDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchKey => $composableBuilder(column: $table.searchKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceCents => $composableBuilder(column: $table.balanceCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creditDueDate =>
      $composableBuilder(column: $table.creditDueDate, builder: (column) => ColumnOrderings(column));
}

class $$LocalCustomersTableAnnotationComposer extends Composer<_$LocalDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchKey => $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<String> get phone => $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get balanceCents => $composableBuilder(column: $table.balanceCents, builder: (column) => column);

  GeneratedColumn<String> get creditDueDate => $composableBuilder(column: $table.creditDueDate, builder: (column) => column);
}

class $$LocalCustomersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalCustomersTable,
          LocalCustomer,
          $$LocalCustomersTableFilterComposer,
          $$LocalCustomersTableOrderingComposer,
          $$LocalCustomersTableAnnotationComposer,
          $$LocalCustomersTableCreateCompanionBuilder,
          $$LocalCustomersTableUpdateCompanionBuilder,
          (LocalCustomer, BaseReferences<_$LocalDatabase, $LocalCustomersTable, LocalCustomer>),
          LocalCustomer,
          PrefetchHooks Function()
        > {
  $$LocalCustomersTableTableManager(_$LocalDatabase db, $LocalCustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LocalCustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LocalCustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LocalCustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<int> balanceCents = const Value.absent(),
                Value<String?> creditDueDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCustomersCompanion(
                id: id,
                name: name,
                searchKey: searchKey,
                phone: phone,
                balanceCents: balanceCents,
                creditDueDate: creditDueDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String searchKey,
                required String phone,
                required int balanceCents,
                Value<String?> creditDueDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCustomersCompanion.insert(
                id: id,
                name: name,
                searchKey: searchKey,
                phone: phone,
                balanceCents: balanceCents,
                creditDueDate: creditDueDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCustomersTable, LocalCustomer>(table),
                  BaseReferences<_$LocalDatabase, $LocalCustomersTable, LocalCustomer>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalCustomersTable,
      LocalCustomer,
      $$LocalCustomersTableFilterComposer,
      $$LocalCustomersTableOrderingComposer,
      $$LocalCustomersTableAnnotationComposer,
      $$LocalCustomersTableCreateCompanionBuilder,
      $$LocalCustomersTableUpdateCompanionBuilder,
      (LocalCustomer, BaseReferences<_$LocalDatabase, $LocalCustomersTable, LocalCustomer>),
      LocalCustomer,
      PrefetchHooks Function()
    >;
typedef $$SyncMarksTableCreateCompanionBuilder = SyncMarksCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncMarksTableUpdateCompanionBuilder = SyncMarksCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$SyncMarksTableFilterComposer extends Composer<_$LocalDatabase, $SyncMarksTable> {
  $$SyncMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncMarksTableOrderingComposer extends Composer<_$LocalDatabase, $SyncMarksTable> {
  $$SyncMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncMarksTableAnnotationComposer extends Composer<_$LocalDatabase, $SyncMarksTable> {
  $$SyncMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMarksTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SyncMarksTable,
          SyncMark,
          $$SyncMarksTableFilterComposer,
          $$SyncMarksTableOrderingComposer,
          $$SyncMarksTableAnnotationComposer,
          $$SyncMarksTableCreateCompanionBuilder,
          $$SyncMarksTableUpdateCompanionBuilder,
          (SyncMark, BaseReferences<_$LocalDatabase, $SyncMarksTable, SyncMark>),
          SyncMark,
          PrefetchHooks Function()
        > {
  $$SyncMarksTableTableManager(_$LocalDatabase db, $SyncMarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SyncMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncMarksCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
              SyncMarksCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMarksTable, SyncMark>(table),
                  BaseReferences<_$LocalDatabase, $SyncMarksTable, SyncMark>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SyncMarksTable,
      SyncMark,
      $$SyncMarksTableFilterComposer,
      $$SyncMarksTableOrderingComposer,
      $$SyncMarksTableAnnotationComposer,
      $$SyncMarksTableCreateCompanionBuilder,
      $$SyncMarksTableUpdateCompanionBuilder,
      (SyncMark, BaseReferences<_$LocalDatabase, $SyncMarksTable, SyncMark>),
      SyncMark,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder = OutboxEntriesCompanion Function({
  required String id,
  required String ownerId,
  required String kind,
  required String payload,
  required DateTime createdAt,
  Value<int> sequence,
  Value<int> attempts,
  Value<bool> rejected,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$OutboxEntriesTableUpdateCompanionBuilder = OutboxEntriesCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> kind,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> sequence,
  Value<int> attempts,
  Value<bool> rejected,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$OutboxEntriesTableFilterComposer extends Composer<_$LocalDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequence => $composableBuilder(column: $table.sequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rejected => $composableBuilder(column: $table.rejected, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$OutboxEntriesTableOrderingComposer extends Composer<_$LocalDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequence => $composableBuilder(column: $table.sequence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rejected => $composableBuilder(column: $table.rejected, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$OutboxEntriesTableAnnotationComposer extends Composer<_$LocalDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId => $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sequence => $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<bool> get rejected => $composableBuilder(column: $table.rejected, builder: (column) => column);

  GeneratedColumn<String> get lastError => $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (OutboxEntry, BaseReferences<_$LocalDatabase, $OutboxEntriesTable, OutboxEntry>),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$LocalDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<bool> rejected = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                ownerId: ownerId,
                kind: kind,
                payload: payload,
                createdAt: createdAt,
                sequence: sequence,
                attempts: attempts,
                rejected: rejected,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String kind,
                required String payload,
                required DateTime createdAt,
                Value<int> sequence = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<bool> rejected = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                ownerId: ownerId,
                kind: kind,
                payload: payload,
                createdAt: createdAt,
                sequence: sequence,
                attempts: attempts,
                rejected: rejected,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxEntriesTable, OutboxEntry>(table),
                  BaseReferences<_$LocalDatabase, $OutboxEntriesTable, OutboxEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (OutboxEntry, BaseReferences<_$LocalDatabase, $OutboxEntriesTable, OutboxEntry>),
      OutboxEntry,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$LocalProductsTableTableManager get localProducts => $$LocalProductsTableTableManager(_db, _db.localProducts);
  $$LocalCustomersTableTableManager get localCustomers => $$LocalCustomersTableTableManager(_db, _db.localCustomers);
  $$SyncMarksTableTableManager get syncMarks => $$SyncMarksTableTableManager(_db, _db.syncMarks);
  $$OutboxEntriesTableTableManager get outboxEntries => $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
}
