import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

List<String> Questions = [];
List<List<String>> Options = [];
List<int> CorrectOptions = [];

class Hostquiz extends StatefulWidget {
  const Hostquiz({super.key});

  @override
  State<Hostquiz> createState() => _HostquizState();
}

class _HostquizState extends State<Hostquiz> {
  final TextEditingController _QuizName = TextEditingController();
  final hostName = FirebaseAuth.instance.currentUser!.displayName;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Host a Quiz"),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextFormField(
                controller: _QuizName,
                decoration: InputDecoration(
                  label: Text("Quiz Name"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  String quizName = _QuizName.text.trim();
                  if (quizName.isEmpty || hostName!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill Quiz Name & Host Name'),
                      ),
                    );
                  } else {
                    print("Quiz Name: $quizName, Host Name: $hostName");
                    await FirebaseFirestore.instance
                        .collection('quizzes')
                        .doc(quizName)
                        .set({
                          'createdBy': hostName,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddQuestion(
                              quizName: quizName,
                              hostName: hostName?.toString() ?? '',
                            ),
                      ),
                    );
                  }
                },
                child: Text("Add Question"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddQuestion extends StatefulWidget {
  final String quizName;
  final String hostName;
  AddQuestion({super.key, required this.quizName, required this.hostName});

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  late String quizName;
  late String hostName;
  @override
  void initState() {
    super.initState();
    quizName = widget.quizName;
    hostName = widget.hostName;
  }

  // Controllers for question and options
  final TextEditingController _Question = TextEditingController();
  final TextEditingController _option1 = TextEditingController();
  final TextEditingController _option2 = TextEditingController();
  final TextEditingController _option3 = TextEditingController();
  final TextEditingController _option4 = TextEditingController();

  int? correctOption; // selected correct option (1-4)

  // Save current question & clear fields
  void saveQuestion() async {
    final questionText = _Question.text.trim();
    final options1 = _option1.text.trim();
    final options2 = _option2.text.trim();
    final options3 = _option3.text.trim();
    final options4 = _option4.text.trim();
    if (questionText.isEmpty ||
        options1.isEmpty ||
        options2.isEmpty ||
        options3.isEmpty ||
        options4.isEmpty ||
        correctOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and select correct option'),
        ),
      );
    } else {
      try {
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(quizName)
            .collection('questions')
            .add({
              'question': questionText,
              'options': [options1, options2, options3, options4],
              'correctIndex': correctOption! - 1,
              'createdBy': hostName,
              'timestamp': FieldValue.serverTimestamp(),
            });

        _Question.clear();
        _option1.clear();
        _option2.clear();
        _option3.clear();
        _option4.clear();
        setState(() {
          correctOption = null;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Question added!')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding question: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Question"),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 40),
            CustomFromField(label: "Question", controller: _Question),
            SizedBox(height: 40),
            CustomFromField(label: "Option1", controller: _option1),
            SizedBox(height: 40),
            CustomFromField(label: "Option2", controller: _option2),
            SizedBox(height: 40),
            CustomFromField(label: "Option3", controller: _option3),
            SizedBox(height: 40),
            CustomFromField(label: "Option4", controller: _option4),
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              constraints: const BoxConstraints(maxWidth: 400),
              child: DropdownButtonFormField<int>(
                value: correctOption,
                decoration: InputDecoration(
                  label: Text("Correct Option"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                items:
                    [1, 2, 3, 4].map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("Option $value"),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    correctOption = value;
                  });
                },
              ),
            ),
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.fromLTRB(30, 10, 10, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      saveQuestion();
                    },
                    child: Text("Add Next"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveQuestion();
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFromField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  CustomFromField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormField(
        maxLines: label == "Question" ? 4 : 1,
        controller: controller,
        decoration: InputDecoration(
          label: Text(label),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
