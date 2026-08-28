import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('opens a conversation from the chats list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('محادثاتك'), findsOneWidget);
    expect(find.text('سارة أحمد'), findsOneWidget);

    await tester.tap(find.text('سارة أحمد'));
    await tester.pumpAndSettle();

    expect(find.text('اكتب رسالة...'), findsOneWidget);
    expect(find.text('متصل الآن'), findsOneWidget);
  });

  testWidgets('sends a message in a conversation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('سارة أحمد'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'رسالة جديدة');
    await tester.tap(find.byTooltip('إرسال'));
    await tester.pump();

    expect(find.text('رسالة جديدة'), findsOneWidget);
  });
}
