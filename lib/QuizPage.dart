import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result_page.dart';
import 'quizQuestion.dart';

class Quizpage extends StatefulWidget {
  final String name;
  const Quizpage({super.key, required this.name});

  @override
  State<Quizpage> createState() => _QuizpageState();
}

class _QuizpageState extends State<Quizpage> {
  List<Map<String, dynamic>> questionsData = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  bool showAnswer = false;
  bool hasAnswered = false;
  int remainingSeconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    remainingSeconds = 30;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        t.cancel();
        revealAnswer();
      }
    });
  }

  Future<void> fetchQuestions() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('quizzes')
              .doc(widget.name)
              .collection('questions')
              .get();
      questionsData = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() => isLoading = false);
      startTimer();
    } catch (e) {
      print("Fetch error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load questions")));
    }
  }

  void checkAnswer(String selectedAnswer) {
    if (hasAnswered) return;

    final correctIndex = questionsData[currentQuestionIndex]['correctIndex'];
    final correctAnswer =
        questionsData[currentQuestionIndex]['options'][correctIndex];

    if (selectedAnswer == correctAnswer) {
      score++;
    }

    setState(() {
      showAnswer = true;
      hasAnswered = true;
    });

    timer?.cancel();
  }

  void revealAnswer() {
    if (!hasAnswered) {
      setState(() {
        showAnswer = true;
        hasAnswered = true;
      });
    }
  }

  Future<void> onNext() async {
    if (!hasAnswered) return;

    if (currentQuestionIndex + 1 < questionsData.length) {
      setState(() {
        currentQuestionIndex++;
        showAnswer = false;
        hasAnswered = false;
      });
      startTimer();
    } else {
      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance
          .collection('leaderboards')
          .doc(widget.name)
          .collection('entries')
          .add({
            'userId': user.uid,
            'userName': user.displayName ?? "Anonymous",
            'score': score,
            'timestamp': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('results')
          .doc(user.uid)
          .collection('quizzes')
          .add({
            'quizName': widget.name,
            'score': score,
            'totalQuestions': questionsData.length,
            'timestamp': FieldValue.serverTimestamp(),
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultPage(
                score: score,
                totalQuestions: questionsData.length,
                quizName: widget.name,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : questionsData.isEmpty
              ? Center(child: Text("No questions found"))
              : QuizQuestion(
                question: questionsData[currentQuestionIndex]['question'],
                options: List<String>.from(
                  questionsData[currentQuestionIndex]['options'],
                ),
                correctAnswer:
                    questionsData[currentQuestionIndex]['options'][questionsData[currentQuestionIndex]['correctIndex']],
                onAnswerSelected: checkAnswer,
                onNext: onNext,
                showAnswer: showAnswer,
                remainingSeconds: remainingSeconds,
              ),
    );
  }
}
