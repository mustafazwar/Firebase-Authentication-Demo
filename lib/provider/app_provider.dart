import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

final reff = FirebaseFirestore.instance;
final todoProvider =
    StateNotifierProvider<TodoProv, List<Map<String, dynamic>>>(
      (ref) => TodoProv(),
    );

class TodoProv extends StateNotifier<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> allTodos = [];
  final auth = FirebaseAuth.instance;

  TodoProv() : super([]) {
    fetchData();
  }

  void fetchData() async {
    allTodos.clear();
    final snapshot = await reff
        .collection('todos')
        .where("user_id", isEqualTo: auth.currentUser!.uid)
        .get();

    allTodos = snapshot.docs.map((e) {
      return {"id": e.id, ...e.data()};
    }).toList();
    state = allTodos;
  }

  void addTodo({required String title, required String desc}) async {
    try {
      await reff.collection('todos').add({
        "title": title,
        "description": desc,
        "user_id": auth.currentUser!.uid,
        "timeStamp": DateTime.now().millisecondsSinceEpoch,
      });
      fetchData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void updateTodo({
    required String id,
    required String title,
    required String desc,
  }) async {
    try {
      await reff.collection('todos').doc(id).update({
        'title': title,
        'description': desc,
      });
      fetchData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void searchTodo(String value) {
    if (value.isNotEmpty) {
      state = allTodos
          .where((e) => e['title'].toString().toLowerCase().contains(value) || e['description'].toString().toLowerCase().contains(value))
          .toList();
    } else {
      state = allTodos;
    }
  }

  void deleteTodo({required String id}) async {
    try {
      await reff.collection('todos').doc(id).delete();
      fetchData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }


  void doneTask({required String id , required bool isDone})async{
    try {
      await reff.collection('todos').doc(id).update({'done':isDone});
      fetchData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
