import 'package:ecp/ecp.dart';
import 'package:eko_app/utilities/constants.dart' as c;

Uri messengerActorId(String supabaseUid) {
  final base = c.messengerDefaultServerUrl;
  return base.replace(
    pathSegments: [
      ...base.pathSegments.where((s) => s.isNotEmpty),
      'users',
      supabaseUid
    ],
  );
}

Uri messengerDeviceId(String supabaseUid, String deviceDid) {
  final actorId = messengerActorId(supabaseUid);
  return actorId.replace(
    pathSegments: [...actorId.pathSegments, 'devices', deviceDid],
  );
}

Person buildMessengerPerson({
  required String supabaseUid,
  required String preferredUsername,
}) {
  final actorId = messengerActorId(supabaseUid);
  return Person(
    id: actorId,
    inbox: actorId.replace(pathSegments: [...actorId.pathSegments, 'inbox']),
    outbox: actorId.replace(pathSegments: [...actorId.pathSegments, 'outbox']),
    devicesEndpoint:
        actorId.replace(pathSegments: [...actorId.pathSegments, 'devices']),
    preferredUsername: preferredUsername,
  );
}
