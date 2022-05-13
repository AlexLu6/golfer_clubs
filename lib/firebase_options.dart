// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD26EyAImrDoOMn3o6FgmSQjlttxjqmS7U',
    appId: '1:301278524425:web:0d38c4cb30ad60e24074d8',
    messagingSenderId: '301278524425',
    projectId: 'golferclub-fce89',
    authDomain: 'golferclub-fce89.firebaseapp.com',
    storageBucket: 'golferclub-fce89.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2g9-ydkWCwzQ3f-8mUi1MQ7yIpOUeCwM',
    appId: '1:301278524425:android:df818845775cfc8e4074d8',
    messagingSenderId: '301278524425',
    projectId: 'golferclub-fce89',
    storageBucket: 'golferclub-fce89.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCnrCQBTHmxTmLTDIpAPhKL8ltbxruX1No',
    appId: '1:301278524425:ios:e0794d35fae7f9d14074d8',
    messagingSenderId: '301278524425',
    projectId: 'golferclub-fce89',
    storageBucket: 'golferclub-fce89.appspot.com',
    iosClientId: '301278524425-ijka5t3miu7a2ti7c86pagdr4f9h05ba.apps.googleusercontent.com',
    iosBundleId: 'com.example.drawerAndBottomBar',
  );
}