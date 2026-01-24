import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetup {
  static const String defaultAdminEmail = 'admin@homlypro.com';
  static const String defaultAdminPassword = 'admin123456';
  
  /// Create default admin account if it doesn't exist
  static Future<void> createDefaultAdminIfNeeded() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Check if admin user exists in Firestore
      final QuerySnapshot adminQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: defaultAdminEmail)
          .limit(1)
          .get();
      
      if (adminQuery.docs.isNotEmpty) {
        final adminDoc = adminQuery.docs.first.data() as Map<String, dynamic>;
        if (adminDoc['userType'] == 'admin') {
          return;
        }
      }
      
      // Try to create admin account
      try {
        final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: defaultAdminEmail,
          password: defaultAdminPassword,
        );
        
        // Create admin user document in Firestore
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': defaultAdminEmail,
          'username': 'Admin',
          'userType': 'admin',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'profileComplete': true,
          'phoneNumber': '',
          'address': '',
          'city': '',
          'profileImageUrl': '',
        });
        
        // Sign out after creating admin
        await auth.signOut();
        
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Get the user by email and update to admin if needed
          final signInMethods = await auth.fetchSignInMethodsForEmail(defaultAdminEmail);
          if (signInMethods.isNotEmpty) {
            // Try to sign in and update
            try {
              final UserCredential userCredential = await auth.signInWithEmailAndPassword(
                email: defaultAdminEmail,
                password: defaultAdminPassword,
              );
              
              // Update user type to admin
              await firestore.collection('users').doc(userCredential.user!.uid).set({
                'uid': userCredential.user!.uid,
                'email': defaultAdminEmail,
                'username': 'Admin',
                'userType': 'admin',
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              }, SetOptions(merge: true));
              
              await auth.signOut();
            } catch (signInError) {
              // Silently fail
            }
          }
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }
  
  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        return false;
      }
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!doc.exists) {
        return false;
      }
      
      final data = doc.data();
      final userType = data?['userType'];
      
      return userType == 'admin';
    } catch (e) {
      return false;
    }
  }
}
