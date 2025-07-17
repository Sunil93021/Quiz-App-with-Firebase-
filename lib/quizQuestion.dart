import 'package:flutter/material.dart';

class QuizQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final VoidCallback onNext;
  final String correctAnswer;
  final Function(String selectedAnswer) onAnswerSelected;
  final bool showAnswer;
  final int remainingSeconds;

  const QuizQuestion({
    super.key,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.onNext,
    required this.onAnswerSelected,
    required this.showAnswer,
    required this.remainingSeconds,
  });

  @override
  State<QuizQuestion> createState() => _QuizQuestionState();
}

class _QuizQuestionState extends State<QuizQuestion> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              widget.question,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Time Left: ${widget.remainingSeconds}s",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 20),
            ...widget.options.map((option) {
              Color? tileColor =
                  widget.showAnswer
                      ? option == widget.correctAnswer
                          ? Colors.green.shade100
                          : option == _selectedOption
                          ? Colors.red.shade100
                          : null
                      : null;

              return RadioListTile<String>(
                title: Text(option),
                value: option,
                tileColor: tileColor,
                groupValue: _selectedOption,
                activeColor: colorScheme.primary,
                onChanged:
                    widget.showAnswer
                        ? null
                        : (value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  widget.showAnswer && _selectedOption != null
                      ? widget.onNext
                      : _selectedOption != null
                      ? () => widget.onAnswerSelected(_selectedOption!)
                      : null,
              child: Text(widget.showAnswer ? "Next" : "Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
