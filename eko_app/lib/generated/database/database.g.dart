// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../database/database.dart';

// ignore_for_file: type=lint
class $CapabilitiesTable extends Capabilities
    with TableInfo<$CapabilitiesTable, Capability> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapabilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      capabilities = GeneratedColumn<String>('capabilities', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Map<String, dynamic>>(
              $CapabilitiesTable.$convertercapabilities);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, capabilities, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capabilities';
  @override
  VerificationContext validateIntegrity(Insertable<Capability> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Capability map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Capability(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      capabilities: $CapabilitiesTable.$convertercapabilities.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}capabilities'])!),
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
    );
  }

  @override
  $CapabilitiesTable createAlias(String alias) {
    return $CapabilitiesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $convertercapabilities =
      const JsonValueConverter();
}

class Capability extends DataClass implements Insertable<Capability> {
  final int id;
  final Map<String, dynamic> capabilities;
  final DateTime time;
  const Capability(
      {required this.id, required this.capabilities, required this.time});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['capabilities'] = Variable<String>(
          $CapabilitiesTable.$convertercapabilities.toSql(capabilities));
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

  factory Capability.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Capability(
      id: serializer.fromJson<int>(json['id']),
      capabilities:
          serializer.fromJson<Map<String, dynamic>>(json['capabilities']),
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

  Capability copyWith(
          {int? id, Map<String, dynamic>? capabilities, DateTime? time}) =>
      Capability(
        id: id ?? this.id,
        capabilities: capabilities ?? this.capabilities,
        time: time ?? this.time,
      );
  Capability copyWithCompanion(CapabilitiesCompanion data) {
    return Capability(
      id: data.id.present ? data.id.value : this.id,
      capabilities: data.capabilities.present
          ? data.capabilities.value
          : this.capabilities,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Capability(')
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
      (other is Capability &&
          other.id == this.id &&
          other.capabilities == this.capabilities &&
          other.time == this.time);
}

class CapabilitiesCompanion extends UpdateCompanion<Capability> {
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
  static Insertable<Capability> custom({
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

  CapabilitiesCompanion copyWith(
      {Value<int>? id,
      Value<Map<String, dynamic>>? capabilities,
      Value<DateTime>? time}) {
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
          $CapabilitiesTable.$convertercapabilities.toSql(capabilities.value));
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
    with TableInfo<$MlsCredentialsTable, MlsCredential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MlsCredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _credentialIdentityMeta =
      const VerificationMeta('credentialIdentity');
  @override
  late final GeneratedColumn<Uint8List> credentialIdentity =
      GeneratedColumn<Uint8List>('credential_identity', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _credentialBytesMeta =
      const VerificationMeta('credentialBytes');
  @override
  late final GeneratedColumn<Uint8List> credentialBytes =
      GeneratedColumn<Uint8List>('credential_bytes', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _signerBytesMeta =
      const VerificationMeta('signerBytes');
  @override
  late final GeneratedColumn<Uint8List> signerBytes =
      GeneratedColumn<Uint8List>('signer_bytes', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _signerPublicKeyMeta =
      const VerificationMeta('signerPublicKey');
  @override
  late final GeneratedColumn<Uint8List> signerPublicKey =
      GeneratedColumn<Uint8List>('signer_public_key', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, credentialIdentity, credentialBytes, signerBytes, signerPublicKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mls_credentials';
  @override
  VerificationContext validateIntegrity(Insertable<MlsCredential> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('credential_identity')) {
      context.handle(
          _credentialIdentityMeta,
          credentialIdentity.isAcceptableOrUnknown(
              data['credential_identity']!, _credentialIdentityMeta));
    } else if (isInserting) {
      context.missing(_credentialIdentityMeta);
    }
    if (data.containsKey('credential_bytes')) {
      context.handle(
          _credentialBytesMeta,
          credentialBytes.isAcceptableOrUnknown(
              data['credential_bytes']!, _credentialBytesMeta));
    } else if (isInserting) {
      context.missing(_credentialBytesMeta);
    }
    if (data.containsKey('signer_bytes')) {
      context.handle(
          _signerBytesMeta,
          signerBytes.isAcceptableOrUnknown(
              data['signer_bytes']!, _signerBytesMeta));
    } else if (isInserting) {
      context.missing(_signerBytesMeta);
    }
    if (data.containsKey('signer_public_key')) {
      context.handle(
          _signerPublicKeyMeta,
          signerPublicKey.isAcceptableOrUnknown(
              data['signer_public_key']!, _signerPublicKeyMeta));
    } else if (isInserting) {
      context.missing(_signerPublicKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MlsCredential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MlsCredential(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      credentialIdentity: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}credential_identity'])!,
      credentialBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}credential_bytes'])!,
      signerBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}signer_bytes'])!,
      signerPublicKey: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}signer_public_key'])!,
    );
  }

  @override
  $MlsCredentialsTable createAlias(String alias) {
    return $MlsCredentialsTable(attachedDatabase, alias);
  }
}

class MlsCredential extends DataClass implements Insertable<MlsCredential> {
  final int id;
  final Uint8List credentialIdentity;
  final Uint8List credentialBytes;
  final Uint8List signerBytes;
  final Uint8List signerPublicKey;
  const MlsCredential(
      {required this.id,
      required this.credentialIdentity,
      required this.credentialBytes,
      required this.signerBytes,
      required this.signerPublicKey});
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

  factory MlsCredential.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MlsCredential(
      id: serializer.fromJson<int>(json['id']),
      credentialIdentity:
          serializer.fromJson<Uint8List>(json['credentialIdentity']),
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

  MlsCredential copyWith(
          {int? id,
          Uint8List? credentialIdentity,
          Uint8List? credentialBytes,
          Uint8List? signerBytes,
          Uint8List? signerPublicKey}) =>
      MlsCredential(
        id: id ?? this.id,
        credentialIdentity: credentialIdentity ?? this.credentialIdentity,
        credentialBytes: credentialBytes ?? this.credentialBytes,
        signerBytes: signerBytes ?? this.signerBytes,
        signerPublicKey: signerPublicKey ?? this.signerPublicKey,
      );
  MlsCredential copyWithCompanion(MlsCredentialsCompanion data) {
    return MlsCredential(
      id: data.id.present ? data.id.value : this.id,
      credentialIdentity: data.credentialIdentity.present
          ? data.credentialIdentity.value
          : this.credentialIdentity,
      credentialBytes: data.credentialBytes.present
          ? data.credentialBytes.value
          : this.credentialBytes,
      signerBytes:
          data.signerBytes.present ? data.signerBytes.value : this.signerBytes,
      signerPublicKey: data.signerPublicKey.present
          ? data.signerPublicKey.value
          : this.signerPublicKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MlsCredential(')
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
      $driftBlobEquality.hash(signerPublicKey));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MlsCredential &&
          other.id == this.id &&
          $driftBlobEquality.equals(
              other.credentialIdentity, this.credentialIdentity) &&
          $driftBlobEquality.equals(
              other.credentialBytes, this.credentialBytes) &&
          $driftBlobEquality.equals(other.signerBytes, this.signerBytes) &&
          $driftBlobEquality.equals(
              other.signerPublicKey, this.signerPublicKey));
}

class MlsCredentialsCompanion extends UpdateCompanion<MlsCredential> {
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
  })  : credentialIdentity = Value(credentialIdentity),
        credentialBytes = Value(credentialBytes),
        signerBytes = Value(signerBytes),
        signerPublicKey = Value(signerPublicKey);
  static Insertable<MlsCredential> custom({
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

  MlsCredentialsCompanion copyWith(
      {Value<int>? id,
      Value<Uint8List>? credentialIdentity,
      Value<Uint8List>? credentialBytes,
      Value<Uint8List>? signerBytes,
      Value<Uint8List>? signerPublicKey}) {
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
      map['credential_identity'] =
          Variable<Uint8List>(credentialIdentity.value);
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
    with TableInfo<$MlsKeyPackagesTable, MlsKeyPackage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MlsKeyPackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyPackageMeta =
      const VerificationMeta('keyPackage');
  @override
  late final GeneratedColumn<Uint8List> keyPackage = GeneratedColumn<Uint8List>(
      'key_package', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, keyPackage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mls_key_packages';
  @override
  VerificationContext validateIntegrity(Insertable<MlsKeyPackage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key_package')) {
      context.handle(
          _keyPackageMeta,
          keyPackage.isAcceptableOrUnknown(
              data['key_package']!, _keyPackageMeta));
    } else if (isInserting) {
      context.missing(_keyPackageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MlsKeyPackage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MlsKeyPackage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      keyPackage: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}key_package'])!,
    );
  }

  @override
  $MlsKeyPackagesTable createAlias(String alias) {
    return $MlsKeyPackagesTable(attachedDatabase, alias);
  }
}

class MlsKeyPackage extends DataClass implements Insertable<MlsKeyPackage> {
  final int id;
  final Uint8List keyPackage;
  const MlsKeyPackage({required this.id, required this.keyPackage});
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

  factory MlsKeyPackage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MlsKeyPackage(
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

  MlsKeyPackage copyWith({int? id, Uint8List? keyPackage}) => MlsKeyPackage(
        id: id ?? this.id,
        keyPackage: keyPackage ?? this.keyPackage,
      );
  MlsKeyPackage copyWithCompanion(MlsKeyPackagesCompanion data) {
    return MlsKeyPackage(
      id: data.id.present ? data.id.value : this.id,
      keyPackage:
          data.keyPackage.present ? data.keyPackage.value : this.keyPackage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MlsKeyPackage(')
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
      (other is MlsKeyPackage &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.keyPackage, this.keyPackage));
}

class MlsKeyPackagesCompanion extends UpdateCompanion<MlsKeyPackage> {
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
  static Insertable<MlsKeyPackage> custom({
    Expression<int>? id,
    Expression<Uint8List>? keyPackage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyPackage != null) 'key_package': keyPackage,
    });
  }

  MlsKeyPackagesCompanion copyWith(
      {Value<int>? id, Value<Uint8List>? keyPackage}) {
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

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Uri, String> id =
      GeneratedColumn<String>('id', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Uri>($UsersTable.$converterid);
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: $UsersTable.$converterid.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converterid = const UriTypeConverter();
}

class User extends DataClass implements Insertable<User> {
  final Uri id;
  const User({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<String>($UsersTable.$converterid.toSql(id));
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<Uri>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uri>(id),
    };
  }

  User copyWith({Uri? id}) => User(
        id: id ?? this.id,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is User && other.id == this.id);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<Uri> id;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required Uri id,
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({Value<Uri>? id, Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>($UsersTable.$converterid.toSql(id.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserDevicesTable extends UserDevices
    with TableInfo<$UserDevicesTable, UserDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<Uri, String> userId =
      GeneratedColumn<String>('user_id', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              defaultConstraints: GeneratedColumn.constraintIsAlways(
                  'REFERENCES users (id) ON DELETE CASCADE'))
          .withConverter<Uri>($UserDevicesTable.$converteruserId);
  @override
  late final GeneratedColumnWithTypeConverter<Uri, String> deviceId =
      GeneratedColumn<String>('device_id', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'))
          .withConverter<Uri>($UserDevicesTable.$converterdeviceId);
  @override
  List<GeneratedColumn> get $columns => [id, userId, deviceId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_devices';
  @override
  VerificationContext validateIntegrity(Insertable<UserDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserDevice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: $UserDevicesTable.$converteruserId.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!),
      deviceId: $UserDevicesTable.$converterdeviceId.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!),
    );
  }

  @override
  $UserDevicesTable createAlias(String alias) {
    return $UserDevicesTable(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converteruserId = const UriTypeConverter();
  static TypeConverter<Uri, String> $converterdeviceId =
      const UriTypeConverter();
}

class UserDevice extends DataClass implements Insertable<UserDevice> {
  final int id;
  final Uri userId;
  final Uri deviceId;
  const UserDevice(
      {required this.id, required this.userId, required this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['user_id'] =
          Variable<String>($UserDevicesTable.$converteruserId.toSql(userId));
    }
    {
      map['device_id'] = Variable<String>(
          $UserDevicesTable.$converterdeviceId.toSql(deviceId));
    }
    return map;
  }

  UserDevicesCompanion toCompanion(bool nullToAbsent) {
    return UserDevicesCompanion(
      id: Value(id),
      userId: Value(userId),
      deviceId: Value(deviceId),
    );
  }

  factory UserDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserDevice(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<Uri>(json['userId']),
      deviceId: serializer.fromJson<Uri>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<Uri>(userId),
      'deviceId': serializer.toJson<Uri>(deviceId),
    };
  }

  UserDevice copyWith({int? id, Uri? userId, Uri? deviceId}) => UserDevice(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        deviceId: deviceId ?? this.deviceId,
      );
  UserDevice copyWithCompanion(UserDevicesCompanion data) {
    return UserDevice(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserDevice(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserDevice &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId);
}

class UserDevicesCompanion extends UpdateCompanion<UserDevice> {
  final Value<int> id;
  final Value<Uri> userId;
  final Value<Uri> deviceId;
  const UserDevicesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
  });
  UserDevicesCompanion.insert({
    this.id = const Value.absent(),
    required Uri userId,
    required Uri deviceId,
  })  : userId = Value(userId),
        deviceId = Value(deviceId);
  static Insertable<UserDevice> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
    });
  }

  UserDevicesCompanion copyWith(
      {Value<int>? id, Value<Uri>? userId, Value<Uri>? deviceId}) {
    return UserDevicesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(
          $UserDevicesTable.$converteruserId.toSql(userId.value));
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(
          $UserDevicesTable.$converterdeviceId.toSql(deviceId.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserDevicesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId')
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
  late final $UsersTable users = $UsersTable(this);
  late final $UserDevicesTable userDevices = $UserDevicesTable(this);
  late final Index idxDeviceId = Index('idx_device_id',
      'CREATE INDEX idx_device_id ON user_devices (device_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        capabilities,
        mlsCredentials,
        mlsKeyPackages,
        users,
        userDevices,
        idxDeviceId
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('user_devices', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$CapabilitiesTableCreateCompanionBuilder = CapabilitiesCompanion
    Function({
  Value<int> id,
  required Map<String, dynamic> capabilities,
  Value<DateTime> time,
});
typedef $$CapabilitiesTableUpdateCompanionBuilder = CapabilitiesCompanion
    Function({
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>, Map<String, dynamic>,
          String>
      get capabilities => $composableBuilder(
          column: $table.capabilities,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capabilities => $composableBuilder(
      column: $table.capabilities,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));
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
          column: $table.capabilities, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$CapabilitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CapabilitiesTable,
    Capability,
    $$CapabilitiesTableFilterComposer,
    $$CapabilitiesTableOrderingComposer,
    $$CapabilitiesTableAnnotationComposer,
    $$CapabilitiesTableCreateCompanionBuilder,
    $$CapabilitiesTableUpdateCompanionBuilder,
    (Capability, BaseReferences<_$AppDatabase, $CapabilitiesTable, Capability>),
    Capability,
    PrefetchHooks Function()> {
  $$CapabilitiesTableTableManager(_$AppDatabase db, $CapabilitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapabilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapabilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapabilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Map<String, dynamic>> capabilities = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
          }) =>
              CapabilitiesCompanion(
            id: id,
            capabilities: capabilities,
            time: time,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required Map<String, dynamic> capabilities,
            Value<DateTime> time = const Value.absent(),
          }) =>
              CapabilitiesCompanion.insert(
            id: id,
            capabilities: capabilities,
            time: time,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CapabilitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CapabilitiesTable,
    Capability,
    $$CapabilitiesTableFilterComposer,
    $$CapabilitiesTableOrderingComposer,
    $$CapabilitiesTableAnnotationComposer,
    $$CapabilitiesTableCreateCompanionBuilder,
    $$CapabilitiesTableUpdateCompanionBuilder,
    (Capability, BaseReferences<_$AppDatabase, $CapabilitiesTable, Capability>),
    Capability,
    PrefetchHooks Function()>;
typedef $$MlsCredentialsTableCreateCompanionBuilder = MlsCredentialsCompanion
    Function({
  Value<int> id,
  required Uint8List credentialIdentity,
  required Uint8List credentialBytes,
  required Uint8List signerBytes,
  required Uint8List signerPublicKey,
});
typedef $$MlsCredentialsTableUpdateCompanionBuilder = MlsCredentialsCompanion
    Function({
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get credentialIdentity => $composableBuilder(
      column: $table.credentialIdentity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get credentialBytes => $composableBuilder(
      column: $table.credentialBytes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get signerBytes => $composableBuilder(
      column: $table.signerBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get signerPublicKey => $composableBuilder(
      column: $table.signerPublicKey,
      builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get credentialIdentity => $composableBuilder(
      column: $table.credentialIdentity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get credentialBytes => $composableBuilder(
      column: $table.credentialBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get signerBytes => $composableBuilder(
      column: $table.signerBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get signerPublicKey => $composableBuilder(
      column: $table.signerPublicKey,
      builder: (column) => ColumnOrderings(column));
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
      column: $table.credentialIdentity, builder: (column) => column);

  GeneratedColumn<Uint8List> get credentialBytes => $composableBuilder(
      column: $table.credentialBytes, builder: (column) => column);

  GeneratedColumn<Uint8List> get signerBytes => $composableBuilder(
      column: $table.signerBytes, builder: (column) => column);

  GeneratedColumn<Uint8List> get signerPublicKey => $composableBuilder(
      column: $table.signerPublicKey, builder: (column) => column);
}

class $$MlsCredentialsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MlsCredentialsTable,
    MlsCredential,
    $$MlsCredentialsTableFilterComposer,
    $$MlsCredentialsTableOrderingComposer,
    $$MlsCredentialsTableAnnotationComposer,
    $$MlsCredentialsTableCreateCompanionBuilder,
    $$MlsCredentialsTableUpdateCompanionBuilder,
    (
      MlsCredential,
      BaseReferences<_$AppDatabase, $MlsCredentialsTable, MlsCredential>
    ),
    MlsCredential,
    PrefetchHooks Function()> {
  $$MlsCredentialsTableTableManager(
      _$AppDatabase db, $MlsCredentialsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MlsCredentialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MlsCredentialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MlsCredentialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Uint8List> credentialIdentity = const Value.absent(),
            Value<Uint8List> credentialBytes = const Value.absent(),
            Value<Uint8List> signerBytes = const Value.absent(),
            Value<Uint8List> signerPublicKey = const Value.absent(),
          }) =>
              MlsCredentialsCompanion(
            id: id,
            credentialIdentity: credentialIdentity,
            credentialBytes: credentialBytes,
            signerBytes: signerBytes,
            signerPublicKey: signerPublicKey,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required Uint8List credentialIdentity,
            required Uint8List credentialBytes,
            required Uint8List signerBytes,
            required Uint8List signerPublicKey,
          }) =>
              MlsCredentialsCompanion.insert(
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
        ));
}

typedef $$MlsCredentialsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MlsCredentialsTable,
    MlsCredential,
    $$MlsCredentialsTableFilterComposer,
    $$MlsCredentialsTableOrderingComposer,
    $$MlsCredentialsTableAnnotationComposer,
    $$MlsCredentialsTableCreateCompanionBuilder,
    $$MlsCredentialsTableUpdateCompanionBuilder,
    (
      MlsCredential,
      BaseReferences<_$AppDatabase, $MlsCredentialsTable, MlsCredential>
    ),
    MlsCredential,
    PrefetchHooks Function()>;
typedef $$MlsKeyPackagesTableCreateCompanionBuilder = MlsKeyPackagesCompanion
    Function({
  Value<int> id,
  required Uint8List keyPackage,
});
typedef $$MlsKeyPackagesTableUpdateCompanionBuilder = MlsKeyPackagesCompanion
    Function({
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get keyPackage => $composableBuilder(
      column: $table.keyPackage, builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get keyPackage => $composableBuilder(
      column: $table.keyPackage, builder: (column) => ColumnOrderings(column));
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
      column: $table.keyPackage, builder: (column) => column);
}

class $$MlsKeyPackagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MlsKeyPackagesTable,
    MlsKeyPackage,
    $$MlsKeyPackagesTableFilterComposer,
    $$MlsKeyPackagesTableOrderingComposer,
    $$MlsKeyPackagesTableAnnotationComposer,
    $$MlsKeyPackagesTableCreateCompanionBuilder,
    $$MlsKeyPackagesTableUpdateCompanionBuilder,
    (
      MlsKeyPackage,
      BaseReferences<_$AppDatabase, $MlsKeyPackagesTable, MlsKeyPackage>
    ),
    MlsKeyPackage,
    PrefetchHooks Function()> {
  $$MlsKeyPackagesTableTableManager(
      _$AppDatabase db, $MlsKeyPackagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MlsKeyPackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MlsKeyPackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MlsKeyPackagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Uint8List> keyPackage = const Value.absent(),
          }) =>
              MlsKeyPackagesCompanion(
            id: id,
            keyPackage: keyPackage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required Uint8List keyPackage,
          }) =>
              MlsKeyPackagesCompanion.insert(
            id: id,
            keyPackage: keyPackage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MlsKeyPackagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MlsKeyPackagesTable,
    MlsKeyPackage,
    $$MlsKeyPackagesTableFilterComposer,
    $$MlsKeyPackagesTableOrderingComposer,
    $$MlsKeyPackagesTableAnnotationComposer,
    $$MlsKeyPackagesTableCreateCompanionBuilder,
    $$MlsKeyPackagesTableUpdateCompanionBuilder,
    (
      MlsKeyPackage,
      BaseReferences<_$AppDatabase, $MlsKeyPackagesTable, MlsKeyPackage>
    ),
    MlsKeyPackage,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required Uri id,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<Uri> id,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserDevicesTable, List<UserDevice>>
      _userDevicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userDevices,
          aliasName: $_aliasNameGenerator(db.users.id, db.userDevices.userId));

  $$UserDevicesTableProcessedTableManager get userDevicesRefs {
    final manager = $$UserDevicesTableTableManager($_db, $_db.userDevices)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userDevicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Uri, Uri, String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> userDevicesRefs(
      Expression<bool> Function($$UserDevicesTableFilterComposer f) f) {
    final $$UserDevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userDevices,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserDevicesTableFilterComposer(
              $db: $db,
              $table: $db.userDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Uri, String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  Expression<T> userDevicesRefs<T extends Object>(
      Expression<T> Function($$UserDevicesTableAnnotationComposer a) f) {
    final $$UserDevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userDevices,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserDevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.userDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool userDevicesRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uri> id = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uri id,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({userDevicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userDevicesRefs) db.userDevices],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userDevicesRefs)
                    await $_getPrefetchedData<User, $UsersTable, UserDevice>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._userDevicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .userDevicesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool userDevicesRefs})>;
typedef $$UserDevicesTableCreateCompanionBuilder = UserDevicesCompanion
    Function({
  Value<int> id,
  required Uri userId,
  required Uri deviceId,
});
typedef $$UserDevicesTableUpdateCompanionBuilder = UserDevicesCompanion
    Function({
  Value<int> id,
  Value<Uri> userId,
  Value<Uri> deviceId,
});

final class $$UserDevicesTableReferences
    extends BaseReferences<_$AppDatabase, $UserDevicesTable, UserDevice> {
  $$UserDevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.userDevices.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $UserDevicesTable> {
  $$UserDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Uri, Uri, String> get deviceId =>
      $composableBuilder(
          column: $table.deviceId,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserDevicesTable> {
  $$UserDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserDevicesTable> {
  $$UserDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Uri, String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserDevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserDevicesTable,
    UserDevice,
    $$UserDevicesTableFilterComposer,
    $$UserDevicesTableOrderingComposer,
    $$UserDevicesTableAnnotationComposer,
    $$UserDevicesTableCreateCompanionBuilder,
    $$UserDevicesTableUpdateCompanionBuilder,
    (UserDevice, $$UserDevicesTableReferences),
    UserDevice,
    PrefetchHooks Function({bool userId})> {
  $$UserDevicesTableTableManager(_$AppDatabase db, $UserDevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Uri> userId = const Value.absent(),
            Value<Uri> deviceId = const Value.absent(),
          }) =>
              UserDevicesCompanion(
            id: id,
            userId: userId,
            deviceId: deviceId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required Uri userId,
            required Uri deviceId,
          }) =>
              UserDevicesCompanion.insert(
            id: id,
            userId: userId,
            deviceId: deviceId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserDevicesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$UserDevicesTableReferences._userIdTable(db),
                    referencedColumn:
                        $$UserDevicesTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserDevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserDevicesTable,
    UserDevice,
    $$UserDevicesTableFilterComposer,
    $$UserDevicesTableOrderingComposer,
    $$UserDevicesTableAnnotationComposer,
    $$UserDevicesTableCreateCompanionBuilder,
    $$UserDevicesTableUpdateCompanionBuilder,
    (UserDevice, $$UserDevicesTableReferences),
    UserDevice,
    PrefetchHooks Function({bool userId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CapabilitiesTableTableManager get capabilities =>
      $$CapabilitiesTableTableManager(_db, _db.capabilities);
  $$MlsCredentialsTableTableManager get mlsCredentials =>
      $$MlsCredentialsTableTableManager(_db, _db.mlsCredentials);
  $$MlsKeyPackagesTableTableManager get mlsKeyPackages =>
      $$MlsKeyPackagesTableTableManager(_db, _db.mlsKeyPackages);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserDevicesTableTableManager get userDevices =>
      $$UserDevicesTableTableManager(_db, _db.userDevices);
}
