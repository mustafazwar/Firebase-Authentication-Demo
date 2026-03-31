import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseintro/screens/update_todo_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/app_provider.dart';
import 'add_todo_screen.dart';
import 'login_screen.dart';

class RealtimeHomepage extends ConsumerStatefulWidget {
  const RealtimeHomepage({super.key});

  @override
  ConsumerState<RealtimeHomepage> createState() => _RealtimeHomepageState();
}

class _RealtimeHomepageState extends ConsumerState<RealtimeHomepage> {
  final fireRef = FirebaseFirestore.instance;
  final auth  =FirebaseAuth.instance;
  final _searchCnt = TextEditingController();
  String _searchText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(
            'Wellcome ${auth.currentUser!.email}',
          ),
        ),

      ),
      body: StreamBuilder(
          stream:_searchText.isNotEmpty ? fireRef.collection('todos').where('user_id',isEqualTo: auth.currentUser!.uid).orderBy('title')
              .where('title', isGreaterThanOrEqualTo: _searchText)
          .where('title', isLessThanOrEqualTo: _searchText + '\uf8ff').snapshots() : fireRef.collection('todos').where('user_id',isEqualTo: auth.currentUser!.uid).snapshots(),


          builder: (context, snapshot) {
        final alltodos;

        if (snapshot.hasError) {
          return InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: '${snapshot.error}'));
              },
              child: Center(child: Text('Error: ${snapshot.error}')));
        }
        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return Center(child: Text('No item found'));
        }

        if(snapshot.hasData){
          alltodos = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchCnt,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },

                  decoration: InputDecoration(
                    suffixIcon:_searchCnt.text.isNotEmpty ? IconButton(onPressed: () {
                      setState(() {
                        _searchText ='';
                      });
                      _searchCnt.clear();
                      FocusScope.of(context).unfocus();
                    }, icon: Icon(Icons.clear)):null,
                    labelText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: alltodos.length,
                  itemBuilder: (context, index) {
                    final todo = alltodos[index].data() as Map<String,dynamic>;
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
                              ref.read(todoProvider.notifier).doneTask(id: alltodos[index].id, isDone: value!);
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
                                      .deleteTodo(id: alltodos[index].id);

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
                                            uId: alltodos[index].id ,
                                            uDesc: todo['description'],
                                          ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ],
                          ),
                        ));

                },),
              ),
            ],
          );

        }


        return Center(child: CircularProgressIndicator.adaptive());
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen()),
          );
        },
        child: Icon(CupertinoIcons.add),
      ),
    );
  }
}
