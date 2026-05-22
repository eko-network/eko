import 'package:drift/drift.dart';
import 'package:eko_app/database/tables/messages.dart';
import 'package:eko_app/database/type_converters.dart';

class Media extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()
      .map(const UuidValueConverter())
      .references(Messages, #id, onDelete: KeyAction.cascade)();
  TextColumn get url => text().map(const UriTypeConverter())();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get contentType => text().nullable()();
}
