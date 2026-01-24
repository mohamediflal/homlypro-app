import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugAdminPage extends StatefulWidget {
  const DebugAdminPage({Key? key}) : super(key: key);

  @override
  State<DebugAdminPage> createState() => _DebugAdminPageState();
}

class _DebugAdminPageState extends State<DebugAdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _debugLog = 'Waiting for action...\n';

  void _addLog(String message) {
    setState(() {
      _debugLog += '$message\n';
    });
    print(message);
  }

  Future<void> _checkCurrentUser() async {
    _addLog('🔍 Checking current user...');
    
    final user = _auth.currentUser;
    if (user == null) {
      _addLog('❌ No user logged in');
      return;
    }

    _addLog('✅ User UID: ${user.uid}');
    _addLog('✅ User Email: ${user.email}');

    // Check Firestore document
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        _addLog('❌ Firestore document does NOT exist');
        _addLog('📝 Document ID needed: ${user.uid}');
        return;
      }

      final data = doc.data();
      _addLog('✅ Firestore document exists');
      _addLog('📋 Data: $data');
      _addLog('👤 userType: ${data?['userType']}');
    } catch (e) {
      _addLog('❌ Error reading Firestore: $e');
    }
  }

  Future<void> _makeUserAdmin() async {
    _addLog('🔄 Making current user admin...');
    
    final user = _auth.currentUser;
    if (user == null) {
      _addLog('❌ No user logged in');
      return;
    }

    try {
      // First check if document exists
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        _addLog('📝 Creating new admin document...');
        // Create document
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
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
        _addLog('✅ Admin document created!');
      } else {
        _addLog('📝 Updating existing document to admin...');
        // Update document
        await _firestore.collection('users').doc(user.uid).update({
          'userType': 'admin',
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
        _addLog('✅ User updated to admin!');
      }

      // Verify
      await Future.delayed(const Duration(milliseconds: 500));
      _addLog('🔍 Verifying...');
      final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
      final updatedData = updatedDoc.data();
      _addLog('✅ Verified userType: ${updatedData?['userType']}');
      _addLog('✨ Ready to login again!');
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Admin Setup'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _debugLog,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _checkCurrentUser,
                  icon: const Icon(Icons.search),
                  label: const Text('Check Current User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _makeUserAdmin,
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Make Current User Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
