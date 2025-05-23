// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBAB8-JhDXokRmruUhuVdE7YRolj_eK9w0',
    appId: '1:356188148934:web:031e723f7188fb453bf3c7',
    messagingSenderId: '356188148934',
    projectId: 'muliti-b318f',
    authDomain: 'muliti-b318f.firebaseapp.com',
    storageBucket: 'muliti-b318f.firebasestorage.app',
    measurementId: 'G-JWMQFFER2E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8tFICcJqZILytgePGIoLWad-Uuin2gHc',
    appId: '1:356188148934:android:5a68af81d2e3f7383bf3c7',
    messagingSenderId: '356188148934',
    projectId: 'muliti-b318f',
    storageBucket: 'muliti-b318f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVhuzHTMmrhS0u5EXADxIjq1a7JsGnDgY',
    appId: '1:356188148934:ios:0e001d59e06df42a3bf3c7',
    messagingSenderId: '356188148934',
    projectId: 'muliti-b318f',
    storageBucket: 'muliti-b318f.firebasestorage.app',
    iosBundleId: 'com.example.gam3ya',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAB8-JhDXokRmruUhuVdE7YRolj_eK9w0',
    appId: '1:356188148934:web:4d1b8c26bb2696953bf3c7',
    messagingSenderId: '356188148934',
    projectId: 'muliti-b318f',
    authDomain: 'muliti-b318f.firebaseapp.com',
    storageBucket: 'muliti-b318f.firebasestorage.app',
    measurementId: 'G-7MCXVFY2RD',
  );
}
