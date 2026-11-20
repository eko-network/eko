import 'package:drift/drift.dart';

// There are no DMs on web, so there is no local database to open.
LazyDatabase openConnection() => LazyDatabase(
  () =>
      throw UnsupportedError('The messenger database is not available on web'),
);
