# Nabd Chat

Flutter local-first chat application foundation.

## Phase 1

The project currently contains the application shell, Material 3 theme, `go_router` navigation, Arabic/English ARB localization, a local interactive chat preview, and the Drift local database layer.

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter analyze
flutter test
```

The local database is defined in [lib/data/local/database](lib/data/local/database), uses an in-memory constructor for tests, and has an application-file constructor for device storage. Development fixtures are opt-in through `AppDatabase.open(seedDevelopmentFixtures: true)`.

## Local mode

Firebase Core is now initialized for the configured `chating001-a6a78` project. The current auth flow is still local-only: a phone number identifies the local account, profile setup is stored in Drift, and the route is restored from the local profile on relaunch. No fake OTP or network request is used. Logging out removes the local profile session while preserving local chat history.

Firebase Auth, the relay mailbox, and real multi-device delivery remain deferred to the final integration phase.

Phone OTP is now wired through `firebase_auth`. Before testing it on a device, enable **Authentication > Sign-in method > Phone** in the Firebase console for project `chating001-a6a78`, then use a real phone number or configure a Firebase test phone number. Android debug builds also need the registered package `com.example.myapp`; iOS builds use the registered bundle `com.example.myapp`.

The contacts phase is local-only as well: `flutter_contacts` requests read permission, imports names and phone numbers into Drift, and the Contacts screen supports search plus registered/unregistered sections. Since the user directory is deferred, imported contacts remain unregistered unless seeded locally.

The Chats phase now reads conversation rows from Drift ordered by `last_message_at`. Selecting a local contact finds or creates an idempotent direct conversation and opens its chat route. Message persistence and relay delivery are handled in the next messaging phase.

Text messaging is now persisted locally: Chat detail streams `Messages`, sends create `sent` rows, and update the conversation preview and timestamp transactionally. Firebase relay delivery, receipts, and remote synchronization are still a later phase.

The Firestore relay foundation is now in [firebase_mailbox_service.dart](lib/data/remote/firebase/firebase_mailbox_service.dart). It uses `mailbox/{recipientUid}/messages/{messageId}` for temporary payload delivery, then acknowledges and deletes the mailbox document while writing a delivery receipt. Payloads are named `payload` and are intended for ciphertext; the current local composer is not connected to this relay until contact directory matching supplies a real recipient UID.

The Firebase user directory is now in [firebase_user_directory_service.dart](lib/data/remote/firebase/firebase_user_directory_service.dart). Profile setup publishes only a SHA-256 phone hash, UID, display name, and timestamp. Contact sync queries hashes and stores `registeredUserId` locally. The directory is not a permanent chat database and never stores message content.

`LocalMessagesRepository` now accepts an optional `FirebaseMailboxService`; when a real `recipientUid` is supplied, it writes the message locally first and then sends the relay payload. The current conversation UI does not invent recipient IDs, so unmatched/local conversations remain fully usable offline.

Deploy the mailbox rules after enabling Firestore in project `chating001-a6a78`:

```bash
firebase deploy --only firestore:rules --project chating001-a6a78
```

Copy `.env.example` to `.env` for local-only configuration. Firebase project options are generated in `lib/firebase_options.dart`; authentication and relay services are introduced in later phases.