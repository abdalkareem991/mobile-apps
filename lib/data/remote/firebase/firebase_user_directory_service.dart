import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDirectoryUser {
  const FirebaseDirectoryUser({required this.uid, required this.displayName});

  final String uid;
  final String displayName;
}

class FirebaseUserDirectoryService {
  FirebaseUserDirectoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError(
        'A signed-in Firebase user is required for directory access.',
      );
    }
    return uid;
  }

  Future<void> publishCurrentUser({
    required String phoneNumber,
    required String displayName,
  }) async {
    await _firestore.collection('users').doc(_uid).set({
      'uid': _uid,
      'phoneHash': hashPhone(phoneNumber),
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<FirebaseDirectoryUser?> findByPhone(String phoneNumber) async {
    final result = await _firestore
        .collection('users')
        .where('phoneHash', isEqualTo: hashPhone(phoneNumber))
        .limit(1)
        .get();
    if (result.docs.isEmpty) return null;
    final data = result.docs.first.data();
    final uid = data['uid'];
    final displayName = data['displayName'];
    if (uid is! String || displayName is! String) {
      throw StateError('Invalid user directory document.');
    }
    return FirebaseDirectoryUser(uid: uid, displayName: displayName);
  }

  static String hashPhone(String phoneNumber) {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
