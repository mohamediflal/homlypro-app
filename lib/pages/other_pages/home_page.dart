import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_service/services/auth_service.dart';
import 'package:home_service/services/notification_service.dart';
import 'package:home_service/pages/other_pages/login_page.dart';
import 'package:home_service/pages/other_pages/notification_center_page.dart';
import 'ser_booking_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedIndex;
  String _userName = 'User';
  bool _isLoading = true;
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        setState(() {
          _userName = 'Guest';
          _isLoading = false;
        });
        return;
      }

      _userId = user.uid;

      // Reload user to get latest data
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      
      print('User ID: ${updatedUser?.uid}');
      print('Display Name: ${updatedUser?.displayName}');
      print('Email: ${updatedUser?.email}');

      // Add a small delay to ensure Firestore is ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Try to get username from Firestore first
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser!.uid)
          .get();
      
      print('Document exists: ${doc.exists}');
      print('Document data: ${doc.data()}');

      if (doc.exists) {
        final data = doc.data();
        final username = data?['username'];
        print('Username from Firestore: $username');
        
        if (username != null && username.toString().isNotEmpty) {
          setState(() {
            _userName = username.toString();
            _isLoading = false;
          });
          return;
        }
      }
      
      // Try display name from Firebase Auth
      if (updatedUser.displayName != null && updatedUser.displayName!.isNotEmpty) {
        setState(() {
          _userName = updatedUser.displayName!;
          _isLoading = false;
        });
        return;
      }
      
      // Fall back to email prefix
      setState(() {
        _userName = updatedUser.email?.split('@')[0] ?? 'User';
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error loading user data: $e');
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        _userName = user?.email?.split('@')[0] ?? 'User';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    if (_userId.isEmpty) {
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
        icon: const Icon(Icons.notifications_none, size: 26, color: Colors.black87),
        tooltip: 'Login to view notifications',
      );
    }

    return StreamBuilder<int>(
      stream: _notificationService.streamUnreadNotificationCount(_userId),
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return IconButton(
          onPressed: _openNotifications,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none, size: 26, color: Colors.black87),
              if (unread > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openNotifications() {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to view notifications')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 600;

            return Container(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 16,
                isMobile ? 12 : 16,
                isMobile ? 12 : 16,
                4,
              ),
              width: isMobile ? double.infinity : screenWidth * 0.9,
              constraints: BoxConstraints(
                maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.7 : 420,
                maxWidth: isMobile ? double.infinity : 500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isMobile)
                        TextButton(
                          onPressed: () async {
                            await _notificationService.markAllNotificationsAsRead(_userId);
                          },
                          child: const Text('Mark all read'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: isMobile ? 20 : 24,
                        padding: EdgeInsets.all(isMobile ? 4 : 8),
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                      ),
                    ],
                  ),
                  if (isMobile) ...[
                    TextButton(
                      onPressed: () async {
                        await _notificationService.markAllNotificationsAsRead(_userId);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Mark all read', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(height: 4),
                  ],
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _notificationService.streamUserNotifications(_userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final notifications = snapshot.data ?? [];
                        if (notifications.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('No notifications yet', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: notifications.length > 5 ? 5 : notifications.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            final isRead = notification['isRead'] ?? false;
                            final type = notification['notificationType'] ?? '';
                            final createdAt = notification['createdAt'];
                            final dateTime = createdAt is Timestamp
                                ? createdAt.toDate()
                                : DateTime.now();

                            return ListTile(
                              dense: isMobile,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 16,
                                vertical: isMobile ? 4 : 8,
                              ),
                              leading: CircleAvatar(
                                radius: isMobile ? 18 : 20,
                                backgroundColor: _getNotificationColor(type).withOpacity(0.12),
                                child: Icon(
                                  _getNotificationIcon(type),
                                  color: _getNotificationColor(type),
                                  size: isMobile ? 18 : 20,
                                ),
                              ),
                              title: Text(
                                notification['title'] ?? 'Notification',
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                  color: Colors.black87,
                                  fontSize: isMobile ? 13 : 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['body'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: isMobile ? 11 : 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatNotificationTime(dateTime),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: isMobile ? 10 : 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: !isRead && !isMobile
                                  ? TextButton(
                                      onPressed: () async {
                                        await _notificationService.markNotificationAsRead(notification['id']);
                                      },
                                      child: const Text('Mark read', style: TextStyle(fontSize: 12)),
                                    )
                                  : (!isRead && isMobile
                                      ? const Icon(Icons.circle, size: 8, color: Colors.blue)
                                      : null),
                              onTap: () async {
                                if (!isRead) {
                                  await _notificationService.markNotificationAsRead(notification['id']);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await _notificationService.deleteAllNotifications(_userId);
                        },
                        child: const Text('Clear all'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationCenterPage()),
                          );
                        },
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatNotificationTime(DateTime dateTime) {
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'booking_assigned':
        return Icons.person_add;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'booking_completed':
        return Icons.done_all;
      case 'new_message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking_confirmed':
        return Colors.blue;
      case 'booking_assigned':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'booking_completed':
        return Colors.purple;
      case 'new_message':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final services = [
      {'title': 'Cleaning', 'image': 'assets/service/clean.jpg'},
      {'title': 'Plumber', 'image': 'assets/service/plumber.jpg'},
      {'title': 'Electrician', 'image': 'assets/service/elec.png'},
      {'title': 'Painter', 'image': 'assets/service/paint.png'},
      {'title': 'Carpenter', 'image': 'assets/service/carpenter.png'},
      {'title': 'Gardener', 'image': 'assets/service/gardener.jpg'},
      {'title': 'Cook', 'image': 'assets/service/cook.png'},
      {'title': 'Driver', 'image': 'assets/service/driver.jpg'},
      {'title': 'Mechanic', 'image': 'assets/service/mech.jpg'},
      {'title': 'Tailor', 'image': 'assets/service/tailor.png'},
    ];

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 1),
                            _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    'Welcome back $_userName',
                                    style: const TextStyle(fontSize: 15, color: Colors.black),
                                  ),
                          ],
                        ),
                      ),
                      // Logout icon
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          size: 24,
                          color: Colors.black87,
                        ),
                        tooltip: 'Logout',
                      ),
                      _buildNotificationButton(),
                    ],
                  ),
                ),
              ),

            

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  'Which service do you need?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 40,
                    childAspectRatio: 1,
                    children: services.asMap().entries.map((entry) {
                      final index = entry.key;
                      final s = entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SerBookingPage(
                                serviceTitle: s['title']!,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) setState(() => _selectedIndex = null);
                          });
                        },
                        child: _ServiceCard(
                          title: s['title']!,
                          imagePath: s['image']!,
                          isSelected: _selectedIndex == index,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;

  const _ServiceCard({required this.title, required this.imagePath, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF8A2BE2) : Colors.transparent,
          width: isSelected ? 2.0 : 0.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}