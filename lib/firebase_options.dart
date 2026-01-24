import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: "AIzaSyB-_yLjpSE5oo9alBRuCAHTox34DQsEtgQ",
    authDomain: "homlypro-app.firebaseapp.com",
    projectId: "homlypro-app",
    storageBucket: "homlypro-app.firebasestorage.app",
    messagingSenderId: "223440389399",
    appId: "1:223440389399:web:67ec507a005c8ce9c52352",
    measurementId: "G-M75JS9WTVR",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwUmOiw_5eT_C0RcWU0i9hdMuBPdrTj_4',
    appId: '1:223440389399:android:7c410b61457558e0c52352',
    messagingSenderId: '223440389399',
    projectId: 'homlypro-app',
    databaseURL: 'https://homlypro-app-default-rtdb.firebaseio.com',
    storageBucket: 'homlypro-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqKBGcboIlJgkWS9vNo7bvMr5vLmi89wo',
    appId: '1:223440389399:ios:810fd247a6bd5cd0c52352',
    messagingSenderId: '223440389399',
    projectId: 'homlypro-app',
    databaseURL: 'https://homlypro-app-default-rtdb.firebaseio.com',
    storageBucket: 'homlypro-app.firebasestorage.app',
    iosBundleId: 'com.example.homeService',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MACOS_MESSAGING_SENDER_ID',
    projectId: 'YOUR_MACOS_PROJECT_ID',
    databaseURL: 'YOUR_MACOS_DATABASE_URL',
    storageBucket: 'YOUR_MACOS_STORAGE_BUCKET',
    iosBundleId: 'YOUR_MACOS_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_WINDOWS_MESSAGING_SENDER_ID',
    projectId: 'YOUR_WINDOWS_PROJECT_ID',
    databaseURL: 'YOUR_WINDOWS_DATABASE_URL',
    storageBucket: 'YOUR_WINDOWS_STORAGE_BUCKET',
  );
}
