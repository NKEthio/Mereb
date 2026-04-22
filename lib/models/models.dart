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

class Course {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String? youtubeUrl;
  final int lessons;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    this.youtubeUrl,
    this.lessons = 0,
  });

  factory Course.fromMap(Map<String, dynamic> data, String documentId) {
    return Course(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      youtubeUrl: data['youtubeUrl'],
      lessons: data['lessons'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'youtubeUrl': youtubeUrl,
      'lessons': lessons,
    };
  }
}
