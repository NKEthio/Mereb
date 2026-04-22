import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'services/database_service.dart';

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
  late TextEditingController _lessonsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _youtubeUrlController = TextEditingController(text: widget.course?.youtubeUrl ?? '');
    _lessonsController = TextEditingController(text: widget.course?.lessons.toString() ?? '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    _lessonsController.dispose();
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
        lessons: int.tryParse(_lessonsController.text) ?? 0,
      );

      if (widget.course == null) {
        await db.createCourse(course);
      } else {
        await db.updateCourse(course);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _youtubeUrlController,
              decoration: const InputDecoration(labelText: 'YouTube URL'),
            ),
            TextFormField(
              controller: _lessonsController,
              decoration: const InputDecoration(labelText: 'Number of Lessons'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
