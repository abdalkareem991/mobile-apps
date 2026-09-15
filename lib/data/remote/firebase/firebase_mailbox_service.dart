import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseMailboxEnvelope {
  const FirebaseMailboxEnvelope({
    required this.messageId,
    required this.senderUid,
    required this.recipientUid,
    required this.conversationId,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  final String messageId;
  final String senderUid;
  final String recipientUid;
  final String conversationId;
  final String type;
  final String payload;
  final DateTime? createdAt;

  factory FirebaseMailboxEnvelope.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw StateError('Mailbox document ${document.id} has no data.');
    }
    return FirebaseMailboxEnvelope(
      messageId: document.id,
      senderUid: _requiredString(data, 'senderUid'),
      recipientUid: _requiredString(data, 'recipientUid'),
      conversationId: _requiredString(data, 'conversationId'),
      type: _requiredString(data, 'type'),
      payload: _requiredString(data, 'payload'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static String _requiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String || value.isEmpty) {
      throw StateError('Mailbox field $key is missing or invalid.');
    }
    return value;
  }
}

class FirebaseMailboxService {
  FirebaseMailboxService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError(
        'A signed-in Firebase user is required for mailbox access.',
      );
    }
    return uid;
  }

  Future<void> sendCiphertext({
    required String recipientUid,
    required String messageId,
    required String conversationId,
    required String type,
    required String payload,
  }) async {
    final senderUid = _currentUid;
    await _firestore
        .collection('mailbox')
        .doc(recipientUid)
        .collection('messages')
        .doc(messageId)
        .set({
          'senderUid': senderUid,
          'recipientUid': recipientUid,
          'conversationId': conversationId,
          'type': type,
          'payload': payload,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<FirebaseMailboxEnvelope> watchInbox() {
    final recipientUid = _currentUid;
    return _firestore
        .collection('mailbox')
        .doc(recipientUid)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .expand((change) sync* {
          for (final document in change.docs) {
            yield FirebaseMailboxEnvelope.fromDocument(document);
          }
        });
  }

  Future<void> acknowledgeAndDelete(FirebaseMailboxEnvelope envelope) async {
    final recipientUid = _currentUid;
    if (envelope.recipientUid != recipientUid) {
      throw StateError(
        'Mailbox envelope recipient does not match current user.',
      );
    }
    final batch = _firestore.batch();
    final messageReference = _firestore
        .collection('mailbox')
        .doc(recipientUid)
        .collection('messages')
        .doc(envelope.messageId);
    final receiptReference = _firestore
        .collection('mailbox')
        .doc(envelope.senderUid)
        .collection('receipts')
        .doc(envelope.messageId);
    batch.delete(messageReference);
    batch.set(receiptReference, {
      'messageId': envelope.messageId,
      'recipientUid': recipientUid,
      'status': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Stream<QueryDocumentSnapshot<Map<String, dynamic>>> watchReceipts() {
    final senderUid = _currentUid;
    return _firestore
        .collection('mailbox')
        .doc(senderUid)
        .collection('receipts')
        .snapshots()
        .expand((change) => change.docs);
  }
}
