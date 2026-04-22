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
}
