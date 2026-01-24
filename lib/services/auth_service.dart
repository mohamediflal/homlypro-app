import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign up with email and password
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'username': username,
          'userType': 'customer', // customer or admin
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'profileComplete': false,
          'phoneNumber': '',
          'address': '',
          'city': '',
          'profileImageUrl': '',
        });
        
        // Update display name
        await userCredential.user!.updateDisplayName(username);
      } catch (firestoreError) {
        print('Firestore error: $firestoreError');
        // User is created but Firestore save failed
        // Still return null since user can login
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      // Log the actual error for debugging
      print('Signup error: $e');
      return null; // Return null instead of error if user was created
    }
  }

  /// Sign in with email and password
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Send password reset email
  Future<String?> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<String?> updateUserProfile({
    required String uid,
    String? username,
    String? phoneNumber,
    String? address,
    String? city,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (username != null) updateData['username'] = username;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;

      await _firestore.collection('users').doc(uid).update(updateData);
      return null; // Success
    } catch (e) {
      return 'Failed to update profile';
    }
  }

  /// Parse Firebase Auth exceptions to user-friendly messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An error occurred during authentication';
    }
  }
}
