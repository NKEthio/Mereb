import '../models/models.dart';
import 'database_service.dart';

class DataSeeder {
  final DatabaseService _db = DatabaseService();

  Future<void> seedSampleCourses(String instructorId, String instructorName) async {
    final courses = [
      Course(
        id: '',
        title: 'AI Fundamentals',
        description: 'Learn the basics of Artificial Intelligence and its applications.',
        instructorId: instructorId,
        instructorName: instructorName,
        youtubeUrl: 'https://www.youtube.com/watch?v=ad79nYk2keg',
        cost: 'Free',
        duration: '4 hours',
        level: 'Beginner',
        lessonsList: [
          Lesson(
            id: 'ai_lesson_1',
            title: 'Introduction to AI',
            content: [
              TextContent(text: 'Artificial Intelligence (AI) is the simulation of human intelligence processes by machines, especially computer systems.'),
              VideoContent(videoUrl: 'https://www.youtube.com/watch?v=2ePf9rue1Ao'),
              QuizContent(questions: [
                QuizQuestion(
                  question: 'What does AI stand for?',
                  options: ['Artificial Intelligence', 'Automated Interface', 'Advanced Integration'],
                  correctOptionIndex: 0,
                ),
              ]),
            ],
          ),
        ],
      ),
      Course(
        id: '',
        title: 'Biology: Cell Structure',
        description: 'Discover the fascinating world of cells, the building blocks of life.',
        instructorId: instructorId,
        instructorName: instructorName,
        youtubeUrl: 'https://www.youtube.com/watch?v=URUJD5NEXC8',
        cost: 'Free',
        duration: '3 hours',
        level: 'Intermediate',
        lessonsList: [
          Lesson(
            id: 'bio_lesson_1',
            title: 'Cell Organelles',
            content: [
              TextContent(text: 'Cells contain various organelles that perform specific functions necessary for life.'),
              VideoContent(videoUrl: 'https://www.youtube.com/watch?v=8IlzKri08t0'),
              QuizContent(questions: [
                QuizQuestion(
                  question: 'Which organelle is known as the powerhouse of the cell?',
                  options: ['Nucleus', 'Mitochondria', 'Ribosome'],
                  correctOptionIndex: 1,
                ),
              ]),
            ],
          ),
        ],
      ),
      Course(
        id: '',
        title: 'English: Mastering Tenses',
        description: 'Improve your English by mastering all verb tenses with ease.',
        instructorId: instructorId,
        instructorName: instructorName,
        youtubeUrl: 'https://www.youtube.com/watch?v=84jVz0D-KkY',
        cost: r'$19.99',
        duration: '5 hours',
        level: 'All Levels',
        lessonsList: [
          Lesson(
            id: 'eng_lesson_1',
            title: 'Present Simple vs Present Continuous',
            content: [
              TextContent(text: 'Understand when to use the Present Simple and when to use the Present Continuous tense.'),
              VideoContent(videoUrl: 'https://www.youtube.com/watch?v=XpZ6vT_tWn8'),
              QuizContent(questions: [
                QuizQuestion(
                  question: 'Which tense do we use for habits and routines?',
                  options: ['Present Continuous', 'Present Simple', 'Past Simple'],
                  correctOptionIndex: 1,
                ),
              ]),
            ],
          ),
        ],
      ),
    ];

    for (var course in courses) {
      await _db.createCourse(course);
    }
  }
}
