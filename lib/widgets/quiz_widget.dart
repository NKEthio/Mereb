import 'package:flutter/material.dart';
import '../models/models.dart';

class QuizWidget extends StatefulWidget {
  final QuizContent quiz;

  const QuizWidget({super.key, required this.quiz});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final Map<int, int> _selectedOptions = {};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.quiz.questions.asMap().entries.map((entry) {
          final qIndex = entry.key;
          final question = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q${qIndex + 1}: ${question.question}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...question.options.asMap().entries.map((oEntry) {
                final oIndex = oEntry.key;
                final option = oEntry.value;
                Color? textColor;
                if (_submitted) {
                  if (oIndex == question.correctOptionIndex) {
                    textColor = Colors.green;
                  } else if (_selectedOptions[qIndex] == oIndex) {
                    textColor = Colors.red;
                  }
                }
                return RadioListTile<int>(
                  title: Text(option, style: TextStyle(color: textColor)),
                  value: oIndex,
                  groupValue: _selectedOptions[qIndex],
                  onChanged: _submitted
                      ? null
                      : (val) {
                          setState(() {
                            _selectedOptions[qIndex] = val!;
                          });
                        },
                );
              }),
              const Divider(),
            ],
          );
        }),
        if (!_submitted)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _submitted = true;
              });
            },
            child: const Text('Submit Quiz'),
          )
        else
          Text(
            'Score: ${_calculateScore()}/${widget.quiz.questions.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  int _calculateScore() {
    int score = 0;
    widget.quiz.questions.asMap().forEach((index, question) {
      if (_selectedOptions[index] == question.correctOptionIndex) {
        score++;
      }
    });
    return score;
  }
}
