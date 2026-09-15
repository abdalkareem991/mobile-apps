import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsDaoMixin {
  ContactsDao(super.attachedDatabase);

  Future<void> upsert(ContactsCompanion contact) {
    return into(contacts).insert(contact, mode: InsertMode.insertOrReplace);
  }

  Future<Contact?> findById(String id) {
    return (select(
      contacts,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<Contact?> findByRegisteredUserId(String userId) {
    return (select(contacts)
          ..where((table) => table.registeredUserId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> markRegistered({
    required String contactId,
    required String userId,
  }) {
    return (update(
      contacts,
    )..where((table) => table.id.equals(contactId))).write(
      ContactsCompanion(
        registeredUserId: Value(userId),
        isAppUser: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<Contact>> watchAll() {
    return (select(
      contacts,
    )..orderBy([(table) => OrderingTerm.asc(table.savedName)])).watch();
  }
}

@DriftAccessor(tables: [UserProfiles])
class UserProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfilesDaoMixin {
  UserProfilesDao(super.attachedDatabase);

  Future<void> save(UserProfilesCompanion profile) {
    return into(userProfiles).insert(profile, mode: InsertMode.insertOrReplace);
  }

  Future<UserProfile?> getCurrent() => select(userProfiles).getSingleOrNull();

  Future<void> deleteCurrent() => delete(userProfiles).go();
}

@DriftAccessor(tables: [Conversations, ConversationMembers])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(super.attachedDatabase);

  Future<void> create(ConversationsCompanion conversation) {
    return into(conversations).insert(conversation);
  }

  Future<void> addMember(ConversationMembersCompanion member) {
    return into(conversationMembers).insert(member);
  }

  Future<Conversation?> findById(String id) {
    return (select(
      conversations,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Conversation>> watchOrdered() {
    return (select(conversations)..orderBy([
          (table) => OrderingTerm(
            expression: table.lastMessageAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch();
  }

  Future<void> updateUnreadCount(String id, int unreadCount) {
    return (update(conversations)..where((table) => table.id.equals(id))).write(
      ConversationsCompanion(
        unreadCount: Value(unreadCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

@DriftAccessor(tables: [Messages, Conversations])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.attachedDatabase);

  Future<void> insertAndUpdateConversation(
    MessagesCompanion message, {
    required String preview,
  }) async {
    await transaction(() async {
      await into(messages).insert(message);
      final conversation =
          await (select(conversations)..where(
                (table) => table.id.equals(message.conversationId.value),
              ))
              .getSingle();
      await (update(
        conversations,
      )..where((table) => table.id.equals(conversation.id))).write(
        ConversationsCompanion(
          lastMessageId: Value(message.id.value),
          lastMessagePreview: Value(preview),
          lastMessageAt: Value(message.createdAt.value),
          unreadCount: Value(conversation.unreadCount + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> insertOutgoingAndUpdateConversation(
    MessagesCompanion message, {
    required String preview,
  }) async {
    await transaction(() async {
      await into(messages).insert(message);
      await (update(
        conversations,
      )..where((table) => table.id.equals(message.conversationId.value))).write(
        ConversationsCompanion(
          lastMessageId: Value(message.id.value),
          lastMessagePreview: Value(preview),
          lastMessageAt: Value(message.createdAt.value),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<Message?> findById(String id) {
    return (select(
      messages,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateStatus(String id, MessageStatus status) {
    return (update(messages)..where((table) => table.id.equals(id))).write(
      MessagesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<Message>> watchForConversation(String conversationId) {
    return (select(messages)
          ..where((table) => table.conversationId.equals(conversationId))
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .watch();
  }
}

@DriftAccessor(tables: [MessageReads])
class MessageReadsDao extends DatabaseAccessor<AppDatabase>
    with _$MessageReadsDaoMixin {
  MessageReadsDao(super.attachedDatabase);

  Future<void> save(MessageReadsCompanion read) {
    return into(messageReads).insert(read, mode: InsertMode.insertOrReplace);
  }

  Stream<List<MessageRead>> watchForMessage(String messageId) {
    return (select(
      messageReads,
    )..where((table) => table.messageId.equals(messageId))).watch();
  }
}

@DriftAccessor(tables: [BlockedUsers])
class BlockedUsersDao extends DatabaseAccessor<AppDatabase>
    with _$BlockedUsersDaoMixin {
  BlockedUsersDao(super.attachedDatabase);

  Future<void> block(BlockedUsersCompanion blockedUser) {
    return into(blockedUsers)
        .insert(blockedUser, mode: InsertMode.insertOrReplace);
  }

  Future<void> unblock(String contactId) {
    return (delete(
      blockedUsers,
    )..where((table) => table.contactId.equals(contactId))).go();
  }

  Stream<List<BlockedUser>> watchAll() => select(blockedUsers).watch();
}

@DriftAccessor(tables: [FriendRequests])
class FriendRequestsDao extends DatabaseAccessor<AppDatabase>
    with _$FriendRequestsDaoMixin {
  FriendRequestsDao(super.attachedDatabase);

  Future<void> save(FriendRequestsCompanion request) {
    return into(friendRequests)
        .insert(request, mode: InsertMode.insertOrReplace);
  }

  Stream<List<FriendRequest>> watchPending() {
    return (select(friendRequests)..where(
          (table) => table.status.equalsValue(FriendRequestStatus.pending),
        ))
        .watch();
  }
}
