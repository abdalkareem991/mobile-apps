import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'daos.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Contacts,
    UserProfiles,
    Conversations,
    ConversationMembers,
    Messages,
    MessageReads,
    BlockedUsers,
    FriendRequests,
  ],
  daos: [
    ContactsDao,
    UserProfilesDao,
    ConversationsDao,
    MessagesDao,
    MessageReadsDao,
    BlockedUsersDao,
    FriendRequestsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.inMemory() => AppDatabase(NativeDatabase.memory());

  static Future<AppDatabase> open({
    bool seedDevelopmentFixtures = false,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final databaseFile = File(path.join(directory.path, 'nabd_chat.sqlite'));
    final database = AppDatabase(
      NativeDatabase.createInBackground(databaseFile),
    );
    if (seedDevelopmentFixtures) {
      await database.seedDevelopmentFixtures();
    }
    return database;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {},
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> seedDevelopmentFixtures() async {
    if ((await select(userProfiles).get()).isNotEmpty) return;

    final now = DateTime.now().toUtc();
    await transaction(() async {
      await userProfilesDao.save(
        UserProfilesCompanion.insert(
          id: 'me',
          phoneNumber: '+10000000000',
          realName: 'Nabd User',
          displayName: 'Nabd User',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await contactsDao.upsert(
        ContactsCompanion.insert(
          id: 'contact-sara',
          phoneNumber: '+10000000001',
          savedName: 'Sara Ahmed',
          isAppUser: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await conversationsDao.create(
        ConversationsCompanion.insert(
          id: 'conversation-sara',
          type: ConversationType.direct,
          title: const Value('Sara Ahmed'),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await conversationsDao.addMember(
        ConversationMembersCompanion.insert(
          id: 'member-sara',
          conversationId: 'conversation-sara',
          contactId: const Value('contact-sara'),
          role: MemberRole.member,
          joinedAt: now,
        ),
      );
      await messagesDao.insertAndUpdateConversation(
        MessagesCompanion.insert(
          id: 'message-sara',
          conversationId: 'conversation-sara',
          type: MessageType.text,
          body: const Value('Welcome to Nabd Chat'),
          status: MessageStatus.sent,
          createdAt: now,
          updatedAt: now,
        ),
        preview: 'Welcome to Nabd Chat',
      );
    });
  }
}
