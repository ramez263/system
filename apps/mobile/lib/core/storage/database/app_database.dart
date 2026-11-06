import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class TunnelConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get protocol => text()(); // ovpn, vless, vmess, trojan, ss, hy2
  TextColumn get serverAddress => text()();
  IntColumn get serverPort => integer()();
  TextColumn get rawConfig => text()(); // ovpn profile or json payload
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ConnectionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverName => text()();
  TextColumn get protocol => text()();
  DateTimeColumn get connectedAt => dateTime()();
  DateTimeColumn get disconnectedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get bytesUploaded => integer().withDefault(const Constant(0))();
  IntColumn get bytesDownloaded => integer().withDefault(const Constant(0))();
  TextColumn get disconnectReason => text().nullable()();
}

@DriftDatabase(tables: [TunnelConfigs, ConnectionLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ramez_tunnel_db');
  }
}
