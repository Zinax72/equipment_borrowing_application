import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDMarWywpyVwhiSaswronK9kym8vgTVlGk',
    appId: '1:673091039332:web:31f0d46337ba39eaa7af71',
    messagingSenderId: '673091039332',
    projectId: 'borrowit-9547b',
    authDomain: 'borrowit-9547b.firebaseapp.com',
    storageBucket: 'borrowit-9547b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvcrRfqAqUVjlZ729vBHjRkfTJLNY8KcQ',
    appId: '1:673091039332:android:338ab5009f6c4adca7af71',
    messagingSenderId: '673091039332',
    projectId: 'borrowit-9547b',
    storageBucket: 'borrowit-9547b.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6L3tYDKavhTUVZmTumH5eKMebuQWrVao',
    appId: '1:673091039332:ios:7e5828f3e070dde5a7af71',
    messagingSenderId: '673091039332',
    projectId: 'borrowit-9547b',
    storageBucket: 'borrowit-9547b.firebasestorage.app',
    iosBundleId: 'com.example.equipmentBarrowingApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB6L3tYDKavhTUVZmTumH5eKMebuQWrVao',
    appId: '1:673091039332:ios:7e5828f3e070dde5a7af71',
    messagingSenderId: '673091039332',
    projectId: 'borrowit-9547b',
    storageBucket: 'borrowit-9547b.firebasestorage.app',
    iosBundleId: 'com.example.equipmentBarrowingApplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDMarWywpyVwhiSaswronK9kym8vgTVlGk',
    appId: '1:673091039332:web:4e7b476ffae911d9a7af71',
    messagingSenderId: '673091039332',
    projectId: 'borrowit-9547b',
    authDomain: 'borrowit-9547b.firebaseapp.com',
    storageBucket: 'borrowit-9547b.firebasestorage.app',
  );
}
