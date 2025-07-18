import 'package:flutter/material.dart';
import 'package:quiz_app/HomePage.dart';
import 'LoginPage.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final user = FirebaseAuth.instance.currentUser;
  runApp(
    MaterialApp(
      title: "Quiz App",
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // home: QuizQuestion(
      //   question: "What is the capital of India?",
      //   options: ["Delhi", "Mumbai", "Kolkata", "Chennai"],
      //   onNext: () {},
      // ),
      home: user != null ? HomeWidget() : LoginWidget(),
    ),
  );
}
