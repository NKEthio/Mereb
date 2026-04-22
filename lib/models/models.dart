enum UserRole {
  student,
  teacher,
  admin,
}

class AppUser {
  final String id;
  final String email;
  final UserRole role;
  final String? displayName;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      id: documentId,
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (data['role'] ?? 'student'),
        orElse: () => UserRole.student,
      ),
      displayName: data['displayName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.name,
      'displayName': displayName,
    };
  }
}

enum ContentType { text, video, quiz }

abstract class ContentBlock {
  final ContentType type;
  ContentBlock({required this.type});
  Map<String, dynamic> toMap();
  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    final type = ContentType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => ContentType.text,
    );
    switch (type) {
      case ContentType.text:
        return TextContent.fromMap(map);
      case ContentType.video:
        return VideoContent.fromMap(map);
      case ContentType.quiz:
        return QuizContent.fromMap(map);
    }
  }
}

class TextContent extends ContentBlock {
  final String text;
  TextContent({required this.text}) : super(type: ContentType.text);
  @override
  Map<String, dynamic> toMap() => {'type': type.name, 'text': text};
  factory TextContent.fromMap(Map<String, dynamic> map) =>
      TextContent(text: map['text'] ?? '');
}

class VideoContent extends ContentBlock {
  final String videoUrl;
  VideoContent({required this.videoUrl}) : super(type: ContentType.video);
  @override
  Map<String, dynamic> toMap() => {'type': type.name, 'videoUrl': videoUrl};
  factory VideoContent.fromMap(Map<String, dynamic> map) =>
      VideoContent(videoUrl: map['videoUrl'] ?? '');
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
      };
  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        question: map['question'] ?? '',
        options: List<String>.from(map['options'] ?? []),
        correctOptionIndex: map['correctOptionIndex'] ?? 0,
      );
}

class QuizContent extends ContentBlock {
  final List<QuizQuestion> questions;
  QuizContent({required this.questions}) : super(type: ContentType.quiz);
  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'questions': questions.map((q) => q.toMap()).toList(),
      };
  factory QuizContent.fromMap(Map<String, dynamic> map) => QuizContent(
        questions: (map['questions'] as List?)
                ?.map((q) => QuizQuestion.fromMap(q))
                .toList() ??
            [],
      );
}

class Lesson {
  final String id;
  final String title;
  final List<ContentBlock> content;

  Lesson({required this.id, required this.title, required this.content});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content.map((c) => c.toMap()).toList(),
      };

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        content: (map['content'] as List?)
                ?.map((c) => ContentBlock.fromMap(c as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class Course {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String? youtubeUrl;
  final List<Lesson> lessonsList;
  final String cost;
  final String duration;
  final String level;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    this.youtubeUrl,
    this.lessonsList = const [],
    this.cost = 'Free',
    this.duration = 'N/A',
    this.level = 'Beginner',
  });

  factory Course.fromMap(Map<String, dynamic> data, String documentId) {
    return Course(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      youtubeUrl: data['youtubeUrl'],
      lessonsList: (data['lessonsList'] as List?)
              ?.map((l) => Lesson.fromMap(l as Map<String, dynamic>))
              .toList() ??
          [],
      cost: data['cost'] ?? 'Free',
      duration: data['duration'] ?? 'N/A',
      level: data['level'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'youtubeUrl': youtubeUrl,
      'lessonsList': lessonsList.map((l) => l.toMap()).toList(),
      'cost': cost,
      'duration': duration,
      'level': level,
    };
  }

  int get lessonsCount => lessonsList.length;
}

enum EnrollmentStatus { pending, approved, rejected }

class EnrollmentRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseTitle;
  final EnrollmentStatus status;

  EnrollmentRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseTitle,
    required this.status,
  });

  factory EnrollmentRequest.fromMap(Map<String, dynamic> data, String documentId) {
    return EnrollmentRequest(
      id: documentId,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      courseId: data['courseId'] ?? '',
      courseTitle: data['courseTitle'] ?? '',
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => EnrollmentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'status': status.name,
    };
  }
}

class UserProgress {
  final String userId;
  final String courseId;
  final List<String> completedLessonIds;

  UserProgress({
    required this.userId,
    required this.courseId,
    this.completedLessonIds = const [],
  });

  factory UserProgress.fromMap(Map<String, dynamic> data) {
    return UserProgress(
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      completedLessonIds: List<String>.from(data['completedLessonIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completedLessonIds': completedLessonIds,
    };
  }
}
