import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Values derived from android/app/src/dev/google-services.json and
// ios/config/firebase/dev/GoogleService-Info.plist (ts-drivers-dev).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web on the dev flavor.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_GOOGLE_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_APP_ID',
    messagingSenderId: '841970356562',
    projectId: 'ts-drivers-dev',
    databaseURL: 'https://ts-drivers-dev-default-rtdb.firebaseio.com',
    storageBucket: 'ts-drivers-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_GOOGLE_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_APP_ID',
    messagingSenderId: '841970356562',
    projectId: 'ts-drivers-dev',
    databaseURL: 'https://ts-drivers-dev-default-rtdb.firebaseio.com',
    storageBucket: 'ts-drivers-dev.firebasestorage.app',
    iosBundleId: 'com.transportsystemgroup.tsdrivers.dev',
  );
}
