import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class TodoRemoteDatasource {
  final FirebaseFirestore _firestore;

  final String userId;

  TodoRemoteDatasource({required this.userId, FirebaseFirestore? firestore})
  : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String,dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('todos');


  Future<void> pushTodo(TodoModel todo) async {
    await _collection.doc(todo.id).set(todo.toFirestoreMap());
  }

  Future<void> deleteTodo(String id) async {
    await _collection.doc(id).delete();
  }


  Future<List<TodoModel>> fetchAllTodos() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(
            (doc) => TodoModel.fromFirestore
              (doc.id, doc.data())).toList();

  }

  Stream<List<TodoModel>> watchTodos() {
    return _collection.snapshots().map(
          (snap) => snap.docs.map((doc) =>
              TodoModel.fromFirestore(doc.id, doc.data())).
          toList(),
    );
  }



}