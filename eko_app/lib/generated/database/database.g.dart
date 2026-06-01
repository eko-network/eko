// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../database/database.dart';

// ignore_for_file: type=lint
class $CapabilitiesTable extends Capabilities
    with TableInfo<$CapabilitiesTable, CapabilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapabilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  capabilities =
      GeneratedColumn<String>(
        'capabilities',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, dynamic>>(
        $CapabilitiesTable.$convertercapabilities,
      );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, capabilities, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capabilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapabilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapabilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapabilityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      capabilities: $CapabilitiesTable.$convertercapabilities.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}capabilities'],
        )!,
      ),
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
    );
  }

  @override
  $CapabilitiesTable createAlias(String alias) {
    return $CapabilitiesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $convertercapabilities =
      const JsonValueConverter();
}

class CapabilityRow extends DataClass implements Insertable<CapabilityRow> {
  final int id;
  final Map<String, dynamic> capabilities;
  final DateTime time;
  const CapabilityRow({
    required this.id,
    required this.capabilities,
    required this.time,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['capabilities'] = Variable<String>(
        $CapabilitiesTable.$convertercapabilities.toSql(capabilities),
      );
    }
    map['time'] = Variable<DateTime>(time);
    return map;
  }

  CapabilitiesCompanion toCompanion(bool nullToAbsent) {
    return CapabilitiesCompanion(
      id: Value(id),
      capabilities: Value(capabilities),
      time: Value(time),
    );
  }

  factory CapabilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapabilityRow(
      id: serializer.fromJson<int>(json['id']),
      capabilities: serializer.fromJson<Map<String, dynamic>>(
        json['capabilities'],
      ),
      time: serializer.fromJson<DateTime>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'capabilities': serializer.toJson<Map<String, dynamic>>(capabilities),
      'time': serializer.toJson<DateTime>(time),
    };
  }

  CapabilityRow copyWith({
    int? id,
    Map<String, dynamic>? capabilities,
    DateTime? time,
  }) => CapabilityRow(
    id: id ?? this.id,
    capabilities: capabilities ?? this.capabilities,
    time: time ?? this.time,
  );
  CapabilityRow copyWithCompanion(CapabilitiesCompanion data) {
    return CapabilityRow(
      id: data.id.present ? data.id.value : this.id,
      capabilities: data.capabilities.present
          ? data.capabilities.value
          : this.capabilities,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapabilityRow(')
          ..write('id: $id, ')
          ..write('capabilities: $capabilities, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, capabilities, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapabilityRow &&
          other.id == this.id &&
          other.capabilities == this.capabilities &&
          other.time == this.time);
}

class CapabilitiesCompanion extends UpdateCompanion<CapabilityRow> {
  final Value<int> id;
  final Value<Map<String, dynamic>> capabilities;
  final Value<DateTime> time;
  const CapabilitiesCompanion({
    this.id = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.time = const Value.absent(),
  });
  CapabilitiesCompanion.insert({
    this.id = const Value.absent(),
    required Map<String, dynamic> capabilities,
    this.time = const Value.absent(),
  }) : capabilities = Value(capabilities);
  static Insertable<CapabilityRow> custom({
    Expression<int>? id,
    Expression<String>? capabilities,
    Expression<DateTime>? time,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (capabilities != null) 'capabilities': capabilities,
      if (time != null) 'time': time,
    });
  }

  CapabilitiesCompanion copyWith({
    Value<int>? id,
    Value<Map<String, dynamic>>? capabilities,
    Value<DateTime>? time,
  }) {
    return CapabilitiesCompanion(
      id: id ?? this.id,
      capabilities: capabilities ?? this.capabilities,
      time: time ?? this.time,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (capabilities.present) {
      map['capabilities'] = Variable<String>(
        $CapabilitiesTable.$convertercapabilities.toSql(capabilities.value),
      );
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapabilitiesCompanion(')
          ..write('id: $id, ')
          ..write('capabilities: $capabilities, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }
}

class $MlsCredentialsTable extends MlsCredentials
    with TableInfo<$MlsCredentialsTable, MlsCredentialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MlsCredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _credentialIdentityMeta =
      const VerificationMeta('credentialIdentity');
  @override
  late final GeneratedColumn<Uint8List> credentialIdentity =
      GeneratedColumn<Uint8List>(
        'credential_identity',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _credentialBytesMeta = const VerificationMeta(
    'credentialBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> credentialBytes =
      GeneratedColumn<Uint8List>(
        'credential_bytes',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _signerBytesMeta = const VerificationMeta(
    'signerBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> signerBytes =
      GeneratedColumn<Uint8List>(
        'signer_bytes',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _signerPublicKeyMeta = const VerificationMeta(
    'signerPublicKey',
  );
  @override
  late final GeneratedColumn<Uint8List> signerPublicKey =
      GeneratedColumn<Uint8List>(
        'signer_public_key',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    credentialIdentity,
    credentialBytes,
    signerBytes,
    signerPublicKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mls_credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<MlsCredentialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('credential_identity')) {
      context.handle(
        _credentialIdentityMeta,
        credentialIdentity.isAcceptableOrUnknown(
          data['credential_identity']!,
          _credentialIdentityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_credentialIdentityMeta);
    }
    if (data.containsKey('credential_bytes')) {
      context.handle(
        _credentialBytesMeta,
        credentialBytes.isAcceptableOrUnknown(
          data['credential_bytes']!,
          _credentialBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_credentialBytesMeta);
    }
    if (data.containsKey('signer_bytes')) {
      context.handle(
        _signerBytesMeta,
        signerBytes.isAcceptableOrUnknown(
          data['signer_bytes']!,
          _signerBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signerBytesMeta);
    }
    if (data.containsKey('signer_public_key')) {
      context.handle(
        _signerPublicKeyMeta,
        signerPublicKey.isAcceptableOrUnknown(
          data['signer_public_key']!,
          _signerPublicKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signerPublicKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MlsCredentialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MlsCredentialRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      credentialIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}credential_identity'],
      )!,
      credentialBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}credential_bytes'],
      )!,
      signerBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signer_bytes'],
      )!,
      signerPublicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signer_public_key'],
      )!,
    );
  }

  @override
  $MlsCredentialsTable createAlias(String alias) {
    return $MlsCredentialsTable(attachedDatabase, alias);
  }
}

class MlsCredentialRow extends DataClass
    implements Insertable<MlsCredentialRow> {
  final int id;
  final Uint8List credentialIdentity;
  final Uint8List credentialBytes;
  final Uint8List signerBytes;
  final Uint8List signerPublicKey;
  const MlsCredentialRow({
    required this.id,
    required this.credentialIdentity,
    required this.credentialBytes,
    required this.signerBytes,
    required this.signerPublicKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['credential_identity'] = Variable<Uint8List>(credentialIdentity);
    map['credential_bytes'] = Variable<Uint8List>(credentialBytes);
    map['signer_bytes'] = Variable<Uint8List>(signerBytes);
    map['signer_public_key'] = Variable<Uint8List>(signerPublicKey);
    return map;
  }

  MlsCredentialsCompanion toCompanion(bool nullToAbsent) {
    return MlsCredentialsCompanion(
      id: Value(id),
      credentialIdentity: Value(credentialIdentity),
      credentialBytes: Value(credentialBytes),
      signerBytes: Value(signerBytes),
      signerPublicKey: Value(signerPublicKey),
    );
  }

  factory MlsCredentialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MlsCredentialRow(
      id: serializer.fromJson<int>(json['id']),
      credentialIdentity: serializer.fromJson<Uint8List>(
        json['credentialIdentity'],
      ),
      credentialBytes: serializer.fromJson<Uint8List>(json['credentialBytes']),
      signerBytes: serializer.fromJson<Uint8List>(json['signerBytes']),
      signerPublicKey: serializer.fromJson<Uint8List>(json['signerPublicKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'credentialIdentity': serializer.toJson<Uint8List>(credentialIdentity),
      'credentialBytes': serializer.toJson<Uint8List>(credentialBytes),
      'signerBytes': serializer.toJson<Uint8List>(signerBytes),
      'signerPublicKey': serializer.toJson<Uint8List>(signerPublicKey),
    };
  }

  MlsCredentialRow copyWith({
    int? id,
    Uint8List? credentialIdentity,
    Uint8List? credentialBytes,
    Uint8List? signerBytes,
    Uint8List? signerPublicKey,
  }) => MlsCredentialRow(
    id: id ?? this.id,
    credentialIdentity: credentialIdentity ?? this.credentialIdentity,
    credentialBytes: credentialBytes ?? this.credentialBytes,
    signerBytes: signerBytes ?? this.signerBytes,
    signerPublicKey: signerPublicKey ?? this.signerPublicKey,
  );
  MlsCredentialRow copyWithCompanion(MlsCredentialsCompanion data) {
    return MlsCredentialRow(
      id: data.id.present ? data.id.value : this.id,
      credentialIdentity: data.credentialIdentity.present
          ? data.credentialIdentity.value
          : this.credentialIdentity,
      credentialBytes: data.credentialBytes.present
          ? data.credentialBytes.value
          : this.credentialBytes,
      signerBytes: data.signerBytes.present
          ? data.signerBytes.value
          : this.signerBytes,
      signerPublicKey: data.signerPublicKey.present
          ? data.signerPublicKey.value
          : this.signerPublicKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MlsCredentialRow(')
          ..write('id: $id, ')
          ..write('credentialIdentity: $credentialIdentity, ')
          ..write('credentialBytes: $credentialBytes, ')
          ..write('signerBytes: $signerBytes, ')
          ..write('signerPublicKey: $signerPublicKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(credentialIdentity),
    $driftBlobEquality.hash(credentialBytes),
    $driftBlobEquality.hash(signerBytes),
    $driftBlobEquality.hash(signerPublicKey),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MlsCredentialRow &&
          other.id == this.id &&
          $driftBlobEquality.equals(
            other.credentialIdentity,
            this.credentialIdentity,
          ) &&
          $driftBlobEquality.equals(
            other.credentialBytes,
            this.credentialBytes,
          ) &&
          $driftBlobEquality.equals(other.signerBytes, this.signerBytes) &&
          $driftBlobEquality.equals(
            other.signerPublicKey,
            this.signerPublicKey,
          ));
}

class MlsCredentialsCompanion extends UpdateCompanion<MlsCredentialRow> {
  final Value<int> id;
  final Value<Uint8List> credentialIdentity;
  final Value<Uint8List> credentialBytes;
  final Value<Uint8List> signerBytes;
  final Value<Uint8List> signerPublicKey;
  const MlsCredentialsCompanion({
    this.id = const Value.absent(),
    this.credentialIdentity = const Value.absent(),
    this.credentialBytes = const Value.absent(),
    this.signerBytes = const Value.absent(),
    this.signerPublicKey = const Value.absent(),
  });
  MlsCredentialsCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List credentialIdentity,
    required Uint8List credentialBytes,
    required Uint8List signerBytes,
    required Uint8List signerPublicKey,
  }) : credentialIdentity = Value(credentialIdentity),
       credentialBytes = Value(credentialBytes),
       signerBytes = Value(signerBytes),
       signerPublicKey = Value(signerPublicKey);
  static Insertable<MlsCredentialRow> custom({
    Expression<int>? id,
    Expression<Uint8List>? credentialIdentity,
    Expression<Uint8List>? credentialBytes,
    Expression<Uint8List>? signerBytes,
    Expression<Uint8List>? signerPublicKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (credentialIdentity != null) 'credential_identity': credentialIdentity,
      if (credentialBytes != null) 'credential_bytes': credentialBytes,
      if (signerBytes != null) 'signer_bytes': signerBytes,
      if (signerPublicKey != null) 'signer_public_key': signerPublicKey,
    });
  }

  MlsCredentialsCompanion copyWith({
    Value<int>? id,
    Value<Uint8List>? credentialIdentity,
    Value<Uint8List>? credentialBytes,
    Value<Uint8List>? signerBytes,
    Value<Uint8List>? signerPublicKey,
  }) {
    return MlsCredentialsCompanion(
      id: id ?? this.id,
      credentialIdentity: credentialIdentity ?? this.credentialIdentity,
      credentialBytes: credentialBytes ?? this.credentialBytes,
      signerBytes: signerBytes ?? this.signerBytes,
      signerPublicKey: signerPublicKey ?? this.signerPublicKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (credentialIdentity.present) {
      map['credential_identity'] = Variable<Uint8List>(
        credentialIdentity.value,
      );
    }
    if (credentialBytes.present) {
      map['credential_bytes'] = Variable<Uint8List>(credentialBytes.value);
    }
    if (signerBytes.present) {
      map['signer_bytes'] = Variable<Uint8List>(signerBytes.value);
    }
    if (signerPublicKey.present) {
      map['signer_public_key'] = Variable<Uint8List>(signerPublicKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MlsCredentialsCompanion(')
          ..write('id: $id, ')
          ..write('credentialIdentity: $credentialIdentity, ')
          ..write('credentialBytes: $credentialBytes, ')
          ..write('signerBytes: $signerBytes, ')
          ..write('signerPublicKey: $signerPublicKey')
          ..write(')'))
        .toString();
  }
}

class $MlsKeyPackagesTable extends MlsKeyPackages
    with TableInfo<$MlsKeyPackagesTable, MlsKeyPackageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MlsKeyPackagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keyPackageMeta = const VerificationMeta(
    'keyPackage',
  );
  @override
  late final GeneratedColumn<Uint8List> keyPackage = GeneratedColumn<Uint8List>(
    'key_package',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, keyPackage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mls_key_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MlsKeyPackageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key_package')) {
      context.handle(
        _keyPackageMeta,
        keyPackage.isAcceptableOrUnknown(data['key_package']!, _keyPackageMeta),
      );
    } else if (isInserting) {
      context.missing(_keyPackageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MlsKeyPackageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MlsKeyPackageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      keyPackage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}key_package'],
      )!,
    );
  }

  @override
  $MlsKeyPackagesTable createAlias(String alias) {
    return $MlsKeyPackagesTable(attachedDatabase, alias);
  }
}

class MlsKeyPackageRow extends DataClass
    implements Insertable<MlsKeyPackageRow> {
  final int id;
  final Uint8List keyPackage;
  const MlsKeyPackageRow({required this.id, required this.keyPackage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key_package'] = Variable<Uint8List>(keyPackage);
    return map;
  }

  MlsKeyPackagesCompanion toCompanion(bool nullToAbsent) {
    return MlsKeyPackagesCompanion(
      id: Value(id),
      keyPackage: Value(keyPackage),
    );
  }

  factory MlsKeyPackageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MlsKeyPackageRow(
      id: serializer.fromJson<int>(json['id']),
      keyPackage: serializer.fromJson<Uint8List>(json['keyPackage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'keyPackage': serializer.toJson<Uint8List>(keyPackage),
    };
  }

  MlsKeyPackageRow copyWith({int? id, Uint8List? keyPackage}) =>
      MlsKeyPackageRow(
        id: id ?? this.id,
        keyPackage: keyPackage ?? this.keyPackage,
      );
  MlsKeyPackageRow copyWithCompanion(MlsKeyPackagesCompanion data) {
    return MlsKeyPackageRow(
      id: data.id.present ? data.id.value : this.id,
      keyPackage: data.keyPackage.present
          ? data.keyPackage.value
          : this.keyPackage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MlsKeyPackageRow(')
          ..write('id: $id, ')
          ..write('keyPackage: $keyPackage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, $driftBlobEquality.hash(keyPackage));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MlsKeyPackageRow &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.keyPackage, this.keyPackage));
}

class MlsKeyPackagesCompanion extends UpdateCompanion<MlsKeyPackageRow> {
  final Value<int> id;
  final Value<Uint8List> keyPackage;
  const MlsKeyPackagesCompanion({
    this.id = const Value.absent(),
    this.keyPackage = const Value.absent(),
  });
  MlsKeyPackagesCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List keyPackage,
  }) : keyPackage = Value(keyPackage);
  static Insertable<MlsKeyPackageRow> custom({
    Expression<int>? id,
    Expression<Uint8List>? keyPackage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyPackage != null) 'key_package': keyPackage,
    });
  }

  MlsKeyPackagesCompanion copyWith({
    Value<int>? id,
    Value<Uint8List>? keyPackage,
  }) {
    return MlsKeyPackagesCompanion(
      id: id ?? this.id,
      keyPackage: keyPackage ?? this.keyPackage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (keyPackage.present) {
      map['key_package'] = Variable<Uint8List>(keyPackage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MlsKeyPackagesCompanion(')
          ..write('id: $id, ')
          ..write('keyPackage: $keyPackage')
          ..write(')'))
        .toString();
  }
}

class $MlsGroupsTable extends MlsGroups
    with TableInfo<$MlsGroupsTable, MlsGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MlsGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _groupIdBytesMeta = const VerificationMeta(
    'groupIdBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> groupIdBytes =
      GeneratedColumn<Uint8List>(
        'group_id_bytes',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
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
  static const VerificationMeta _lastActivityAtMeta = const VerificationMeta(
    'lastActivityAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivityAt =
      GeneratedColumn<DateTime>(
        'last_activity_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupIdBytes,
    displayName,
    createdAt,
    lastActivityAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mls_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<MlsGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id_bytes')) {
      context.handle(
        _groupIdBytesMeta,
        groupIdBytes.isAcceptableOrUnknown(
          data['group_id_bytes']!,
          _groupIdBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_groupIdBytesMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_activity_at')) {
      context.handle(
        _lastActivityAtMeta,
        lastActivityAt.isAcceptableOrUnknown(
          data['last_activity_at']!,
          _lastActivityAtMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MlsGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MlsGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      groupIdBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}group_id_bytes'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastActivityAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MlsGroupsTable createAlias(String alias) {
    return $MlsGroupsTable(attachedDatabase, alias);
  }
}

class MlsGroupRow extends DataClass implements Insertable<MlsGroupRow> {
  final int id;
  final Uint8List groupIdBytes;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final bool isActive;
  const MlsGroupRow({
    required this.id,
    required this.groupIdBytes,
    this.displayName,
    required this.createdAt,
    required this.lastActivityAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id_bytes'] = Variable<Uint8List>(groupIdBytes);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_activity_at'] = Variable<DateTime>(lastActivityAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MlsGroupsCompanion toCompanion(bool nullToAbsent) {
    return MlsGroupsCompanion(
      id: Value(id),
      groupIdBytes: Value(groupIdBytes),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      createdAt: Value(createdAt),
      lastActivityAt: Value(lastActivityAt),
      isActive: Value(isActive),
    );
  }

  factory MlsGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MlsGroupRow(
      id: serializer.fromJson<int>(json['id']),
      groupIdBytes: serializer.fromJson<Uint8List>(json['groupIdBytes']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastActivityAt: serializer.fromJson<DateTime>(json['lastActivityAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupIdBytes': serializer.toJson<Uint8List>(groupIdBytes),
      'displayName': serializer.toJson<String?>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastActivityAt': serializer.toJson<DateTime>(lastActivityAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MlsGroupRow copyWith({
    int? id,
    Uint8List? groupIdBytes,
    Value<String?> displayName = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastActivityAt,
    bool? isActive,
  }) => MlsGroupRow(
    id: id ?? this.id,
    groupIdBytes: groupIdBytes ?? this.groupIdBytes,
    displayName: displayName.present ? displayName.value : this.displayName,
    createdAt: createdAt ?? this.createdAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    isActive: isActive ?? this.isActive,
  );
  MlsGroupRow copyWithCompanion(MlsGroupsCompanion data) {
    return MlsGroupRow(
      id: data.id.present ? data.id.value : this.id,
      groupIdBytes: data.groupIdBytes.present
          ? data.groupIdBytes.value
          : this.groupIdBytes,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastActivityAt: data.lastActivityAt.present
          ? data.lastActivityAt.value
          : this.lastActivityAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MlsGroupRow(')
          ..write('id: $id, ')
          ..write('groupIdBytes: $groupIdBytes, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(groupIdBytes),
    displayName,
    createdAt,
    lastActivityAt,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MlsGroupRow &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.groupIdBytes, this.groupIdBytes) &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.lastActivityAt == this.lastActivityAt &&
          other.isActive == this.isActive);
}

class MlsGroupsCompanion extends UpdateCompanion<MlsGroupRow> {
  final Value<int> id;
  final Value<Uint8List> groupIdBytes;
  final Value<String?> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastActivityAt;
  final Value<bool> isActive;
  const MlsGroupsCompanion({
    this.id = const Value.absent(),
    this.groupIdBytes = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  MlsGroupsCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List groupIdBytes,
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : groupIdBytes = Value(groupIdBytes);
  static Insertable<MlsGroupRow> custom({
    Expression<int>? id,
    Expression<Uint8List>? groupIdBytes,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastActivityAt,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupIdBytes != null) 'group_id_bytes': groupIdBytes,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (isActive != null) 'is_active': isActive,
    });
  }

  MlsGroupsCompanion copyWith({
    Value<int>? id,
    Value<Uint8List>? groupIdBytes,
    Value<String?>? displayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastActivityAt,
    Value<bool>? isActive,
  }) {
    return MlsGroupsCompanion(
      id: id ?? this.id,
      groupIdBytes: groupIdBytes ?? this.groupIdBytes,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupIdBytes.present) {
      map['group_id_bytes'] = Variable<Uint8List>(groupIdBytes.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastActivityAt.present) {
      map['last_activity_at'] = Variable<DateTime>(lastActivityAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MlsGroupsCompanion(')
          ..write('id: $id, ')
          ..write('groupIdBytes: $groupIdBytes, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $MlsEngineConfigsTable extends MlsEngineConfigs
    with TableInfo<$MlsEngineConfigsTable, MlsEngineConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MlsEngineConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dbPathMeta = const VerificationMeta('dbPath');
  @override
  late final GeneratedColumn<String> dbPath = GeneratedColumn<String>(
    'db_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptionKeyMeta = const VerificationMeta(
    'encryptionKey',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptionKey =
      GeneratedColumn<Uint8List>(
        'encryption_key',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [id, dbPath, encryptionKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mls_engine_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MlsEngineConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('db_path')) {
      context.handle(
        _dbPathMeta,
        dbPath.isAcceptableOrUnknown(data['db_path']!, _dbPathMeta),
      );
    } else if (isInserting) {
      context.missing(_dbPathMeta);
    }
    if (data.containsKey('encryption_key')) {
      context.handle(
        _encryptionKeyMeta,
        encryptionKey.isAcceptableOrUnknown(
          data['encryption_key']!,
          _encryptionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptionKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MlsEngineConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MlsEngineConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}db_path'],
      )!,
      encryptionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encryption_key'],
      )!,
    );
  }

  @override
  $MlsEngineConfigsTable createAlias(String alias) {
    return $MlsEngineConfigsTable(attachedDatabase, alias);
  }
}

class MlsEngineConfigRow extends DataClass
    implements Insertable<MlsEngineConfigRow> {
  final int id;
  final String dbPath;
  final Uint8List encryptionKey;
  const MlsEngineConfigRow({
    required this.id,
    required this.dbPath,
    required this.encryptionKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['db_path'] = Variable<String>(dbPath);
    map['encryption_key'] = Variable<Uint8List>(encryptionKey);
    return map;
  }

  MlsEngineConfigsCompanion toCompanion(bool nullToAbsent) {
    return MlsEngineConfigsCompanion(
      id: Value(id),
      dbPath: Value(dbPath),
      encryptionKey: Value(encryptionKey),
    );
  }

  factory MlsEngineConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MlsEngineConfigRow(
      id: serializer.fromJson<int>(json['id']),
      dbPath: serializer.fromJson<String>(json['dbPath']),
      encryptionKey: serializer.fromJson<Uint8List>(json['encryptionKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dbPath': serializer.toJson<String>(dbPath),
      'encryptionKey': serializer.toJson<Uint8List>(encryptionKey),
    };
  }

  MlsEngineConfigRow copyWith({
    int? id,
    String? dbPath,
    Uint8List? encryptionKey,
  }) => MlsEngineConfigRow(
    id: id ?? this.id,
    dbPath: dbPath ?? this.dbPath,
    encryptionKey: encryptionKey ?? this.encryptionKey,
  );
  MlsEngineConfigRow copyWithCompanion(MlsEngineConfigsCompanion data) {
    return MlsEngineConfigRow(
      id: data.id.present ? data.id.value : this.id,
      dbPath: data.dbPath.present ? data.dbPath.value : this.dbPath,
      encryptionKey: data.encryptionKey.present
          ? data.encryptionKey.value
          : this.encryptionKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MlsEngineConfigRow(')
          ..write('id: $id, ')
          ..write('dbPath: $dbPath, ')
          ..write('encryptionKey: $encryptionKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dbPath, $driftBlobEquality.hash(encryptionKey));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MlsEngineConfigRow &&
          other.id == this.id &&
          other.dbPath == this.dbPath &&
          $driftBlobEquality.equals(other.encryptionKey, this.encryptionKey));
}

class MlsEngineConfigsCompanion extends UpdateCompanion<MlsEngineConfigRow> {
  final Value<int> id;
  final Value<String> dbPath;
  final Value<Uint8List> encryptionKey;
  const MlsEngineConfigsCompanion({
    this.id = const Value.absent(),
    this.dbPath = const Value.absent(),
    this.encryptionKey = const Value.absent(),
  });
  MlsEngineConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String dbPath,
    required Uint8List encryptionKey,
  }) : dbPath = Value(dbPath),
       encryptionKey = Value(encryptionKey);
  static Insertable<MlsEngineConfigRow> custom({
    Expression<int>? id,
    Expression<String>? dbPath,
    Expression<Uint8List>? encryptionKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dbPath != null) 'db_path': dbPath,
      if (encryptionKey != null) 'encryption_key': encryptionKey,
    });
  }

  MlsEngineConfigsCompanion copyWith({
    Value<int>? id,
    Value<String>? dbPath,
    Value<Uint8List>? encryptionKey,
  }) {
    return MlsEngineConfigsCompanion(
      id: id ?? this.id,
      dbPath: dbPath ?? this.dbPath,
      encryptionKey: encryptionKey ?? this.encryptionKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dbPath.present) {
      map['db_path'] = Variable<String>(dbPath.value);
    }
    if (encryptionKey.present) {
      map['encryption_key'] = Variable<Uint8List>(encryptionKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MlsEngineConfigsCompanion(')
          ..write('id: $id, ')
          ..write('dbPath: $dbPath, ')
          ..write('encryptionKey: $encryptionKey')
          ..write(')'))
        .toString();
  }
}

class $ProcessedObjectsTable extends ProcessedObjects
    with TableInfo<$ProcessedObjectsTable, ProcessedObjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessedObjectsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Uri, String> id =
      GeneratedColumn<String>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Uri>($ProcessedObjectsTable.$converterid);
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processed_objects';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessedObjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessedObjectRow(
      id: $ProcessedObjectsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}id'],
        )!,
      ),
    );
  }

  @override
  $ProcessedObjectsTable createAlias(String alias) {
    return $ProcessedObjectsTable(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converterid = const UriTypeConverter();
}

class ProcessedObjectRow extends DataClass
    implements Insertable<ProcessedObjectRow> {
  final Uri id;
  const ProcessedObjectRow({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<String>(
        $ProcessedObjectsTable.$converterid.toSql(id),
      );
    }
    return map;
  }

  ProcessedObjectsCompanion toCompanion(bool nullToAbsent) {
    return ProcessedObjectsCompanion(id: Value(id));
  }

  factory ProcessedObjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessedObjectRow(id: serializer.fromJson<Uri>(json['id']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<Uri>(id)};
  }

  ProcessedObjectRow copyWith({Uri? id}) =>
      ProcessedObjectRow(id: id ?? this.id);
  ProcessedObjectRow copyWithCompanion(ProcessedObjectsCompanion data) {
    return ProcessedObjectRow(id: data.id.present ? data.id.value : this.id);
  }

  @override
  String toString() {
    return (StringBuffer('ProcessedObjectRow(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessedObjectRow && other.id == this.id);
}

class ProcessedObjectsCompanion extends UpdateCompanion<ProcessedObjectRow> {
  final Value<Uri> id;
  final Value<int> rowid;
  const ProcessedObjectsCompanion({
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessedObjectsCompanion.insert({
    required Uri id,
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ProcessedObjectRow> custom({
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessedObjectsCompanion copyWith({Value<Uri>? id, Value<int>? rowid}) {
    return ProcessedObjectsCompanion(
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(
        $ProcessedObjectsTable.$converterid.toSql(id.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessedObjectsCompanion(')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredMessagesTable extends StoredMessages
    with TableInfo<$StoredMessagesTable, StoredMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredMessagesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Uri, String> serverActivityId =
      GeneratedColumn<String>(
        'server_activity_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Uri>($StoredMessagesTable.$converterserverActivityId);
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Uri, String> senderId =
      GeneratedColumn<String>(
        'sender_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Uri>($StoredMessagesTable.$convertersenderId);
  @override
  late final GeneratedColumnWithTypeConverter<InternalId, String> id =
      GeneratedColumn<String>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<InternalId>($StoredMessagesTable.$converterid);
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<Uint8List> groupId = GeneratedColumn<Uint8List>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<InternalId?, String> inReplyTo =
      GeneratedColumn<String>(
        'in_reply_to',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<InternalId?>($StoredMessagesTable.$converterinReplyTon);
  @override
  List<GeneratedColumn> get $columns => [
    serverActivityId,
    receivedAt,
    senderId,
    id,
    content,
    groupId,
    inReplyTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverActivityId};
  @override
  StoredMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredMessageRow(
      serverActivityId: $StoredMessagesTable.$converterserverActivityId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}server_activity_id'],
        )!,
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      senderId: $StoredMessagesTable.$convertersenderId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sender_id'],
        )!,
      ),
      id: $StoredMessagesTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}id'],
        )!,
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}group_id'],
      )!,
      inReplyTo: $StoredMessagesTable.$converterinReplyTon.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}in_reply_to'],
        ),
      ),
    );
  }

  @override
  $StoredMessagesTable createAlias(String alias) {
    return $StoredMessagesTable(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converterserverActivityId =
      const UriTypeConverter();
  static TypeConverter<Uri, String> $convertersenderId =
      const UriTypeConverter();
  static TypeConverter<InternalId, String> $converterid =
      const InternalIdConverter();
  static TypeConverter<InternalId, String> $converterinReplyTo =
      const InternalIdConverter();
  static TypeConverter<InternalId?, String?> $converterinReplyTon =
      NullAwareTypeConverter.wrap($converterinReplyTo);
}

class StoredMessageRow extends DataClass
    implements Insertable<StoredMessageRow> {
  final Uri serverActivityId;
  final DateTime receivedAt;
  final Uri senderId;
  final InternalId id;
  final String? content;
  final Uint8List groupId;
  final InternalId? inReplyTo;
  const StoredMessageRow({
    required this.serverActivityId,
    required this.receivedAt,
    required this.senderId,
    required this.id,
    this.content,
    required this.groupId,
    this.inReplyTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['server_activity_id'] = Variable<String>(
        $StoredMessagesTable.$converterserverActivityId.toSql(serverActivityId),
      );
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    {
      map['sender_id'] = Variable<String>(
        $StoredMessagesTable.$convertersenderId.toSql(senderId),
      );
    }
    {
      map['id'] = Variable<String>($StoredMessagesTable.$converterid.toSql(id));
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['group_id'] = Variable<Uint8List>(groupId);
    if (!nullToAbsent || inReplyTo != null) {
      map['in_reply_to'] = Variable<String>(
        $StoredMessagesTable.$converterinReplyTon.toSql(inReplyTo),
      );
    }
    return map;
  }

  StoredMessagesCompanion toCompanion(bool nullToAbsent) {
    return StoredMessagesCompanion(
      serverActivityId: Value(serverActivityId),
      receivedAt: Value(receivedAt),
      senderId: Value(senderId),
      id: Value(id),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      groupId: Value(groupId),
      inReplyTo: inReplyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(inReplyTo),
    );
  }

  factory StoredMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredMessageRow(
      serverActivityId: serializer.fromJson<Uri>(json['serverActivityId']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      senderId: serializer.fromJson<Uri>(json['senderId']),
      id: serializer.fromJson<InternalId>(json['id']),
      content: serializer.fromJson<String?>(json['content']),
      groupId: serializer.fromJson<Uint8List>(json['groupId']),
      inReplyTo: serializer.fromJson<InternalId?>(json['inReplyTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverActivityId': serializer.toJson<Uri>(serverActivityId),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'senderId': serializer.toJson<Uri>(senderId),
      'id': serializer.toJson<InternalId>(id),
      'content': serializer.toJson<String?>(content),
      'groupId': serializer.toJson<Uint8List>(groupId),
      'inReplyTo': serializer.toJson<InternalId?>(inReplyTo),
    };
  }

  StoredMessageRow copyWith({
    Uri? serverActivityId,
    DateTime? receivedAt,
    Uri? senderId,
    InternalId? id,
    Value<String?> content = const Value.absent(),
    Uint8List? groupId,
    Value<InternalId?> inReplyTo = const Value.absent(),
  }) => StoredMessageRow(
    serverActivityId: serverActivityId ?? this.serverActivityId,
    receivedAt: receivedAt ?? this.receivedAt,
    senderId: senderId ?? this.senderId,
    id: id ?? this.id,
    content: content.present ? content.value : this.content,
    groupId: groupId ?? this.groupId,
    inReplyTo: inReplyTo.present ? inReplyTo.value : this.inReplyTo,
  );
  StoredMessageRow copyWithCompanion(StoredMessagesCompanion data) {
    return StoredMessageRow(
      serverActivityId: data.serverActivityId.present
          ? data.serverActivityId.value
          : this.serverActivityId,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      inReplyTo: data.inReplyTo.present ? data.inReplyTo.value : this.inReplyTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredMessageRow(')
          ..write('serverActivityId: $serverActivityId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('senderId: $senderId, ')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('groupId: $groupId, ')
          ..write('inReplyTo: $inReplyTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverActivityId,
    receivedAt,
    senderId,
    id,
    content,
    $driftBlobEquality.hash(groupId),
    inReplyTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredMessageRow &&
          other.serverActivityId == this.serverActivityId &&
          other.receivedAt == this.receivedAt &&
          other.senderId == this.senderId &&
          other.id == this.id &&
          other.content == this.content &&
          $driftBlobEquality.equals(other.groupId, this.groupId) &&
          other.inReplyTo == this.inReplyTo);
}

class StoredMessagesCompanion extends UpdateCompanion<StoredMessageRow> {
  final Value<Uri> serverActivityId;
  final Value<DateTime> receivedAt;
  final Value<Uri> senderId;
  final Value<InternalId> id;
  final Value<String?> content;
  final Value<Uint8List> groupId;
  final Value<InternalId?> inReplyTo;
  final Value<int> rowid;
  const StoredMessagesCompanion({
    this.serverActivityId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.senderId = const Value.absent(),
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.groupId = const Value.absent(),
    this.inReplyTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredMessagesCompanion.insert({
    required Uri serverActivityId,
    required DateTime receivedAt,
    required Uri senderId,
    required InternalId id,
    this.content = const Value.absent(),
    required Uint8List groupId,
    this.inReplyTo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : serverActivityId = Value(serverActivityId),
       receivedAt = Value(receivedAt),
       senderId = Value(senderId),
       id = Value(id),
       groupId = Value(groupId);
  static Insertable<StoredMessageRow> custom({
    Expression<String>? serverActivityId,
    Expression<DateTime>? receivedAt,
    Expression<String>? senderId,
    Expression<String>? id,
    Expression<String>? content,
    Expression<Uint8List>? groupId,
    Expression<String>? inReplyTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverActivityId != null) 'server_activity_id': serverActivityId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (senderId != null) 'sender_id': senderId,
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (groupId != null) 'group_id': groupId,
      if (inReplyTo != null) 'in_reply_to': inReplyTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredMessagesCompanion copyWith({
    Value<Uri>? serverActivityId,
    Value<DateTime>? receivedAt,
    Value<Uri>? senderId,
    Value<InternalId>? id,
    Value<String?>? content,
    Value<Uint8List>? groupId,
    Value<InternalId?>? inReplyTo,
    Value<int>? rowid,
  }) {
    return StoredMessagesCompanion(
      serverActivityId: serverActivityId ?? this.serverActivityId,
      receivedAt: receivedAt ?? this.receivedAt,
      senderId: senderId ?? this.senderId,
      id: id ?? this.id,
      content: content ?? this.content,
      groupId: groupId ?? this.groupId,
      inReplyTo: inReplyTo ?? this.inReplyTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverActivityId.present) {
      map['server_activity_id'] = Variable<String>(
        $StoredMessagesTable.$converterserverActivityId.toSql(
          serverActivityId.value,
        ),
      );
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(
        $StoredMessagesTable.$convertersenderId.toSql(senderId.value),
      );
    }
    if (id.present) {
      map['id'] = Variable<String>(
        $StoredMessagesTable.$converterid.toSql(id.value),
      );
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<Uint8List>(groupId.value);
    }
    if (inReplyTo.present) {
      map['in_reply_to'] = Variable<String>(
        $StoredMessagesTable.$converterinReplyTon.toSql(inReplyTo.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredMessagesCompanion(')
          ..write('serverActivityId: $serverActivityId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('senderId: $senderId, ')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('groupId: $groupId, ')
          ..write('inReplyTo: $inReplyTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageAttachmentsTable extends MessageAttachments
    with TableInfo<$MessageAttachmentsTable, MessageAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageAttachmentsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Uri, String> messageId =
      GeneratedColumn<String>(
        'message_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES stored_messages (server_activity_id)',
        ),
      ).withConverter<Uri>($MessageAttachmentsTable.$convertermessageId);
  @override
  late final GeneratedColumnWithTypeConverter<InternalId, String> attachmentId =
      GeneratedColumn<String>(
        'attachment_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<InternalId>(
        $MessageAttachmentsTable.$converterattachmentId,
      );
  @override
  List<GeneratedColumn> get $columns => [messageId, attachmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_attachments';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MessageAttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageAttachmentRow(
      messageId: $MessageAttachmentsTable.$convertermessageId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}message_id'],
        )!,
      ),
      attachmentId: $MessageAttachmentsTable.$converterattachmentId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attachment_id'],
        )!,
      ),
    );
  }

  @override
  $MessageAttachmentsTable createAlias(String alias) {
    return $MessageAttachmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $convertermessageId =
      const UriTypeConverter();
  static TypeConverter<InternalId, String> $converterattachmentId =
      const InternalIdConverter();
}

class MessageAttachmentRow extends DataClass
    implements Insertable<MessageAttachmentRow> {
  final Uri messageId;
  final InternalId attachmentId;
  const MessageAttachmentRow({
    required this.messageId,
    required this.attachmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['message_id'] = Variable<String>(
        $MessageAttachmentsTable.$convertermessageId.toSql(messageId),
      );
    }
    {
      map['attachment_id'] = Variable<String>(
        $MessageAttachmentsTable.$converterattachmentId.toSql(attachmentId),
      );
    }
    return map;
  }

  MessageAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return MessageAttachmentsCompanion(
      messageId: Value(messageId),
      attachmentId: Value(attachmentId),
    );
  }

  factory MessageAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageAttachmentRow(
      messageId: serializer.fromJson<Uri>(json['messageId']),
      attachmentId: serializer.fromJson<InternalId>(json['attachmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<Uri>(messageId),
      'attachmentId': serializer.toJson<InternalId>(attachmentId),
    };
  }

  MessageAttachmentRow copyWith({Uri? messageId, InternalId? attachmentId}) =>
      MessageAttachmentRow(
        messageId: messageId ?? this.messageId,
        attachmentId: attachmentId ?? this.attachmentId,
      );
  MessageAttachmentRow copyWithCompanion(MessageAttachmentsCompanion data) {
    return MessageAttachmentRow(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageAttachmentRow(')
          ..write('messageId: $messageId, ')
          ..write('attachmentId: $attachmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, attachmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageAttachmentRow &&
          other.messageId == this.messageId &&
          other.attachmentId == this.attachmentId);
}

class MessageAttachmentsCompanion
    extends UpdateCompanion<MessageAttachmentRow> {
  final Value<Uri> messageId;
  final Value<InternalId> attachmentId;
  final Value<int> rowid;
  const MessageAttachmentsCompanion({
    this.messageId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageAttachmentsCompanion.insert({
    required Uri messageId,
    required InternalId attachmentId,
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       attachmentId = Value(attachmentId);
  static Insertable<MessageAttachmentRow> custom({
    Expression<String>? messageId,
    Expression<String>? attachmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageAttachmentsCompanion copyWith({
    Value<Uri>? messageId,
    Value<InternalId>? attachmentId,
    Value<int>? rowid,
  }) {
    return MessageAttachmentsCompanion(
      messageId: messageId ?? this.messageId,
      attachmentId: attachmentId ?? this.attachmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(
        $MessageAttachmentsTable.$convertermessageId.toSql(messageId.value),
      );
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(
        $MessageAttachmentsTable.$converterattachmentId.toSql(
          attachmentId.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageAttachmentsCompanion(')
          ..write('messageId: $messageId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CapabilitiesTable capabilities = $CapabilitiesTable(this);
  late final $MlsCredentialsTable mlsCredentials = $MlsCredentialsTable(this);
  late final $MlsKeyPackagesTable mlsKeyPackages = $MlsKeyPackagesTable(this);
  late final $MlsGroupsTable mlsGroups = $MlsGroupsTable(this);
  late final $MlsEngineConfigsTable mlsEngineConfigs = $MlsEngineConfigsTable(
    this,
  );
  late final $ProcessedObjectsTable processedObjects = $ProcessedObjectsTable(
    this,
  );
  late final $StoredMessagesTable storedMessages = $StoredMessagesTable(this);
  late final $MessageAttachmentsTable messageAttachments =
      $MessageAttachmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    capabilities,
    mlsCredentials,
    mlsKeyPackages,
    mlsGroups,
    mlsEngineConfigs,
    processedObjects,
    storedMessages,
    messageAttachments,
  ];
}

typedef $$CapabilitiesTableCreateCompanionBuilder =
    CapabilitiesCompanion Function({
      Value<int> id,
      required Map<String, dynamic> capabilities,
      Value<DateTime> time,
    });
typedef $$CapabilitiesTableUpdateCompanionBuilder =
    CapabilitiesCompanion Function({
      Value<int> id,
      Value<Map<String, dynamic>> capabilities,
      Value<DateTime> time,
    });

class $$CapabilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $CapabilitiesTable> {
  $$CapabilitiesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapabilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CapabilitiesTable> {
  $$CapabilitiesTableOrderingComposer({
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

  ColumnOrderings<String> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapabilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapabilitiesTable> {
  $$CapabilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$CapabilitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapabilitiesTable,
          CapabilityRow,
          $$CapabilitiesTableFilterComposer,
          $$CapabilitiesTableOrderingComposer,
          $$CapabilitiesTableAnnotationComposer,
          $$CapabilitiesTableCreateCompanionBuilder,
          $$CapabilitiesTableUpdateCompanionBuilder,
          (
            CapabilityRow,
            BaseReferences<_$AppDatabase, $CapabilitiesTable, CapabilityRow>,
          ),
          CapabilityRow,
          PrefetchHooks Function()
        > {
  $$CapabilitiesTableTableManager(_$AppDatabase db, $CapabilitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapabilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapabilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapabilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Map<String, dynamic>> capabilities = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
              }) => CapabilitiesCompanion(
                id: id,
                capabilities: capabilities,
                time: time,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Map<String, dynamic> capabilities,
                Value<DateTime> time = const Value.absent(),
              }) => CapabilitiesCompanion.insert(
                id: id,
                capabilities: capabilities,
                time: time,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CapabilitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapabilitiesTable,
      CapabilityRow,
      $$CapabilitiesTableFilterComposer,
      $$CapabilitiesTableOrderingComposer,
      $$CapabilitiesTableAnnotationComposer,
      $$CapabilitiesTableCreateCompanionBuilder,
      $$CapabilitiesTableUpdateCompanionBuilder,
      (
        CapabilityRow,
        BaseReferences<_$AppDatabase, $CapabilitiesTable, CapabilityRow>,
      ),
      CapabilityRow,
      PrefetchHooks Function()
    >;
typedef $$MlsCredentialsTableCreateCompanionBuilder =
    MlsCredentialsCompanion Function({
      Value<int> id,
      required Uint8List credentialIdentity,
      required Uint8List credentialBytes,
      required Uint8List signerBytes,
      required Uint8List signerPublicKey,
    });
typedef $$MlsCredentialsTableUpdateCompanionBuilder =
    MlsCredentialsCompanion Function({
      Value<int> id,
      Value<Uint8List> credentialIdentity,
      Value<Uint8List> credentialBytes,
      Value<Uint8List> signerBytes,
      Value<Uint8List> signerPublicKey,
    });

class $$MlsCredentialsTableFilterComposer
    extends Composer<_$AppDatabase, $MlsCredentialsTable> {
  $$MlsCredentialsTableFilterComposer({
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

  ColumnFilters<Uint8List> get credentialIdentity => $composableBuilder(
    column: $table.credentialIdentity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get credentialBytes => $composableBuilder(
    column: $table.credentialBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signerBytes => $composableBuilder(
    column: $table.signerBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signerPublicKey => $composableBuilder(
    column: $table.signerPublicKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MlsCredentialsTableOrderingComposer
    extends Composer<_$AppDatabase, $MlsCredentialsTable> {
  $$MlsCredentialsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get credentialIdentity => $composableBuilder(
    column: $table.credentialIdentity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get credentialBytes => $composableBuilder(
    column: $table.credentialBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signerBytes => $composableBuilder(
    column: $table.signerBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signerPublicKey => $composableBuilder(
    column: $table.signerPublicKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MlsCredentialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MlsCredentialsTable> {
  $$MlsCredentialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get credentialIdentity => $composableBuilder(
    column: $table.credentialIdentity,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get credentialBytes => $composableBuilder(
    column: $table.credentialBytes,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get signerBytes => $composableBuilder(
    column: $table.signerBytes,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get signerPublicKey => $composableBuilder(
    column: $table.signerPublicKey,
    builder: (column) => column,
  );
}

class $$MlsCredentialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MlsCredentialsTable,
          MlsCredentialRow,
          $$MlsCredentialsTableFilterComposer,
          $$MlsCredentialsTableOrderingComposer,
          $$MlsCredentialsTableAnnotationComposer,
          $$MlsCredentialsTableCreateCompanionBuilder,
          $$MlsCredentialsTableUpdateCompanionBuilder,
          (
            MlsCredentialRow,
            BaseReferences<
              _$AppDatabase,
              $MlsCredentialsTable,
              MlsCredentialRow
            >,
          ),
          MlsCredentialRow,
          PrefetchHooks Function()
        > {
  $$MlsCredentialsTableTableManager(
    _$AppDatabase db,
    $MlsCredentialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MlsCredentialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MlsCredentialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MlsCredentialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Uint8List> credentialIdentity = const Value.absent(),
                Value<Uint8List> credentialBytes = const Value.absent(),
                Value<Uint8List> signerBytes = const Value.absent(),
                Value<Uint8List> signerPublicKey = const Value.absent(),
              }) => MlsCredentialsCompanion(
                id: id,
                credentialIdentity: credentialIdentity,
                credentialBytes: credentialBytes,
                signerBytes: signerBytes,
                signerPublicKey: signerPublicKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Uint8List credentialIdentity,
                required Uint8List credentialBytes,
                required Uint8List signerBytes,
                required Uint8List signerPublicKey,
              }) => MlsCredentialsCompanion.insert(
                id: id,
                credentialIdentity: credentialIdentity,
                credentialBytes: credentialBytes,
                signerBytes: signerBytes,
                signerPublicKey: signerPublicKey,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MlsCredentialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MlsCredentialsTable,
      MlsCredentialRow,
      $$MlsCredentialsTableFilterComposer,
      $$MlsCredentialsTableOrderingComposer,
      $$MlsCredentialsTableAnnotationComposer,
      $$MlsCredentialsTableCreateCompanionBuilder,
      $$MlsCredentialsTableUpdateCompanionBuilder,
      (
        MlsCredentialRow,
        BaseReferences<_$AppDatabase, $MlsCredentialsTable, MlsCredentialRow>,
      ),
      MlsCredentialRow,
      PrefetchHooks Function()
    >;
typedef $$MlsKeyPackagesTableCreateCompanionBuilder =
    MlsKeyPackagesCompanion Function({
      Value<int> id,
      required Uint8List keyPackage,
    });
typedef $$MlsKeyPackagesTableUpdateCompanionBuilder =
    MlsKeyPackagesCompanion Function({
      Value<int> id,
      Value<Uint8List> keyPackage,
    });

class $$MlsKeyPackagesTableFilterComposer
    extends Composer<_$AppDatabase, $MlsKeyPackagesTable> {
  $$MlsKeyPackagesTableFilterComposer({
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

  ColumnFilters<Uint8List> get keyPackage => $composableBuilder(
    column: $table.keyPackage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MlsKeyPackagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MlsKeyPackagesTable> {
  $$MlsKeyPackagesTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get keyPackage => $composableBuilder(
    column: $table.keyPackage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MlsKeyPackagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MlsKeyPackagesTable> {
  $$MlsKeyPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get keyPackage => $composableBuilder(
    column: $table.keyPackage,
    builder: (column) => column,
  );
}

class $$MlsKeyPackagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MlsKeyPackagesTable,
          MlsKeyPackageRow,
          $$MlsKeyPackagesTableFilterComposer,
          $$MlsKeyPackagesTableOrderingComposer,
          $$MlsKeyPackagesTableAnnotationComposer,
          $$MlsKeyPackagesTableCreateCompanionBuilder,
          $$MlsKeyPackagesTableUpdateCompanionBuilder,
          (
            MlsKeyPackageRow,
            BaseReferences<
              _$AppDatabase,
              $MlsKeyPackagesTable,
              MlsKeyPackageRow
            >,
          ),
          MlsKeyPackageRow,
          PrefetchHooks Function()
        > {
  $$MlsKeyPackagesTableTableManager(
    _$AppDatabase db,
    $MlsKeyPackagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MlsKeyPackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MlsKeyPackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MlsKeyPackagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Uint8List> keyPackage = const Value.absent(),
              }) => MlsKeyPackagesCompanion(id: id, keyPackage: keyPackage),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Uint8List keyPackage,
              }) => MlsKeyPackagesCompanion.insert(
                id: id,
                keyPackage: keyPackage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MlsKeyPackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MlsKeyPackagesTable,
      MlsKeyPackageRow,
      $$MlsKeyPackagesTableFilterComposer,
      $$MlsKeyPackagesTableOrderingComposer,
      $$MlsKeyPackagesTableAnnotationComposer,
      $$MlsKeyPackagesTableCreateCompanionBuilder,
      $$MlsKeyPackagesTableUpdateCompanionBuilder,
      (
        MlsKeyPackageRow,
        BaseReferences<_$AppDatabase, $MlsKeyPackagesTable, MlsKeyPackageRow>,
      ),
      MlsKeyPackageRow,
      PrefetchHooks Function()
    >;
typedef $$MlsGroupsTableCreateCompanionBuilder =
    MlsGroupsCompanion Function({
      Value<int> id,
      required Uint8List groupIdBytes,
      Value<String?> displayName,
      Value<DateTime> createdAt,
      Value<DateTime> lastActivityAt,
      Value<bool> isActive,
    });
typedef $$MlsGroupsTableUpdateCompanionBuilder =
    MlsGroupsCompanion Function({
      Value<int> id,
      Value<Uint8List> groupIdBytes,
      Value<String?> displayName,
      Value<DateTime> createdAt,
      Value<DateTime> lastActivityAt,
      Value<bool> isActive,
    });

class $$MlsGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $MlsGroupsTable> {
  $$MlsGroupsTableFilterComposer({
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

  ColumnFilters<Uint8List> get groupIdBytes => $composableBuilder(
    column: $table.groupIdBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MlsGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $MlsGroupsTable> {
  $$MlsGroupsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get groupIdBytes => $composableBuilder(
    column: $table.groupIdBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MlsGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MlsGroupsTable> {
  $$MlsGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get groupIdBytes => $composableBuilder(
    column: $table.groupIdBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$MlsGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MlsGroupsTable,
          MlsGroupRow,
          $$MlsGroupsTableFilterComposer,
          $$MlsGroupsTableOrderingComposer,
          $$MlsGroupsTableAnnotationComposer,
          $$MlsGroupsTableCreateCompanionBuilder,
          $$MlsGroupsTableUpdateCompanionBuilder,
          (
            MlsGroupRow,
            BaseReferences<_$AppDatabase, $MlsGroupsTable, MlsGroupRow>,
          ),
          MlsGroupRow,
          PrefetchHooks Function()
        > {
  $$MlsGroupsTableTableManager(_$AppDatabase db, $MlsGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MlsGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MlsGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MlsGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Uint8List> groupIdBytes = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastActivityAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => MlsGroupsCompanion(
                id: id,
                groupIdBytes: groupIdBytes,
                displayName: displayName,
                createdAt: createdAt,
                lastActivityAt: lastActivityAt,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Uint8List groupIdBytes,
                Value<String?> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastActivityAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => MlsGroupsCompanion.insert(
                id: id,
                groupIdBytes: groupIdBytes,
                displayName: displayName,
                createdAt: createdAt,
                lastActivityAt: lastActivityAt,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MlsGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MlsGroupsTable,
      MlsGroupRow,
      $$MlsGroupsTableFilterComposer,
      $$MlsGroupsTableOrderingComposer,
      $$MlsGroupsTableAnnotationComposer,
      $$MlsGroupsTableCreateCompanionBuilder,
      $$MlsGroupsTableUpdateCompanionBuilder,
      (
        MlsGroupRow,
        BaseReferences<_$AppDatabase, $MlsGroupsTable, MlsGroupRow>,
      ),
      MlsGroupRow,
      PrefetchHooks Function()
    >;
typedef $$MlsEngineConfigsTableCreateCompanionBuilder =
    MlsEngineConfigsCompanion Function({
      Value<int> id,
      required String dbPath,
      required Uint8List encryptionKey,
    });
typedef $$MlsEngineConfigsTableUpdateCompanionBuilder =
    MlsEngineConfigsCompanion Function({
      Value<int> id,
      Value<String> dbPath,
      Value<Uint8List> encryptionKey,
    });

class $$MlsEngineConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $MlsEngineConfigsTable> {
  $$MlsEngineConfigsTableFilterComposer({
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

  ColumnFilters<String> get dbPath => $composableBuilder(
    column: $table.dbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptionKey => $composableBuilder(
    column: $table.encryptionKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MlsEngineConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $MlsEngineConfigsTable> {
  $$MlsEngineConfigsTableOrderingComposer({
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

  ColumnOrderings<String> get dbPath => $composableBuilder(
    column: $table.dbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptionKey => $composableBuilder(
    column: $table.encryptionKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MlsEngineConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MlsEngineConfigsTable> {
  $$MlsEngineConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dbPath =>
      $composableBuilder(column: $table.dbPath, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptionKey => $composableBuilder(
    column: $table.encryptionKey,
    builder: (column) => column,
  );
}

class $$MlsEngineConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MlsEngineConfigsTable,
          MlsEngineConfigRow,
          $$MlsEngineConfigsTableFilterComposer,
          $$MlsEngineConfigsTableOrderingComposer,
          $$MlsEngineConfigsTableAnnotationComposer,
          $$MlsEngineConfigsTableCreateCompanionBuilder,
          $$MlsEngineConfigsTableUpdateCompanionBuilder,
          (
            MlsEngineConfigRow,
            BaseReferences<
              _$AppDatabase,
              $MlsEngineConfigsTable,
              MlsEngineConfigRow
            >,
          ),
          MlsEngineConfigRow,
          PrefetchHooks Function()
        > {
  $$MlsEngineConfigsTableTableManager(
    _$AppDatabase db,
    $MlsEngineConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MlsEngineConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MlsEngineConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MlsEngineConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dbPath = const Value.absent(),
                Value<Uint8List> encryptionKey = const Value.absent(),
              }) => MlsEngineConfigsCompanion(
                id: id,
                dbPath: dbPath,
                encryptionKey: encryptionKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dbPath,
                required Uint8List encryptionKey,
              }) => MlsEngineConfigsCompanion.insert(
                id: id,
                dbPath: dbPath,
                encryptionKey: encryptionKey,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MlsEngineConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MlsEngineConfigsTable,
      MlsEngineConfigRow,
      $$MlsEngineConfigsTableFilterComposer,
      $$MlsEngineConfigsTableOrderingComposer,
      $$MlsEngineConfigsTableAnnotationComposer,
      $$MlsEngineConfigsTableCreateCompanionBuilder,
      $$MlsEngineConfigsTableUpdateCompanionBuilder,
      (
        MlsEngineConfigRow,
        BaseReferences<
          _$AppDatabase,
          $MlsEngineConfigsTable,
          MlsEngineConfigRow
        >,
      ),
      MlsEngineConfigRow,
      PrefetchHooks Function()
    >;
typedef $$ProcessedObjectsTableCreateCompanionBuilder =
    ProcessedObjectsCompanion Function({required Uri id, Value<int> rowid});
typedef $$ProcessedObjectsTableUpdateCompanionBuilder =
    ProcessedObjectsCompanion Function({Value<Uri> id, Value<int> rowid});

class $$ProcessedObjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessedObjectsTable> {
  $$ProcessedObjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Uri, Uri, String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ProcessedObjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessedObjectsTable> {
  $$ProcessedObjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProcessedObjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessedObjectsTable> {
  $$ProcessedObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Uri, String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$ProcessedObjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcessedObjectsTable,
          ProcessedObjectRow,
          $$ProcessedObjectsTableFilterComposer,
          $$ProcessedObjectsTableOrderingComposer,
          $$ProcessedObjectsTableAnnotationComposer,
          $$ProcessedObjectsTableCreateCompanionBuilder,
          $$ProcessedObjectsTableUpdateCompanionBuilder,
          (
            ProcessedObjectRow,
            BaseReferences<
              _$AppDatabase,
              $ProcessedObjectsTable,
              ProcessedObjectRow
            >,
          ),
          ProcessedObjectRow,
          PrefetchHooks Function()
        > {
  $$ProcessedObjectsTableTableManager(
    _$AppDatabase db,
    $ProcessedObjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessedObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessedObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessedObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Uri> id = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProcessedObjectsCompanion(id: id, rowid: rowid),
          createCompanionCallback:
              ({required Uri id, Value<int> rowid = const Value.absent()}) =>
                  ProcessedObjectsCompanion.insert(id: id, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProcessedObjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcessedObjectsTable,
      ProcessedObjectRow,
      $$ProcessedObjectsTableFilterComposer,
      $$ProcessedObjectsTableOrderingComposer,
      $$ProcessedObjectsTableAnnotationComposer,
      $$ProcessedObjectsTableCreateCompanionBuilder,
      $$ProcessedObjectsTableUpdateCompanionBuilder,
      (
        ProcessedObjectRow,
        BaseReferences<
          _$AppDatabase,
          $ProcessedObjectsTable,
          ProcessedObjectRow
        >,
      ),
      ProcessedObjectRow,
      PrefetchHooks Function()
    >;
typedef $$StoredMessagesTableCreateCompanionBuilder =
    StoredMessagesCompanion Function({
      required Uri serverActivityId,
      required DateTime receivedAt,
      required Uri senderId,
      required InternalId id,
      Value<String?> content,
      required Uint8List groupId,
      Value<InternalId?> inReplyTo,
      Value<int> rowid,
    });
typedef $$StoredMessagesTableUpdateCompanionBuilder =
    StoredMessagesCompanion Function({
      Value<Uri> serverActivityId,
      Value<DateTime> receivedAt,
      Value<Uri> senderId,
      Value<InternalId> id,
      Value<String?> content,
      Value<Uint8List> groupId,
      Value<InternalId?> inReplyTo,
      Value<int> rowid,
    });

final class $$StoredMessagesTableReferences
    extends
        BaseReferences<_$AppDatabase, $StoredMessagesTable, StoredMessageRow> {
  $$StoredMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $MessageAttachmentsTable,
    List<MessageAttachmentRow>
  >
  _messageAttachmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.messageAttachments,
        aliasName: $_aliasNameGenerator(
          db.storedMessages.serverActivityId,
          db.messageAttachments.messageId,
        ),
      );

  $$MessageAttachmentsTableProcessedTableManager get messageAttachmentsRefs {
    final manager =
        $$MessageAttachmentsTableTableManager(
          $_db,
          $_db.messageAttachments,
        ).filter(
          (f) => f.messageId.serverActivityId.sqlEquals(
            $_itemColumn<String>('server_activity_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _messageAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoredMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $StoredMessagesTable> {
  $$StoredMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Uri, Uri, String> get serverActivityId =>
      $composableBuilder(
        column: $table.serverActivityId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Uri, Uri, String> get senderId =>
      $composableBuilder(
        column: $table.senderId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<InternalId, InternalId, String> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<InternalId?, InternalId, String>
  get inReplyTo => $composableBuilder(
    column: $table.inReplyTo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> messageAttachmentsRefs(
    Expression<bool> Function($$MessageAttachmentsTableFilterComposer f) f,
  ) {
    final $$MessageAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverActivityId,
      referencedTable: $db.messageAttachments,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.messageAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoredMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredMessagesTable> {
  $$StoredMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serverActivityId => $composableBuilder(
    column: $table.serverActivityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inReplyTo => $composableBuilder(
    column: $table.inReplyTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredMessagesTable> {
  $$StoredMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Uri, String> get serverActivityId =>
      $composableBuilder(
        column: $table.serverActivityId,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Uri, String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InternalId, String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<Uint8List> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InternalId?, String> get inReplyTo =>
      $composableBuilder(column: $table.inReplyTo, builder: (column) => column);

  Expression<T> messageAttachmentsRefs<T extends Object>(
    Expression<T> Function($$MessageAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$MessageAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.serverActivityId,
          referencedTable: $db.messageAttachments,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MessageAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.messageAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StoredMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredMessagesTable,
          StoredMessageRow,
          $$StoredMessagesTableFilterComposer,
          $$StoredMessagesTableOrderingComposer,
          $$StoredMessagesTableAnnotationComposer,
          $$StoredMessagesTableCreateCompanionBuilder,
          $$StoredMessagesTableUpdateCompanionBuilder,
          (StoredMessageRow, $$StoredMessagesTableReferences),
          StoredMessageRow,
          PrefetchHooks Function({bool messageAttachmentsRefs})
        > {
  $$StoredMessagesTableTableManager(
    _$AppDatabase db,
    $StoredMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Uri> serverActivityId = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<Uri> senderId = const Value.absent(),
                Value<InternalId> id = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<Uint8List> groupId = const Value.absent(),
                Value<InternalId?> inReplyTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredMessagesCompanion(
                serverActivityId: serverActivityId,
                receivedAt: receivedAt,
                senderId: senderId,
                id: id,
                content: content,
                groupId: groupId,
                inReplyTo: inReplyTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Uri serverActivityId,
                required DateTime receivedAt,
                required Uri senderId,
                required InternalId id,
                Value<String?> content = const Value.absent(),
                required Uint8List groupId,
                Value<InternalId?> inReplyTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredMessagesCompanion.insert(
                serverActivityId: serverActivityId,
                receivedAt: receivedAt,
                senderId: senderId,
                id: id,
                content: content,
                groupId: groupId,
                inReplyTo: inReplyTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoredMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageAttachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (messageAttachmentsRefs) db.messageAttachments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messageAttachmentsRefs)
                    await $_getPrefetchedData<
                      StoredMessageRow,
                      $StoredMessagesTable,
                      MessageAttachmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$StoredMessagesTableReferences
                          ._messageAttachmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StoredMessagesTableReferences(
                            db,
                            table,
                            p0,
                          ).messageAttachmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.messageId == item.serverActivityId,
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

typedef $$StoredMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredMessagesTable,
      StoredMessageRow,
      $$StoredMessagesTableFilterComposer,
      $$StoredMessagesTableOrderingComposer,
      $$StoredMessagesTableAnnotationComposer,
      $$StoredMessagesTableCreateCompanionBuilder,
      $$StoredMessagesTableUpdateCompanionBuilder,
      (StoredMessageRow, $$StoredMessagesTableReferences),
      StoredMessageRow,
      PrefetchHooks Function({bool messageAttachmentsRefs})
    >;
typedef $$MessageAttachmentsTableCreateCompanionBuilder =
    MessageAttachmentsCompanion Function({
      required Uri messageId,
      required InternalId attachmentId,
      Value<int> rowid,
    });
typedef $$MessageAttachmentsTableUpdateCompanionBuilder =
    MessageAttachmentsCompanion Function({
      Value<Uri> messageId,
      Value<InternalId> attachmentId,
      Value<int> rowid,
    });

final class $$MessageAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MessageAttachmentsTable,
          MessageAttachmentRow
        > {
  $$MessageAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StoredMessagesTable _messageIdTable(_$AppDatabase db) =>
      db.storedMessages.createAlias(
        $_aliasNameGenerator(
          db.messageAttachments.messageId,
          db.storedMessages.serverActivityId,
        ),
      );

  $$StoredMessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<String>('message_id')!;

    final manager = $$StoredMessagesTableTableManager(
      $_db,
      $_db.storedMessages,
    ).filter((f) => f.serverActivityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessageAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $MessageAttachmentsTable> {
  $$MessageAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<InternalId, InternalId, String>
  get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$StoredMessagesTableFilterComposer get messageId {
    final $$StoredMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.storedMessages,
      getReferencedColumn: (t) => t.serverActivityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMessagesTableFilterComposer(
            $db: $db,
            $table: $db.storedMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageAttachmentsTable> {
  $$MessageAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoredMessagesTableOrderingComposer get messageId {
    final $$StoredMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.storedMessages,
      getReferencedColumn: (t) => t.serverActivityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.storedMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageAttachmentsTable> {
  $$MessageAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<InternalId, String> get attachmentId =>
      $composableBuilder(
        column: $table.attachmentId,
        builder: (column) => column,
      );

  $$StoredMessagesTableAnnotationComposer get messageId {
    final $$StoredMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.storedMessages,
      getReferencedColumn: (t) => t.serverActivityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.storedMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageAttachmentsTable,
          MessageAttachmentRow,
          $$MessageAttachmentsTableFilterComposer,
          $$MessageAttachmentsTableOrderingComposer,
          $$MessageAttachmentsTableAnnotationComposer,
          $$MessageAttachmentsTableCreateCompanionBuilder,
          $$MessageAttachmentsTableUpdateCompanionBuilder,
          (MessageAttachmentRow, $$MessageAttachmentsTableReferences),
          MessageAttachmentRow,
          PrefetchHooks Function({bool messageId})
        > {
  $$MessageAttachmentsTableTableManager(
    _$AppDatabase db,
    $MessageAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<Uri> messageId = const Value.absent(),
                Value<InternalId> attachmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageAttachmentsCompanion(
                messageId: messageId,
                attachmentId: attachmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Uri messageId,
                required InternalId attachmentId,
                Value<int> rowid = const Value.absent(),
              }) => MessageAttachmentsCompanion.insert(
                messageId: messageId,
                attachmentId: attachmentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessageAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false}) {
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
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable:
                                    $$MessageAttachmentsTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$MessageAttachmentsTableReferences
                                        ._messageIdTable(db)
                                        .serverActivityId,
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

typedef $$MessageAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageAttachmentsTable,
      MessageAttachmentRow,
      $$MessageAttachmentsTableFilterComposer,
      $$MessageAttachmentsTableOrderingComposer,
      $$MessageAttachmentsTableAnnotationComposer,
      $$MessageAttachmentsTableCreateCompanionBuilder,
      $$MessageAttachmentsTableUpdateCompanionBuilder,
      (MessageAttachmentRow, $$MessageAttachmentsTableReferences),
      MessageAttachmentRow,
      PrefetchHooks Function({bool messageId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CapabilitiesTableTableManager get capabilities =>
      $$CapabilitiesTableTableManager(_db, _db.capabilities);
  $$MlsCredentialsTableTableManager get mlsCredentials =>
      $$MlsCredentialsTableTableManager(_db, _db.mlsCredentials);
  $$MlsKeyPackagesTableTableManager get mlsKeyPackages =>
      $$MlsKeyPackagesTableTableManager(_db, _db.mlsKeyPackages);
  $$MlsGroupsTableTableManager get mlsGroups =>
      $$MlsGroupsTableTableManager(_db, _db.mlsGroups);
  $$MlsEngineConfigsTableTableManager get mlsEngineConfigs =>
      $$MlsEngineConfigsTableTableManager(_db, _db.mlsEngineConfigs);
  $$ProcessedObjectsTableTableManager get processedObjects =>
      $$ProcessedObjectsTableTableManager(_db, _db.processedObjects);
  $$StoredMessagesTableTableManager get storedMessages =>
      $$StoredMessagesTableTableManager(_db, _db.storedMessages);
  $$MessageAttachmentsTableTableManager get messageAttachments =>
      $$MessageAttachmentsTableTableManager(_db, _db.messageAttachments);
}
