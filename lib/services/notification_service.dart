import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize Firebase Cloud Messaging
  Future<void> initializeNotifications() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Save token to current user
    if (_auth.currentUser != null && token != null) {
      await saveFCMTokenToFirestore(_auth.currentUser!.uid);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Handle notification tap
    });

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (_auth.currentUser != null) {
        saveFCMTokenToFirestore(_auth.currentUser!.uid);
      }
    });
  }

  /// Get FCM token for a user
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Firestore
  Future<void> saveFCMTokenToFirestore(String userId) async {
    try {
      String? token = await getFCMToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Send notification to user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String notificationType,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'notificationType': notificationType,
        'data': data ?? {},
        'isRead': false,
        'createdAt': Timestamp.now(),
        'createdAtServer': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Send notification to employee
  Future<void> sendNotificationToEmployee({
    required String employeeId,
    required String title,
    required String body,
    required String notificationType,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get employee's uid
      final employeeDoc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();
      
      if (employeeDoc.exists) {
        final uid = employeeDoc.data()?['uid'];
        if (uid != null) {
          await _firestore.collection('notifications').add({
            'userId': uid,
            'employeeId': employeeId,
            'title': title,
            'body': body,
            'notificationType': notificationType,
            'data': data ?? {},
            'isRead': false,
            'createdAt': Timestamp.now(),
            'createdAtServer': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error sending notification to employee: $e');
    }
  }

  /// Send notification to all admins
  Future<void> sendNotificationToAdmins({
    required String title,
    required String body,
    required String notificationType,
    Map<String, dynamic>? data,
  }) async {
    try {
      final adminSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'admin')
          .get();

      for (var doc in adminSnapshot.docs) {
        await _firestore.collection('notifications').add({
          'userId': doc.id,
          'title': title,
          'body': body,
          'notificationType': notificationType,
          'data': data ?? {},
          'isRead': false,
          'createdAt': Timestamp.now(),
          'createdAtServer': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error sending notification to admins: $e');
    }
  }

  /// Send booking confirmation notification
  Future<void> sendBookingConfirmationNotification({
    required String userId,
    required String serviceType,
    required String bookingId,
    required DateTime bookingDate,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Booking Confirmed',
      body: 'Your $serviceType booking for ${bookingDate.day}/${bookingDate.month} has been confirmed!',
      notificationType: 'booking_confirmed',
      data: {'bookingId': bookingId},
    );
  }

  /// Send employee assignment notification
  Future<void> sendEmployeeAssignmentNotification({
    required String userId,
    required String employeeName,
    required String bookingId,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Employee Assigned',
      body: '$employeeName has been assigned to your booking',
      notificationType: 'booking_assigned',
      data: {'bookingId': bookingId},
    );
  }

  /// Send booking cancellation notification
  Future<void> sendBookingCancellationNotification({
    required String userId,
    required String reason,
    required String bookingId,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Booking Cancelled',
      body: 'Your booking has been cancelled. Reason: $reason',
      notificationType: 'booking_cancelled',
      data: {'bookingId': bookingId, 'reason': reason},
    );
  }

  /// Send booking completion notification
  Future<void> sendBookingCompletionNotification({
    required String userId,
    required String serviceType,
    required String bookingId,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Service Completed',
      body: 'Your $serviceType service has been completed successfully!',
      notificationType: 'booking_completed',
      data: {'bookingId': bookingId},
    );
  }

  /// Send new booking alert to admins
  Future<void> sendNewBookingAlertToAdmins({
    required String serviceType,
    required String bookingId,
    required String userName,
  }) async {
    await sendNotificationToAdmins(
      title: 'New Booking Request',
      body: '$userName has requested a $serviceType service',
      notificationType: 'new_booking',
      data: {'bookingId': bookingId},
    );
  }

  /// Send employee deactivation notification
  Future<void> sendEmployeeDeactivationNotification({
    required String employeeId,
    required String reason,
  }) async {
    await sendNotificationToEmployee(
      employeeId: employeeId,
      title: 'Account Deactivated',
      body: 'Your employee account has been temporarily deactivated. Reason: $reason',
      notificationType: 'account_deactivated',
      data: {'reason': reason},
    );
  }

  /// Send employee reactivation notification
  Future<void> sendEmployeeReactivationNotification({
    required String employeeId,
  }) async {
    await sendNotificationToEmployee(
      employeeId: employeeId,
      title: 'Account Reactivated',
      body: 'Your employee account has been reactivated. You can now accept bookings.',
      notificationType: 'account_reactivated',
      data: {},
    );
  }

  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .limit(50)
          .get();

      final items = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();

      items.sort((a, b) {
        final aServer = a['createdAtServer'];
        final bServer = b['createdAtServer'];
        final aClient = a['createdAt'];
        final bClient = b['createdAt'];

        DateTime ad = aServer is Timestamp
            ? aServer.toDate()
            : (aClient is Timestamp ? aClient.toDate() : DateTime.fromMillisecondsSinceEpoch(0));
        DateTime bd = bServer is Timestamp
            ? bServer.toDate()
            : (bClient is Timestamp ? bClient.toDate() : DateTime.fromMillisecondsSinceEpoch(0));
        return bd.compareTo(ad);
      });

      return items;
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Stream user notifications
  Stream<List<Map<String, dynamic>>> streamUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
              .toList();
          items.sort((a, b) {
            final aServer = a['createdAtServer'];
            final bServer = b['createdAtServer'];
            final aClient = a['createdAt'];
            final bClient = b['createdAt'];

            DateTime ad = aServer is Timestamp
                ? aServer.toDate()
                : (aClient is Timestamp ? aClient.toDate() : DateTime.fromMillisecondsSinceEpoch(0));
            DateTime bd = bServer is Timestamp
                ? bServer.toDate()
                : (bClient is Timestamp ? bClient.toDate() : DateTime.fromMillisecondsSinceEpoch(0));
            return bd.compareTo(ad);
          });
          return items;
        });
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.size;
    } catch (e) {
      return 0;
    }
  }

  /// Stream unread notification count
  Stream<int> streamUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Delete old notifications (older than 30 days)
  Future<void> deleteOldNotifications(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting old notifications: $e');
    }
  }
}
