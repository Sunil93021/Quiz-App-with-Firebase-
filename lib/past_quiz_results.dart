import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PastResultsPage extends StatelessWidget {
  const PastResultsPage({super.key});

  Future<List<Map<String, dynamic>>> fetchUserResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('results')
            .doc(user.uid)
            .collection('quizzes')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  String formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Past Results"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load past results"));
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return const Center(child: Text("No past results found"));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final timestamp = result['timestamp'] as Timestamp?;
              final formattedDate =
                  timestamp != null ? formatTimestamp(timestamp) : "Unknown";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text("Quiz: ${result['quizName'] ?? 'Unknown'}"),
                  subtitle: Text(
                    "Score: ${result['score']}/${result['totalQuestions']}\n$formattedDate",
                    style: const TextStyle(height: 1.5),
                  ),
                  leading: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.teal,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
