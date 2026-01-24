import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notification_service.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({Key? key}) : super(key: key);

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  final NotificationService _notificationService = NotificationService();
  late String _userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllNotifications,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 205, 187, 223),
              Color.fromARGB(255, 143, 171, 220),
            ],
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _userId.isEmpty
              ? const Stream.empty()
              : _notificationService.streamUserNotifications(_userId),
          builder: (context, snapshot) {
            if (_userId.isEmpty) {
              return const Center(
                child: Text('Login to view notifications'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No notifications yet'),
                  ],
                ),
              );
            }

            final notifications = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification, context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    BuildContext context,
  ) {
    final isRead = notification['isRead'] ?? false;
    final notificationType = notification['notificationType'] ?? '';
    final createdAt = (notification['createdAt'] as Timestamp).toDate();
    final timeString = _formatTime(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isRead ? Colors.white : Colors.blue.shade50,
          border: Border(
            left: BorderSide(
              color: _getNotificationColor(notificationType),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getNotificationIcon(notificationType),
                          color: _getNotificationColor(notificationType),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification['title'] ?? 'Notification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isRead ? Colors.black87 : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification['body'] ?? '',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeString,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      if (!isRead)
                        TextButton.icon(
                          onPressed: () =>
                              _markAsRead(notification['id'], context),
                          icon: const Icon(Icons.done, size: 18),
                          label: const Text('Mark Read'),
                        ),
                      TextButton.icon(
                        onPressed: () =>
                            _deleteNotification(notification['id'], context),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId, BuildContext context) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(
    String notificationId,
    BuildContext context,
  ) async {
    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login to clear notifications')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _notificationService.deleteAllNotifications(_userId);
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  IconData _getNotificationIcon(String notificationType) {
    switch (notificationType) {
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'booking_assigned':
        return Icons.person_add;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'booking_completed':
        return Icons.done_all;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String notificationType) {
    switch (notificationType) {
      case 'booking_confirmed':
        return Colors.blue;
      case 'booking_assigned':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'booking_completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
