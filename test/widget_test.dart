import 'package:flutter_test/flutter_test.dart';

import 'package:pesabook1/main.dart';

void main() {
  testWidgets('PesaBook app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const PesaBookApp());

    expect(find.text('PesaBook'), findsOneWidget);
  });
}