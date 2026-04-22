import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'models/models.dart' as models;
import 'services/database_service.dart';
import 'teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
      ],
      child: const MerebApp(),
    ),
  );
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
      home: const AppGate(),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user == null) {
      return const LoginPage();
    }

    return FutureBuilder<models.AppUser?>(
      future: context.read<DatabaseService>().getUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final appUser = snapshot.data;
        if (appUser == null) {
          // If Firestore document doesn't exist yet, we might need to wait or handle it.
          // For now, assume it's being created.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (appUser.role == models.UserRole.teacher) {
          return Provider<models.AppUser>.value(
            value: appUser,
            child: const TeacherDashboard(),
          );
        }

        return Provider<models.AppUser>.value(
          value: appUser,
          child: const PrototypeHomePage(),
        );
      },
    );
  }
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      if (_isSignUp) {
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.school_outlined, size: 30),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isSignUp ? 'Create Account' : 'Welcome to Mereb',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp
                              ? 'Join our learning community today.'
                              : 'Sign in to continue your learning journey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          key: const Key('login_email_field'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email.';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('login_password_field'),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          key: const Key('login_button'),
                          onPressed: _isLoading ? null : _submit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isSignUp ? 'Sign up' : 'Sign in'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: const Icon(Icons.login), // Replace with Google icon if available
                          label: const Text('Sign in with Google'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(_isSignUp
                              ? 'Already have an account? Sign in'
                              : 'Don\'t have an account? Sign up'),
                        ),
                        if (!_isSignUp)
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset flow coming soon.'),
                                ),
                              );
                            },
                            child: const Text('Forgot password?'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrototypeHomePage extends StatefulWidget {
  const PrototypeHomePage({super.key});

  @override
  State<PrototypeHomePage> createState() => _PrototypeHomePageState();
}

class _PrototypeHomePageState extends State<PrototypeHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<models.Course>>(
      stream: context.read<DatabaseService>().streamCourses(),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
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
      },
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.courses});

  final List<models.Course> courses;
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
    // In a real app, progress would be tracked per user in Firestore
    const avgProgress = 0.0;

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
          'Available courses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (courses.isEmpty)
          const Card(
            child: ListTile(
              title: Text('No courses available yet.'),
            ),
          )
        else
          ...courses.take(3).map(
            (course) => Card(
              child: ListTile(
                title: Text(course.title),
                subtitle: Text('by ${course.instructorName}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CourseDetailsPage(course: course),
                    ),
                  );
                },
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

  final List<models.Course> courses;

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
            subtitle: Text('${course.instructorName} • ${course.lessons} lessons'),
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

  final List<models.Course> courses;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final appUser = context.watch<models.AppUser>();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32, 
            backgroundImage: user?.photoURL != null 
              ? NetworkImage(user!.photoURL!) 
              : null,
            child: user?.photoURL == null 
              ? const Icon(Icons.person, size: 36) 
              : null,
          ),
          const SizedBox(height: 12),
          Text(
            appUser.displayName ?? 'Learner',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(appUser.email),
          const SizedBox(height: 4),
          Chip(label: Text(appUser.role.name.toUpperCase())),
          const Divider(height: 32),
          Text('Enrolled courses: 0'), // Simplified for prototype
          const SizedBox(height: 8),
          Text('Completed courses: 0'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.read<AuthService>().signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key, required this.course});

  final models.Course course;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.course.youtubeUrl != null && widget.course.youtubeUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.course.youtubeUrl!);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_controller != null)
            YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: true,
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('No video available')),
            ),
          const SizedBox(height: 16),
          Text(widget.course.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text('Instructor: ${widget.course.instructorName}'),
          const SizedBox(height: 8),
          Text('Lessons: ${widget.course.lessons}'),
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
