// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/app.dart';
import '../../src/models/export.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'src/constants/SharedPreferences.dart';

late PrefsHandler prefsHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PrefsHandler.init();
  // Initialize Hive

  await Hive.initFlutter();
  // Register Hive adapters
  Hive.registerAdapter(Gam3yaAdapter());
  Hive.registerAdapter(Gam3yaStatusAdapter());
  Hive.registerAdapter(Gam3yaDurationAdapter());
  Hive.registerAdapter(Gam3yaSizeAdapter());
  Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(Gam3yaAccessAdapter());
  Hive.registerAdapter(UserStatusAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(Gam3yaMemberAdapter());
  Hive.registerAdapter(Gam3yaPaymentAdapter());
  Hive.registerAdapter(PaymentHistoryItemAdapter());
  Hive.registerAdapter(PaymentStatusAdapter());
  Hive.registerAdapter(PaymentTypeAdapter());
  Hive.registerAdapter(NearbyDeviceAdapter());
  Hive.registerAdapter(UserNotificationAdapter());
  //Hive.registerAdapter(AppSettingsAdapter());

  // Open Hive boxes
  print('Nearby device adapter registered.');
  print('Opening Hive boxes...');
  await Hive.openBox<User>('users');
  print('Users box opened.');
  await Hive.openBox<Gam3ya>('gam3yas');
  print('Gam3yas box opened.');
  await Hive.openBox<Gam3yaMember>('gam3yaMembers');
  print('Gam3ya members box opened.');
  await Hive.openBox<Gam3yaPayment>('gam3yaPayments');
  print('Gam3ya payments box opened.');
  await Hive.openBox<UserNotification>('userNotifications');
  print('User notifications box opened.');
  await Hive.openBox<NearbyDevice>('nearbyDevices');
  print('Nearby devices box opened.');
  await Hive.openBox<PaymentHistoryItem>('paymentHistory');
  print('Payment history box opened.');
  await Hive.openBox<UserRole>('userRoles');
  print('User roles box opened.');
  await Hive.openBox<Gam3yaAccess>('gam3yaAccesses');
  print('Gam3ya accesses box opened.');
  await Hive.openBox<UserStatus>('userStatuses');
  print('User statuses box opened.');
  await Hive.openBox<Gam3yaStatus>('gam3yaStatuses');
  print('Gam3ya statuses box opened.');
  await Hive.openBox<Gam3yaDuration>('gam3yaDurations');
  print('Gam3ya durations box opened.');
  await Hive.openBox<Gam3yaSize>('gam3yaSizes');
  print('Gam3ya sizes box opened.');
  await Hive.openBox<Gam3yaAdapter>('gam3yaAdapters');
  print('Gam3ya adapters box opened.');
  await Hive.openBox<Gam3yaMember>('gam3yaMembers');
  print('Gam3ya members box opened.');
  await Hive.openBox<Gam3yaPayment>('gam3yaPayments');
  print('Gam3ya payments box opened.');
  await Hive.openBox<UserNotification>('userNotifications');
  print('User notifications box opened.');

  await Hive.openBox('appSettings');
  print('App settings box opened.');

  runApp(const ProviderScope(child: Gam3yaApp()));
}
