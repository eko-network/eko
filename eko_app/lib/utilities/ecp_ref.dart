import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/daos/ecp/storage.dart';

final _storage = DriftStorage(db);
final ecp = EcpCore(storage: _storage);
