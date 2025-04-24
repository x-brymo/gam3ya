// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/app.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'src/models/nearby_model.dart';
import 'src/models/user_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  //Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(Gam3yaAdapter());
  // Hive.registerAdapter(Gam3yaStatusAdapter());
  // Hive.registerAdapter(Gam3yaDurationAdapter());
  // Hive.registerAdapter(Gam3yaSizeAdapter());
  // Hive.registerAdapter(Gam3yaAccessAdapter());
  Hive.registerAdapter(Gam3yaMemberAdapter());
  Hive.registerAdapter(Gam3yaPaymentAdapter());
  Hive.registerAdapter(NearbyDeviceAdapter());
  
  // Open Hive boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Gam3ya>('gam3yas');
  await Hive.openBox<Gam3yaMember>('gam3yaMembers');
  await Hive.openBox<Gam3yaPayment>('gam3yaPayments');
  await Hive.openBox<UserNotification>('userNotifications');
  
  await Hive.openBox('appSettings');
  
  runApp(
    const ProviderScope(
      child: Gam3yaApp(),
    ),
  );
}