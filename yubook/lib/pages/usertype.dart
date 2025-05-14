import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserTypePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final username = args?['username'] ?? 'Unknown';
    final email = args?['email'] ?? 'Unknown';
    final User? currentUser=FirebaseAuth.instance.currentUser;
    final uid = args?['uid'] ?? 'Unknown'; // Ensure UID is passed from the registration page

print(uid);
    // Function to update user type in Firestore
    Future<void> updateUserType(String userType) async {
      try {
        // Query Firestore to find the document with the matching email
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          final docId = querySnapshot.docs.first.id;

          // Update the user type in Firestore
          await _firestore.collection('users').doc(docId).update({
            'tipoUser': userType,
          });

          print('User type updated to $userType');
        } else {
          print('No user found with the provided email.');
        }
      } catch (e) {
        print('Failed to update user type: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha o Tipo de Usuário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Que tipo de usuário você quer ser?',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Update user type to "Cliente" in Firestore
                await updateUserType('Cliente');
                // Navigate to Cliente's home page
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home_page');
              },
              child: const Text('cliente'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Update user type to "Business" in Firestore
                await updateUserType('gestor');
                // Navigate to Business form page
               
                Navigator.pushNamed(context, '/add_business_form');
              },
              child: const Text('Business'),
            ),
          ],
        ),
      ),
    );
  }
}