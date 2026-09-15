import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:myapp/data/local/database/database.dart';
import 'package:myapp/data/local/database/tables.dart';
import 'package:myapp/data/repositories/local_messages_repository.dart';

void main() {
  test(
    'sendText persists a message and updates conversation preview',
    () async {
      final database = AppDatabase.inMemory();
      final now = DateTime.utc(2026, 9, 15);
      await database.conversationsDao.create(
        ConversationsCompanion.insert(
          id: 'conversation-1',
          type: ConversationType.direct,
          title: const Value('Sara Ahmed'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await LocalMessagesRepository(database)
          .sendText(conversationId: 'conversation-1', body: 'رسالة محفوظة');

      final messages = await database.select(database.messages).get();
      final conversation = await database.conversationsDao.findById(
        'conversation-1',
      );
      expect(messages, hasLength(1));
      expect(messages.single.body, 'رسالة محفوظة');
      expect(messages.single.status, MessageStatus.sent);
      expect(conversation?.lastMessagePreview, 'رسالة محفوظة');
      expect(conversation?.unreadCount, 0);
      await database.close();
    },
  );
}
