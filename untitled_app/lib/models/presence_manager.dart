import 'dart:math';
import '../utilities/constants.dart' as c;
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';

class PresenceManager {
  String? sessionId;
  String uid = '';
  //final idValue = ;

  String _generateSessionID() {
    const randomChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charsLength = randomChars.length;

    final rand = Random();
    final codeUnits = List.generate(c.sessionIdLength, (index) {
      int randIndex = rand.nextInt(charsLength);
      return randomChars.codeUnitAt(randIndex);
    });

    return String.fromCharCodes(codeUnits);
  }

  String getSessionId() {
    sessionId ??= _generateSessionID();
    return sessionId!;
  }

  unVerifySession() {
    if (uid != '') {
      DatabaseReference userStatusDatabaseRef =
          FirebaseDatabase.instance.ref().child('/status/$uid');
      Map<String, dynamic> isOfflineForDatabase = {
        'online': false,
        'last_changed': ServerValue.timestamp,
      };
      sessionId = null;
      userStatusDatabaseRef.set(isOfflineForDatabase);
      userStatusDatabaseRef.onDisconnect().cancel();
      uid = '';
    }
    
  }

  verifySession() {
    uid = locator<CurrentUser>().getUID();
    DatabaseReference userStatusDatabaseRef =
        FirebaseDatabase.instance.ref().child('/status/$uid');

    Map<String, dynamic> isOfflineForDatabase = {
      'online': false,
      'last_changed': ServerValue.timestamp,
    };
    Map<String, dynamic> isOnlineForDatabase = {
      'online': true,
      'id': getSessionId(),
      'last_changed': ServerValue.timestamp,
    };

    FirebaseDatabase.instance
        .ref()
        .child('.info/connected')
        .onValue
        .listen((event) {
      // If we're not currently connected, don't do anything.
      if (event.snapshot.value == false) {
        return;
      }

      // If we are currently connected, then use the 'onDisconnect()'
      // method to add a set which will only trigger once this
      // client has disconnected by closing the app,
      // losing internet, or any other means.
      userStatusDatabaseRef.onDisconnect().set(isOfflineForDatabase).then((_) {
        userStatusDatabaseRef.set(isOnlineForDatabase);
      });
    });
  }

  updateSessionId() {
    DatabaseReference userStatusDatabaseRef = FirebaseDatabase.instance
        .ref()
        .child('/status/${locator<CurrentUser>().getUID()}');
    Map<String, dynamic> isOnlineForDatabase = {
      'online': true,
      'id': getSessionId(),
      'last_changed': ServerValue.timestamp,
    };
    userStatusDatabaseRef.set(isOnlineForDatabase);
  }
}
