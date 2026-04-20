import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mereb/main.dart';

void main() {
  testWidgets('App renders prototype title', (WidgetTester tester) async {
    await tester.pumpWidget(const MerebApp());

    expect(find.text('Mereb E-Learning'), findsOneWidget);
    expect(find.text('Continue learning'), findsOneWidget);
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
