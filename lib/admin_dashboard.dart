import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'services/database_service.dart';
import 'auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthService>().signOut(),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.book), text: 'Courses'),
              Tab(icon: Icon(Icons.assignment_ind), text: 'Enrollments'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UserManagementTab(),
            CourseManagementTab(),
            EnrollmentManagementTab(),
          ],
        ),
      ),
    );
  }
}

class UserManagementTab extends StatelessWidget {
  const UserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();

    return FutureBuilder<List<AppUser>>(
      future: db.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final users = snapshot.data ?? [];

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.displayName ?? user.email),
              subtitle: Text('Role: ${user.role.name}'),
              trailing: PopupMenuButton<UserRole>(
                onSelected: (role) async {
                  await db.updateUserRole(user.id, role);
                  // Refresh UI
                  (context as Element).markNeedsBuild();
                },
                itemBuilder: (context) => UserRole.values
                    .map((role) => PopupMenuItem(
                          value: role,
                          child: Text('Set as ${role.name}'),
                        ))
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class CourseManagementTab extends StatelessWidget {
  const CourseManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();

    return StreamBuilder<List<Course>>(
      stream: db.streamCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data ?? [];

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return ListTile(
              title: Text(course.title),
              subtitle: Text('Instructor: ${course.instructorName}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, db, course.id),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, DatabaseService db, String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              db.deleteCourse(courseId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class EnrollmentManagementTab extends StatelessWidget {
  const EnrollmentManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();

    return StreamBuilder<List<EnrollmentRequest>>(
      stream: db.streamEnrollmentRequests(status: EnrollmentStatus.pending),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(child: Text('No pending enrollment requests.'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(request.courseTitle),
                subtitle: Text('Student: ${request.studentName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => db.updateEnrollmentRequestStatus(
                        request.id,
                        EnrollmentStatus.approved,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => db.updateEnrollmentRequestStatus(
                        request.id,
                        EnrollmentStatus.rejected,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
