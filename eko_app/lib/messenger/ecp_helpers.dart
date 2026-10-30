import 'package:ecp/ecp.dart';
import 'package:eko_app/utilities/api_constants.dart' as api;

Uri actorIdFromUid(String supabaseUid) {
  final base = api.messengerUrl;
  return base.replace(
    pathSegments: [
      ...base.pathSegments.where((s) => s.isNotEmpty),
      'users',
      supabaseUid,
    ],
  );
}

String uidFromActorId(Uri id) {
  return id.pathSegments.last;
}

extension type EkoPerson(Person person) implements Person {
  EkoPerson.fromUid(String uid) : person = Person.fromId(actorIdFromUid(uid));
}

extension EcpHelpers on Person {
  String uid() {
    return id.pathSegments.last;
  }
}
