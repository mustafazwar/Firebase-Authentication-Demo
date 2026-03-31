import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseintro/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final myKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;

  void registerUser() async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Screen')),
      body: Form(
        key: myKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This Field must not be Empty';
                  } else if (!value.contains('@')) {
                    return 'Write Email like abc@gmail.com';
                  }

                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: password,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This Field must not be Empty';
                  }

                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (myKey.currentState!.validate()) {
                  registerUser();
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
