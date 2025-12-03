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
          ..write('cropParamsId: $cropParamsId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    cropParamsId,
  );
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
