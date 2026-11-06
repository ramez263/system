// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TunnelConfigsTable extends TunnelConfigs
    with TableInfo<$TunnelConfigsTable, TunnelConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TunnelConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _protocolMeta =
      const VerificationMeta('protocol');
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
      'protocol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverAddressMeta =
      const VerificationMeta('serverAddress');
  @override
  late final GeneratedColumn<String> serverAddress = GeneratedColumn<String>(
      'server_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverPortMeta =
      const VerificationMeta('serverPort');
  @override
  late final GeneratedColumn<int> serverPort = GeneratedColumn<int>(
      'server_port', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rawConfigMeta =
      const VerificationMeta('rawConfig');
  @override
  late final GeneratedColumn<String> rawConfig = GeneratedColumn<String>(
      'raw_config', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        protocol,
        serverAddress,
        serverPort,
        rawConfig,
        isFavorite,
        isLocked,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tunnel_configs';
  @override
  VerificationContext validateIntegrity(Insertable<TunnelConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('protocol')) {
      context.handle(_protocolMeta,
          protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta));
    } else if (isInserting) {
      context.missing(_protocolMeta);
    }
    if (data.containsKey('server_address')) {
      context.handle(
          _serverAddressMeta,
          serverAddress.isAcceptableOrUnknown(
              data['server_address']!, _serverAddressMeta));
    } else if (isInserting) {
      context.missing(_serverAddressMeta);
    }
    if (data.containsKey('server_port')) {
      context.handle(
          _serverPortMeta,
          serverPort.isAcceptableOrUnknown(
              data['server_port']!, _serverPortMeta));
    } else if (isInserting) {
      context.missing(_serverPortMeta);
    }
    if (data.containsKey('raw_config')) {
      context.handle(_rawConfigMeta,
          rawConfig.isAcceptableOrUnknown(data['raw_config']!, _rawConfigMeta));
    } else if (isInserting) {
      context.missing(_rawConfigMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TunnelConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TunnelConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      protocol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}protocol'])!,
      serverAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_address'])!,
      serverPort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_port'])!,
      rawConfig: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_config'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TunnelConfigsTable createAlias(String alias) {
    return $TunnelConfigsTable(attachedDatabase, alias);
  }
}

class TunnelConfig extends DataClass implements Insertable<TunnelConfig> {
  final int id;
  final String name;
  final String protocol;
  final String serverAddress;
  final int serverPort;
  final String rawConfig;
  final bool isFavorite;
  final bool isLocked;
  final DateTime createdAt;
  const TunnelConfig(
      {required this.id,
      required this.name,
      required this.protocol,
      required this.serverAddress,
      required this.serverPort,
      required this.rawConfig,
      required this.isFavorite,
      required this.isLocked,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['protocol'] = Variable<String>(protocol);
    map['server_address'] = Variable<String>(serverAddress);
    map['server_port'] = Variable<int>(serverPort);
    map['raw_config'] = Variable<String>(rawConfig);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_locked'] = Variable<bool>(isLocked);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TunnelConfigsCompanion toCompanion(bool nullToAbsent) {
    return TunnelConfigsCompanion(
      id: Value(id),
      name: Value(name),
      protocol: Value(protocol),
      serverAddress: Value(serverAddress),
      serverPort: Value(serverPort),
      rawConfig: Value(rawConfig),
      isFavorite: Value(isFavorite),
      isLocked: Value(isLocked),
      createdAt: Value(createdAt),
    );
  }

  factory TunnelConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TunnelConfig(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      protocol: serializer.fromJson<String>(json['protocol']),
      serverAddress: serializer.fromJson<String>(json['serverAddress']),
      serverPort: serializer.fromJson<int>(json['serverPort']),
      rawConfig: serializer.fromJson<String>(json['rawConfig']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'protocol': serializer.toJson<String>(protocol),
      'serverAddress': serializer.toJson<String>(serverAddress),
      'serverPort': serializer.toJson<int>(serverPort),
      'rawConfig': serializer.toJson<String>(rawConfig),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isLocked': serializer.toJson<bool>(isLocked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TunnelConfig copyWith(
          {int? id,
          String? name,
          String? protocol,
          String? serverAddress,
          int? serverPort,
          String? rawConfig,
          bool? isFavorite,
          bool? isLocked,
          DateTime? createdAt}) =>
      TunnelConfig(
        id: id ?? this.id,
        name: name ?? this.name,
        protocol: protocol ?? this.protocol,
        serverAddress: serverAddress ?? this.serverAddress,
        serverPort: serverPort ?? this.serverPort,
        rawConfig: rawConfig ?? this.rawConfig,
        isFavorite: isFavorite ?? this.isFavorite,
        isLocked: isLocked ?? this.isLocked,
        createdAt: createdAt ?? this.createdAt,
      );
  TunnelConfig copyWithCompanion(TunnelConfigsCompanion data) {
    return TunnelConfig(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      serverAddress: data.serverAddress.present
          ? data.serverAddress.value
          : this.serverAddress,
      serverPort:
          data.serverPort.present ? data.serverPort.value : this.serverPort,
      rawConfig: data.rawConfig.present ? data.rawConfig.value : this.rawConfig,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TunnelConfig(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('protocol: $protocol, ')
          ..write('serverAddress: $serverAddress, ')
          ..write('serverPort: $serverPort, ')
          ..write('rawConfig: $rawConfig, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, protocol, serverAddress, serverPort,
      rawConfig, isFavorite, isLocked, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TunnelConfig &&
          other.id == this.id &&
          other.name == this.name &&
          other.protocol == this.protocol &&
          other.serverAddress == this.serverAddress &&
          other.serverPort == this.serverPort &&
          other.rawConfig == this.rawConfig &&
          other.isFavorite == this.isFavorite &&
          other.isLocked == this.isLocked &&
          other.createdAt == this.createdAt);
}

class TunnelConfigsCompanion extends UpdateCompanion<TunnelConfig> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> protocol;
  final Value<String> serverAddress;
  final Value<int> serverPort;
  final Value<String> rawConfig;
  final Value<bool> isFavorite;
  final Value<bool> isLocked;
  final Value<DateTime> createdAt;
  const TunnelConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.protocol = const Value.absent(),
    this.serverAddress = const Value.absent(),
    this.serverPort = const Value.absent(),
    this.rawConfig = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TunnelConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String protocol,
    required String serverAddress,
    required int serverPort,
    required String rawConfig,
    this.isFavorite = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        protocol = Value(protocol),
        serverAddress = Value(serverAddress),
        serverPort = Value(serverPort),
        rawConfig = Value(rawConfig);
  static Insertable<TunnelConfig> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? protocol,
    Expression<String>? serverAddress,
    Expression<int>? serverPort,
    Expression<String>? rawConfig,
    Expression<bool>? isFavorite,
    Expression<bool>? isLocked,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (protocol != null) 'protocol': protocol,
      if (serverAddress != null) 'server_address': serverAddress,
      if (serverPort != null) 'server_port': serverPort,
      if (rawConfig != null) 'raw_config': rawConfig,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isLocked != null) 'is_locked': isLocked,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TunnelConfigsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? protocol,
      Value<String>? serverAddress,
      Value<int>? serverPort,
      Value<String>? rawConfig,
      Value<bool>? isFavorite,
      Value<bool>? isLocked,
      Value<DateTime>? createdAt}) {
    return TunnelConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      serverAddress: serverAddress ?? this.serverAddress,
      serverPort: serverPort ?? this.serverPort,
      rawConfig: rawConfig ?? this.rawConfig,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
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
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (serverAddress.present) {
      map['server_address'] = Variable<String>(serverAddress.value);
    }
    if (serverPort.present) {
      map['server_port'] = Variable<int>(serverPort.value);
    }
    if (rawConfig.present) {
      map['raw_config'] = Variable<String>(rawConfig.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TunnelConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('protocol: $protocol, ')
          ..write('serverAddress: $serverAddress, ')
          ..write('serverPort: $serverPort, ')
          ..write('rawConfig: $rawConfig, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ConnectionLogsTable extends ConnectionLogs
    with TableInfo<$ConnectionLogsTable, ConnectionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverNameMeta =
      const VerificationMeta('serverName');
  @override
  late final GeneratedColumn<String> serverName = GeneratedColumn<String>(
      'server_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _protocolMeta =
      const VerificationMeta('protocol');
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
      'protocol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _connectedAtMeta =
      const VerificationMeta('connectedAt');
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
      'connected_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _disconnectedAtMeta =
      const VerificationMeta('disconnectedAt');
  @override
  late final GeneratedColumn<DateTime> disconnectedAt =
      GeneratedColumn<DateTime>('disconnected_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bytesUploadedMeta =
      const VerificationMeta('bytesUploaded');
  @override
  late final GeneratedColumn<int> bytesUploaded = GeneratedColumn<int>(
      'bytes_uploaded', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bytesDownloadedMeta =
      const VerificationMeta('bytesDownloaded');
  @override
  late final GeneratedColumn<int> bytesDownloaded = GeneratedColumn<int>(
      'bytes_downloaded', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _disconnectReasonMeta =
      const VerificationMeta('disconnectReason');
  @override
  late final GeneratedColumn<String> disconnectReason = GeneratedColumn<String>(
      'disconnect_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverName,
        protocol,
        connectedAt,
        disconnectedAt,
        durationSeconds,
        bytesUploaded,
        bytesDownloaded,
        disconnectReason
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connection_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ConnectionLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_name')) {
      context.handle(
          _serverNameMeta,
          serverName.isAcceptableOrUnknown(
              data['server_name']!, _serverNameMeta));
    } else if (isInserting) {
      context.missing(_serverNameMeta);
    }
    if (data.containsKey('protocol')) {
      context.handle(_protocolMeta,
          protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta));
    } else if (isInserting) {
      context.missing(_protocolMeta);
    }
    if (data.containsKey('connected_at')) {
      context.handle(
          _connectedAtMeta,
          connectedAt.isAcceptableOrUnknown(
              data['connected_at']!, _connectedAtMeta));
    } else if (isInserting) {
      context.missing(_connectedAtMeta);
    }
    if (data.containsKey('disconnected_at')) {
      context.handle(
          _disconnectedAtMeta,
          disconnectedAt.isAcceptableOrUnknown(
              data['disconnected_at']!, _disconnectedAtMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('bytes_uploaded')) {
      context.handle(
          _bytesUploadedMeta,
          bytesUploaded.isAcceptableOrUnknown(
              data['bytes_uploaded']!, _bytesUploadedMeta));
    }
    if (data.containsKey('bytes_downloaded')) {
      context.handle(
          _bytesDownloadedMeta,
          bytesDownloaded.isAcceptableOrUnknown(
              data['bytes_downloaded']!, _bytesDownloadedMeta));
    }
    if (data.containsKey('disconnect_reason')) {
      context.handle(
          _disconnectReasonMeta,
          disconnectReason.isAcceptableOrUnknown(
              data['disconnect_reason']!, _disconnectReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConnectionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_name'])!,
      protocol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}protocol'])!,
      connectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}connected_at'])!,
      disconnectedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}disconnected_at']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      bytesUploaded: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes_uploaded'])!,
      bytesDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes_downloaded'])!,
      disconnectReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}disconnect_reason']),
    );
  }

  @override
  $ConnectionLogsTable createAlias(String alias) {
    return $ConnectionLogsTable(attachedDatabase, alias);
  }
}

class ConnectionLog extends DataClass implements Insertable<ConnectionLog> {
  final int id;
  final String serverName;
  final String protocol;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final int durationSeconds;
  final int bytesUploaded;
  final int bytesDownloaded;
  final String? disconnectReason;
  const ConnectionLog(
      {required this.id,
      required this.serverName,
      required this.protocol,
      required this.connectedAt,
      this.disconnectedAt,
      required this.durationSeconds,
      required this.bytesUploaded,
      required this.bytesDownloaded,
      this.disconnectReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_name'] = Variable<String>(serverName);
    map['protocol'] = Variable<String>(protocol);
    map['connected_at'] = Variable<DateTime>(connectedAt);
    if (!nullToAbsent || disconnectedAt != null) {
      map['disconnected_at'] = Variable<DateTime>(disconnectedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['bytes_uploaded'] = Variable<int>(bytesUploaded);
    map['bytes_downloaded'] = Variable<int>(bytesDownloaded);
    if (!nullToAbsent || disconnectReason != null) {
      map['disconnect_reason'] = Variable<String>(disconnectReason);
    }
    return map;
  }

  ConnectionLogsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionLogsCompanion(
      id: Value(id),
      serverName: Value(serverName),
      protocol: Value(protocol),
      connectedAt: Value(connectedAt),
      disconnectedAt: disconnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(disconnectedAt),
      durationSeconds: Value(durationSeconds),
      bytesUploaded: Value(bytesUploaded),
      bytesDownloaded: Value(bytesDownloaded),
      disconnectReason: disconnectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(disconnectReason),
    );
  }

  factory ConnectionLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionLog(
      id: serializer.fromJson<int>(json['id']),
      serverName: serializer.fromJson<String>(json['serverName']),
      protocol: serializer.fromJson<String>(json['protocol']),
      connectedAt: serializer.fromJson<DateTime>(json['connectedAt']),
      disconnectedAt: serializer.fromJson<DateTime?>(json['disconnectedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      bytesUploaded: serializer.fromJson<int>(json['bytesUploaded']),
      bytesDownloaded: serializer.fromJson<int>(json['bytesDownloaded']),
      disconnectReason: serializer.fromJson<String?>(json['disconnectReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverName': serializer.toJson<String>(serverName),
      'protocol': serializer.toJson<String>(protocol),
      'connectedAt': serializer.toJson<DateTime>(connectedAt),
      'disconnectedAt': serializer.toJson<DateTime?>(disconnectedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'bytesUploaded': serializer.toJson<int>(bytesUploaded),
      'bytesDownloaded': serializer.toJson<int>(bytesDownloaded),
      'disconnectReason': serializer.toJson<String?>(disconnectReason),
    };
  }

  ConnectionLog copyWith(
          {int? id,
          String? serverName,
          String? protocol,
          DateTime? connectedAt,
          Value<DateTime?> disconnectedAt = const Value.absent(),
          int? durationSeconds,
          int? bytesUploaded,
          int? bytesDownloaded,
          Value<String?> disconnectReason = const Value.absent()}) =>
      ConnectionLog(
        id: id ?? this.id,
        serverName: serverName ?? this.serverName,
        protocol: protocol ?? this.protocol,
        connectedAt: connectedAt ?? this.connectedAt,
        disconnectedAt:
            disconnectedAt.present ? disconnectedAt.value : this.disconnectedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        bytesUploaded: bytesUploaded ?? this.bytesUploaded,
        bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
        disconnectReason: disconnectReason.present
            ? disconnectReason.value
            : this.disconnectReason,
      );
  ConnectionLog copyWithCompanion(ConnectionLogsCompanion data) {
    return ConnectionLog(
      id: data.id.present ? data.id.value : this.id,
      serverName:
          data.serverName.present ? data.serverName.value : this.serverName,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      connectedAt:
          data.connectedAt.present ? data.connectedAt.value : this.connectedAt,
      disconnectedAt: data.disconnectedAt.present
          ? data.disconnectedAt.value
          : this.disconnectedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      bytesUploaded: data.bytesUploaded.present
          ? data.bytesUploaded.value
          : this.bytesUploaded,
      bytesDownloaded: data.bytesDownloaded.present
          ? data.bytesDownloaded.value
          : this.bytesDownloaded,
      disconnectReason: data.disconnectReason.present
          ? data.disconnectReason.value
          : this.disconnectReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionLog(')
          ..write('id: $id, ')
          ..write('serverName: $serverName, ')
          ..write('protocol: $protocol, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('disconnectedAt: $disconnectedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('bytesUploaded: $bytesUploaded, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('disconnectReason: $disconnectReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverName,
      protocol,
      connectedAt,
      disconnectedAt,
      durationSeconds,
      bytesUploaded,
      bytesDownloaded,
      disconnectReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionLog &&
          other.id == this.id &&
          other.serverName == this.serverName &&
          other.protocol == this.protocol &&
          other.connectedAt == this.connectedAt &&
          other.disconnectedAt == this.disconnectedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.bytesUploaded == this.bytesUploaded &&
          other.bytesDownloaded == this.bytesDownloaded &&
          other.disconnectReason == this.disconnectReason);
}

class ConnectionLogsCompanion extends UpdateCompanion<ConnectionLog> {
  final Value<int> id;
  final Value<String> serverName;
  final Value<String> protocol;
  final Value<DateTime> connectedAt;
  final Value<DateTime?> disconnectedAt;
  final Value<int> durationSeconds;
  final Value<int> bytesUploaded;
  final Value<int> bytesDownloaded;
  final Value<String?> disconnectReason;
  const ConnectionLogsCompanion({
    this.id = const Value.absent(),
    this.serverName = const Value.absent(),
    this.protocol = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.disconnectedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.bytesUploaded = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.disconnectReason = const Value.absent(),
  });
  ConnectionLogsCompanion.insert({
    this.id = const Value.absent(),
    required String serverName,
    required String protocol,
    required DateTime connectedAt,
    this.disconnectedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.bytesUploaded = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.disconnectReason = const Value.absent(),
  })  : serverName = Value(serverName),
        protocol = Value(protocol),
        connectedAt = Value(connectedAt);
  static Insertable<ConnectionLog> custom({
    Expression<int>? id,
    Expression<String>? serverName,
    Expression<String>? protocol,
    Expression<DateTime>? connectedAt,
    Expression<DateTime>? disconnectedAt,
    Expression<int>? durationSeconds,
    Expression<int>? bytesUploaded,
    Expression<int>? bytesDownloaded,
    Expression<String>? disconnectReason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverName != null) 'server_name': serverName,
      if (protocol != null) 'protocol': protocol,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (disconnectedAt != null) 'disconnected_at': disconnectedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (bytesUploaded != null) 'bytes_uploaded': bytesUploaded,
      if (bytesDownloaded != null) 'bytes_downloaded': bytesDownloaded,
      if (disconnectReason != null) 'disconnect_reason': disconnectReason,
    });
  }

  ConnectionLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverName,
      Value<String>? protocol,
      Value<DateTime>? connectedAt,
      Value<DateTime?>? disconnectedAt,
      Value<int>? durationSeconds,
      Value<int>? bytesUploaded,
      Value<int>? bytesDownloaded,
      Value<String?>? disconnectReason}) {
    return ConnectionLogsCompanion(
      id: id ?? this.id,
      serverName: serverName ?? this.serverName,
      protocol: protocol ?? this.protocol,
      connectedAt: connectedAt ?? this.connectedAt,
      disconnectedAt: disconnectedAt ?? this.disconnectedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      disconnectReason: disconnectReason ?? this.disconnectReason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverName.present) {
      map['server_name'] = Variable<String>(serverName.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    if (disconnectedAt.present) {
      map['disconnected_at'] = Variable<DateTime>(disconnectedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (bytesUploaded.present) {
      map['bytes_uploaded'] = Variable<int>(bytesUploaded.value);
    }
    if (bytesDownloaded.present) {
      map['bytes_downloaded'] = Variable<int>(bytesDownloaded.value);
    }
    if (disconnectReason.present) {
      map['disconnect_reason'] = Variable<String>(disconnectReason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionLogsCompanion(')
          ..write('id: $id, ')
          ..write('serverName: $serverName, ')
          ..write('protocol: $protocol, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('disconnectedAt: $disconnectedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('bytesUploaded: $bytesUploaded, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('disconnectReason: $disconnectReason')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TunnelConfigsTable tunnelConfigs = $TunnelConfigsTable(this);
  late final $ConnectionLogsTable connectionLogs = $ConnectionLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tunnelConfigs, connectionLogs];
}

typedef $$TunnelConfigsTableCreateCompanionBuilder = TunnelConfigsCompanion
    Function({
  Value<int> id,
  required String name,
  required String protocol,
  required String serverAddress,
  required int serverPort,
  required String rawConfig,
  Value<bool> isFavorite,
  Value<bool> isLocked,
  Value<DateTime> createdAt,
});
typedef $$TunnelConfigsTableUpdateCompanionBuilder = TunnelConfigsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> protocol,
  Value<String> serverAddress,
  Value<int> serverPort,
  Value<String> rawConfig,
  Value<bool> isFavorite,
  Value<bool> isLocked,
  Value<DateTime> createdAt,
});

class $$TunnelConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $TunnelConfigsTable> {
  $$TunnelConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get protocol => $composableBuilder(
      column: $table.protocol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverAddress => $composableBuilder(
      column: $table.serverAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverPort => $composableBuilder(
      column: $table.serverPort, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawConfig => $composableBuilder(
      column: $table.rawConfig, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TunnelConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $TunnelConfigsTable> {
  $$TunnelConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get protocol => $composableBuilder(
      column: $table.protocol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverAddress => $composableBuilder(
      column: $table.serverAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverPort => $composableBuilder(
      column: $table.serverPort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawConfig => $composableBuilder(
      column: $table.rawConfig, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TunnelConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TunnelConfigsTable> {
  $$TunnelConfigsTableAnnotationComposer({
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

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get serverAddress => $composableBuilder(
      column: $table.serverAddress, builder: (column) => column);

  GeneratedColumn<int> get serverPort => $composableBuilder(
      column: $table.serverPort, builder: (column) => column);

  GeneratedColumn<String> get rawConfig =>
      $composableBuilder(column: $table.rawConfig, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TunnelConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TunnelConfigsTable,
    TunnelConfig,
    $$TunnelConfigsTableFilterComposer,
    $$TunnelConfigsTableOrderingComposer,
    $$TunnelConfigsTableAnnotationComposer,
    $$TunnelConfigsTableCreateCompanionBuilder,
    $$TunnelConfigsTableUpdateCompanionBuilder,
    (
      TunnelConfig,
      BaseReferences<_$AppDatabase, $TunnelConfigsTable, TunnelConfig>
    ),
    TunnelConfig,
    PrefetchHooks Function()> {
  $$TunnelConfigsTableTableManager(_$AppDatabase db, $TunnelConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TunnelConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TunnelConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TunnelConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> protocol = const Value.absent(),
            Value<String> serverAddress = const Value.absent(),
            Value<int> serverPort = const Value.absent(),
            Value<String> rawConfig = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TunnelConfigsCompanion(
            id: id,
            name: name,
            protocol: protocol,
            serverAddress: serverAddress,
            serverPort: serverPort,
            rawConfig: rawConfig,
            isFavorite: isFavorite,
            isLocked: isLocked,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String protocol,
            required String serverAddress,
            required int serverPort,
            required String rawConfig,
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TunnelConfigsCompanion.insert(
            id: id,
            name: name,
            protocol: protocol,
            serverAddress: serverAddress,
            serverPort: serverPort,
            rawConfig: rawConfig,
            isFavorite: isFavorite,
            isLocked: isLocked,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TunnelConfigsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TunnelConfigsTable,
    TunnelConfig,
    $$TunnelConfigsTableFilterComposer,
    $$TunnelConfigsTableOrderingComposer,
    $$TunnelConfigsTableAnnotationComposer,
    $$TunnelConfigsTableCreateCompanionBuilder,
    $$TunnelConfigsTableUpdateCompanionBuilder,
    (
      TunnelConfig,
      BaseReferences<_$AppDatabase, $TunnelConfigsTable, TunnelConfig>
    ),
    TunnelConfig,
    PrefetchHooks Function()>;
typedef $$ConnectionLogsTableCreateCompanionBuilder = ConnectionLogsCompanion
    Function({
  Value<int> id,
  required String serverName,
  required String protocol,
  required DateTime connectedAt,
  Value<DateTime?> disconnectedAt,
  Value<int> durationSeconds,
  Value<int> bytesUploaded,
  Value<int> bytesDownloaded,
  Value<String?> disconnectReason,
});
typedef $$ConnectionLogsTableUpdateCompanionBuilder = ConnectionLogsCompanion
    Function({
  Value<int> id,
  Value<String> serverName,
  Value<String> protocol,
  Value<DateTime> connectedAt,
  Value<DateTime?> disconnectedAt,
  Value<int> durationSeconds,
  Value<int> bytesUploaded,
  Value<int> bytesDownloaded,
  Value<String?> disconnectReason,
});

class $$ConnectionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionLogsTable> {
  $$ConnectionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverName => $composableBuilder(
      column: $table.serverName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get protocol => $composableBuilder(
      column: $table.protocol, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get disconnectedAt => $composableBuilder(
      column: $table.disconnectedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytesUploaded => $composableBuilder(
      column: $table.bytesUploaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytesDownloaded => $composableBuilder(
      column: $table.bytesDownloaded,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get disconnectReason => $composableBuilder(
      column: $table.disconnectReason,
      builder: (column) => ColumnFilters(column));
}

class $$ConnectionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionLogsTable> {
  $$ConnectionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverName => $composableBuilder(
      column: $table.serverName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get protocol => $composableBuilder(
      column: $table.protocol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get disconnectedAt => $composableBuilder(
      column: $table.disconnectedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytesUploaded => $composableBuilder(
      column: $table.bytesUploaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytesDownloaded => $composableBuilder(
      column: $table.bytesDownloaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get disconnectReason => $composableBuilder(
      column: $table.disconnectReason,
      builder: (column) => ColumnOrderings(column));
}

class $$ConnectionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionLogsTable> {
  $$ConnectionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverName => $composableBuilder(
      column: $table.serverName, builder: (column) => column);

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get disconnectedAt => $composableBuilder(
      column: $table.disconnectedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get bytesUploaded => $composableBuilder(
      column: $table.bytesUploaded, builder: (column) => column);

  GeneratedColumn<int> get bytesDownloaded => $composableBuilder(
      column: $table.bytesDownloaded, builder: (column) => column);

  GeneratedColumn<String> get disconnectReason => $composableBuilder(
      column: $table.disconnectReason, builder: (column) => column);
}

class $$ConnectionLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConnectionLogsTable,
    ConnectionLog,
    $$ConnectionLogsTableFilterComposer,
    $$ConnectionLogsTableOrderingComposer,
    $$ConnectionLogsTableAnnotationComposer,
    $$ConnectionLogsTableCreateCompanionBuilder,
    $$ConnectionLogsTableUpdateCompanionBuilder,
    (
      ConnectionLog,
      BaseReferences<_$AppDatabase, $ConnectionLogsTable, ConnectionLog>
    ),
    ConnectionLog,
    PrefetchHooks Function()> {
  $$ConnectionLogsTableTableManager(
      _$AppDatabase db, $ConnectionLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverName = const Value.absent(),
            Value<String> protocol = const Value.absent(),
            Value<DateTime> connectedAt = const Value.absent(),
            Value<DateTime?> disconnectedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> bytesUploaded = const Value.absent(),
            Value<int> bytesDownloaded = const Value.absent(),
            Value<String?> disconnectReason = const Value.absent(),
          }) =>
              ConnectionLogsCompanion(
            id: id,
            serverName: serverName,
            protocol: protocol,
            connectedAt: connectedAt,
            disconnectedAt: disconnectedAt,
            durationSeconds: durationSeconds,
            bytesUploaded: bytesUploaded,
            bytesDownloaded: bytesDownloaded,
            disconnectReason: disconnectReason,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverName,
            required String protocol,
            required DateTime connectedAt,
            Value<DateTime?> disconnectedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> bytesUploaded = const Value.absent(),
            Value<int> bytesDownloaded = const Value.absent(),
            Value<String?> disconnectReason = const Value.absent(),
          }) =>
              ConnectionLogsCompanion.insert(
            id: id,
            serverName: serverName,
            protocol: protocol,
            connectedAt: connectedAt,
            disconnectedAt: disconnectedAt,
            durationSeconds: durationSeconds,
            bytesUploaded: bytesUploaded,
            bytesDownloaded: bytesDownloaded,
            disconnectReason: disconnectReason,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConnectionLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConnectionLogsTable,
    ConnectionLog,
    $$ConnectionLogsTableFilterComposer,
    $$ConnectionLogsTableOrderingComposer,
    $$ConnectionLogsTableAnnotationComposer,
    $$ConnectionLogsTableCreateCompanionBuilder,
    $$ConnectionLogsTableUpdateCompanionBuilder,
    (
      ConnectionLog,
      BaseReferences<_$AppDatabase, $ConnectionLogsTable, ConnectionLog>
    ),
    ConnectionLog,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TunnelConfigsTableTableManager get tunnelConfigs =>
      $$TunnelConfigsTableTableManager(_db, _db.tunnelConfigs);
  $$ConnectionLogsTableTableManager get connectionLogs =>
      $$ConnectionLogsTableTableManager(_db, _db.connectionLogs);
}
