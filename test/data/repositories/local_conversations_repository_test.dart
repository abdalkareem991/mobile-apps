import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/data/local/database/database.dart';
import 'package:myapp/data/repositories/local_conversations_repository.dart';

void main() {
  test('findOrCreateDirect is idempotent for a contact', () async {
    final database = AppDatabase.inMemory();
    final now = DateTime.utc(2026, 9, 15);
    final contact = Contact(
      id: 'contact-new',
      phoneNumber: '+15550000002',
      savedName: 'New Contact',
      registeredUserId: null,
      isAppUser: false,
      createdAt: now,
      updatedAt: now,
    );
    await database.contactsDao.upsert(
      ContactsCompanion.insert(
        id: contact.id,
        phoneNumber: contact.phoneNumber,
        savedName: contact.savedName,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final repository = LocalConversationsRepository(database);
    final firstId = await repository.findOrCreateDirect(contact);
    final secondId = await repository.findOrCreateDirect(contact);

    expect(secondId, firstId);
    expect(await database.conversationsDao.findById(firstId), isNotNull);
    expect(
      (await database.select(database.conversationMembers).get()).length,
      1,
    );
    await database.close();
  });
}
