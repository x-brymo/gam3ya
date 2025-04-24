// providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/user_model.dart';
import 'package:gam3ya/src/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_notification.dart';
import 'auth_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final userNotificationsProvider = StreamProvider<List<UserNotification>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value([]);
  }
  
  return notificationService.getUserNotifications(currentUser.id);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(userNotificationsProvider);
  
  return notifications.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, int>((ref) {
  return NotificationNotifier(ref, ref.watch(unreadNotificationsCountProvider), ref.watch(currentUserProvider));
  });
  class NotificationNotifier extends StateNotifier<int> {
  final Ref _ref;
  final int _unreadNotificationsCount;
  final User? _currentUser;
  NotificationNotifier(this._ref, this._unreadNotificationsCount, this._currentUser) : super(_unreadNotificationsCount);

  void updateUnreadNotificationsCount(int count) {
    state = count;
  }
  void refreshNotifications() {
    if (_currentUser != null) {
      _ref.read(userNotificationsProvider).asData!.value.forEach((notification) {
        if (!notification.isRead) {
          updateUnreadNotificationsCount(state - 1);
          }
      });
    }
  }
  // void markNotificationAsRead(String notificationId) {
  //   final notificationService = _ref.read(notificationServiceProvider);
  //   notificationService.markAsRead(notificationId);
  //   refreshNotifications();
  // }
  void clearAllNotifications() {
    final notificationService = _ref.read(notificationServiceProvider);
    notificationService.clearNotificationHistory();
    refreshNotifications();
  }
  Future<void> markAllNotificationsAsRead() async {
    final hiveBox = await Hive.openBox<UserNotification>('userNotifications');
    final notifications = hiveBox.values.toList();
    
    for (var notification in notifications) {
      notification.isRead = true;
      await hiveBox.put(notification.id, notification);
    }
    
    refreshNotifications();
  }
  // notification in hive
  Future<void> saveAllNotificationsLocal(UserNotification notification) async {
    final hiveBox = await Hive.openBox<UserNotification>('userNotifications');
    await hiveBox.add(notification);
    refreshNotifications();


  }
  Future<void>deleteNotification(String id)async{
    final hiveBox = await Hive.openBox<UserNotification>('userNotifications');
    await hiveBox.delete(id);
    refreshNotifications();
  }
}
// Removed the unused Reader class