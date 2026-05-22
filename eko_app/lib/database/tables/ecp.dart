import 'package:drift/drift.dart';
import 'package:eko_app/database/type_converters.dart';

class Capabilities extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get capabilities => text().map(const JsonValueConverter())();
  DateTimeColumn get time => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class MlsCredentials extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BlobColumn get credentialIdentity => blob()();
  BlobColumn get credentialBytes => blob()();
  BlobColumn get signerBytes => blob()();
  BlobColumn get signerPublicKey => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

class MlsKeyPackages extends Table {
  IntColumn get id => integer().autoIncrement()();
  BlobColumn get keyPackage => blob()();
}
