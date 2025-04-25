// screens/home/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gam3ya/src/widgets/animations/slide_animation.dart';
import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

import '../../controllers/notification_provider.dart';
import '../../models/user_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _handleNotificationTap(dynamic payload, BuildContext context) {
    // Example implementation: handle navigation or actions based on payload content
    if (payload == null) return;

    if (payload is Map<String, dynamic>) {
      final type = payload['type'];
      final route = payload['route'];
      final id = payload['id'];

      if (route != null) {
        Navigator.of(context).pushNamed(route, arguments: id);
        return;
      }

      // Add more handling based on type or other keys
      switch (type) {
        case 'payment':
          Navigator.of(context).pushNamed('/payments', arguments: id);
          break;
        case 'gam3ya':
          Navigator.of(context).pushNamed('/gam3ya', arguments: id);
          break;
        case 'reminder':
          Navigator.of(context).pushNamed('/reminders', arguments: id);
          break;
        default:
          // Default action or show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الضغط على الإشعار')),
          );
      }
    } else {
      // Handle other payload types if necessary
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الضغط على الإشعار')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(userNotificationsProvider);
    
    return Scaffold(
      body: notificationsAsyncValue.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          return _buildNotificationsList(context, ref, notifications);
        },
        loading: () => const Center(
          child: LoadingIndicator(),
        ),
        error: (error, stackTrace) => ErrorDisplayWidget(
          message: 'حدث خطأ أثناء تحميل الإشعارات',
          onRetry: () {
            ref.refresh(userNotificationsProvider);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'clearNotifications',
        onPressed: () {
          _showDeleteConfirmationDialog(context, ref);
        },
        backgroundColor: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_sweep),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ستظهر هنا إشعارات جمعياتك والمدفوعات',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context, 
    WidgetRef ref, 
    List<UserNotification> notifications
  ) {
    // Group notifications by date
    Map<String, List<UserNotification>> groupedNotifications = {};
    
    for (var notification in notifications) {
      final date = DateFormat('yyyy-MM-dd').format(notification.timestamp);
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, dateIndex) {
        final date = groupedNotifications.keys.toList()[dateIndex];
        final dateNotifications = groupedNotifications[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            ...dateNotifications.asMap().entries.map((entry) {
              final index = entry.key;
              final notification = entry.value;
              return SlideAnimation(
                duration: Duration(milliseconds: 300 + (index * 50)),
                child: Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    ref.read(notificationNotifierProvider.notifier).deleteNotification(notification.id);
                  },
                  child: _buildNotificationCard(context, notification),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, UserNotification notification) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.payment:
        iconData = Icons.attach_money;
        iconColor = Colors.green;
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case NotificationType.turn:
        iconData = Icons.event_available;
        iconColor = Colors.blue;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.purple;
        break;
      case NotificationType.gam3ya:
        iconData = Icons.group;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Theme.of(context).colorScheme.primary;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(
            iconData,
            color: iconColor,
          ),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(notification.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // Handle notification tap based on type and data
          // Navigate to related screen based on notification data
          _handleNotificationTap(notification, context);
                },
      ),
    );
  }
  
  String _formatDate(String date) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));
    
    if (date == today) {
      return 'اليوم';
    } else if (date == yesterday) {
      return 'الأمس';
    } else {
      return DateFormat('EEEE, d MMMM', 'ar').format(DateTime.parse(date));
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الإشعارات'),
          content: const Text('هل تريد حذف جميع الإشعارات؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                ref.read(notificationNotifierProvider.notifier).clearAllNotifications();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف جميع الإشعارات'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('حذف الكل'),
            ),
          ],
        );
      },
    );
  }
}