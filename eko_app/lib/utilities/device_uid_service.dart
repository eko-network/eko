import 'package:uuid/uuid.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';

class DeviceUidService {
  static final Uuid _uuid = Uuid();

  static String getOrCreate() {
    final existing = PrefsService.deviceUid;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final created = _uuid.v7();
    PrefsService.deviceUid = created;
    return created;
  }

  static void remove() {
    PrefsService.deviceUid = null;
  }
}
