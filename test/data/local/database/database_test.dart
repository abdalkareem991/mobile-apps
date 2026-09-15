import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:myapp/data/local/database/database.dart';
import 'package:myapp/data/local/database/tables.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 9, 15, 10, 30);

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  test('reads and writes every local database table', () async {
    await database.contactsDao.upsert(
      ContactsCompanion.insert(
        id: 'contact-1',
        phoneNumber: '+15550000001',
        savedName: 'Sara Ahmed',
        isAppUser: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(
      (await database.contactsDao.findById('contact-1'))?.savedName,
      'Sara Ahmed',
    );

    await database.userProfilesDao.save(
      UserProfilesCompanion.insert(
        id: 'me',
        phoneNumber: '+15550000000',
        realName: 'Nabd User',
        displayName: 'Nabd',
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect((await database.userProfilesDao.getCurrent())?.displayName, 'Nabd');

    await database.conversationsDao.create(
      ConversationsCompanion.insert(
        id: 'conversation-1',
        type: ConversationType.direct,
        title: const Value('Sara Ahmed'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.conversationsDao.addMember(
      ConversationMembersCompanion.insert(
        id: 'member-1',
        conversationId: 'conversation-1',
        contactId: const Value('contact-1'),
        role: MemberRole.member,
        joinedAt: now,
      ),
    );

    await database.messagesDao.insertAndUpdateConversation(
      MessagesCompanion.insert(
        id: 'message-1',
        conversationId: 'conversation-1',
        senderContactId: const Value('contact-1'),
        type: MessageType.text,
        body: const Value('Hello'),
        status: MessageStatus.delivered,
        createdAt: now,
        updatedAt: now,
      ),
      preview: 'Hello',
    );
    expect((await database.messagesDao.findById('message-1'))?.body, 'Hello');
    final conversation = await database.conversationsDao.findById(
      'conversation-1',
    );
    expect(conversation?.lastMessagePreview, 'Hello');
    expect(conversation?.unreadCount, 1);

    await database.messageReadsDao.save(
      MessageReadsCompanion.insert(
        id: 'read-1',
        messageId: 'message-1',
        contactId: 'contact-1',
        readAt: now,
      ),
    );
    expect(
      (await database.messageReadsDao.watchForMessage('message-1').first)
          .length,
      1,
    );

    await database.blockedUsersDao.block(
      BlockedUsersCompanion.insert(contactId: 'contact-1', blockedAt: now),
    );
    expect((await database.blockedUsersDao.watchAll().first).length, 1);
    await database.blockedUsersDao.unblock('contact-1');
    expect((await database.blockedUsersDao.watchAll().first), isEmpty);

    await database.friendRequestsDao.save(
      FriendRequestsCompanion.insert(
        id: 'request-1',
        fromContactId: 'contact-1',
        toContactId: 'contact-1',
        status: FriendRequestStatus.pending,
        createdAt: now,
      ),
    );
    expect((await database.friendRequestsDao.watchPending().first).length, 1);
  });

  test('seeds development fixtures once', () async {
    await database.seedDevelopmentFixtures();
    await database.seedDevelopmentFixtures();

    expect((await database.select(database.userProfiles).get()).length, 1);
    expect((await database.select(database.contacts).get()).length, 1);
    expect((await database.select(database.conversations).get()).length, 1);
    expect((await database.select(database.messages).get()).length, 1);
  });
}
