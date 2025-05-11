import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  // get collection of notes
  final CollectionReference business = FirebaseFirestore.instance.collection(
    "business",
  );
  // CREATE a new note
  Future<void> addBusiness(String nome, String email, int telefone, String localizacao,String fotoPerfil, String gerenteId) async {
    business.add({
      "nome": nome,
      "email": email,
      "telefone": telefone,
      "localizacao": localizacao,
      "fotoPerfil": fotoPerfil,
      "gerenteId": gerenteId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // READ
  /**
 * Podes adicionar desta forma
 * final notesStream=notes.orderBy("createdAt", descending: true).snapshots();
 * return notesStream;( Para reutilização provalmente)
 */

  Stream<QuerySnapshot> getBusiness() {
    return business.orderBy("createdAt", descending: true).snapshots();
  }

  // UPDATE
  /*Future<void> updateNote(String noteId, String description) async {
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