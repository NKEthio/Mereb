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

class PrototypeHomePage extends StatefulWidget {
  const PrototypeHomePage({super.key});

  @override
  State<PrototypeHomePage> createState() => _PrototypeHomePageState();
}

class _PrototypeHomePageState extends State<PrototypeHomePage> {
  final List<Course> _courses = const [
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mereb E-Learning'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardTab(courses: _courses),
          _CoursesTab(courses: _courses),
          _ProfileTab(courses: _courses),
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

  @override
  Widget build(BuildContext context) {
    final inProgress = courses.where((course) => course.progress > 0).toList();
    final avgProgress = courses.fold<double>(
          0,
          (total, course) => total + course.progress,
        ) /
        courses.length;

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
        ...inProgress.map(
          (course) => Card(
            child: ListTile(
              title: Text(course.title),
              subtitle: Text('${(course.progress * 100).toStringAsFixed(0)}% complete'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            onPressed: () {},
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start lesson (prototype)'),
          ),
        ],
      ),
    );
  }
}
