import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _db.collection('users').doc(uid).update({'role': role.name});
  }

  // Course operations
  Future<void> createCourse(Course course) async {
    await _db.collection('courses').add(course.toMap());
  }

  Stream<List<Course>> streamCourses({String? instructorId}) {
    Query query = _db.collection('courses');
    if (instructorId != null) {
      query = query.where('instructorId', isEqualTo: instructorId);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> updateCourse(Course course) async {
    await _db.collection('courses').doc(course.id).update(course.toMap());
  }

  Future<void> deleteCourse(String courseId) async {
    await _db.collection('courses').doc(courseId).delete();
  }

  // Enrollment operations
  Future<void> createEnrollmentRequest(EnrollmentRequest request) async {
    await _db.collection('enrollment_requests').add(request.toMap());
  }

  Stream<List<EnrollmentRequest>> streamEnrollmentRequests({EnrollmentStatus? status}) {
    Query query = _db.collection('enrollment_requests');
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => EnrollmentRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> updateEnrollmentRequestStatus(String requestId, EnrollmentStatus status) async {
    await _db.collection('enrollment_requests').doc(requestId).update({'status': status.name});
  }

  Stream<EnrollmentStatus?> streamUserEnrollmentStatus(String userId, String courseId) {
    return _db
        .collection('enrollment_requests')
        .where('studentId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data();
      return EnrollmentStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => EnrollmentStatus.pending,
      );
    });
  }

  Stream<List<String>> streamEnrolledCourseIds(String userId) {
    return _db
        .collection('enrollment_requests')
        .where('studentId', isEqualTo: userId)
        .where('status', isEqualTo: EnrollmentStatus.approved.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()['courseId'] as String).toList());
  }

  // Progress tracking
  Future<void> updateLessonProgress(String userId, String courseId, String lessonId) async {
    final docId = '${userId}_$courseId';
    final docRef = _db.collection('user_progress').doc(docId);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'completedLessonIds': FieldValue.arrayUnion([lessonId]),
      });
    } else {
      await docRef.set({
        'userId': userId,
        'courseId': courseId,
        'completedLessonIds': [lessonId],
      });
    }
  }

  Stream<UserProgress?> streamUserProgress(String userId, String courseId) {
    final docId = '${userId}_$courseId';
    return _db.collection('user_progress').doc(docId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProgress.fromMap(doc.data()!);
      }
      return null;
    });
  }
}
