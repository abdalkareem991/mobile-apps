import 'package:drift/drift.dart';

class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get phoneNumber => text().unique()();
  TextColumn get savedName => text()();
  TextColumn get registeredUserId => text().nullable()();
  BoolColumn get isAppUser => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get realName => text()();
  TextColumn get displayName => text()();
  TextColumn get about => text().withDefault(const Constant(''))();
  TextColumn get avatarLocalPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

enum ConversationType { direct, group }

enum MemberRole { owner, admin, member }

enum MessageType { text, image, video, file, voice, system }

enum MessageStatus { sending, sent, delivered, read, failed }

enum FriendRequestStatus { pending, accepted, rejected }

@TableIndex(
  name: 'conversations_last_message_at_idx',
  columns: {#lastMessageAt},
)
class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<ConversationType>()();
  TextColumn get title => text().nullable()();
  TextColumn get lastMessageId => text().nullable()();
  TextColumn get lastMessagePreview => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isMuted => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ConversationMembers extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text().references(Conversations, #id)();
  TextColumn get contactId => text().nullable().references(Contacts, #id)();
  TextColumn get role => textEnum<MemberRole>()();
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(
  name: 'messages_conversation_created_idx',
  columns: {#conversationId, #createdAt},
)
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text().references(Conversations, #id)();
  TextColumn get senderContactId =>
      text().nullable().references(Contacts, #id)();
  TextColumn get type => textEnum<MessageType>()();
  TextColumn get body => text().nullable()();
  TextColumn get mediaLocalPath => text().nullable()();
  TextColumn get mediaRemoteRef => text().nullable()();
  TextColumn get replyToMessageId => text().nullable()();
  TextColumn get status => textEnum<MessageStatus>()();
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeletedForMe =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isDeletedForEveryone =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MessageReads extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text().references(Messages, #id)();
  TextColumn get contactId => text().references(Contacts, #id)();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BlockedUsers extends Table {
  TextColumn get contactId => text().references(Contacts, #id)();
  DateTimeColumn get blockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {contactId};
}

class FriendRequests extends Table {
  TextColumn get id => text()();
  @ReferenceName('sentFriendRequests')
  TextColumn get fromContactId => text().references(Contacts, #id)();
  @ReferenceName('receivedFriendRequests')
  TextColumn get toContactId => text().references(Contacts, #id)();
  TextColumn get status => textEnum<FriendRequestStatus>()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
