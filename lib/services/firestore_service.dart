import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a booking
  Future<String?> createBooking({
    required String userId,
    required String serviceType, // Cleaning, Plumber, etc.
    required String serviceDescription,
    required DateTime bookingDate,
    required String address,
    required String city,
    required String phoneNumber,
    required double estimatedCost,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('bookings').add({
        'userId': userId,
        'serviceType': serviceType,
        'serviceDescription': serviceDescription,
        'bookingDate': bookingDate,
        'address': address,
        'city': city,
        'phoneNumber': phoneNumber,
        'estimatedCost': estimatedCost,
        'status': 'pending', // pending, assigned, completed, cancelled
        'assignedEmployeeId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id; // Return booking ID
    } catch (e) {
      return null;
    }
  }

  /// Get user bookings
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all pending bookings (for admin)
  Future<List<Map<String, dynamic>>> getPendingBookings() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .orderBy('bookingDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Assign employee to booking
  Future<String?> assignEmployeeToBooking({
    required String bookingId,
    required String employeeId,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'assignedEmployeeId': employeeId,
        'status': 'assigned',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return 'Failed to assign employee';
    }
  }

  /// Cancel booking
  Future<String?> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return 'Failed to cancel booking';
    }
  }

  /// Get booking details
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('bookings').doc(bookingId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Add available service
  Future<String?> addService({
    required String serviceType,
    required String description,
    required double baseCost,
    required String imageUrl,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('services').add({
        'serviceType': serviceType,
        'description': description,
        'baseCost': baseCost,
        'imageUrl': imageUrl,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Get all services
  Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get employees
  Future<List<Map<String, dynamic>>> getAvailableEmployees(
      String serviceType) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('employees')
          .where('serviceType', isEqualTo: serviceType)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add employee
  Future<String?> addEmployee({
    required String name,
    required String serviceType,
    required String phone,
    required String email,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('employees').add({
        'name': name,
        'serviceType': serviceType,
        'phone': phone,
        'email': email,
        'isActive': true,
        'isAvailable': true,
        'currentBookingId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Update employee availability
  Future<String?> updateEmployeeAvailability({
    required String employeeId,
    required bool isAvailable,
  }) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employeeId)
          .update({'isAvailable': isAvailable});
      return null; // Success
    } catch (e) {
      return 'Failed to update employee availability';
    }
  }

  /// Stream of user bookings (real-time updates)
  Stream<List<Map<String, dynamic>>> streamUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList());
  }

  /// Stream of all bookings (for admin)
  Stream<List<Map<String, dynamic>>> streamAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList());
  }
}
