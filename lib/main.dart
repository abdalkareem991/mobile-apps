import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app/app.dart';
import 'data/local/database/database.dart';
import 'data/repositories/local_session_repository.dart';
import 'data/repositories/local_messages_repository.dart';
import 'data/repositories/phone_auth_service.dart';
import 'data/remote/firebase/firebase_user_directory_service.dart';
import 'data/remote/firebase/firebase_mailbox_service.dart';
import 'data/remote/firebase/firebase_mailbox_sync_worker.dart';
import 'firebase_options.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final database = await AppDatabase.open();
  final session = LocalSessionRepository(database);
  final state = await session.state();
  final mailbox = FirebaseMailboxService();
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseMailboxSyncWorker(
      mailbox: mailbox,
      messages: LocalMessagesRepository(database, mailbox: mailbox),
      database: database,
    ).start();
  }
  runApp(
    NabdApp(
      database: database,
      auth: FirebasePhoneAuthService(),
      directory: FirebaseUserDirectoryService(),
      mailbox: mailbox,
      initialLocation: state == LocalSessionState.signedIn ? '/' : '/login',
    ),
  );
}
