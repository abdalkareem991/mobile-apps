import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/generated/app_localizations.dart';
import '../data/repositories/local_contacts_repository.dart';
import '../data/repositories/local_conversations_repository.dart';
import '../data/repositories/local_messages_repository.dart';
import '../data/repositories/local_session_repository.dart';
import '../data/repositories/phone_auth_service.dart';
import '../data/remote/firebase/firebase_user_directory_service.dart';
import '../data/remote/firebase/firebase_mailbox_service.dart';
import '../data/local/database/database.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class NabdApp extends StatelessWidget {
  const NabdApp({
    required this.database,
    required this.initialLocation,
    required this.auth,
    this.directory,
    this.mailbox,
    super.key,
  });

  final AppDatabase database;
  final String initialLocation;
  final PhoneAuthService auth;
  final FirebaseUserDirectoryService? directory;
  final FirebaseMailboxService? mailbox;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nabd Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: createAppRouter(
        contacts: LocalContactsRepository(database),
        conversations: LocalConversationsRepository(database),
        messages: LocalMessagesRepository(database, mailbox: mailbox),
        auth: auth,
        directory: directory,
        session: LocalSessionRepository(database),
        initialLocation: initialLocation,
      ),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
