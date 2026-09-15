// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$ContactsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContactsTable get contacts => attachedDatabase.contacts;
  ContactsDaoManager get managers => ContactsDaoManager(this);
}

class ContactsDaoManager {
  final _$ContactsDaoMixin _db;
  ContactsDaoManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
}

mixin _$UserProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTable get userProfiles => attachedDatabase.userProfiles;
  UserProfilesDaoManager get managers => UserProfilesDaoManager(this);
}

class UserProfilesDaoManager {
  final _$UserProfilesDaoMixin _db;
  UserProfilesDaoManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db.attachedDatabase, _db.userProfiles);
}

mixin _$ConversationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $ConversationMembersTable get conversationMembers =>
      attachedDatabase.conversationMembers;
  ConversationsDaoManager get managers => ConversationsDaoManager(this);
}

class ConversationsDaoManager {
  final _$ConversationsDaoMixin _db;
  ConversationsDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$ConversationMembersTableTableManager get conversationMembers =>
      $$ConversationMembersTableTableManager(
        _db.attachedDatabase,
        _db.conversationMembers,
      );
}

mixin _$MessagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $MessagesTable get messages => attachedDatabase.messages;
  MessagesDaoManager get managers => MessagesDaoManager(this);
}

class MessagesDaoManager {
  final _$MessagesDaoMixin _db;
  MessagesDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db.attachedDatabase, _db.messages);
}

mixin _$MessageReadsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $MessagesTable get messages => attachedDatabase.messages;
  $MessageReadsTable get messageReads => attachedDatabase.messageReads;
  MessageReadsDaoManager get managers => MessageReadsDaoManager(this);
}

class MessageReadsDaoManager {
  final _$MessageReadsDaoMixin _db;
  MessageReadsDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db.attachedDatabase, _db.messages);
  $$MessageReadsTableTableManager get messageReads =>
      $$MessageReadsTableTableManager(_db.attachedDatabase, _db.messageReads);
}

mixin _$BlockedUsersDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContactsTable get contacts => attachedDatabase.contacts;
  $BlockedUsersTable get blockedUsers => attachedDatabase.blockedUsers;
  BlockedUsersDaoManager get managers => BlockedUsersDaoManager(this);
}

class BlockedUsersDaoManager {
  final _$BlockedUsersDaoMixin _db;
  BlockedUsersDaoManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$BlockedUsersTableTableManager get blockedUsers =>
      $$BlockedUsersTableTableManager(_db.attachedDatabase, _db.blockedUsers);
}

mixin _$FriendRequestsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContactsTable get contacts => attachedDatabase.contacts;
  $FriendRequestsTable get friendRequests => attachedDatabase.friendRequests;
  FriendRequestsDaoManager get managers => FriendRequestsDaoManager(this);
}

class FriendRequestsDaoManager {
  final _$FriendRequestsDaoMixin _db;
  FriendRequestsDaoManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$FriendRequestsTableTableManager get friendRequests =>
      $$FriendRequestsTableTableManager(
        _db.attachedDatabase,
        _db.friendRequests,
      );
}
