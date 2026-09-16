import 'package:flutter_test/flutter_test.dart';
import 'package:bano_qabil_exam/main.dart';

void main() {
  testWidgets('Bano Qabil Exam app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}