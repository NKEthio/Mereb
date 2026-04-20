import 'package:flutter_test/flutter_test.dart';
import 'package:mereb/main.dart';

void main() {
  testWidgets('app renders prototype title', (WidgetTester tester) async {
    await tester.pumpWidget(const MerebApp());

    expect(find.text('Mereb E-Learning'), findsOneWidget);
    expect(find.text('Continue learning'), findsOneWidget);
  });
}
