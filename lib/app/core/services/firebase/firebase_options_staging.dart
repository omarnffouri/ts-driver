import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Values derived from android/app/src/staging/google-services.json and
// ios/config/firebase/staging/GoogleService-Info.plist (ts-drivers-staging).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web on the staging flavor.',
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
    messagingSenderId: '138715591816',
    projectId: 'ts-drivers-staging',
    databaseURL: 'https://ts-drivers-staging-default-rtdb.firebaseio.com',
    storageBucket: 'ts-drivers-staging.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_GOOGLE_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_APP_ID',
    messagingSenderId: '138715591816',
    projectId: 'ts-drivers-staging',
    databaseURL: 'https://ts-drivers-staging-default-rtdb.firebaseio.com',
    storageBucket: 'ts-drivers-staging.firebasestorage.app',
    iosBundleId: 'com.transportsystemgroup.tsdrivers.staging',
  );
}
