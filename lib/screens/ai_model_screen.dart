import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AiModelScreen extends StatefulWidget {
  const AiModelScreen({super.key});

  @override
  State<AiModelScreen> createState() => _AiModelScreenState();
}

class _AiModelScreenState extends State<AiModelScreen> {
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3-flash-preview',
  );
  final input = TextEditingController();

  String response = '';
  bool isLoading = false;

  @override
  void dispose() {
    input.dispose(); // Always clean up your controllers!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat With Me')),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: response.isEmpty
                        ? Center(child: Text('Hello There'))
                        : SingleChildScrollView(child: Text(response)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: input,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              labelText: "Enter your Prompt",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        input.text.trim().isNotEmpty
                            ? IconButton.outlined(
                                onPressed: () async {
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    final prompt = [Content.text(input.text)];
                                    final aiResponse = await model
                                        .generateContent(prompt);
                                    response +=
                                        '${aiResponse.text} \n \n \n   ';
                                    setState(() {
                                      isLoading = false;
                                    });
                                    input.clear();
                                    print(aiResponse.text);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                },
                                icon: Icon(CupertinoIcons.arrow_up),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
