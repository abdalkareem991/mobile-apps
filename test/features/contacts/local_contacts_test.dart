import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/data/local/database/database.dart';
import 'package:myapp/main.dart';

import '../../support/fake_phone_auth_service.dart';

void main() {
  testWidgets('shows locally imported contacts', (tester) async {
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

    await tester.tap(find.text('جهات الاتصال'));
    await tester.pumpAndSettle();

    expect(find.text('Sara Ahmed'), findsOneWidget);
    expect(find.text('+10000000001'), findsOneWidget);
    await tester.tap(find.text('Sara Ahmed'));
    await tester.pumpAndSettle();

    expect(find.text('اكتب رسالة...'), findsOneWidget);
    expect(
      (await database.conversationsDao.findById('conversation-sara')),
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await database.close();
  });
}
