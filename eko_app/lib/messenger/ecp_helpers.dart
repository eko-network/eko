import 'package:ecp/ecp.dart';
import 'package:eko_app/utilities/constants.dart' as c;

Uri actorIdFromUid(String supabaseUid) {
  final base = c.messengerDefaultServerUrl;
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
