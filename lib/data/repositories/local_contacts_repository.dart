import 'package:flutter_contacts/flutter_contacts.dart' as device_contacts;

import '../local/database/database.dart';
import '../remote/firebase/firebase_user_directory_service.dart';

class LocalContactsRepository {
  LocalContactsRepository(this.database);

  final AppDatabase database;

  Stream<List<Contact>> watchContacts() => database.contactsDao.watchAll();

  Future<int> syncRegisteredUsers(
    FirebaseUserDirectoryService directory,
  ) async {
    var matched = 0;
    final contacts = await database.contactsDao.watchAll().first;
    for (final contact in contacts) {
      final user = await directory.findByPhone(contact.phoneNumber);
      if (user == null) continue;
      await database.contactsDao.markRegistered(
        contactId: contact.id,
        userId: user.uid,
      );
      matched++;
    }
    return matched;
  }

  Future<bool> importFromDevice() async {
    final permission = await device_contacts.FlutterContacts.permissions
        .request(device_contacts.PermissionType.read);
    if (permission != device_contacts.PermissionStatus.granted &&
        permission != device_contacts.PermissionStatus.limited) {
      return false;
    }

    final contacts = await device_contacts.FlutterContacts.getAll(
      properties: {
        device_contacts.ContactProperty.name,
        device_contacts.ContactProperty.phone,
      },
    );
    final now = DateTime.now().toUtc();
    for (final contact in contacts) {
      final phone = _firstPhone(contact);
      if (phone == null) continue;
      await database.contactsDao.upsert(
        ContactsCompanion.insert(
          id: _contactId(contact, phone),
          phoneNumber: phone,
          savedName: contact.displayName?.trim().isNotEmpty == true
              ? contact.displayName!.trim()
              : phone,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return true;
  }

  String? _firstPhone(device_contacts.Contact contact) {
    for (final phone in contact.phones) {
      final normalized = _normalizePhone(
        phone.normalizedNumber ?? phone.number,
      );
      if (normalized.isNotEmpty) return normalized;
    }
    return null;
  }

  String _contactId(device_contacts.Contact contact, String phone) {
    final source = contact.id?.trim().isNotEmpty == true ? contact.id! : phone;
    return 'contact-${source.hashCode.abs()}';
  }

  String _normalizePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('+')) {
      return '+${trimmed.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    }
    return trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
