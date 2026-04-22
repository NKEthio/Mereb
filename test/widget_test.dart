import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mereb/main.dart';

void main() {
  testWidgets('App starts on login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MerebApp());

    expect(find.text('Welcome to Mereb'), findsOneWidget);
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('Login button opens the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MerebApp());

    await tester.enterText(find.byKey(const Key('login_email_field')), 'learner@mereb.app');
    await tester.enterText(find.byKey(const Key('login_password_field')), 'secret12');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Mereb E-Learning'), findsOneWidget);
    expect(find.text('Continue learning'), findsOneWidget);
    expect(find.text('Suggested features'), findsOneWidget);
    expect(find.textContaining('Overall progress:'), findsOneWidget);
  });

  testWidgets('Home shows empty continue-learning state', (WidgetTester tester) async {
    const noProgressCourses = [
      Course(
        id: 'c-empty',
        title: 'Sample Course',
        instructor: 'Instructor',
        lessons: 5,
        progress: 0,
        description: 'Description',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: PrototypeHomePage(courses: noProgressCourses),
      ),
    );

    expect(find.text('No courses in progress yet.'), findsOneWidget);
  });
}
