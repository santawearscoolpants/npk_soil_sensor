// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CropParamsTable extends CropParams
    with TableInfo<$CropParamsTable, CropParam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropParamsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soilTypeMeta = const VerificationMeta(
    'soilType',
  );
  @override
  late final GeneratedColumn<String> soilType = GeneratedColumn<String>(
    'soil_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soilPropertiesMeta = const VerificationMeta(
    'soilProperties',
  );
  @override
  late final GeneratedColumn<String> soilProperties = GeneratedColumn<String>(
    'soil_properties',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leafColorMeta = const VerificationMeta(
    'leafColor',
  );
  @override
  late final GeneratedColumn<String> leafColor = GeneratedColumn<String>(
    'leaf_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stemDescriptionMeta = const VerificationMeta(
    'stemDescription',
  );
  @override
  late final GeneratedColumn<String> stemDescription = GeneratedColumn<String>(
    'stem_description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    soilType,
    soilProperties,
    leafColor,
    stemDescription,
    heightCm,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_params';
  @override
  VerificationContext validateIntegrity(
    Insertable<CropParam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('soil_type')) {
      context.handle(
        _soilTypeMeta,
        soilType.isAcceptableOrUnknown(data['soil_type']!, _soilTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_soilTypeMeta);
    }
    if (data.containsKey('soil_properties')) {
      context.handle(
        _soilPropertiesMeta,
        soilProperties.isAcceptableOrUnknown(
          data['soil_properties']!,
          _soilPropertiesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soilPropertiesMeta);
    }
    if (data.containsKey('leaf_color')) {
      context.handle(
        _leafColorMeta,
        leafColor.isAcceptableOrUnknown(data['leaf_color']!, _leafColorMeta),
      );
    } else if (isInserting) {
      context.missing(_leafColorMeta);
    }
    if (data.containsKey('stem_description')) {
      context.handle(
        _stemDescriptionMeta,
        stemDescription.isAcceptableOrUnknown(
          data['stem_description']!,
          _stemDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stemDescriptionMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropParam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropParam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      soilType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_type'],
      )!,
      soilProperties: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_properties'],
      )!,
      leafColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaf_color'],
      )!,
      stemDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stem_description'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CropParamsTable createAlias(String alias) {
    return $CropParamsTable(attachedDatabase, alias);
  }
}

class CropParam extends DataClass implements Insertable<CropParam> {
  final int id;
  final DateTime createdAt;
  final String soilType;
  final String soilProperties;
  final String leafColor;
  final String stemDescription;
  final double heightCm;
  final String? notes;
  const CropParam({
    required this.id,
    required this.createdAt,
    required this.soilType,
    required this.soilProperties,
    required this.leafColor,
    required this.stemDescription,
    required this.heightCm,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['soil_type'] = Variable<String>(soilType);
    map['soil_properties'] = Variable<String>(soilProperties);
    map['leaf_color'] = Variable<String>(leafColor);
    map['stem_description'] = Variable<String>(stemDescription);
    map['height_cm'] = Variable<double>(heightCm);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CropParamsCompanion toCompanion(bool nullToAbsent) {
    return CropParamsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      soilType: Value(soilType),
      soilProperties: Value(soilProperties),
      leafColor: Value(leafColor),
      stemDescription: Value(stemDescription),
      heightCm: Value(heightCm),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CropParam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropParam(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      soilType: serializer.fromJson<String>(json['soilType']),
      soilProperties: serializer.fromJson<String>(json['soilProperties']),
      leafColor: serializer.fromJson<String>(json['leafColor']),
      stemDescription: serializer.fromJson<String>(json['stemDescription']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'soilType': serializer.toJson<String>(soilType),
      'soilProperties': serializer.toJson<String>(soilProperties),
      'leafColor': serializer.toJson<String>(leafColor),
      'stemDescription': serializer.toJson<String>(stemDescription),
      'heightCm': serializer.toJson<double>(heightCm),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CropParam copyWith({
    int? id,
    DateTime? createdAt,
    String? soilType,
    String? soilProperties,
    String? leafColor,
    String? stemDescription,
    double? heightCm,
    Value<String?> notes = const Value.absent(),
  }) => CropParam(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    soilType: soilType ?? this.soilType,
    soilProperties: soilProperties ?? this.soilProperties,
    leafColor: leafColor ?? this.leafColor,
    stemDescription: stemDescription ?? this.stemDescription,
    heightCm: heightCm ?? this.heightCm,
    notes: notes.present ? notes.value : this.notes,
  );
  CropParam copyWithCompanion(CropParamsCompanion data) {
    return CropParam(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      soilType: data.soilType.present ? data.soilType.value : this.soilType,
      soilProperties: data.soilProperties.present
          ? data.soilProperties.value
          : this.soilProperties,
      leafColor: data.leafColor.present ? data.leafColor.value : this.leafColor,
      stemDescription: data.stemDescription.present
          ? data.stemDescription.value
          : this.stemDescription,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropParam(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('soilType: $soilType, ')
          ..write('soilProperties: $soilProperties, ')
          ..write('leafColor: $leafColor, ')
          ..write('stemDescription: $stemDescription, ')
          ..write('heightCm: $heightCm, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    soilType,
    soilProperties,
    leafColor,
    stemDescription,
    heightCm,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropParam &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.soilType == this.soilType &&
          other.soilProperties == this.soilProperties &&
          other.leafColor == this.leafColor &&
          other.stemDescription == this.stemDescription &&
          other.heightCm == this.heightCm &&
          other.notes == this.notes);
}

class CropParamsCompanion extends UpdateCompanion<CropParam> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> soilType;
  final Value<String> soilProperties;
  final Value<String> leafColor;
  final Value<String> stemDescription;
  final Value<double> heightCm;
  final Value<String?> notes;
  const CropParamsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.soilType = const Value.absent(),
    this.soilProperties = const Value.absent(),
    this.leafColor = const Value.absent(),
    this.stemDescription = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CropParamsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required String soilType,
    required String soilProperties,
    required String leafColor,
    required String stemDescription,
    required double heightCm,
    this.notes = const Value.absent(),
  }) : createdAt = Value(createdAt),
       soilType = Value(soilType),
       soilProperties = Value(soilProperties),
       leafColor = Value(leafColor),
       stemDescription = Value(stemDescription),
       heightCm = Value(heightCm);
  static Insertable<CropParam> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? soilType,
    Expression<String>? soilProperties,
    Expression<String>? leafColor,
    Expression<String>? stemDescription,
    Expression<double>? heightCm,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (soilType != null) 'soil_type': soilType,
      if (soilProperties != null) 'soil_properties': soilProperties,
      if (leafColor != null) 'leaf_color': leafColor,
      if (stemDescription != null) 'stem_description': stemDescription,
      if (heightCm != null) 'height_cm': heightCm,
      if (notes != null) 'notes': notes,
    });
  }

  CropParamsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? soilType,
    Value<String>? soilProperties,
    Value<String>? leafColor,
    Value<String>? stemDescription,
    Value<double>? heightCm,
    Value<String?>? notes,
  }) {
    return CropParamsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      soilType: soilType ?? this.soilType,
      soilProperties: soilProperties ?? this.soilProperties,
      leafColor: leafColor ?? this.leafColor,
      stemDescription: stemDescription ?? this.stemDescription,
      heightCm: heightCm ?? this.heightCm,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (soilType.present) {
      map['soil_type'] = Variable<String>(soilType.value);
    }
    if (soilProperties.present) {
      map['soil_properties'] = Variable<String>(soilProperties.value);
    }
    if (leafColor.present) {
      map['leaf_color'] = Variable<String>(leafColor.value);
    }
    if (stemDescription.present) {
      map['stem_description'] = Variable<String>(stemDescription.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropParamsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('soilType: $soilType, ')
          ..write('soilProperties: $soilProperties, ')
          ..write('leafColor: $leafColor, ')
          ..write('stemDescription: $stemDescription, ')
          ..write('heightCm: $heightCm, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SensorReadingsTable extends SensorReadings
    with TableInfo<$SensorReadingsTable, SensorReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorReadingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moistureMeta = const VerificationMeta(
    'moisture',
  );
  @override
  late final GeneratedColumn<double> moisture = GeneratedColumn<double>(
    'moisture',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ecMeta = const VerificationMeta('ec');
  @override
  late final GeneratedColumn<double> ec = GeneratedColumn<double>(
    'ec',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phMeta = const VerificationMeta('ph');
  @override
  late final GeneratedColumn<double> ph = GeneratedColumn<double>(
    'ph',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nitrogenMeta = const VerificationMeta(
    'nitrogen',
  );
  @override
  late final GeneratedColumn<int> nitrogen = GeneratedColumn<int>(
    'nitrogen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phosphorusMeta = const VerificationMeta(
    'phosphorus',
  );
  @override
  late final GeneratedColumn<int> phosphorus = GeneratedColumn<int>(
    'phosphorus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _potassiumMeta = const VerificationMeta(
    'potassium',
  );
  @override
  late final GeneratedColumn<int> potassium = GeneratedColumn<int>(
    'potassium',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salinityMeta = const VerificationMeta(
    'salinity',
  );
  @override
  late final GeneratedColumn<double> salinity = GeneratedColumn<double>(
    'salinity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tdsMeta = const VerificationMeta('tds');
  @override
  late final GeneratedColumn<int> tds = GeneratedColumn<int>(
    'tds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ecConvMeta = const VerificationMeta('ecConv');
  @override
  late final GeneratedColumn<double> ecConv = GeneratedColumn<double>(
    'ec_conv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ecCalMeta = const VerificationMeta('ecCal');
  @override
  late final GeneratedColumn<double> ecCal = GeneratedColumn<double>(
    'ec_cal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phConvMeta = const VerificationMeta('phConv');
  @override
  late final GeneratedColumn<double> phConv = GeneratedColumn<double>(
    'ph_conv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phCalMeta = const VerificationMeta('phCal');
  @override
  late final GeneratedColumn<double> phCal = GeneratedColumn<double>(
    'ph_cal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nConvMeta = const VerificationMeta('nConv');
  @override
  late final GeneratedColumn<double> nConv = GeneratedColumn<double>(
    'n_conv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nCalMeta = const VerificationMeta('nCal');
  @override
  late final GeneratedColumn<double> nCal = GeneratedColumn<double>(
    'n_cal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pConvMeta = const VerificationMeta('pConv');
  @override
  late final GeneratedColumn<double> pConv = GeneratedColumn<double>(
    'p_conv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pCalMeta = const VerificationMeta('pCal');
  @override
  late final GeneratedColumn<double> pCal = GeneratedColumn<double>(
    'p_cal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kConvMeta = const VerificationMeta('kConv');
  @override
  late final GeneratedColumn<double> kConv = GeneratedColumn<double>(
    'k_conv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kCalMeta = const VerificationMeta('kCal');
  @override
  late final GeneratedColumn<double> kCal = GeneratedColumn<double>(
    'k_cal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cropParamsIdMeta = const VerificationMeta(
    'cropParamsId',
  );
  @override
  late final GeneratedColumn<int> cropParamsId = GeneratedColumn<int>(
    'crop_params_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crop_params (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    moisture,
    ec,
    temperature,
    ph,
    nitrogen,
    phosphorus,
    potassium,
    salinity,
    tds,
    ecConv,
    ecCal,
    phConv,
    phCal,
    nConv,
    nCal,
    pConv,
    pCal,
    kConv,
    kCal,
    cropParamsId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('moisture')) {
      context.handle(
        _moistureMeta,
        moisture.isAcceptableOrUnknown(data['moisture']!, _moistureMeta),
      );
    } else if (isInserting) {
      context.missing(_moistureMeta);
    }
    if (data.containsKey('ec')) {
      context.handle(_ecMeta, ec.isAcceptableOrUnknown(data['ec']!, _ecMeta));
    } else if (isInserting) {
      context.missing(_ecMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMeta);
    }
    if (data.containsKey('ph')) {
      context.handle(_phMeta, ph.isAcceptableOrUnknown(data['ph']!, _phMeta));
    } else if (isInserting) {
      context.missing(_phMeta);
    }
    if (data.containsKey('nitrogen')) {
      context.handle(
        _nitrogenMeta,
        nitrogen.isAcceptableOrUnknown(data['nitrogen']!, _nitrogenMeta),
      );
    } else if (isInserting) {
      context.missing(_nitrogenMeta);
    }
    if (data.containsKey('phosphorus')) {
      context.handle(
        _phosphorusMeta,
        phosphorus.isAcceptableOrUnknown(data['phosphorus']!, _phosphorusMeta),
      );
    } else if (isInserting) {
      context.missing(_phosphorusMeta);
    }
    if (data.containsKey('potassium')) {
      context.handle(
        _potassiumMeta,
        potassium.isAcceptableOrUnknown(data['potassium']!, _potassiumMeta),
      );
    } else if (isInserting) {
      context.missing(_potassiumMeta);
    }
    if (data.containsKey('salinity')) {
      context.handle(
        _salinityMeta,
        salinity.isAcceptableOrUnknown(data['salinity']!, _salinityMeta),
      );
    } else if (isInserting) {
      context.missing(_salinityMeta);
    }
    if (data.containsKey('tds')) {
      context.handle(
        _tdsMeta,
        tds.isAcceptableOrUnknown(data['tds']!, _tdsMeta),
      );
    }
    if (data.containsKey('ec_conv')) {
      context.handle(
        _ecConvMeta,
        ecConv.isAcceptableOrUnknown(data['ec_conv']!, _ecConvMeta),
      );
    }
    if (data.containsKey('ec_cal')) {
      context.handle(
        _ecCalMeta,
        ecCal.isAcceptableOrUnknown(data['ec_cal']!, _ecCalMeta),
      );
    }
    if (data.containsKey('ph_conv')) {
      context.handle(
        _phConvMeta,
        phConv.isAcceptableOrUnknown(data['ph_conv']!, _phConvMeta),
      );
    }
    if (data.containsKey('ph_cal')) {
      context.handle(
        _phCalMeta,
        phCal.isAcceptableOrUnknown(data['ph_cal']!, _phCalMeta),
      );
    }
    if (data.containsKey('n_conv')) {
      context.handle(
        _nConvMeta,
        nConv.isAcceptableOrUnknown(data['n_conv']!, _nConvMeta),
      );
    }
    if (data.containsKey('n_cal')) {
      context.handle(
        _nCalMeta,
        nCal.isAcceptableOrUnknown(data['n_cal']!, _nCalMeta),
      );
    }
    if (data.containsKey('p_conv')) {
      context.handle(
        _pConvMeta,
        pConv.isAcceptableOrUnknown(data['p_conv']!, _pConvMeta),
      );
    }
    if (data.containsKey('p_cal')) {
      context.handle(
        _pCalMeta,
        pCal.isAcceptableOrUnknown(data['p_cal']!, _pCalMeta),
      );
    }
    if (data.containsKey('k_conv')) {
      context.handle(
        _kConvMeta,
        kConv.isAcceptableOrUnknown(data['k_conv']!, _kConvMeta),
      );
    }
    if (data.containsKey('k_cal')) {
      context.handle(
        _kCalMeta,
        kCal.isAcceptableOrUnknown(data['k_cal']!, _kCalMeta),
      );
    }
    if (data.containsKey('crop_params_id')) {
      context.handle(
        _cropParamsIdMeta,
        cropParamsId.isAcceptableOrUnknown(
          data['crop_params_id']!,
          _cropParamsIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      moisture: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}moisture'],
      )!,
      ec: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ec'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      )!,
      ph: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph'],
      )!,
      nitrogen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nitrogen'],
      )!,
      phosphorus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phosphorus'],
      )!,
      potassium: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}potassium'],
      )!,
      salinity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salinity'],
      )!,
      tds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tds'],
      )!,
      ecConv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ec_conv'],
      ),
      ecCal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ec_cal'],
      ),
      phConv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_conv'],
      ),
      phCal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_cal'],
      ),
      nConv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}n_conv'],
      ),
      nCal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}n_cal'],
      ),
      pConv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}p_conv'],
      ),
      pCal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}p_cal'],
      ),
      kConv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}k_conv'],
      ),
      kCal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}k_cal'],
      ),
      cropParamsId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}crop_params_id'],
      ),
    );
  }

  @override
  $SensorReadingsTable createAlias(String alias) {
    return $SensorReadingsTable(attachedDatabase, alias);
  }
}

class SensorReading extends DataClass implements Insertable<SensorReading> {
  final int id;
  final DateTime timestamp;
  final double moisture;
  final double ec;
  final double temperature;
  final double ph;
  final int nitrogen;
  final int phosphorus;
  final int potassium;
  final double salinity;
  final int tds;
  final double? ecConv;
  final double? ecCal;
  final double? phConv;
  final double? phCal;
  final double? nConv;
  final double? nCal;
  final double? pConv;
  final double? pCal;
  final double? kConv;
  final double? kCal;
  final int? cropParamsId;
  const SensorReading({
    required this.id,
    required this.timestamp,
    required this.moisture,
    required this.ec,
    required this.temperature,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.salinity,
    required this.tds,
    this.ecConv,
    this.ecCal,
    this.phConv,
    this.phCal,
    this.nConv,
    this.nCal,
    this.pConv,
    this.pCal,
    this.kConv,
    this.kCal,
    this.cropParamsId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['moisture'] = Variable<double>(moisture);
    map['ec'] = Variable<double>(ec);
    map['temperature'] = Variable<double>(temperature);
    map['ph'] = Variable<double>(ph);
    map['nitrogen'] = Variable<int>(nitrogen);
    map['phosphorus'] = Variable<int>(phosphorus);
    map['potassium'] = Variable<int>(potassium);
    map['salinity'] = Variable<double>(salinity);
    map['tds'] = Variable<int>(tds);
    if (!nullToAbsent || ecConv != null) {
      map['ec_conv'] = Variable<double>(ecConv);
    }
    if (!nullToAbsent || ecCal != null) {
      map['ec_cal'] = Variable<double>(ecCal);
    }
    if (!nullToAbsent || phConv != null) {
      map['ph_conv'] = Variable<double>(phConv);
    }
    if (!nullToAbsent || phCal != null) {
      map['ph_cal'] = Variable<double>(phCal);
    }
    if (!nullToAbsent || nConv != null) {
      map['n_conv'] = Variable<double>(nConv);
    }
    if (!nullToAbsent || nCal != null) {
      map['n_cal'] = Variable<double>(nCal);
    }
    if (!nullToAbsent || pConv != null) {
      map['p_conv'] = Variable<double>(pConv);
    }
    if (!nullToAbsent || pCal != null) {
      map['p_cal'] = Variable<double>(pCal);
    }
    if (!nullToAbsent || kConv != null) {
      map['k_conv'] = Variable<double>(kConv);
    }
    if (!nullToAbsent || kCal != null) {
      map['k_cal'] = Variable<double>(kCal);
    }
    if (!nullToAbsent || cropParamsId != null) {
      map['crop_params_id'] = Variable<int>(cropParamsId);
    }
    return map;
  }

  SensorReadingsCompanion toCompanion(bool nullToAbsent) {
    return SensorReadingsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      moisture: Value(moisture),
      ec: Value(ec),
      temperature: Value(temperature),
      ph: Value(ph),
      nitrogen: Value(nitrogen),
      phosphorus: Value(phosphorus),
      potassium: Value(potassium),
      salinity: Value(salinity),
      tds: Value(tds),
      ecConv: ecConv == null && nullToAbsent
          ? const Value.absent()
          : Value(ecConv),
      ecCal: ecCal == null && nullToAbsent
          ? const Value.absent()
          : Value(ecCal),
      phConv: phConv == null && nullToAbsent
          ? const Value.absent()
          : Value(phConv),
      phCal: phCal == null && nullToAbsent
          ? const Value.absent()
          : Value(phCal),
      nConv: nConv == null && nullToAbsent
          ? const Value.absent()
          : Value(nConv),
      nCal: nCal == null && nullToAbsent ? const Value.absent() : Value(nCal),
      pConv: pConv == null && nullToAbsent
          ? const Value.absent()
          : Value(pConv),
      pCal: pCal == null && nullToAbsent ? const Value.absent() : Value(pCal),
      kConv: kConv == null && nullToAbsent
          ? const Value.absent()
          : Value(kConv),
      kCal: kCal == null && nullToAbsent ? const Value.absent() : Value(kCal),
      cropParamsId: cropParamsId == null && nullToAbsent
          ? const Value.absent()
          : Value(cropParamsId),
    );
  }

  factory SensorReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorReading(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      moisture: serializer.fromJson<double>(json['moisture']),
      ec: serializer.fromJson<double>(json['ec']),
      temperature: serializer.fromJson<double>(json['temperature']),
      ph: serializer.fromJson<double>(json['ph']),
      nitrogen: serializer.fromJson<int>(json['nitrogen']),
      phosphorus: serializer.fromJson<int>(json['phosphorus']),
      potassium: serializer.fromJson<int>(json['potassium']),
      salinity: serializer.fromJson<double>(json['salinity']),
      tds: serializer.fromJson<int>(json['tds']),
      ecConv: serializer.fromJson<double?>(json['ecConv']),
      ecCal: serializer.fromJson<double?>(json['ecCal']),
      phConv: serializer.fromJson<double?>(json['phConv']),
      phCal: serializer.fromJson<double?>(json['phCal']),
      nConv: serializer.fromJson<double?>(json['nConv']),
      nCal: serializer.fromJson<double?>(json['nCal']),
      pConv: serializer.fromJson<double?>(json['pConv']),
      pCal: serializer.fromJson<double?>(json['pCal']),
      kConv: serializer.fromJson<double?>(json['kConv']),
      kCal: serializer.fromJson<double?>(json['kCal']),
      cropParamsId: serializer.fromJson<int?>(json['cropParamsId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'moisture': serializer.toJson<double>(moisture),
      'ec': serializer.toJson<double>(ec),
      'temperature': serializer.toJson<double>(temperature),
      'ph': serializer.toJson<double>(ph),
      'nitrogen': serializer.toJson<int>(nitrogen),
      'phosphorus': serializer.toJson<int>(phosphorus),
      'potassium': serializer.toJson<int>(potassium),
      'salinity': serializer.toJson<double>(salinity),
      'tds': serializer.toJson<int>(tds),
      'ecConv': serializer.toJson<double?>(ecConv),
      'ecCal': serializer.toJson<double?>(ecCal),
      'phConv': serializer.toJson<double?>(phConv),
      'phCal': serializer.toJson<double?>(phCal),
      'nConv': serializer.toJson<double?>(nConv),
      'nCal': serializer.toJson<double?>(nCal),
      'pConv': serializer.toJson<double?>(pConv),
      'pCal': serializer.toJson<double?>(pCal),
      'kConv': serializer.toJson<double?>(kConv),
      'kCal': serializer.toJson<double?>(kCal),
      'cropParamsId': serializer.toJson<int?>(cropParamsId),
    };
  }

  SensorReading copyWith({
    int? id,
    DateTime? timestamp,
    double? moisture,
    double? ec,
    double? temperature,
    double? ph,
    int? nitrogen,
    int? phosphorus,
    int? potassium,
    double? salinity,
    int? tds,
    Value<double?> ecConv = const Value.absent(),
    Value<double?> ecCal = const Value.absent(),
    Value<double?> phConv = const Value.absent(),
    Value<double?> phCal = const Value.absent(),
    Value<double?> nConv = const Value.absent(),
    Value<double?> nCal = const Value.absent(),
    Value<double?> pConv = const Value.absent(),
    Value<double?> pCal = const Value.absent(),
    Value<double?> kConv = const Value.absent(),
    Value<double?> kCal = const Value.absent(),
    Value<int?> cropParamsId = const Value.absent(),
  }) => SensorReading(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    moisture: moisture ?? this.moisture,
    ec: ec ?? this.ec,
    temperature: temperature ?? this.temperature,
    ph: ph ?? this.ph,
    nitrogen: nitrogen ?? this.nitrogen,
    phosphorus: phosphorus ?? this.phosphorus,
    potassium: potassium ?? this.potassium,
    salinity: salinity ?? this.salinity,
    tds: tds ?? this.tds,
    ecConv: ecConv.present ? ecConv.value : this.ecConv,
    ecCal: ecCal.present ? ecCal.value : this.ecCal,
    phConv: phConv.present ? phConv.value : this.phConv,
    phCal: phCal.present ? phCal.value : this.phCal,
    nConv: nConv.present ? nConv.value : this.nConv,
    nCal: nCal.present ? nCal.value : this.nCal,
    pConv: pConv.present ? pConv.value : this.pConv,
    pCal: pCal.present ? pCal.value : this.pCal,
    kConv: kConv.present ? kConv.value : this.kConv,
    kCal: kCal.present ? kCal.value : this.kCal,
    cropParamsId: cropParamsId.present ? cropParamsId.value : this.cropParamsId,
  );
  SensorReading copyWithCompanion(SensorReadingsCompanion data) {
    return SensorReading(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      moisture: data.moisture.present ? data.moisture.value : this.moisture,
      ec: data.ec.present ? data.ec.value : this.ec,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      ph: data.ph.present ? data.ph.value : this.ph,
      nitrogen: data.nitrogen.present ? data.nitrogen.value : this.nitrogen,
      phosphorus: data.phosphorus.present
          ? data.phosphorus.value
          : this.phosphorus,
      potassium: data.potassium.present ? data.potassium.value : this.potassium,
      salinity: data.salinity.present ? data.salinity.value : this.salinity,
      tds: data.tds.present ? data.tds.value : this.tds,
      ecConv: data.ecConv.present ? data.ecConv.value : this.ecConv,
      ecCal: data.ecCal.present ? data.ecCal.value : this.ecCal,
      phConv: data.phConv.present ? data.phConv.value : this.phConv,
      phCal: data.phCal.present ? data.phCal.value : this.phCal,
      nConv: data.nConv.present ? data.nConv.value : this.nConv,
      nCal: data.nCal.present ? data.nCal.value : this.nCal,
      pConv: data.pConv.present ? data.pConv.value : this.pConv,
      pCal: data.pCal.present ? data.pCal.value : this.pCal,
      kConv: data.kConv.present ? data.kConv.value : this.kConv,
      kCal: data.kCal.present ? data.kCal.value : this.kCal,
      cropParamsId: data.cropParamsId.present
          ? data.cropParamsId.value
          : this.cropParamsId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorReading(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('moisture: $moisture, ')
          ..write('ec: $ec, ')
          ..write('temperature: $temperature, ')
          ..write('ph: $ph, ')
          ..write('nitrogen: $nitrogen, ')
          ..write('phosphorus: $phosphorus, ')
          ..write('potassium: $potassium, ')
          ..write('salinity: $salinity, ')
          ..write('tds: $tds, ')
          ..write('ecConv: $ecConv, ')
          ..write('ecCal: $ecCal, ')
          ..write('phConv: $phConv, ')
          ..write('phCal: $phCal, ')
          ..write('nConv: $nConv, ')
          ..write('nCal: $nCal, ')
          ..write('pConv: $pConv, ')
          ..write('pCal: $pCal, ')
          ..write('kConv: $kConv, ')
          ..write('kCal: $kCal, ')
          ..write('cropParamsId: $cropParamsId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    timestamp,
    moisture,
    ec,
    temperature,
    ph,
    nitrogen,
    phosphorus,
    potassium,
    salinity,
    tds,
    ecConv,
    ecCal,
    phConv,
    phCal,
    nConv,
    nCal,
    pConv,
    pCal,
    kConv,
    kCal,
    cropParamsId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorReading &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.moisture == this.moisture &&
          other.ec == this.ec &&
          other.temperature == this.temperature &&
          other.ph == this.ph &&
          other.nitrogen == this.nitrogen &&
          other.phosphorus == this.phosphorus &&
          other.potassium == this.potassium &&
          other.salinity == this.salinity &&
          other.tds == this.tds &&
          other.ecConv == this.ecConv &&
          other.ecCal == this.ecCal &&
          other.phConv == this.phConv &&
          other.phCal == this.phCal &&
          other.nConv == this.nConv &&
          other.nCal == this.nCal &&
          other.pConv == this.pConv &&
          other.pCal == this.pCal &&
          other.kConv == this.kConv &&
          other.kCal == this.kCal &&
          other.cropParamsId == this.cropParamsId);
}

class SensorReadingsCompanion extends UpdateCompanion<SensorReading> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<double> moisture;
  final Value<double> ec;
  final Value<double> temperature;
  final Value<double> ph;
  final Value<int> nitrogen;
  final Value<int> phosphorus;
  final Value<int> potassium;
  final Value<double> salinity;
  final Value<int> tds;
  final Value<double?> ecConv;
  final Value<double?> ecCal;
  final Value<double?> phConv;
  final Value<double?> phCal;
  final Value<double?> nConv;
  final Value<double?> nCal;
  final Value<double?> pConv;
  final Value<double?> pCal;
  final Value<double?> kConv;
  final Value<double?> kCal;
  final Value<int?> cropParamsId;
  const SensorReadingsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.moisture = const Value.absent(),
    this.ec = const Value.absent(),
    this.temperature = const Value.absent(),
    this.ph = const Value.absent(),
    this.nitrogen = const Value.absent(),
    this.phosphorus = const Value.absent(),
    this.potassium = const Value.absent(),
    this.salinity = const Value.absent(),
    this.tds = const Value.absent(),
    this.ecConv = const Value.absent(),
    this.ecCal = const Value.absent(),
    this.phConv = const Value.absent(),
    this.phCal = const Value.absent(),
    this.nConv = const Value.absent(),
    this.nCal = const Value.absent(),
    this.pConv = const Value.absent(),
    this.pCal = const Value.absent(),
    this.kConv = const Value.absent(),
    this.kCal = const Value.absent(),
    this.cropParamsId = const Value.absent(),
  });
  SensorReadingsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required double moisture,
    required double ec,
    required double temperature,
    required double ph,
    required int nitrogen,
    required int phosphorus,
    required int potassium,
    required double salinity,
    this.tds = const Value.absent(),
    this.ecConv = const Value.absent(),
    this.ecCal = const Value.absent(),
    this.phConv = const Value.absent(),
    this.phCal = const Value.absent(),
    this.nConv = const Value.absent(),
    this.nCal = const Value.absent(),
    this.pConv = const Value.absent(),
    this.pCal = const Value.absent(),
    this.kConv = const Value.absent(),
    this.kCal = const Value.absent(),
    this.cropParamsId = const Value.absent(),
  }) : timestamp = Value(timestamp),
       moisture = Value(moisture),
       ec = Value(ec),
       temperature = Value(temperature),
       ph = Value(ph),
       nitrogen = Value(nitrogen),
       phosphorus = Value(phosphorus),
       potassium = Value(potassium),
       salinity = Value(salinity);
  static Insertable<SensorReading> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<double>? moisture,
    Expression<double>? ec,
    Expression<double>? temperature,
    Expression<double>? ph,
    Expression<int>? nitrogen,
    Expression<int>? phosphorus,
    Expression<int>? potassium,
    Expression<double>? salinity,
    Expression<int>? tds,
    Expression<double>? ecConv,
    Expression<double>? ecCal,
    Expression<double>? phConv,
    Expression<double>? phCal,
    Expression<double>? nConv,
    Expression<double>? nCal,
    Expression<double>? pConv,
    Expression<double>? pCal,
    Expression<double>? kConv,
    Expression<double>? kCal,
    Expression<int>? cropParamsId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (moisture != null) 'moisture': moisture,
      if (ec != null) 'ec': ec,
      if (temperature != null) 'temperature': temperature,
      if (ph != null) 'ph': ph,
      if (nitrogen != null) 'nitrogen': nitrogen,
      if (phosphorus != null) 'phosphorus': phosphorus,
      if (potassium != null) 'potassium': potassium,
      if (salinity != null) 'salinity': salinity,
      if (tds != null) 'tds': tds,
      if (ecConv != null) 'ec_conv': ecConv,
      if (ecCal != null) 'ec_cal': ecCal,
      if (phConv != null) 'ph_conv': phConv,
      if (phCal != null) 'ph_cal': phCal,
      if (nConv != null) 'n_conv': nConv,
      if (nCal != null) 'n_cal': nCal,
      if (pConv != null) 'p_conv': pConv,
      if (pCal != null) 'p_cal': pCal,
      if (kConv != null) 'k_conv': kConv,
      if (kCal != null) 'k_cal': kCal,
      if (cropParamsId != null) 'crop_params_id': cropParamsId,
    });
  }

  SensorReadingsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<double>? moisture,
    Value<double>? ec,
    Value<double>? temperature,
    Value<double>? ph,
    Value<int>? nitrogen,
    Value<int>? phosphorus,
    Value<int>? potassium,
    Value<double>? salinity,
    Value<int>? tds,
    Value<double?>? ecConv,
    Value<double?>? ecCal,
    Value<double?>? phConv,
    Value<double?>? phCal,
    Value<double?>? nConv,
    Value<double?>? nCal,
    Value<double?>? pConv,
    Value<double?>? pCal,
    Value<double?>? kConv,
    Value<double?>? kCal,
    Value<int?>? cropParamsId,
  }) {
    return SensorReadingsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      moisture: moisture ?? this.moisture,
      ec: ec ?? this.ec,
      temperature: temperature ?? this.temperature,
      ph: ph ?? this.ph,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      salinity: salinity ?? this.salinity,
      tds: tds ?? this.tds,
      ecConv: ecConv ?? this.ecConv,
      ecCal: ecCal ?? this.ecCal,
      phConv: phConv ?? this.phConv,
      phCal: phCal ?? this.phCal,
      nConv: nConv ?? this.nConv,
      nCal: nCal ?? this.nCal,
      pConv: pConv ?? this.pConv,
      pCal: pCal ?? this.pCal,
      kConv: kConv ?? this.kConv,
      kCal: kCal ?? this.kCal,
      cropParamsId: cropParamsId ?? this.cropParamsId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (moisture.present) {
      map['moisture'] = Variable<double>(moisture.value);
    }
    if (ec.present) {
      map['ec'] = Variable<double>(ec.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (ph.present) {
      map['ph'] = Variable<double>(ph.value);
    }
    if (nitrogen.present) {
      map['nitrogen'] = Variable<int>(nitrogen.value);
    }
    if (phosphorus.present) {
      map['phosphorus'] = Variable<int>(phosphorus.value);
    }
    if (potassium.present) {
      map['potassium'] = Variable<int>(potassium.value);
    }
    if (salinity.present) {
      map['salinity'] = Variable<double>(salinity.value);
    }
    if (tds.present) {
      map['tds'] = Variable<int>(tds.value);
    }
    if (ecConv.present) {
      map['ec_conv'] = Variable<double>(ecConv.value);
    }
    if (ecCal.present) {
      map['ec_cal'] = Variable<double>(ecCal.value);
    }
    if (phConv.present) {
      map['ph_conv'] = Variable<double>(phConv.value);
    }
    if (phCal.present) {
      map['ph_cal'] = Variable<double>(phCal.value);
    }
    if (nConv.present) {
      map['n_conv'] = Variable<double>(nConv.value);
    }
    if (nCal.present) {
      map['n_cal'] = Variable<double>(nCal.value);
    }
    if (pConv.present) {
      map['p_conv'] = Variable<double>(pConv.value);
    }
    if (pCal.present) {
      map['p_cal'] = Variable<double>(pCal.value);
    }
    if (kConv.present) {
      map['k_conv'] = Variable<double>(kConv.value);
    }
    if (kCal.present) {
      map['k_cal'] = Variable<double>(kCal.value);
    }
    if (cropParamsId.present) {
      map['crop_params_id'] = Variable<int>(cropParamsId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorReadingsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('moisture: $moisture, ')
          ..write('ec: $ec, ')
          ..write('temperature: $temperature, ')
          ..write('ph: $ph, ')
          ..write('nitrogen: $nitrogen, ')
          ..write('phosphorus: $phosphorus, ')
          ..write('potassium: $potassium, ')
          ..write('salinity: $salinity, ')
          ..write('tds: $tds, ')
          ..write('ecConv: $ecConv, ')
          ..write('ecCal: $ecCal, ')
          ..write('phConv: $phConv, ')
          ..write('phCal: $phCal, ')
          ..write('nConv: $nConv, ')
          ..write('nCal: $nCal, ')
          ..write('pConv: $pConv, ')
          ..write('pCal: $pCal, ')
          ..write('kConv: $kConv, ')
          ..write('kCal: $kCal, ')
          ..write('cropParamsId: $cropParamsId')
          ..write(')'))
        .toString();
  }
}

class $CropImagesTable extends CropImages
    with TableInfo<$CropImagesTable, CropImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropImagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cropParamsIdMeta = const VerificationMeta(
    'cropParamsId',
  );
  @override
  late final GeneratedColumn<int> cropParamsId = GeneratedColumn<int>(
    'crop_params_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crop_params (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relabelledFileNameMeta =
      const VerificationMeta('relabelledFileName');
  @override
  late final GeneratedColumn<String> relabelledFileName =
      GeneratedColumn<String>(
        'relabelled_file_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cropParamsId,
    filePath,
    relabelledFileName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<CropImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('crop_params_id')) {
      context.handle(
        _cropParamsIdMeta,
        cropParamsId.isAcceptableOrUnknown(
          data['crop_params_id']!,
          _cropParamsIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cropParamsIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('relabelled_file_name')) {
      context.handle(
        _relabelledFileNameMeta,
        relabelledFileName.isAcceptableOrUnknown(
          data['relabelled_file_name']!,
          _relabelledFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relabelledFileNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cropParamsId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}crop_params_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      relabelledFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relabelled_file_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CropImagesTable createAlias(String alias) {
    return $CropImagesTable(attachedDatabase, alias);
  }
}

class CropImage extends DataClass implements Insertable<CropImage> {
  final int id;
  final int cropParamsId;
  final String filePath;
  final String relabelledFileName;
  final DateTime createdAt;
  const CropImage({
    required this.id,
    required this.cropParamsId,
    required this.filePath,
    required this.relabelledFileName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['crop_params_id'] = Variable<int>(cropParamsId);
    map['file_path'] = Variable<String>(filePath);
    map['relabelled_file_name'] = Variable<String>(relabelledFileName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CropImagesCompanion toCompanion(bool nullToAbsent) {
    return CropImagesCompanion(
      id: Value(id),
      cropParamsId: Value(cropParamsId),
      filePath: Value(filePath),
      relabelledFileName: Value(relabelledFileName),
      createdAt: Value(createdAt),
    );
  }

  factory CropImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropImage(
      id: serializer.fromJson<int>(json['id']),
      cropParamsId: serializer.fromJson<int>(json['cropParamsId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      relabelledFileName: serializer.fromJson<String>(
        json['relabelledFileName'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cropParamsId': serializer.toJson<int>(cropParamsId),
      'filePath': serializer.toJson<String>(filePath),
      'relabelledFileName': serializer.toJson<String>(relabelledFileName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CropImage copyWith({
    int? id,
    int? cropParamsId,
    String? filePath,
    String? relabelledFileName,
    DateTime? createdAt,
  }) => CropImage(
    id: id ?? this.id,
    cropParamsId: cropParamsId ?? this.cropParamsId,
    filePath: filePath ?? this.filePath,
    relabelledFileName: relabelledFileName ?? this.relabelledFileName,
    createdAt: createdAt ?? this.createdAt,
  );
  CropImage copyWithCompanion(CropImagesCompanion data) {
    return CropImage(
      id: data.id.present ? data.id.value : this.id,
      cropParamsId: data.cropParamsId.present
          ? data.cropParamsId.value
          : this.cropParamsId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      relabelledFileName: data.relabelledFileName.present
          ? data.relabelledFileName.value
          : this.relabelledFileName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropImage(')
          ..write('id: $id, ')
          ..write('cropParamsId: $cropParamsId, ')
          ..write('filePath: $filePath, ')
          ..write('relabelledFileName: $relabelledFileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cropParamsId, filePath, relabelledFileName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropImage &&
          other.id == this.id &&
          other.cropParamsId == this.cropParamsId &&
          other.filePath == this.filePath &&
          other.relabelledFileName == this.relabelledFileName &&
          other.createdAt == this.createdAt);
}

class CropImagesCompanion extends UpdateCompanion<CropImage> {
  final Value<int> id;
  final Value<int> cropParamsId;
  final Value<String> filePath;
  final Value<String> relabelledFileName;
  final Value<DateTime> createdAt;
  const CropImagesCompanion({
    this.id = const Value.absent(),
    this.cropParamsId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.relabelledFileName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CropImagesCompanion.insert({
    this.id = const Value.absent(),
    required int cropParamsId,
    required String filePath,
    required String relabelledFileName,
    required DateTime createdAt,
  }) : cropParamsId = Value(cropParamsId),
       filePath = Value(filePath),
       relabelledFileName = Value(relabelledFileName),
       createdAt = Value(createdAt);
  static Insertable<CropImage> custom({
    Expression<int>? id,
    Expression<int>? cropParamsId,
    Expression<String>? filePath,
    Expression<String>? relabelledFileName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cropParamsId != null) 'crop_params_id': cropParamsId,
      if (filePath != null) 'file_path': filePath,
      if (relabelledFileName != null)
        'relabelled_file_name': relabelledFileName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CropImagesCompanion copyWith({
    Value<int>? id,
    Value<int>? cropParamsId,
    Value<String>? filePath,
    Value<String>? relabelledFileName,
    Value<DateTime>? createdAt,
  }) {
    return CropImagesCompanion(
      id: id ?? this.id,
      cropParamsId: cropParamsId ?? this.cropParamsId,
      filePath: filePath ?? this.filePath,
      relabelledFileName: relabelledFileName ?? this.relabelledFileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cropParamsId.present) {
      map['crop_params_id'] = Variable<int>(cropParamsId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (relabelledFileName.present) {
      map['relabelled_file_name'] = Variable<String>(relabelledFileName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropImagesCompanion(')
          ..write('id: $id, ')
          ..write('cropParamsId: $cropParamsId, ')
          ..write('filePath: $filePath, ')
          ..write('relabelledFileName: $relabelledFileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CropParamsTable cropParams = $CropParamsTable(this);
  late final $SensorReadingsTable sensorReadings = $SensorReadingsTable(this);
  late final $CropImagesTable cropImages = $CropImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cropParams,
    sensorReadings,
    cropImages,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'crop_params',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('crop_images', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CropParamsTableCreateCompanionBuilder =
    CropParamsCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required String soilType,
      required String soilProperties,
      required String leafColor,
      required String stemDescription,
      required double heightCm,
      Value<String?> notes,
    });
typedef $$CropParamsTableUpdateCompanionBuilder =
    CropParamsCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> soilType,
      Value<String> soilProperties,
      Value<String> leafColor,
      Value<String> stemDescription,
      Value<double> heightCm,
      Value<String?> notes,
    });

final class $$CropParamsTableReferences
    extends BaseReferences<_$AppDatabase, $CropParamsTable, CropParam> {
  $$CropParamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SensorReadingsTable, List<SensorReading>>
  _sensorReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sensorReadings,
    aliasName: $_aliasNameGenerator(
      db.cropParams.id,
      db.sensorReadings.cropParamsId,
    ),
  );

  $$SensorReadingsTableProcessedTableManager get sensorReadingsRefs {
    final manager = $$SensorReadingsTableTableManager(
      $_db,
      $_db.sensorReadings,
    ).filter((f) => f.cropParamsId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sensorReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CropImagesTable, List<CropImage>>
  _cropImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cropImages,
    aliasName: $_aliasNameGenerator(
      db.cropParams.id,
      db.cropImages.cropParamsId,
    ),
  );

  $$CropImagesTableProcessedTableManager get cropImagesRefs {
    final manager = $$CropImagesTableTableManager(
      $_db,
      $_db.cropImages,
    ).filter((f) => f.cropParamsId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cropImagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CropParamsTableFilterComposer
    extends Composer<_$AppDatabase, $CropParamsTable> {
  $$CropParamsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilType => $composableBuilder(
    column: $table.soilType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilProperties => $composableBuilder(
    column: $table.soilProperties,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leafColor => $composableBuilder(
    column: $table.leafColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stemDescription => $composableBuilder(
    column: $table.stemDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sensorReadingsRefs(
    Expression<bool> Function($$SensorReadingsTableFilterComposer f) f,
  ) {
    final $$SensorReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorReadings,
      getReferencedColumn: (t) => t.cropParamsId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorReadingsTableFilterComposer(
            $db: $db,
            $table: $db.sensorReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cropImagesRefs(
    Expression<bool> Function($$CropImagesTableFilterComposer f) f,
  ) {
    final $$CropImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cropImages,
      getReferencedColumn: (t) => t.cropParamsId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropImagesTableFilterComposer(
            $db: $db,
            $table: $db.cropImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CropParamsTableOrderingComposer
    extends Composer<_$AppDatabase, $CropParamsTable> {
  $$CropParamsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilType => $composableBuilder(
    column: $table.soilType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilProperties => $composableBuilder(
    column: $table.soilProperties,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leafColor => $composableBuilder(
    column: $table.leafColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stemDescription => $composableBuilder(
    column: $table.stemDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CropParamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropParamsTable> {
  $$CropParamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get soilType =>
      $composableBuilder(column: $table.soilType, builder: (column) => column);

  GeneratedColumn<String> get soilProperties => $composableBuilder(
    column: $table.soilProperties,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leafColor =>
      $composableBuilder(column: $table.leafColor, builder: (column) => column);

  GeneratedColumn<String> get stemDescription => $composableBuilder(
    column: $table.stemDescription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> sensorReadingsRefs<T extends Object>(
    Expression<T> Function($$SensorReadingsTableAnnotationComposer a) f,
  ) {
    final $$SensorReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorReadings,
      getReferencedColumn: (t) => t.cropParamsId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.sensorReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cropImagesRefs<T extends Object>(
    Expression<T> Function($$CropImagesTableAnnotationComposer a) f,
  ) {
    final $$CropImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cropImages,
      getReferencedColumn: (t) => t.cropParamsId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.cropImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CropParamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CropParamsTable,
          CropParam,
          $$CropParamsTableFilterComposer,
          $$CropParamsTableOrderingComposer,
          $$CropParamsTableAnnotationComposer,
          $$CropParamsTableCreateCompanionBuilder,
          $$CropParamsTableUpdateCompanionBuilder,
          (CropParam, $$CropParamsTableReferences),
          CropParam,
          PrefetchHooks Function({bool sensorReadingsRefs, bool cropImagesRefs})
        > {
  $$CropParamsTableTableManager(_$AppDatabase db, $CropParamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropParamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropParamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropParamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> soilType = const Value.absent(),
                Value<String> soilProperties = const Value.absent(),
                Value<String> leafColor = const Value.absent(),
                Value<String> stemDescription = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CropParamsCompanion(
                id: id,
                createdAt: createdAt,
                soilType: soilType,
                soilProperties: soilProperties,
                leafColor: leafColor,
                stemDescription: stemDescription,
                heightCm: heightCm,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required String soilType,
                required String soilProperties,
                required String leafColor,
                required String stemDescription,
                required double heightCm,
                Value<String?> notes = const Value.absent(),
              }) => CropParamsCompanion.insert(
                id: id,
                createdAt: createdAt,
                soilType: soilType,
                soilProperties: soilProperties,
                leafColor: leafColor,
                stemDescription: stemDescription,
                heightCm: heightCm,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CropParamsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sensorReadingsRefs = false, cropImagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sensorReadingsRefs) db.sensorReadings,
                    if (cropImagesRefs) db.cropImages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sensorReadingsRefs)
                        await $_getPrefetchedData<
                          CropParam,
                          $CropParamsTable,
                          SensorReading
                        >(
                          currentTable: table,
                          referencedTable: $$CropParamsTableReferences
                              ._sensorReadingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CropParamsTableReferences(
                                db,
                                table,
                                p0,
                              ).sensorReadingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cropParamsId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cropImagesRefs)
                        await $_getPrefetchedData<
                          CropParam,
                          $CropParamsTable,
                          CropImage
                        >(
                          currentTable: table,
                          referencedTable: $$CropParamsTableReferences
                              ._cropImagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CropParamsTableReferences(
                                db,
                                table,
                                p0,
                              ).cropImagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cropParamsId == item.id,
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

typedef $$CropParamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CropParamsTable,
      CropParam,
      $$CropParamsTableFilterComposer,
      $$CropParamsTableOrderingComposer,
      $$CropParamsTableAnnotationComposer,
      $$CropParamsTableCreateCompanionBuilder,
      $$CropParamsTableUpdateCompanionBuilder,
      (CropParam, $$CropParamsTableReferences),
      CropParam,
      PrefetchHooks Function({bool sensorReadingsRefs, bool cropImagesRefs})
    >;
typedef $$SensorReadingsTableCreateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required double moisture,
      required double ec,
      required double temperature,
      required double ph,
      required int nitrogen,
      required int phosphorus,
      required int potassium,
      required double salinity,
      Value<int> tds,
      Value<double?> ecConv,
      Value<double?> ecCal,
      Value<double?> phConv,
      Value<double?> phCal,
      Value<double?> nConv,
      Value<double?> nCal,
      Value<double?> pConv,
      Value<double?> pCal,
      Value<double?> kConv,
      Value<double?> kCal,
      Value<int?> cropParamsId,
    });
typedef $$SensorReadingsTableUpdateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<double> moisture,
      Value<double> ec,
      Value<double> temperature,
      Value<double> ph,
      Value<int> nitrogen,
      Value<int> phosphorus,
      Value<int> potassium,
      Value<double> salinity,
      Value<int> tds,
      Value<double?> ecConv,
      Value<double?> ecCal,
      Value<double?> phConv,
      Value<double?> phCal,
      Value<double?> nConv,
      Value<double?> nCal,
      Value<double?> pConv,
      Value<double?> pCal,
      Value<double?> kConv,
      Value<double?> kCal,
      Value<int?> cropParamsId,
    });

final class $$SensorReadingsTableReferences
    extends BaseReferences<_$AppDatabase, $SensorReadingsTable, SensorReading> {
  $$SensorReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CropParamsTable _cropParamsIdTable(_$AppDatabase db) =>
      db.cropParams.createAlias(
        $_aliasNameGenerator(db.sensorReadings.cropParamsId, db.cropParams.id),
      );

  $$CropParamsTableProcessedTableManager? get cropParamsId {
    final $_column = $_itemColumn<int>('crop_params_id');
    if ($_column == null) return null;
    final manager = $$CropParamsTableTableManager(
      $_db,
      $_db.cropParams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cropParamsIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SensorReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableFilterComposer({
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

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get moisture => $composableBuilder(
    column: $table.moisture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ec => $composableBuilder(
    column: $table.ec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nitrogen => $composableBuilder(
    column: $table.nitrogen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phosphorus => $composableBuilder(
    column: $table.phosphorus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salinity => $composableBuilder(
    column: $table.salinity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tds => $composableBuilder(
    column: $table.tds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ecConv => $composableBuilder(
    column: $table.ecConv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ecCal => $composableBuilder(
    column: $table.ecCal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phConv => $composableBuilder(
    column: $table.phConv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phCal => $composableBuilder(
    column: $table.phCal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nConv => $composableBuilder(
    column: $table.nConv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nCal => $composableBuilder(
    column: $table.nCal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pConv => $composableBuilder(
    column: $table.pConv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pCal => $composableBuilder(
    column: $table.pCal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kConv => $composableBuilder(
    column: $table.kConv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kCal => $composableBuilder(
    column: $table.kCal,
    builder: (column) => ColumnFilters(column),
  );

  $$CropParamsTableFilterComposer get cropParamsId {
    final $$CropParamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropParamsId,
      referencedTable: $db.cropParams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropParamsTableFilterComposer(
            $db: $db,
            $table: $db.cropParams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get moisture => $composableBuilder(
    column: $table.moisture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ec => $composableBuilder(
    column: $table.ec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nitrogen => $composableBuilder(
    column: $table.nitrogen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phosphorus => $composableBuilder(
    column: $table.phosphorus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salinity => $composableBuilder(
    column: $table.salinity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tds => $composableBuilder(
    column: $table.tds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ecConv => $composableBuilder(
    column: $table.ecConv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ecCal => $composableBuilder(
    column: $table.ecCal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phConv => $composableBuilder(
    column: $table.phConv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phCal => $composableBuilder(
    column: $table.phCal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nConv => $composableBuilder(
    column: $table.nConv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nCal => $composableBuilder(
    column: $table.nCal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pConv => $composableBuilder(
    column: $table.pConv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pCal => $composableBuilder(
    column: $table.pCal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kConv => $composableBuilder(
    column: $table.kConv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kCal => $composableBuilder(
    column: $table.kCal,
    builder: (column) => ColumnOrderings(column),
  );

  $$CropParamsTableOrderingComposer get cropParamsId {
    final $$CropParamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropParamsId,
      referencedTable: $db.cropParams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropParamsTableOrderingComposer(
            $db: $db,
            $table: $db.cropParams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get moisture =>
      $composableBuilder(column: $table.moisture, builder: (column) => column);

  GeneratedColumn<double> get ec =>
      $composableBuilder(column: $table.ec, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ph =>
      $composableBuilder(column: $table.ph, builder: (column) => column);

  GeneratedColumn<int> get nitrogen =>
      $composableBuilder(column: $table.nitrogen, builder: (column) => column);

  GeneratedColumn<int> get phosphorus => $composableBuilder(
    column: $table.phosphorus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get potassium =>
      $composableBuilder(column: $table.potassium, builder: (column) => column);

  GeneratedColumn<double> get salinity =>
      $composableBuilder(column: $table.salinity, builder: (column) => column);

  GeneratedColumn<int> get tds =>
      $composableBuilder(column: $table.tds, builder: (column) => column);

  GeneratedColumn<double> get ecConv =>
      $composableBuilder(column: $table.ecConv, builder: (column) => column);

  GeneratedColumn<double> get ecCal =>
      $composableBuilder(column: $table.ecCal, builder: (column) => column);

  GeneratedColumn<double> get phConv =>
      $composableBuilder(column: $table.phConv, builder: (column) => column);

  GeneratedColumn<double> get phCal =>
      $composableBuilder(column: $table.phCal, builder: (column) => column);

  GeneratedColumn<double> get nConv =>
      $composableBuilder(column: $table.nConv, builder: (column) => column);

  GeneratedColumn<double> get nCal =>
      $composableBuilder(column: $table.nCal, builder: (column) => column);

  GeneratedColumn<double> get pConv =>
      $composableBuilder(column: $table.pConv, builder: (column) => column);

  GeneratedColumn<double> get pCal =>
      $composableBuilder(column: $table.pCal, builder: (column) => column);

  GeneratedColumn<double> get kConv =>
      $composableBuilder(column: $table.kConv, builder: (column) => column);

  GeneratedColumn<double> get kCal =>
      $composableBuilder(column: $table.kCal, builder: (column) => column);

  $$CropParamsTableAnnotationComposer get cropParamsId {
    final $$CropParamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropParamsId,
      referencedTable: $db.cropParams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropParamsTableAnnotationComposer(
            $db: $db,
            $table: $db.cropParams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorReadingsTable,
          SensorReading,
          $$SensorReadingsTableFilterComposer,
          $$SensorReadingsTableOrderingComposer,
          $$SensorReadingsTableAnnotationComposer,
          $$SensorReadingsTableCreateCompanionBuilder,
          $$SensorReadingsTableUpdateCompanionBuilder,
          (SensorReading, $$SensorReadingsTableReferences),
          SensorReading,
          PrefetchHooks Function({bool cropParamsId})
        > {
  $$SensorReadingsTableTableManager(
    _$AppDatabase db,
    $SensorReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> moisture = const Value.absent(),
                Value<double> ec = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<double> ph = const Value.absent(),
                Value<int> nitrogen = const Value.absent(),
                Value<int> phosphorus = const Value.absent(),
                Value<int> potassium = const Value.absent(),
                Value<double> salinity = const Value.absent(),
                Value<int> tds = const Value.absent(),
                Value<double?> ecConv = const Value.absent(),
                Value<double?> ecCal = const Value.absent(),
                Value<double?> phConv = const Value.absent(),
                Value<double?> phCal = const Value.absent(),
                Value<double?> nConv = const Value.absent(),
                Value<double?> nCal = const Value.absent(),
                Value<double?> pConv = const Value.absent(),
                Value<double?> pCal = const Value.absent(),
                Value<double?> kConv = const Value.absent(),
                Value<double?> kCal = const Value.absent(),
                Value<int?> cropParamsId = const Value.absent(),
              }) => SensorReadingsCompanion(
                id: id,
                timestamp: timestamp,
                moisture: moisture,
                ec: ec,
                temperature: temperature,
                ph: ph,
                nitrogen: nitrogen,
                phosphorus: phosphorus,
                potassium: potassium,
                salinity: salinity,
                tds: tds,
                ecConv: ecConv,
                ecCal: ecCal,
                phConv: phConv,
                phCal: phCal,
                nConv: nConv,
                nCal: nCal,
                pConv: pConv,
                pCal: pCal,
                kConv: kConv,
                kCal: kCal,
                cropParamsId: cropParamsId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required double moisture,
                required double ec,
                required double temperature,
                required double ph,
                required int nitrogen,
                required int phosphorus,
                required int potassium,
                required double salinity,
                Value<int> tds = const Value.absent(),
                Value<double?> ecConv = const Value.absent(),
                Value<double?> ecCal = const Value.absent(),
                Value<double?> phConv = const Value.absent(),
                Value<double?> phCal = const Value.absent(),
                Value<double?> nConv = const Value.absent(),
                Value<double?> nCal = const Value.absent(),
                Value<double?> pConv = const Value.absent(),
                Value<double?> pCal = const Value.absent(),
                Value<double?> kConv = const Value.absent(),
                Value<double?> kCal = const Value.absent(),
                Value<int?> cropParamsId = const Value.absent(),
              }) => SensorReadingsCompanion.insert(
                id: id,
                timestamp: timestamp,
                moisture: moisture,
                ec: ec,
                temperature: temperature,
                ph: ph,
                nitrogen: nitrogen,
                phosphorus: phosphorus,
                potassium: potassium,
                salinity: salinity,
                tds: tds,
                ecConv: ecConv,
                ecCal: ecCal,
                phConv: phConv,
                phCal: phCal,
                nConv: nConv,
                nCal: nCal,
                pConv: pConv,
                pCal: pCal,
                kConv: kConv,
                kCal: kCal,
                cropParamsId: cropParamsId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SensorReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cropParamsId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (cropParamsId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cropParamsId,
                                referencedTable: $$SensorReadingsTableReferences
                                    ._cropParamsIdTable(db),
                                referencedColumn:
                                    $$SensorReadingsTableReferences
                                        ._cropParamsIdTable(db)
                                        .id,
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

typedef $$SensorReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorReadingsTable,
      SensorReading,
      $$SensorReadingsTableFilterComposer,
      $$SensorReadingsTableOrderingComposer,
      $$SensorReadingsTableAnnotationComposer,
      $$SensorReadingsTableCreateCompanionBuilder,
      $$SensorReadingsTableUpdateCompanionBuilder,
      (SensorReading, $$SensorReadingsTableReferences),
      SensorReading,
      PrefetchHooks Function({bool cropParamsId})
    >;
typedef $$CropImagesTableCreateCompanionBuilder =
    CropImagesCompanion Function({
      Value<int> id,
      required int cropParamsId,
      required String filePath,
      required String relabelledFileName,
      required DateTime createdAt,
    });
typedef $$CropImagesTableUpdateCompanionBuilder =
    CropImagesCompanion Function({
      Value<int> id,
      Value<int> cropParamsId,
      Value<String> filePath,
      Value<String> relabelledFileName,
      Value<DateTime> createdAt,
    });

final class $$CropImagesTableReferences
    extends BaseReferences<_$AppDatabase, $CropImagesTable, CropImage> {
  $$CropImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CropParamsTable _cropParamsIdTable(_$AppDatabase db) =>
      db.cropParams.createAlias(
        $_aliasNameGenerator(db.cropImages.cropParamsId, db.cropParams.id),
      );

  $$CropParamsTableProcessedTableManager get cropParamsId {
    final $_column = $_itemColumn<int>('crop_params_id')!;

    final manager = $$CropParamsTableTableManager(
      $_db,
      $_db.cropParams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cropParamsIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CropImagesTableFilterComposer
    extends Composer<_$AppDatabase, $CropImagesTable> {
  $$CropImagesTableFilterComposer({
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

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relabelledFileName => $composableBuilder(
    column: $table.relabelledFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CropParamsTableFilterComposer get cropParamsId {
    final $$CropParamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropParamsId,
      referencedTable: $db.cropParams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropParamsTableFilterComposer(
            $db: $db,
            $table: $db.cropParams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CropImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CropImagesTable> {
  $$CropImagesTableOrderingComposer({
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

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relabelledFileName => $composableBuilder(
    column: $table.relabelledFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CropParamsTableOrderingComposer get cropParamsId {
    final $$CropParamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropParamsId,
      referencedTable: $db.cropParams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropParamsTableOrderingComposer(
            $db: $db,
            $table: $db.cropParams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CropImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropImagesTable> {
  $$CropImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get relabelledFileName => $composableBuilder(
    column: $table.relabelledFileName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CropParamsTableAnnotationComposer get cropParamsId {
    final $$CropParamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropParamsId,
      referencedTable: $db.cropParams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropParamsTableAnnotationComposer(
            $db: $db,
            $table: $db.cropParams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CropImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CropImagesTable,
          CropImage,
          $$CropImagesTableFilterComposer,
          $$CropImagesTableOrderingComposer,
          $$CropImagesTableAnnotationComposer,
          $$CropImagesTableCreateCompanionBuilder,
          $$CropImagesTableUpdateCompanionBuilder,
          (CropImage, $$CropImagesTableReferences),
          CropImage,
          PrefetchHooks Function({bool cropParamsId})
        > {
  $$CropImagesTableTableManager(_$AppDatabase db, $CropImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cropParamsId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> relabelledFileName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CropImagesCompanion(
                id: id,
                cropParamsId: cropParamsId,
                filePath: filePath,
                relabelledFileName: relabelledFileName,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cropParamsId,
                required String filePath,
                required String relabelledFileName,
                required DateTime createdAt,
              }) => CropImagesCompanion.insert(
                id: id,
                cropParamsId: cropParamsId,
                filePath: filePath,
                relabelledFileName: relabelledFileName,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CropImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cropParamsId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (cropParamsId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cropParamsId,
                                referencedTable: $$CropImagesTableReferences
                                    ._cropParamsIdTable(db),
                                referencedColumn: $$CropImagesTableReferences
                                    ._cropParamsIdTable(db)
                                    .id,
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

typedef $$CropImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CropImagesTable,
      CropImage,
      $$CropImagesTableFilterComposer,
      $$CropImagesTableOrderingComposer,
      $$CropImagesTableAnnotationComposer,
      $$CropImagesTableCreateCompanionBuilder,
      $$CropImagesTableUpdateCompanionBuilder,
      (CropImage, $$CropImagesTableReferences),
      CropImage,
      PrefetchHooks Function({bool cropParamsId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CropParamsTableTableManager get cropParams =>
      $$CropParamsTableTableManager(_db, _db.cropParams);
  $$SensorReadingsTableTableManager get sensorReadings =>
      $$SensorReadingsTableTableManager(_db, _db.sensorReadings);
  $$CropImagesTableTableManager get cropImages =>
      $$CropImagesTableTableManager(_db, _db.cropImages);
}
