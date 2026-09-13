import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';

class NoteRemoteDatasource {
  final FirebaseFirestore _firestore;
  final String userId;

  NoteRemoteDatasource({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('notes');

  Future<void> pushNote(NoteModel note) async {
    await _collection.doc(note.id).set(note.toFirestoreMap());
  }

  Future<void> deleteNote(String id) async {
    await _collection.doc(id).delete();
  }

  Future<List<NoteModel>> fetchAllNotes() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => NoteModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Stream<List<NoteModel>> watchNotes() {
    return _collection.snapshots().map(
          (snap) => snap.docs
          .map((doc) => NoteModel.fromFirestore(doc.id, doc.data()))
          .toList(),
    );
  }
}
