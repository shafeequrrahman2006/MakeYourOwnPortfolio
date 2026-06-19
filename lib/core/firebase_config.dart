import 'package:firebase_core/firebase_core.dart';

class MUOPFirebaseConfig {
  // Replace these placeholders with actual Firebase Web configuration details
  static const String apiKey = 'AIzaSyAn1wLUnfn_cTv-ZU1b80esFsWWIxRa11E';
  static const String authDomain = 'muop-820e9.firebaseapp.com';
  static const String projectId = 'muop-820e9';
  static const String storageBucket = 'muop-820e9.firebasestorage.app';
  static const String messagingSenderId = '315494433091';
  static const String appId = '1:315494433091:web:773b55eefcc5aafc3f2ff6';
  static const String? measurementId = null;

  static bool get isPlaceholder {
    return apiKey == 'YOUR-API-KEY' || projectId == 'your-project-id';
  }

  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
      measurementId: measurementId,
    );
  }
}
