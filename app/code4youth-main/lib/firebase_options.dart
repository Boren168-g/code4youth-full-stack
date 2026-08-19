import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you are only configured for android.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAvMWhUTGDobTX42X_K6p_G4IrIVBF5N2g',
    appId: '1:664460428859:android:85d22efe023a0448f4fe1e',
    messagingSenderId: '664460428859',
    projectId: 'code4youth-aab16',
    storageBucket: 'code4youth-aab16.firebasestorage.app',
  );
}
