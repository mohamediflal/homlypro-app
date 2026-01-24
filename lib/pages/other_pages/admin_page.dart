import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_service/services/admin_service.dart';
import 'package:home_service/services/auth_service.dart';
import 'package:home_service/models/app_models.dart';
import 'package:home_service/pages/other_pages/login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic> _stats = {
    'pendingBookings': 0,
    'assignedBookings': 0,
    'completedBookings': 0,
    'totalEmployees': 0,
    'availableEmployees': 0,
  };

  // Which booking status to show in the bookings tab
  String _bookingStatusFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardStats() async {
    final stats = await _adminService.getDashboardStats();
    setState(() {
      _stats = stats;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.book_online), text: 'Bookings'),
            Tab(icon: Icon(Icons.people), text: 'Employees'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildBookingsTab(),
          _buildEmployeesTab(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadDashboardStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.3,
                  children: [
                    _buildStatCard(
                      'Pending Bookings',
                      _stats['pendingBookings'].toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Assigned Bookings',
                      _stats['assignedBookings'].toString(),
                      Icons.assignment_turned_in,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Completed',
                      _stats['completedBookings'].toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Total Employees',
                      _stats['totalEmployees'].toString(),
                      Icons.people,
                      Colors.purple,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 8,
            children: [
              _statusChip('pending', 'Pending', Colors.orange),
              _statusChip('assigned', 'Assigned', Colors.blue),
              _statusChip('completed', 'Completed', Colors.green),
              _statusChip('cancelled', 'Cancelled', Colors.red),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<BookingModel>>(
            stream: _adminService.streamBookingsByStatus(_bookingStatusFilter),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading bookings: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No ${_bookingStatusFilter.toUpperCase()} bookings'),
                );
              }

              final bookings = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final dateString =
                      '${booking.bookingDate.year}-${booking.bookingDate.month.toString().padLeft(2, '0')}-${booking.bookingDate.day.toString().padLeft(2, '0')} ${booking.bookingDate.hour.toString().padLeft(2, '0')}:${booking.bookingDate.minute.toString().padLeft(2, '0')}';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.purple,
                                    child: Text(
                                      booking.serviceType.isNotEmpty
                                          ? booking.serviceType[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.serviceType,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Status: ${booking.status}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Chip(
                                label: Text(booking.status.toUpperCase()),
                                backgroundColor: _statusColor(booking.status).withOpacity(0.1),
                                labelStyle: TextStyle(color: _statusColor(booking.status)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Date: $dateString'),
                          Text('Address: ${booking.address}, ${booking.city}'),
                          Text('Phone: ${booking.phoneNumber}'),
                          Text('Description: ${booking.serviceDescription}'),
                          if (booking.assignedEmployeeId != null)
                            FutureBuilder<String>(
                              future: _getEmployeeNameForBooking(booking.assignedEmployeeId!),
                              builder: (context, snapshot) {
                                final employeeName = snapshot.data ?? 'Loading...';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Employee ID: ${booking.assignedEmployeeId}'),
                                    Text('Employee Name: $employeeName'),
                                  ],
                                );
                              },
                            ),
                          const SizedBox(height: 12),
                          _buildBookingActions(booking),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String value, String label, Color color) {
    final isSelected = _bookingStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _bookingStatusFilter = value),
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? color : Colors.black87),
      side: BorderSide(color: color.withOpacity(0.4)),
    );
  }

  Widget _buildBookingActions(BookingModel booking) {
    if (booking.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAssignEmployeeDialog(booking),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Assign'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelBookingDialog(booking.id),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      );
    }

    if (booking.status == 'assigned') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final error = await _adminService.completeBooking(booking.id);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as completed')),
                  );
                  _loadDashboardStats();
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelBookingDialog(booking.id),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<String> _getEmployeeNameForBooking(String employeeId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .get();
      return doc.data()?['name'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _toggleEmployeeActive(EmployeeModel employee) async {
    try {
      final newStatus = !employee.isActive;
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employee.id)
          .update({'isActive': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '${employee.name} has been reactivated'
                  : '${employee.name} has been deactivated',
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating employee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEmployeeActionsDialog(EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(employee.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${employee.serviceType}'),
            const SizedBox(height: 8),
            Text('Phone: ${employee.phone}'),
            const SizedBox(height: 8),
            Text(
              'Status: ${employee.isActive ? 'Active' : 'Inactive'}',
              style: TextStyle(
                color: employee.isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  employee.isActive ? Colors.orange : Colors.green,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _toggleEmployeeActive(employee);
            },
            child: Text(
              employee.isActive ? 'Deactivate' : 'Reactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesTab() {
    return StreamBuilder<List<EmployeeModel>>(
      stream: _adminService.streamEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No employees found'),
          );
        }

        final employees = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final employee = employees[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: employee.isActive
                      ? (employee.isAvailable ? Colors.green : Colors.orange)
                      : Colors.red,
                  child: Text(
                    employee.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  employee.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: employee.isActive ? Colors.black87 : Colors.red,
                  ),
                ),
                subtitle: Text(
                  '${employee.serviceType}\n${employee.phone}',
                ),
                trailing: employee.isActive
                    ? Chip(
                        label: Text(
                          employee.isAvailable ? 'Available' : 'Busy',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: employee.isAvailable
                            ? Colors.green.shade100
                            : Colors.grey.shade300,
                      )
                    : Chip(
                        label: const Text(
                          'Inactive',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                onTap: () => _showEmployeeActionsDialog(employee),
              ),
            );
          },
        );
      },
    );
  }

  void _showAssignEmployeeDialog(BookingModel booking) async {
    final employees = await _adminService.getAvailableEmployeesForService(booking.serviceType);

    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available employees for this service')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Employee'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return ListTile(
                title: Text(employee.name),
                subtitle: Text(employee.phone),
                onTap: () async {
                  Navigator.pop(ctx);
                  final error = await _adminService.assignEmployeeToBooking(
                    bookingId: booking.id,
                    employeeId: employee.id,
                  );
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Employee assigned successfully')),
                    );
                    _loadDashboardStats();
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingDialog(String bookingId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Cancellation Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              Navigator.pop(ctx);
              final error = await _adminService.cancelBooking(
                bookingId: bookingId,
                reason: reasonController.text,
              );

              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled successfully')),
                );
                _loadDashboardStats();
              }
            },
            child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
