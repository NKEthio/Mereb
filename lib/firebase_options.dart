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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFh2m5F7AFOO1naCOTba42CJKwFtc0de8',
    appId: '1:491340937451:web:715da0bbbc6b66032d26ae',
    messagingSenderId: '491340937451',
    projectId: 'mereb-8c7dd',
    authDomain: 'mereb-8c7dd.firebaseapp.com',
    storageBucket: 'mereb-8c7dd.firebasestorage.app',
    measurementId: 'G-G5QWKVRSNK',
  );

  // Note: These are placeholders based on the project ID. 
  // For full Android/iOS support, the user should run 'flutterfire configure'.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFh2m5F7AFOO1naCOTba42CJKwFtc0de8',
    appId: '1:491340937451:android:your_app_id', // Placeholder
    messagingSenderId: '491340937451',
    projectId: 'mereb-8c7dd',
    storageBucket: 'mereb-8c7dd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFh2m5F7AFOO1naCOTba42CJKwFtc0de8',
    appId: '1:491340937451:ios:your_app_id', // Placeholder
    messagingSenderId: '491340937451',
    projectId: 'mereb-8c7dd',
    storageBucket: 'mereb-8c7dd.firebasestorage.app',
    iosBundleId: 'com.example.mereb', // Placeholder
  );
}
