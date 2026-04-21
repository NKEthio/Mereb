import 'package:flutter/material.dart';

void main() {
  runApp(const MerebApp());
}

class MerebApp extends StatelessWidget {
  const MerebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mereb',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PrototypeHomePage(),
    );
  }
}

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.lessons,
    required this.progress,
    required this.description,
  });

  final String id;
  final String title;
  final String instructor;
  final int lessons;
  final double progress;
  final String description;
}

class SuggestedFeature {
  const SuggestedFeature({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class PrototypeHomePage extends StatefulWidget {
  const PrototypeHomePage({super.key, this.courses});

  final List<Course>? courses;

  @override
  State<PrototypeHomePage> createState() => _PrototypeHomePageState();
}

class _PrototypeHomePageState extends State<PrototypeHomePage> {
  static const List<Course> _defaultCourses = [
    Course(
      id: 'c1',
      title: 'Foundations of Algebra',
      instructor: 'Ms. Rahel',
      lessons: 18,
      progress: 0.35,
      description:
          'Learn core algebra skills including equations, variables, and functions.',
    ),
    Course(
      id: 'c2',
      title: 'Introduction to Biology',
      instructor: 'Dr. Hana',
      lessons: 24,
      progress: 0.7,
      description:
          'Explore cells, genetics, ecosystems, and practical scientific thinking.',
    ),
    Course(
      id: 'c3',
      title: 'Digital Literacy Basics',
      instructor: 'Mr. Abel',
      lessons: 12,
      progress: 0.15,
      description:
          'Build confidence in using digital tools safely and effectively.',
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final courses = widget.courses ?? _defaultCourses;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mereb E-Learning'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardTab(courses: courses),
          _CoursesTab(courses: courses),
          _ProfileTab(courses: courses),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Courses',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.courses});

  final List<Course> courses;
  static const List<SuggestedFeature> _suggestedFeatures = [
    SuggestedFeature(
      title: 'Daily learning reminders',
      description: 'Get nudges to keep your study streak going.',
      icon: Icons.notifications_active_outlined,
    ),
    SuggestedFeature(
      title: 'Offline lesson downloads',
      description: 'Save lessons for low-connectivity learning.',
      icon: Icons.download_for_offline_outlined,
    ),
    SuggestedFeature(
      title: 'Peer discussion groups',
      description: 'Join classmates to ask questions and share tips.',
      icon: Icons.groups_outlined,
    ),
    SuggestedFeature(
      title: 'Weekly progress report',
      description: 'Track wins and identify what to focus on next.',
      icon: Icons.insights_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final inProgress = courses.where((course) => course.progress > 0).toList();
    final avgProgress = inProgress.isEmpty
        ? 0.0
        : inProgress.fold<double>(
              0,
              (total, course) => total + course.progress,
            ) /
            inProgress.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back 👋',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Overall progress: ${(avgProgress * 100).toStringAsFixed(0)}%'),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: avgProgress),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Continue learning',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (inProgress.isEmpty)
          const Card(
            child: ListTile(
              title: Text('No courses in progress yet.'),
              subtitle: Text('Browse Courses to start learning.'),
            ),
          )
        else
          ...inProgress.map(
            (course) => Card(
              child: ListTile(
                title: Text(course.title),
                subtitle: Text('${(course.progress * 100).toStringAsFixed(0)}% complete'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          'Suggested features',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ..._suggestedFeatures.map(
          (feature) => Card(
            child: ListTile(
              leading: Icon(feature.icon),
              title: Text(feature.title),
              subtitle: Text(feature.description),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoursesTab extends StatelessWidget {
  const _CoursesTab({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(course.title),
            subtitle: Text('${course.instructor} • ${course.lessons} lessons'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CourseDetailsPage(course: course),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    final completed = courses.where((course) => course.progress >= 1).length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 36)),
          const SizedBox(height: 12),
          const Text('Prototype Learner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('learner@mereb.app'),
          const Divider(height: 32),
          Text('Enrolled courses: ${courses.length}'),
          const SizedBox(height: 8),
          Text('Completed courses: $completed'),
        ],
      ),
    );
  }
}

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(course.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text('Instructor: ${course.instructor}'),
          const SizedBox(height: 8),
          Text('Lessons: ${course.lessons}'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: course.progress),
          const SizedBox(height: 8),
          Text('Progress: ${(course.progress * 100).toStringAsFixed(0)}%'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lesson playback coming soon.'),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start lesson (prototype)'),
          ),
        ],
      ),
    );
  }
}
