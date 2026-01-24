import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _employeesCollection = 'employees';
  final String _usersCollection = 'users';

  /// Sign in employee with email and password
  Future<Map<String, dynamic>> signInEmployee({
    required String email,
    required String password,
  }) async {
    try {
      // First authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Now query employee data (authenticated user can read)
      final employeeQuery = await _firestore
          .collection(_employeesCollection)
          .where('email', isEqualTo: email.trim())
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (employeeQuery.docs.isEmpty) {
        // User exists in Auth but not in employees collection
        await _auth.signOut();
        return {
          'success': false,
          'error': 'No employee account found with this email',
        };
      }

      final employeeDoc = employeeQuery.docs.first;
      final employeeData = employeeDoc.data();

      // Check if employee is active
      if (employeeData['isActive'] != true) {
        await _auth.signOut();
        return {
          'success': false,
          'error': 'Your employee account has been deactivated',
        };
      }

      return {
        'success': true,
        'employeeId': employeeDoc.id,
        'employeeData': employeeData,
        'uid': uid,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No employee account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This employee account has been disabled';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred: $e'};
    }
  }

  /// Register new employee
  Future<Map<String, dynamic>> registerEmployee({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String serviceType,
  }) async {
    try {
      // Check if email already exists in Firebase Auth (allowed without Firestore auth)
      final signInMethods =
          await _auth.fetchSignInMethodsForEmail(email.trim());
      if (signInMethods.isNotEmpty) {
        return {
          'success': false,
          'error': 'This email is already registered',
        };
      }

      // Create Firebase Auth user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Create employee document
      final employeeRef = await _firestore.collection(_employeesCollection).add({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'serviceType': serviceType,
        'isActive': true,
        'isAvailable': true,
        'currentBookingId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': uid, // Link to Firebase Auth user
      });

      // Also create a user document with employee type
      await _firestore.collection(_usersCollection).doc(uid).set({
        'uid': uid,
        'email': email.trim(),
        'username': name.trim(),
        'userType': 'employee',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileComplete': true,
        'phoneNumber': phone.trim(),
        'address': '',
        'city': '',
        'profileImageUrl': '',
        'fcmToken': '',
        'employeeId': employeeRef.id, // Link to employee document
      });

      return {
        'success': true,
        'employeeId': employeeRef.id,
        'uid': uid,
        'message': 'Employee account created successfully',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e'
      };
    }
  }

  /// Get current employee data
  Future<Map<String, dynamic>?> getCurrentEmployeeData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Find employee by uid
      final employeeQuery = await _firestore
          .collection(_employeesCollection)
          .where('uid', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (employeeQuery.docs.isEmpty) return null;

      final employeeDoc = employeeQuery.docs.first;
      return {
        'id': employeeDoc.id,
        ...employeeDoc.data(),
      };
    } catch (e) {
      print('Error getting employee data: $e');
      return null;
    }
  }

  /// Update employee profile
  Future<String?> updateEmployeeProfile({
    required String employeeId,
    String? name,
    String? phone,
    String? serviceType,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name.trim();
      if (phone != null) updateData['phone'] = phone.trim();
      if (serviceType != null) updateData['serviceType'] = serviceType;

      await _firestore
          .collection(_employeesCollection)
          .doc(employeeId)
          .update(updateData);

      return null; // Success
    } catch (e) {
      return 'Failed to update profile: $e';
    }
  }

  /// Update employee availability
  Future<String?> updateAvailability({
    required String employeeId,
    required bool isAvailable,
  }) async {
    try {
      await _firestore.collection(_employeesCollection).doc(employeeId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return 'Failed to update availability: $e';
    }
  }

  /// Check if current user is an employee
  Future<bool> isCurrentUserEmployee() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final userDoc =
          await _firestore.collection(_usersCollection).doc(currentUser.uid).get();

      if (!userDoc.exists) return false;

      return userDoc.data()?['userType'] == 'employee';
    } catch (e) {
      print('Error checking if user is employee: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
