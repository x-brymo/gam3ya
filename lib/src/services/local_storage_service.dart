// services/local_storage_service.dart
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Users
  Future<void> saveUser(User user) async {
    final box = Hive.box<User>('users');
    await box.put(user.id, user);
  }

  User? getUser(String id) {
    final box = Hive.box<User>('users');
    return box.get(id);
  }

  Future<void> deleteUser(String id) async {
    final box = Hive.box<User>('users');
    await box.delete(id);
  }

  // Gam3yas
  Future<void> saveGam3ya(Gam3ya gam3ya) async {
    final box = Hive.box<Gam3ya>('gam3yas');
    await box.put(gam3ya.id, gam3ya);
  }

  Gam3ya? getGam3ya(String id) {
    final box = Hive.box<Gam3ya>('gam3yas');
    return box.get(id);
  }

  List<Gam3ya> getAllGam3yas() {
    final box = Hive.box<Gam3ya>('gam3yas');
    return box.values.toList();
  }

  List<Gam3ya> getUserGam3yas(String userId) {
    final box = Hive.box<Gam3ya>('gam3yas');
    return box.values.where((gam3ya) {
      return gam3ya.members.any((member) => member.userId == userId) || 
             gam3ya.creatorId == userId;
    }).toList();
  }

  Future<void> deleteGam3ya(String id) async {
    final box = Hive.box<Gam3ya>('gam3yas');
    await box.delete(id);
  }

  // App settings
  Future<void> saveAppSetting(String key, dynamic value) async {
    final box = Hive.box('appSettings');
    await box.put(key, value);
  }

  dynamic getAppSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box('appSettings');
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> clearAppSettings() async {
    final box = Hive.box('appSettings');
    await box.clear();
  }

  Future<void> syncWithServer(List<User> users, List<Gam3ya> gam3yas) async {
    // Save all users
    final userBox = Hive.box<User>('users');
    for (final user in users) {
      await userBox.put(user.id, user);
    }
    
    // Save all gam3yas
    final gam3yaBox = Hive.box<Gam3ya>('gam3yas');
    for (final gam3ya in gam3yas) {
      await gam3yaBox.put(gam3ya.id, gam3ya);
    }
    
    // Update last sync time
    await saveAppSetting('lastSyncTime', DateTime.now().toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final lastSyncString = getAppSetting('lastSyncTime');
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }
}