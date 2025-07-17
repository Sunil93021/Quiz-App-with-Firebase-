import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  final String quizName;
  const LeaderboardPage({super.key, required this.quizName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Leaderboard: $quizName"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('leaderboards')
                .doc(quizName)
                .collection('entries')
                .orderBy('score', descending: true)
                .limit(10) // Top 10
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No leaderboard data yet"));
          }

          final entries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final data = entries[index].data() as Map<String, dynamic>;
              final score = data['score'] ?? 0;
              final name = data['userName'] ?? 'Anonymous';

              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text("User: $name"),
                trailing: Text("Score: $score"),
              );
            },
          );
        },
      ),
    );
  }
}
