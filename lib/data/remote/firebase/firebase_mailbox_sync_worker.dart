import 'dart:async';

import 'firebase_mailbox_service.dart';
import '../../repositories/local_messages_repository.dart';
import '../../../data/local/database/database.dart';
import '../../../data/local/database/tables.dart';

class FirebaseMailboxSyncWorker {
  FirebaseMailboxSyncWorker({
    required this.mailbox,
    required this.messages,
    required this.database,
  });

  final FirebaseMailboxService mailbox;
  final LocalMessagesRepository messages;
  final AppDatabase database;
  StreamSubscription<FirebaseMailboxEnvelope>? _inboxSubscription;
  StreamSubscription<dynamic>? _receiptSubscription;

  void start() {
    try {
      _inboxSubscription ??= mailbox.watchInbox().listen(
        (envelope) => unawaited(_processIncoming(envelope)),
        onError: (_, _) {},
      );
      _receiptSubscription ??= mailbox.watchReceipts().listen(
        (receipt) => unawaited(_processReceipt(receipt)),
        onError: (_, _) {},
      );
    } on StateError {
      // Firebase Auth may restore the session after app startup.
    }
  }

  Future<void> stop() async {
    await _inboxSubscription?.cancel();
    await _receiptSubscription?.cancel();
    _inboxSubscription = null;
    _receiptSubscription = null;
  }

  Future<void> _processIncoming(FirebaseMailboxEnvelope envelope) {
    return messages.receiveEnvelope(envelope);
  }

  Future<void> _processReceipt(dynamic receipt) async {
    final data = receipt.data() as Map<String, dynamic>?;
    final messageId = data?['messageId'];
    final status = data?['status'];
    if (messageId is! String || status != 'delivered') return;
    await database.messagesDao.updateStatus(messageId, MessageStatus.delivered);
  }
}
