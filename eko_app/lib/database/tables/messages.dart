import 'package:drift/drift.dart';
import 'package:eko_app/database/type_converters.dart';

class Messages extends Table {
  TextColumn get id => text().map(const UuidValueConverter())();
  TextColumn get envelopeId =>
      text().map(const UriTypeConverter()).nullable()();
  TextColumn get to => text().map(const UriTypeConverter())();
  TextColumn get from => text().map(const UriTypeConverter())();
  TextColumn get content => text().nullable()();
  TextColumn get inReplyTo =>
      text().map(const UuidValueConverter()).nullable()();
  DateTimeColumn get time => dateTime()();
  IntColumn get status =>
      intEnum<MessageStatus>().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
