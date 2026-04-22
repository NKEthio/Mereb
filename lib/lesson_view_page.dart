import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'models/models.dart';
import 'widgets/quiz_widget.dart';

class LessonViewPage extends StatefulWidget {
  final Lesson lesson;

  const LessonViewPage({super.key, required this.lesson});

  @override
  State<LessonViewPage> createState() => _LessonViewPageState();
}

class _LessonViewPageState extends State<LessonViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.lesson.content.length,
        itemBuilder: (context, index) {
          final block = widget.lesson.content[index];
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
        },
      ),
    );
  }
}
