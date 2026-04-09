import "dart:io" show Platform;
import "package:firebase_core/firebase_core.dart" show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS || Platform.isMacOS) {
      return ios;
    }
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCN6z4ptrFrKmhiOoSooT0fg2psG4jTACg",
    appId: "1:796792942112:android:84d15f7331926c469ad645",
    messagingSenderId: "796792942112",
    projectId: "metech-62330",
    storageBucket: "metech-62330.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyD6Wi3zy8YbYAE7cDMBHmS0EYMdCDRIcoU",
    appId: "1:796792942112:ios:4c10016cbfac76d59ad645",
    messagingSenderId: "796792942112",
    projectId: "metech-62330",
    storageBucket: "metech-62330.firebasestorage.app",
    iosBundleId: "com.metech.store",
  );
}
