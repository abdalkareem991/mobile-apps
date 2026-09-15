import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/data/local/database/database.dart';
import 'package:myapp/main.dart';

import '../../support/fake_phone_auth_service.dart';

void main() {
  testWidgets('creates a local profile and opens chats', (tester) async {
    final database = AppDatabase.inMemory();
    await tester.pumpWidget(
      NabdApp(
        database: database,
        initialLocation: '/login',
        auth: FakePhoneAuthService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مرحبًا بك في نبض شات'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '+966500000000');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد رقم الهاتف'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('تأكيد الرقم'));
    await tester.pumpAndSettle();

    expect(find.text('إعداد ملفك الشخصي'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'عبد الكريم');
    await tester.enterText(fields.at(1), 'عبد الكريم');
    await tester.tap(find.text('حفظ الملف الشخصي'));
    await tester.pumpAndSettle();

    expect(find.text('محادثاتك'), findsOneWidget);
    expect(
      (await database.userProfilesDao.getCurrent())?.phoneNumber,
      '+966500000000',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await database.close();
  });
}
