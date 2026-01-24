import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:home_service/models/app_models.dart';
import 'package:home_service/services/employee_auth_service.dart';
import 'package:home_service/pages/other_pages/employee_login_page.dart';

class EmployeeDashboardPage extends StatefulWidget {
  final String employeeId;
  final Map<String, dynamic> employeeData;

  const EmployeeDashboardPage({
    Key? key,
    required this.employeeId,
    required this.employeeData,
  }) : super(key: key);

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EmployeeAuthService _employeeAuthService = EmployeeAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAvailable = true;
  Map<String, dynamic> _stats = {
    'assignedBookings': 0,
    'completedBookings': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isAvailable = widget.employeeData['isAvailable'] ?? true;
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      // Get assigned bookings
      final assignedBookings = await _firestore
          .collection('bookings')
          .where('assignedEmployeeId', isEqualTo: widget.employeeId)
          .where('status', isEqualTo: 'assigned')
          .get();

      // Get completed bookings
      final completedBookings = await _firestore
          .collection('bookings')
          .where('assignedEmployeeId', isEqualTo: widget.employeeId)
          .where('status', isEqualTo: 'completed')
          .get();

      setState(() {
        _stats = {
          'assignedBookings': assignedBookings.size,
          'completedBookings': completedBookings.size,
        };
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _toggleAvailability() async {
    final newStatus = !_isAvailable;
    final error = await _employeeAuthService.updateAvailability(
      employeeId: widget.employeeId,
      isAvailable: newStatus,
    );

    if (error == null) {
      setState(() {
        _isAvailable = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'You are now available for work' : 'You are now unavailable',
          ),
          backgroundColor: newStatus ? Colors.green : Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If completed, make employee available again
      if (newStatus == 'completed') {
        await _employeeAuthService.updateAvailability(
          employeeId: widget.employeeId,
          isAvailable: true,
        );
        await _firestore.collection('employees').doc(widget.employeeId).update({
          'currentBookingId': null,
        });
      }

      _loadStats();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
              await _employeeAuthService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const EmployeeLoginPage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.employeeData['name'] ?? 'Employee'}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isAvailable ? Icons.work : Icons.work_off),
            onPressed: _toggleAvailability,
            tooltip: _isAvailable ? 'Mark Unavailable' : 'Mark Available',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.assignment), text: 'My Jobs'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildMyJobsTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isAvailable
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isAvailable ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isAvailable ? 'Available for Work' : 'Currently Unavailable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.employeeData['serviceType'] ?? 'Employee',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats Cards
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Jobs',
                    '${_stats['assignedBookings']}',
                    Icons.assignment_turned_in,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '${_stats['completedBookings']}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                if (isFullWidth)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: isFullWidth ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyJobsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: const TabBar(
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
              tabs: [
                Tab(text: 'Assigned'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBookingsList('assigned'),
                _buildBookingsList('completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('assignedEmployeeId', isEqualTo: widget.employeeId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Get bookings and sort them by date in memory
        final bookings = snapshot.data?.docs ?? [];
        bookings.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = aData['bookingDate'] as Timestamp?;
          final bDate = bData['bookingDate'] as Timestamp?;
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate); // descending order
        });

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'assigned' ? Icons.work_off : Icons.history,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No $status bookings',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking =
                BookingModel.fromJson(bookings[index].data() as Map<String, dynamic>, bookings[index].id);
            return _buildBookingCard(booking, status);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: status == 'assigned' ? Colors.blue : Colors.green,
          child: Icon(
            status == 'assigned' ? Icons.assignment : Icons.check_circle,
            color: Colors.white,
          ),
        ),
        title: Text(
          booking.serviceType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy - hh:mm a').format(booking.bookingDate),
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.description, 'Description',
                    booking.serviceDescription),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_on, 'Address',
                    '${booking.address}, ${booking.city}'),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.phone, 'Contact', booking.phoneNumber),
                const SizedBox(height: 16),
                if (status == 'assigned')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Complete Job',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _confirmCompleteJob(booking.id),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.purple),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmCompleteJob(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Complete Job'),
        content: const Text('Mark this job as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateBookingStatus(bookingId, 'completed');
            },
            child:
                const Text('Complete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.purple,
            child: Text(
              (widget.employeeData['name'] ?? 'E')[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.employeeData['name'] ?? 'Employee',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.employeeData['serviceType'] ?? 'Service Provider',
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildProfileInfoCard(
            Icons.email,
            'Email',
            widget.employeeData['email'] ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildProfileInfoCard(
            Icons.phone,
            'Phone',
            widget.employeeData['phone'] ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildProfileInfoCard(
            Icons.calendar_today,
            'Member Since',
            widget.employeeData['createdAt'] != null
                ? DateFormat('MMM dd, yyyy')
                    .format((widget.employeeData['createdAt'] as Timestamp).toDate())
                : 'N/A',
          ),
          const SizedBox(height: 12),
          _buildProfileInfoCard(
            Icons.verified,
            'Status',
            widget.employeeData['isActive'] == true ? 'Active' : 'Inactive',
            statusColor:
                widget.employeeData['isActive'] == true ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(IconData icon, String label, String value,
      {Color? statusColor}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: statusColor ?? Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
