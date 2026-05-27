import 'package:drift/drift.dart';
import 'package:eko_app/database/type_converters.dart';

class Users extends Table {
  TextColumn get id => text().map(const UriTypeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_device_id', columns: {#deviceId})
class UserDevices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()
      .references(Users, #id, onDelete: KeyAction.cascade)
      .map(const UriTypeConverter())();
  TextColumn get deviceId => text().unique().map(const UriTypeConverter())();
}
