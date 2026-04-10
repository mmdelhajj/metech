// File generated manually for MeTech Shop Firebase project metech-62330
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCN6z4ptrFrKmhiOoSooT0fg2psG4jTACg',
    appId: '1:796792942112:android:84d15f7331926c469ad645',
    messagingSenderId: '796792942112',
    projectId: 'metech-62330',
    storageBucket: 'metech-62330.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6Wi3zy8YbYAE7cDMBHmS0EYMdCDRIcoU',
    appId: '1:796792942112:ios:4c10016cbfac76d59ad645',
    messagingSenderId: '796792942112',
    projectId: 'metech-62330',
    storageBucket: 'metech-62330.firebasestorage.app',
    iosBundleId: 'com.metech.store',
  );
}
