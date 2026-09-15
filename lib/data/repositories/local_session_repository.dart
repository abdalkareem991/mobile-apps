import 'package:drift/drift.dart';

import '../local/database/database.dart';

enum LocalSessionState { signedOut, needsProfile, signedIn }

class LocalSessionRepository {
  LocalSessionRepository(this.database);

  final AppDatabase database;

  Future<LocalSessionState> state() async {
    final profile = await database.userProfilesDao.getCurrent();
    if (profile == null) return LocalSessionState.signedOut;
    if (profile.realName.trim().isEmpty || profile.displayName.trim().isEmpty) {
      return LocalSessionState.needsProfile;
    }
    return LocalSessionState.signedIn;
  }

  Future<void> saveProfile({
    required String phoneNumber,
    required String realName,
    required String displayName,
    String about = '',
  }) async {
    final now = DateTime.now().toUtc();
    final current = await database.userProfilesDao.getCurrent();
    await database.userProfilesDao.save(
      UserProfilesCompanion.insert(
        id: current?.id ?? 'me',
        phoneNumber: phoneNumber,
        realName: realName,
        displayName: displayName,
        about: Value(about),
        createdAt: current?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Future<String?> phoneNumber() async {
    return (await database.userProfilesDao.getCurrent())?.phoneNumber;
  }

  Future<void> signOut() => database.userProfilesDao.deleteCurrent();
}
