import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreServiceUsers {
  // get collection of notes
  final CollectionReference users = FirebaseFirestore.instance.collection(
    "users",
  );
  // CREATE a new note
  Future<void> createUserDocument(String uid,String nome, String email, String? tipoUser) async {
    users.doc(uid).set({
      "uid": uid,
      "nome": nome,
      "email": email,
      "tipoUser": tipoUser,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // READ
  /**
 * Podes adicionar desta forma
 * final notesStream=notes.orderBy("createdAt", descending: true).snapshots();
 * return notesStream;( Para reutilização provalmente)
 */

  Stream<QuerySnapshot> getUser() {
    return users.orderBy("createdAt", descending: true).snapshots();
  }

  // UPDATE
  /*Future<void> updateUsers(String noteId, String description) async {
    business.doc(noteId).update({
      "description": description,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // DELETE
  Future<void> deleteNote(String noteId) async {
    notes.doc(noteId).delete();
  }
*/
}