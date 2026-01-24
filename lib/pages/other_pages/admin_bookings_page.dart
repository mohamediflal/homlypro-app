import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../models/app_models.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({Key? key}) : super(key: key);

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  String _filterStatus = 'pending'; // pending, assigned, completed, cancelled

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        centerTitle: true,
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
        child: Column(
          children: [
            // Filter tabs
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Pending', 'pending'),
                    _buildFilterChip('Assigned', 'assigned'),
                    _buildFilterChip('Completed', 'completed'),
                    _buildFilterChip('Cancelled', 'cancelled'),
                  ],
                ),
              ),
            ),
            // Bookings list
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.streamAllBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No bookings found'));
                  }

                  // Filter bookings
                  final filteredBookings = snapshot.data!
                      .where((booking) => booking['status'] == _filterStatus)
                      .toList();

                  // Sort completed bookings: new ones at top, old ones at bottom
                  if (_filterStatus == 'completed') {
                    filteredBookings.sort((a, b) {
                      final aDate = (a['bookingDate'] as Timestamp).toDate();
                      final bDate = (b['bookingDate'] as Timestamp).toDate();
                      return bDate.compareTo(aDate); // descending order
                    });
                  }

                  if (filteredBookings.isEmpty) {
                    return Center(
                      child: Text('No $_filterStatus bookings'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _buildBookingCard(booking, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _filterStatus = status);
          }
        },
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Future<String> _getEmployeeName(String employeeId) async {
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

  Widget _buildBookingCard(Map<String, dynamic> booking, BuildContext context) {
    final bookingDate =
        (booking['bookingDate'] as Timestamp).toDate();
    final formattedDate =
        '${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')} ${bookingDate.hour.toString().padLeft(2, '0')}:${bookingDate.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['serviceType'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking ID: ${booking['id']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Date & Time', formattedDate),
            _buildInfoRow('Address', booking['address'] ?? 'N/A'),
            _buildInfoRow('Phone', booking['phoneNumber'] ?? 'N/A'),
            _buildInfoRow('Description', booking['serviceDescription'] ?? 'N/A'),
            if (booking['assignedEmployeeId'] != null)
              FutureBuilder<String>(
                future: _getEmployeeName(booking['assignedEmployeeId']),
                builder: (context, snapshot) {
                  final employeeName = snapshot.data ?? 'Loading...';
                  final employeeId = booking['assignedEmployeeId'];
                  return Column(
                    children: [
                      _buildInfoRow('Employee ID', employeeId),
                      _buildInfoRow('Employee Name', employeeName),
                    ],
                  );
                },
              ),
            if (booking['cancellationReason'] != null)
              _buildInfoRow('Cancellation Reason', booking['cancellationReason'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildActionButtons(booking, context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    Map<String, dynamic> booking,
    BuildContext context,
  ) {
    final status = booking['status'];

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _showEmployeeSelectionDialog(booking, context),
              icon: const Icon(Icons.person_add),
              label: const Text('Assign Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showCancelBookingDialog(booking, context),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      );
    } else if (status == 'assigned') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAsCompleted(booking, context),
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showCancelBookingDialog(booking, context),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showEmployeeSelectionDialog(
    Map<String, dynamic> booking,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Employee'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _firestoreService.getAvailableEmployees(
              booking['serviceType'] ?? '',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No available employees for this service'),
                );
              }

              final employees = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  final isAvailable = employee['isAvailable'] ?? false;

                  return ListTile(
                    leading: Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                    title: Text(employee['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${employee['phone'] ?? 'N/A'} - ${isAvailable ? 'Available' : 'Busy'}',
                    ),
                    enabled: isAvailable,
                    onTap: isAvailable
                        ? () async {
                            await _assignEmployeeToBooking(
                              booking['id'],
                              employee['id'],
                              booking['userId'],
                              employee['name'],
                            );
                            if (mounted) Navigator.of(ctx).pop();
                          }
                        : null,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignEmployeeToBooking(
    String bookingId,
    String employeeId,
    String userId,
    String employeeName,
  ) async {
    try {
      final result = await _firestoreService.assignEmployeeToBooking(
        bookingId: bookingId,
        employeeId: employeeId,
      );

      if (result == null) {
        // Send notification to user
        await _notificationService.sendNotificationToUser(
          userId: userId,
          title: 'Employee Assigned',
          body: '$employeeName has been assigned to your booking',
          notificationType: 'booking_assigned',
          data: {'bookingId': bookingId},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee assigned successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning employee: $e')),
        );
      }
    }
  }

  void _showCancelBookingDialog(
    Map<String, dynamic> booking,
    BuildContext context,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for cancellation:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter cancellation reason...',
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              await _cancelBooking(
                booking['id'],
                booking['userId'],
                reason,
              );

              if (mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(
    String bookingId,
    String userId,
    String reason,
  ) async {
    try {
      final result = await _firestoreService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );

      if (result == null) {
        // Send notification to user
        await _notificationService.sendNotificationToUser(
          userId: userId,
          title: 'Booking Cancelled',
          body: 'Your booking has been cancelled. Reason: $reason',
          notificationType: 'booking_cancelled',
          data: {'bookingId': bookingId, 'reason': reason},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Booking cancelled and user notified',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling booking: $e')),
        );
      }
    }
  }

  Future<void> _markAsCompleted(
    Map<String, dynamic> booking,
    BuildContext context,
  ) async {
    try {
      // Update booking status to completed
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking['id'])
          .update({
            'status': 'completed',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Send notification to user
      await _notificationService.sendNotificationToUser(
        userId: booking['userId'],
        title: 'Service Completed',
        body: 'Your ${booking['serviceType']} service has been completed',
        notificationType: 'booking_completed',
        data: {'bookingId': booking['id']},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking marked as completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating booking: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
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
}
