import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mereb/main.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mereb/auth_service.dart';
import 'package:mereb/services/database_service.dart';

void main() {
  testWidgets('App starts on login page when not authenticated', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>(create: (_) => AuthService()),
          Provider<DatabaseService>(create: (_) => DatabaseService()),
          StreamProvider<User?>(
            create: (_) => const Stream.empty(),
            initialData: null,
          ),
        ],
        child: const MerebApp(),
      ),
    );

    expect(find.text('Welcome to Mereb'), findsOneWidget);
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
  });
}
