import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class LogoService {
  static String? _logo;

  static Future<void> init() async {
    int date = DateTime.now().toUtc().millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    int file = date % 15 + 1;
    final storageRef =
        FirebaseStorage.instance.ref().child('eko_logos/$file.svg');

    final url = await storageRef.getDownloadURL();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      _logo = response.body;
    } else {
      _logo = null;
    }
  }

  static String? get instance {
    return _logo;
  }
}
