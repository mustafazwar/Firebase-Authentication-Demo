import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseintro/provider/app_provider.dart';
import 'package:firebaseintro/screens/add_todo_screen.dart';
import 'package:firebaseintro/screens/ai_model_screen.dart';
import 'package:firebaseintro/screens/login_screen.dart';
import 'package:firebaseintro/screens/update_todo_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  final _searchCnt = TextEditingController();
  
  
  @override
  Widget build(BuildContext context) {
    final allTodos = ref.watch(todoProvider);
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(
            'Wellcome ${FirebaseAuth.instance.currentUser!.email}',
          ),
        ),
        leading: IconButton(
          onPressed: () {
            showDialog(context: context, builder: (context) => AlertDialog(
              title: Text('Logout this Account ?'),
              icon: Text(FirebaseAuth.instance.currentUser!.email as String),
              actions: [
                TextButton(onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                }, child: Text('ok')),
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
              ],
            ),);
          },
          icon: Icon(Icons.logout_outlined ,color: Colors.red,),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCnt,
              onChanged: (value) {
                setState(() {
                  ref.read(todoProvider.notifier).searchTodo(value);
                });
              },
              
              decoration: InputDecoration(
                suffixIcon:_searchCnt.text.isNotEmpty ? IconButton(onPressed: () {
                     _searchCnt.clear();
                     FocusScope.of(context).unfocus();
                     ref.read(todoProvider.notifier).searchTodo('');
                }, icon: Icon(Icons.clear)):null,
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: allTodos.isEmpty
                ? Center(child: Text('Add Todos'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: allTodos.length,
                          itemBuilder: (context, index) {
                            final todo = allTodos[index];
                            final currentCheck = todo['done'] ?? false;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                tileColor: const Color.fromARGB(
                                  255,
                                  220,
                                  220,
                                  220,
                                ),
                                leading: Checkbox.adaptive(value: currentCheck, onChanged: (value) {
                                  setState(() {
                                    ref.read(todoProvider.notifier).doneTask(id: todo['id'], isDone: value!);
                                  });
                                },),
                                title: Text(todo['title'] ,style: TextStyle(decoration:currentCheck ? TextDecoration.lineThrough:null , fontStyle:currentCheck ? FontStyle.italic:null),),
                                subtitle: Text("\n ${todo['description']}",style: TextStyle(decoration:currentCheck ? TextDecoration.lineThrough:null , fontStyle:currentCheck ? FontStyle.italic:null),),
                                trailing: Row(
                                  mainAxisSize: .min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(todoProvider.notifier)
                                            .deleteTodo(id: todo['id']);

                                        setState(() {});
                                      },
                                      icon: Icon(
                                        CupertinoIcons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateTodoScreen(
                                                  uTitle: todo['title'],
                                                  uId: todo['id'],
                                                  uDesc: todo['description'],
                                                ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: .min,
        children: [
          ElevatedButton(
            onPressed: () async {
              ref.read(todoProvider.notifier).fetchData();

              Future.delayed(Duration(seconds: 2), () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Data is UptoDate')));
              });
            },
            child: Icon(CupertinoIcons.refresh),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AiModelScreen()),
              );
            },
            child: Icon(CupertinoIcons.person),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTodoScreen()),
              );
            },
            child: Icon(CupertinoIcons.add),
          ),
        ],
      ),
    );
  }
}
