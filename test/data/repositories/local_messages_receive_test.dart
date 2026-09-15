import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/data/local/database/database.dart';
import 'package:myapp/data/repositories/local_messages_repository.dart';
import 'package:myapp/data/remote/firebase/firebase_mailbox_service.dart';

void main() {
  test('receiveEnvelope stores an incoming message and creates its chat', () async {
    final database = AppDatabase.inMemory();
    final repository = LocalMessagesRepository(database);
    final envelope = FirebaseMailboxEnvelope(
      messageId: 'remote-message-1',
      senderUid: 'sender-uid',
      recipientUid: 'recipient-uid',
      conversationId: 'remote-conversation-1',
      type: 'text',
      payload: 'رسالة واردة',
      createdAt: DateTime.utc(2026, 9, 15),
    );

    await repository.receiveEnvelope(envelope);

    final message = await database.messagesDao.findById('remote-message-1');
    final conversation = await database.conversationsDao.findById(
      'remote-conversation-1',
    );
    expect(message?.body, 'رسالة واردة');
    expect(message?.status.name, 'delivered');
    expect(conversation?.lastMessagePreview, 'رسالة واردة');
    expect(conversation?.unreadCount, 1);
    await database.close();
  });
}
