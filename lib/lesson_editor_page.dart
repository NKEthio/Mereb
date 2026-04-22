import 'package:flutter/material.dart';
import 'models/models.dart';

class LessonEditorPage extends StatefulWidget {
  final Lesson? lesson;

  const LessonEditorPage({super.key, this.lesson});

  @override
  State<LessonEditorPage> createState() => _LessonEditorPageState();
}

class _LessonEditorPageState extends State<LessonEditorPage> {
  final _titleController = TextEditingController();
  final List<ContentBlock> _contentBlocks = [];

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _titleController.text = widget.lesson!.title;
      _contentBlocks.addAll(widget.lesson!.content);
    }
  }

  void _addTextBlock() {
    setState(() {
      _contentBlocks.add(TextContent(text: ''));
    });
  }

  void _addVideoBlock() {
    setState(() {
      _contentBlocks.add(VideoContent(videoUrl: ''));
    });
  }

  void _addQuizBlock() {
    setState(() {
      _contentBlocks.add(QuizContent(questions: []));
    });
  }

  void _save() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a lesson title')),
      );
      return;
    }
    final lesson = Lesson(
      id: widget.lesson?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentBlocks,
    );
    Navigator.pop(context, lesson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson == null ? 'Add Lesson' : 'Edit Lesson'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Lesson Title'),
          ),
          const SizedBox(height: 20),
          const Text('Content Blocks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._contentBlocks.asMap().entries.map((entry) {
            final index = entry.key;
            final block = entry.value;
            return _buildContentBlockEditor(block, index);
          }),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(onPressed: _addTextBlock, icon: const Icon(Icons.text_fields), label: const Text('Text')),
              ElevatedButton.icon(onPressed: _addVideoBlock, icon: const Icon(Icons.video_library), label: const Text('Video')),
              ElevatedButton.icon(onPressed: _addQuizBlock, icon: const Icon(Icons.quiz), label: const Text('Quiz')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentBlockEditor(ContentBlock block, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(block.type.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _contentBlocks.removeAt(index)),
                ),
              ],
            ),
            if (block is TextContent)
              TextField(
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Enter text here...'),
                onChanged: (val) => _contentBlocks[index] = TextContent(text: val),
                controller: TextEditingController(text: block.text)..selection = TextSelection.collapsed(offset: block.text.length),
              )
            else if (block is VideoContent)
              TextField(
                decoration: const InputDecoration(hintText: 'Enter YouTube URL...'),
                onChanged: (val) => _contentBlocks[index] = VideoContent(videoUrl: val),
                controller: TextEditingController(text: block.videoUrl)..selection = TextSelection.collapsed(offset: block.videoUrl.length),
              )
            else if (block is QuizContent)
              _buildQuizEditor(block, index),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizEditor(QuizContent quiz, int index) {
    return Column(
      children: [
        ...quiz.questions.asMap().entries.map((qEntry) {
          final qIndex = qEntry.key;
          final question = qEntry.value;
          return Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Question ${qIndex + 1}'),
                onChanged: (val) {
                  quiz.questions[qIndex] = QuizQuestion(
                    question: val,
                    options: question.options,
                    correctOptionIndex: question.correctOptionIndex,
                  );
                },
                controller: TextEditingController(text: question.question)..selection = TextSelection.collapsed(offset: question.question.length),
              ),
              ...question.options.asMap().entries.map((oEntry) {
                final oIndex = oEntry.key;
                return Row(
                  children: [
                    Radio<int>(
                      value: oIndex,
                      groupValue: question.correctOptionIndex,
                      onChanged: (val) {
                        setState(() {
                          quiz.questions[qIndex] = QuizQuestion(
                            question: question.question,
                            options: question.options,
                            correctOptionIndex: val!,
                          );
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Option ${oIndex + 1}'),
                        onChanged: (val) {
                          question.options[oIndex] = val;
                        },
                        controller: TextEditingController(text: question.options[oIndex])..selection = TextSelection.collapsed(offset: question.options[oIndex].length),
                      ),
                    ),
                  ],
                );
              }),
              TextButton(
                onPressed: () {
                  setState(() {
                    question.options.add('');
                  });
                },
                child: const Text('Add Option'),
              ),
              const Divider(),
            ],
          );
        }),
        ElevatedButton(
          onPressed: () {
            setState(() {
              quiz.questions.add(QuizQuestion(question: '', options: ['', ''], correctOptionIndex: 0));
            });
          },
          child: const Text('Add Question'),
        ),
      ],
    );
  }
}
