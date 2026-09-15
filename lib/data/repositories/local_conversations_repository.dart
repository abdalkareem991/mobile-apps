import 'package:drift/drift.dart';

import '../local/database/database.dart';
import '../local/database/tables.dart';

class LocalConversationsRepository {
  LocalConversationsRepository(this.database);

  final AppDatabase database;

  Stream<List<Conversation>> watchConversations() {
    return database.conversationsDao.watchOrdered();
  }

  Future<String> findOrCreateDirect(Contact contact) async {
    final existingMember =
        await (database.select(database.conversationMembers)
              ..where((member) => member.contactId.equals(contact.id)))
            .getSingleOrNull();
    if (existingMember != null) return existingMember.conversationId;

    final now = DateTime.now().toUtc();
    final conversationId = 'conversation-${contact.id}';
    await database.transaction(() async {
      await database.conversationsDao.create(
        ConversationsCompanion.insert(
          id: conversationId,
          type: ConversationType.direct,
          title: Value(contact.savedName),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.conversationsDao.addMember(
        ConversationMembersCompanion.insert(
          id: 'member-$conversationId',
          conversationId: conversationId,
          contactId: Value(contact.id),
          role: MemberRole.member,
          joinedAt: now,
        ),
      );
    });
    return conversationId;
  }

  ChatPreviewData previewFor(Conversation conversation) {
    return ChatPreviewData(
      id: conversation.id,
      name: conversation.title ?? 'محادثة جديدة',
      preview: conversation.lastMessagePreview ?? '',
      time: _formatTime(conversation.lastMessageAt),
      initials: _initials(conversation.title),
      unread: conversation.unreadCount,
    );
  }

  String _initials(String? title) {
    final value = title?.trim() ?? '';
    return value.isEmpty ? '?' : value.substring(0, 1);
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $suffix';
  }
}

class ChatPreviewData {
  const ChatPreviewData({
    required this.id,
    required this.name,
    required this.preview,
    required this.time,
    required this.initials,
    required this.unread,
  });

  final String id;
  final String name;
  final String preview;
  final String time;
  final String initials;
  final int unread;
}
