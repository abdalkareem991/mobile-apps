import 'package:drift/drift.dart';

import '../local/database/database.dart';
import '../local/database/tables.dart';
import '../remote/firebase/firebase_mailbox_service.dart';

class LocalMessagesRepository {
  LocalMessagesRepository(this.database, {this.mailbox});

  final AppDatabase database;
  final FirebaseMailboxService? mailbox;

  Stream<List<Message>> watchForConversation(String conversationId) {
    return database.messagesDao.watchForConversation(conversationId);
  }

  Future<void> sendText({
    required String conversationId,
    required String body,
    String? recipientUid,
  }) async {
    final now = DateTime.now().toUtc();
    final messageId = 'message-${now.microsecondsSinceEpoch}';
    await database.messagesDao.insertOutgoingAndUpdateConversation(
      MessagesCompanion.insert(
        id: messageId,
        conversationId: conversationId,
        type: MessageType.text,
        body: Value(body),
        status: MessageStatus.sent,
        createdAt: now,
        updatedAt: now,
      ),
      preview: body,
    );
    if (mailbox != null && recipientUid != null) {
      await mailbox!.sendCiphertext(
        recipientUid: recipientUid,
        messageId: messageId,
        conversationId: conversationId,
        type: MessageType.text.name,
        payload: body,
      );
    }
  }

  Future<void> receiveEnvelope(FirebaseMailboxEnvelope envelope) async {
    final existing = await database.messagesDao.findById(envelope.messageId);
    if (existing != null) {
      await mailbox?.acknowledgeAndDelete(envelope);
      return;
    }

    final now = DateTime.now().toUtc();
    final createdAt = envelope.createdAt ?? now;
    final conversation = await database.conversationsDao.findById(
      envelope.conversationId,
    );
    if (conversation == null) {
      await database.conversationsDao.create(
        ConversationsCompanion.insert(
          id: envelope.conversationId,
          type: ConversationType.direct,
          title: Value(
            'مستخدم ${envelope.senderUid.substring(0, envelope.senderUid.length > 6 ? 6 : envelope.senderUid.length)}',
          ),
          createdAt: createdAt,
          updatedAt: now,
        ),
      );
    }

    final sender = await database.contactsDao.findByRegisteredUserId(
      envelope.senderUid,
    );
    final type = MessageType.values.firstWhere(
      (value) => value.name == envelope.type,
      orElse: () => MessageType.text,
    );
    await database.messagesDao.insertAndUpdateConversation(
      MessagesCompanion.insert(
        id: envelope.messageId,
        conversationId: envelope.conversationId,
        senderContactId: Value(sender?.id),
        type: type,
        body: Value(envelope.payload),
        status: MessageStatus.delivered,
        createdAt: createdAt,
        updatedAt: now,
      ),
      preview: envelope.payload,
    );
    await mailbox?.acknowledgeAndDelete(envelope);
  }
}
