import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseServiceAll {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Initialize Firebase
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Add data to Firestore
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).add(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get data from Firestore
  Future<QuerySnapshot> getData(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      rethrow;
    }
  }

  // Update data in Firestore
  Future<void> updateData(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get a specific document from Firestore
  Future<DocumentSnapshot> getDocument(String collection, String? docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      rethrow;
    }
  }

  //Search for documents in a collection
  Future<QuerySnapshot> searchDocuments(
    String collection,
    String field,
    String? value,
  ) async {
    try {
      return await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  // Delete data from Firestore
  Future<void> deleteData(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // O utilizador cancelou
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Booking: criar agendamento
  Future<void> createBooking(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('agendamentos').add(data);
    } catch (e) {
      rethrow;
    }
  }

  // Booking: buscar agendamentos de um usuário
  Stream<QuerySnapshot> getUserBookings(String userId) {
    return _firestore
        .collection('agendamentos')
        .where('userId', isEqualTo: userId)
        .orderBy('dataHora', descending: false)
        .snapshots();
  }

  // Booking: buscar agendamentos de um negócio
  Stream<QuerySnapshot> getBusinessBookings(String negocioId) {
    return _firestore
        .collection('agendamentos')
        .where('negocioId', isEqualTo: negocioId)
        .orderBy('dataHora', descending: false)
        .snapshots();
  }

  // Upload de imagem para o Firebase Storage
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await storageRef.putFile(imageFile);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }
}
