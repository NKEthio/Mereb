import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'services/database_service.dart';
import 'lesson_editor_page.dart';

class CourseFormPage extends StatefulWidget {
  final Course? course;

  const CourseFormPage({super.key, this.course});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _youtubeUrlController;
  late TextEditingController _costController;
  late TextEditingController _durationController;
  late TextEditingController _levelController;
  List<Lesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _youtubeUrlController = TextEditingController(text: widget.course?.youtubeUrl ?? '');
    _costController = TextEditingController(text: widget.course?.cost ?? 'Free');
    _durationController = TextEditingController(text: widget.course?.duration ?? 'N/A');
    _levelController = TextEditingController(text: widget.course?.level ?? 'Beginner');
    _lessons = widget.course?.lessonsList.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    _costController.dispose();
    _durationController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final appUser = context.read<AppUser>();
      final db = context.read<DatabaseService>();

      final course = Course(
        id: widget.course?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        instructorId: appUser.id,
        instructorName: appUser.displayName ?? appUser.email,
        youtubeUrl: _youtubeUrlController.text,
        lessonsList: _lessons,
        cost: _costController.text,
        duration: _durationController.text,
        level: _levelController.text,
      );

      if (widget.course == null) {
        await db.createCourse(course);
      } else {
        await db.updateCourse(course);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  void _addLesson() async {
    final Lesson? newLesson = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LessonEditorPage()),
    );
    if (newLesson != null) {
      setState(() {
        _lessons.add(newLesson);
      });
    }
  }

  void _editLesson(int index) async {
    final Lesson? updatedLesson = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonEditorPage(lesson: _lessons[index])),
    );
    if (updatedLesson != null) {
      setState(() {
        _lessons[index] = updatedLesson;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Course Title'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Cost'),
            ),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration'),
            ),
            TextFormField(
              controller: _levelController,
              decoration: const InputDecoration(labelText: 'Level'),
            ),
            TextFormField(
              controller: _youtubeUrlController,
              decoration: const InputDecoration(labelText: 'Intro Video (YouTube URL)'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lessons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: _addLesson),
              ],
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lessons.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _lessons.removeAt(oldIndex);
                  _lessons.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                return ListTile(
                  key: ValueKey(lesson.id),
                  title: Text(lesson.title),
                  subtitle: Text('${lesson.content.length} content blocks'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editLesson(index)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => _lessons.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
