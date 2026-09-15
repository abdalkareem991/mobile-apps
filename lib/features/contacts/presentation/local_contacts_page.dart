import 'package:flutter/material.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/local/database/database.dart';
import '../../../data/repositories/local_contacts_repository.dart';

class LocalContactsPage extends StatefulWidget {
  const LocalContactsPage({
    required this.contacts,
    required this.onContactTap,
    this.onSyncRequested,
    super.key,
  });

  final LocalContactsRepository contacts;
  final Future<void> Function(Contact contact) onContactTap;
  final Future<void> Function()? onSyncRequested;

  @override
  State<LocalContactsPage> createState() => _LocalContactsPageState();
}

class _LocalContactsPageState extends State<LocalContactsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isImporting = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _importContacts() async {
    setState(() {
      _isImporting = true;
      _error = null;
    });
    try {
      final granted = await widget.contacts.importFromDevice();
      await widget.onSyncRequested?.call();
      if (!granted && mounted) {
        setState(
          () => _error = AppLocalizations.of(context).contactsPermissionDenied,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).contactsImportFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.contacts),
          actions: [
            IconButton(
              onPressed: _isImporting ? null : _importContacts,
              tooltip: l10n.importContacts,
              icon: _isImporting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
            ),
          ],
        ),
        body: StreamBuilder<List<Contact>>(
          stream: widget.contacts.watchContacts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ContactsMessage(
                icon: Icons.error_outline,
                message: l10n.contactsImportFailed,
                action: _importContacts,
                actionLabel: l10n.retry,
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final contacts = snapshot.data!
                .where(
                  (contact) =>
                      contact.savedName.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      contact.phoneNumber.contains(_query),
                )
                .toList();
            final registered = contacts
                .where((contact) => contact.isAppUser)
                .toList();
            final notRegistered = contacts
                .where((contact) => !contact.isAppUser)
                .toList();
            return Column(
              children: [
                if (_error != null)
                  MaterialBanner(
                    content: Text(_error!),
                    actions: [
                      TextButton(
                        onPressed: () => setState(() => _error = null),
                        child: Text(l10n.dismiss),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: l10n.searchContacts,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: contacts.isEmpty
                      ? _ContactsMessage(
                          icon: Icons.contacts_outlined,
                          message: l10n.contactsEmpty,
                          action: _importContacts,
                          actionLabel: l10n.importContacts,
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            if (registered.isNotEmpty) ...[
                              _SectionTitle(title: l10n.onNabd),
                              ...registered.map(
                                (contact) => _ContactTile(
                                  contact: contact,
                                  registeredLabel: l10n.onNabd,
                                  onTap: () => widget.onContactTap(contact),
                                ),
                              ),
                            ],
                            if (notRegistered.isNotEmpty) ...[
                              _SectionTitle(title: l10n.inviteSection),
                              ...notRegistered.map(
                                (contact) => _ContactTile(
                                  contact: contact,
                                  registeredLabel: l10n.onNabd,
                                  onTap: () => widget.onContactTap(contact),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.registeredLabel,
    required this.onTap,
  });

  final Contact contact;
  final String registeredLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = contact.savedName.trim().isEmpty
        ? '?'
        : contact.savedName.trim().characters.first.toUpperCase();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      onTap: onTap,
      leading: CircleAvatar(child: Text(initials)),
      title: Text(contact.savedName),
      subtitle: Text(contact.phoneNumber),
      trailing: contact.isAppUser
          ? Text(registeredLabel, style: const TextStyle(fontSize: 12))
          : null,
    );
  }
}

class _ContactsMessage extends StatelessWidget {
  const _ContactsMessage({
    required this.icon,
    required this.message,
    required this.action,
    required this.actionLabel,
  });

  final IconData icon;
  final String message;
  final VoidCallback action;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: action, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
