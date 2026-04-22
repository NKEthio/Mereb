import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'models/models.dart';
import 'services/database_service.dart';
import 'widgets/quiz_widget.dart';

class LessonViewPage extends StatefulWidget {
  final Lesson lesson;
  final String courseId;

  const LessonViewPage({super.key, required this.lesson, required this.courseId});

  @override
  State<LessonViewPage> createState() => _LessonViewPageState();
}

class _LessonViewPageState extends State<LessonViewPage> {
  Future<void> _markAsComplete() async {
    final appUser = context.read<AppUser>();
    final db = context.read<DatabaseService>();

    try {
      await db.updateLessonProgress(appUser.id, widget.courseId, widget.lesson.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson marked as complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...widget.lesson.content.map((block) {
            if (block is TextContent) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(block.text, style: const TextStyle(fontSize: 16)),
              );
            } else if (block is VideoContent) {
              final videoId = YoutubePlayer.convertUrlToId(block.videoUrl);
              if (videoId != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: const YoutubePlayerFlags(autoPlay: false),
                    ),
                    showVideoProgressIndicator: true,
                  ),
                );
              }
              return const Text('Invalid video URL');
            } else if (block is QuizContent) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: QuizWidget(quiz: block),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _markAsComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Complete'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
