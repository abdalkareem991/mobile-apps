import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/local_contacts_repository.dart';
import '../data/repositories/local_conversations_repository.dart';
import '../data/repositories/local_messages_repository.dart';
import '../data/repositories/phone_auth_service.dart';
import '../data/remote/firebase/firebase_user_directory_service.dart';
import '../data/repositories/local_session_repository.dart';
import '../features/auth/presentation/screens/local_auth_pages.dart';
import '../features/chats/presentation/chats_page.dart';
import '../features/contacts/presentation/local_contacts_page.dart';
import '../features/settings/presentation/local_settings_page.dart';

GoRouter createAppRouter({
  required LocalContactsRepository contacts,
  required LocalConversationsRepository conversations,
  required LocalMessagesRepository messages,
  required PhoneAuthService auth,
  FirebaseUserDirectoryService? directory,
  required LocalSessionRepository session,
  required String initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) async {
      final sessionState = await session.state();
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/profile' ||
          state.matchedLocation == '/otp';
      if (sessionState == LocalSessionState.signedOut && !isAuthRoute) {
        return '/login';
      }
      if (sessionState == LocalSessionState.signedIn && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LocalLoginPage(session: session, auth: auth),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => LocalOtpPage(
          auth: auth,
          args: state.extra as PhoneVerificationArgs,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => LocalProfileSetupPage(
          session: session,
          phoneNumber: state.extra as String? ?? '',
          onProfileSaved: directory?.publishCurrentUser,
        ),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => ChatsPage(conversations: conversations),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final extra = state.extra;
          final chat = extra is ChatPreview
              ? extra
              : chatPreviewForId(state.pathParameters['chatId'] ?? '');
          return ChatPage(chat: chat, messages: messages);
        },
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => LocalContactsPage(
          contacts: contacts,
          onContactTap: (contact) async {
            final conversationId = await conversations.findOrCreateDirect(
              contact,
            );
            if (!context.mounted) return;
            context.push(
              '/chat/$conversationId',
              extra: ChatPreview(
                id: conversationId,
                name: contact.savedName,
                preview: '',
                time: '',
                initials: contact.savedName.isEmpty
                    ? '?'
                    : contact.savedName.substring(0, 1),
              ),
            );
          },
          onSyncRequested: directory == null
              ? null
              : () => contacts.syncRegisteredUsers(directory),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            LocalSettingsPage(session: session, auth: auth),
      ),
    ],
  );
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
