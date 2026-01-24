import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_service/models/app_models.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _bookingsCollection = 'bookings';
  final String _employeesCollection = 'employees';
  final String _usersCollection = 'users';
  final String _notificationsCollection = 'notifications';

  /// Get all pending bookings with pagination
  Future<List<BookingModel>> getPendingBookings({int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_bookingsCollection)
          .where('status', isEqualTo: 'pending')
          .orderBy('bookingDate', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              BookingModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching pending bookings: $e');
      return [];
    }
  }

  /// Get all assigned bookings
  Future<List<BookingModel>> getAssignedBookings({int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_bookingsCollection)
          .where('status', isEqualTo: 'assigned')
          .orderBy('bookingDate', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              BookingModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching assigned bookings: $e');
      return [];
    }
  }

  /// Get available employees for a specific service type
  Future<List<EmployeeModel>> getAvailableEmployeesForService(
      String serviceType) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_employeesCollection)
          .where('serviceType', isEqualTo: serviceType)
          .where('isAvailable', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              EmployeeModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching available employees: $e');
      return [];
    }
  }

  /// Assign employee to booking
  Future<String?> assignEmployeeToBooking({
    required String bookingId,
    required String employeeId,
  }) async {
    try {
      // Get booking and employee details
      final bookingDoc =
          await _firestore.collection(_bookingsCollection).doc(bookingId).get();
      final employeeDoc =
          await _firestore.collection(_employeesCollection).doc(employeeId).get();

      if (!bookingDoc.exists || !employeeDoc.exists) {
        return 'Booking or employee not found';
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final userId = bookingData['userId'];

      // Update booking
      await _firestore.collection(_bookingsCollection).doc(bookingId).update({
        'assignedEmployeeId': employeeId,
        'status': 'assigned',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update employee availability
      await _firestore
          .collection(_employeesCollection)
          .doc(employeeId)
          .update({
        'isAvailable': false,
        'currentBookingId': bookingId,
      });

      // Send notification to user
      await _firestore.collection(_notificationsCollection).add({
        'userId': userId,
        'title': 'Booking Assigned',
        'body': 'Your booking has been assigned to an employee',
        'notificationType': 'booking_assigned',
        'data': {
          'bookingId': bookingId,
          'employeeId': employeeId,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return 'Error assigning employee: $e';
    }
  }

  /// Cancel booking and notify user
  Future<String?> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      // Get booking details
      final bookingDoc =
          await _firestore.collection(_bookingsCollection).doc(bookingId).get();

      if (!bookingDoc.exists) {
        return 'Booking not found';
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final userId = bookingData['userId'];
      final assignedEmployeeId = bookingData['assignedEmployeeId'];

      // Update booking status
      await _firestore.collection(_bookingsCollection).doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If employee was assigned, mark them as available again
      if (assignedEmployeeId != null) {
        await _firestore
            .collection(_employeesCollection)
            .doc(assignedEmployeeId)
            .update({
          'isAvailable': true,
          'currentBookingId': null,
        });
      }

      // Send cancellation notification to user
      await _firestore.collection(_notificationsCollection).add({
        'userId': userId,
        'title': 'Booking Cancelled',
        'body': 'Your booking has been cancelled. Reason: $reason',
        'notificationType': 'booking_cancelled',
        'data': {
          'bookingId': bookingId,
          'reason': reason,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return 'Error cancelling booking: $e';
    }
  }

  /// Mark booking as completed
  Future<String?> completeBooking(String bookingId) async {
    try {
      final bookingDoc =
          await _firestore.collection(_bookingsCollection).doc(bookingId).get();

      if (!bookingDoc.exists) {
        return 'Booking not found';
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final assignedEmployeeId = bookingData['assignedEmployeeId'];
      final userId = bookingData['userId'];

      // Update booking status
      await _firestore.collection(_bookingsCollection).doc(bookingId).update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mark employee as available
      if (assignedEmployeeId != null) {
        await _firestore
            .collection(_employeesCollection)
            .doc(assignedEmployeeId)
            .update({
          'isAvailable': true,
          'currentBookingId': null,
        });
      }

      // Send completion notification
      await _firestore.collection(_notificationsCollection).add({
        'userId': userId,
        'title': 'Service Completed',
        'body': 'Your service has been completed. Thank you for choosing us!',
        'notificationType': 'service_completed',
        'data': {
          'bookingId': bookingId,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return 'Error completing booking: $e';
    }
  }

  /// Add new employee
  Future<String?> addEmployee({
    required String name,
    required String serviceType,
    required String phone,
    required String email,
  }) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(_employeesCollection).add({
        'name': name,
        'serviceType': serviceType,
        'phone': phone,
        'email': email,
        'isActive': true,
        'isAvailable': true,
        'currentBookingId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id; // Return employee ID
    } catch (e) {
      return null;
    }
  }

  /// Update employee details
  Future<String?> updateEmployee({
    required String employeeId,
    String? name,
    String? phone,
    String? email,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (email != null) updateData['email'] = email;

      await _firestore
          .collection(_employeesCollection)
          .doc(employeeId)
          .update(updateData);

      return null; // Success
    } catch (e) {
      return 'Error updating employee: $e';
    }
  }

  /// Deactivate employee
  Future<String?> deactivateEmployee(String employeeId) async {
    try {
      await _firestore
          .collection(_employeesCollection)
          .doc(employeeId)
          .update({
        'isActive': false,
        'isAvailable': false,
      });

      return null; // Success
    } catch (e) {
      return 'Error deactivating employee: $e';
    }
  }

  /// Get all employees
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_employeesCollection)
          .orderBy('name', descending: false)
          .get();

      return snapshot.docs
          .map((doc) =>
              EmployeeModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching employees: $e');
      return [];
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Count pending bookings
      final pendingQuery = await _firestore
          .collection(_bookingsCollection)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      // Count assigned bookings
      final assignedQuery = await _firestore
          .collection(_bookingsCollection)
          .where('status', isEqualTo: 'assigned')
          .count()
          .get();

      // Count completed bookings
      final completedQuery = await _firestore
          .collection(_bookingsCollection)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      // Count total employees
      final employeeQuery =
          await _firestore.collection(_employeesCollection).count().get();

      // Count available employees
      final availableEmployeeQuery = await _firestore
          .collection(_employeesCollection)
          .where('isAvailable', isEqualTo: true)
          .count()
          .get();

      return {
        'pendingBookings': pendingQuery.count,
        'assignedBookings': assignedQuery.count,
        'completedBookings': completedQuery.count,
        'totalEmployees': employeeQuery.count,
        'availableEmployees': availableEmployeeQuery.count,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'pendingBookings': 0,
        'assignedBookings': 0,
        'completedBookings': 0,
        'totalEmployees': 0,
        'availableEmployees': 0,
      };
    }
  }

  /// Stream pending bookings for real-time updates
  Stream<List<BookingModel>> streamPendingBookings() {
    return _firestore
        .collection(_bookingsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('bookingDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                BookingModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Stream bookings by status (pending, assigned, completed, cancelled)
  Stream<List<BookingModel>> streamBookingsByStatus(String status) {
    return _firestore
        .collection(_bookingsCollection)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();
          // Sort by booking date in memory
          bookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
          return bookings;
        });
  }

  /// Stream all employees
  Stream<List<EmployeeModel>> streamEmployees() {
    return _firestore
        .collection(_employeesCollection)
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                EmployeeModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
