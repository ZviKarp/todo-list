import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:todo_list/services/auth.dart';
import 'package:todo_list/services/sqflite.dart';
import 'package:todo_list/models/todo.dart';

/// this service hansles all the connections with firestore
class FirestoreService {
  final Firestore _db = Firestore.instance;

  Future<bool> updateTodo(Todo todo) async {
    String uid = await authService.getUid();
    if (uid == null) return false;
    await _db
        .collection('users')
        .document(uid)
        .collection('todos')
        .document(todo.id.toString())
        .setData({
      'title': todo.title,
      'desc': todo.desc,
      'geo': todo.geo,
      'dueDate': todo.dueDate,
      'createdOnDate': todo.createdOnDate,
      'done': todo.done,
      'synced': true
    });
    sqfliteService.todoWasSynced(todo.id);
    return true;
  }

  Future<bool> deleteTodo(int id) async {
    String uid = await authService.getUid();
    if (uid == null) return false;
    await _db
        .collection('users')
        .document(uid)
        .collection('todos')
        .document(id.toString())
        .delete();
    sqfliteService.todoWasSynced(id);
    return true;
  }

  Future<bool> updateTodosById(List<int> ids) async {
    if (ids.length < 1) return true;
    print(ids.toString() + "______________________________________");
    print(ids.length);
    ids.forEach((id) async {
      bool res = false;
      Todo todo = await sqfliteService.getTodo(id);
      if (todo == null) {
        res = await deleteTodo(id);
        if (!res) return false;
      } else {
        res = await updateTodo(todo);
        if (!res) return false;
      }
    });
    return true;
  }
}

final FirestoreService firestoreService = FirestoreService();
