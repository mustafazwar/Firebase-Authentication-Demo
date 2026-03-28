import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseintro/homescreen.dart';
import 'package:firebaseintro/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final myKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  late FirebaseApp myApp;
  final auth = FirebaseAuth.instance;

  void loginUser() async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
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
      appBar: AppBar(title: Text('Login Screen')),
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
            Row(
              mainAxisSize: .min,
              children: [
                Text('Create New Account ?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                singInWithGoogle();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromARGB(255, 212, 211, 211),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      SvgPicture.asset('assets/svgs/google-icon.svg'),
                      SizedBox(width: 10),
                      Text('Continue With Google'),
                    ],
                  ),
                ),
              ),
            ),

            Row(
              mainAxisSize: .min,
              children: [
                Text('Forget Account Password ?'),
                TextButton(
                  onPressed: () {
                    final emailCnt = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Column(
                          mainAxisSize: .min,
                          children: [
                            Text('Enter Registerd Email'),
                            TextField(
                              controller: emailCnt,
                              decoration: InputDecoration(labelText: 'Email'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              try {
                                await auth.sendPasswordResetEmail(
                                  email: emailCnt.text.trim(),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Cheack Your Email')),
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            child: Text('Ok'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Forget',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (myKey.currentState!.validate()) {
                  loginUser();
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void singInWithGoogle() async {
    String webKitId =
        '711393403861-8rie35ck78e7kshaevtp1oqrftme9a61.apps.googleusercontent.com';

    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(serverClientId: webKitId);
      final account = await signIn.authenticate();
      final userAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: userAuth.idToken,
      );

      // After this add SHA-1 and SHA-256 in firebase fingerprint genrate via this bellow comand
      //paste this comand in cmd              ./gradlew signingReport

      await auth.signInWithCredential(credential);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
