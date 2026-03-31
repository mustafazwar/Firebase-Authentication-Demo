import 'package:firebaseintro/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _myKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final desc = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    title.dispose();
    desc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Todos')),
      body: Form(
        key: _myKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: title,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This Field must not be Empty.";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: desc,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 30),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_myKey.currentState != null) {
                        ref
                            .read(todoProvider.notifier)
                            .addTodo(title: title.text, desc: desc.text);
                      }
                      Navigator.pop(context);

                      title.clear();
                      desc.clear();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      foregroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 14, 14, 14),
                      ),
                    ),
                    child: Text('Add', style: TextStyle(fontSize: 30)),
                  ),
                ),
                SizedBox(width: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
