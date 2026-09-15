import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:myapp/data/local/database/database.dart';

import 'support/fake_phone_auth_service.dart';

void main() {
  testWidgets('opens a conversation from the chats list', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.inMemory();
    await database.seedDevelopmentFixtures();
    await tester.pumpWidget(
      NabdApp(
        database: database,
        initialLocation: '/',
        auth: FakePhoneAuthService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('محادثاتك'), findsOneWidget);
    expect(find.text('Sara Ahmed'), findsOneWidget);

    await tester.tap(find.text('Sara Ahmed'));
    await tester.pumpAndSettle();

    expect(find.text('اكتب رسالة...'), findsOneWidget);
    expect(find.text('آخر ظهور مؤخرًا'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await database.close();
  });

  testWidgets('sends a message in a conversation', (WidgetTester tester) async {
    final database = AppDatabase.inMemory();
    await database.seedDevelopmentFixtures();
    await tester.pumpWidget(
      NabdApp(
        database: database,
        initialLocation: '/',
        auth: FakePhoneAuthService(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sara Ahmed'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'رسالة جديدة');
    await tester.tap(find.byTooltip('إرسال'));
    await tester.pump();

    expect(find.text('رسالة جديدة'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await database.close();
  });
}
