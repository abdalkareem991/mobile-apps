import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/local/database/database.dart';
import '../../../data/repositories/local_conversations_repository.dart';
import '../../../data/repositories/local_messages_repository.dart';

class ChatPreview {
  ChatPreview({
    required this.id,
    required this.name,
    required this.preview,
    required this.time,
    required this.initials,
    this.unread = 0,
    this.isOnline = false,
  });

  final String id;
  final String name;
  String preview;
  final String time;
  final String initials;
  final int unread;
  final bool isOnline;
}

ChatPreview chatPreviewForId(String id) {
  return ChatPreview(
    id: id,
    name: id == 'sara-ahmed' ? 'سارة أحمد' : 'محادثة جديدة',
    preview: '',
    time: '',
    initials: id == 'sara-ahmed' ? 'س' : '؟',
    isOnline: id == 'sara-ahmed',
  );
}

class ChatsPage extends StatefulWidget {
  const ChatsPage({required this.conversations, super.key});

  final LocalConversationsRepository conversations;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.appName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () => context.push('/settings'),
              tooltip: l10n.settingsTooltip,
              icon: const Icon(Icons.settings_outlined),
            ),
            IconButton(
              onPressed: () {},
              tooltip: l10n.newChat,
              icon: const Icon(Icons.edit_square),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: widget.conversations.watchConversations(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(l10n.contactsImportFailed));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final visibleChats = snapshot.data!
                .map(widget.conversations.previewFor)
                .map(
                  (chat) => ChatPreview(
                    id: chat.id,
                    name: chat.name,
                    preview: chat.preview,
                    time: chat.time,
                    initials: chat.initials,
                    unread: chat.unread,
                  ),
                )
                .where((chat) => chat.name.contains(_query.trim()))
                .toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  l10n.yourChats,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: l10n.searchChats,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                if (visibleChats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Center(child: Text(l10n.noMatchingChats)),
                  )
                else
                  ...visibleChats.map(
                    (chat) => ChatTile(
                      chat: chat,
                      onTap: () =>
                          context.push('/chat/${chat.id}', extra: chat),
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (index) {
            if (index == 1) context.push('/contacts');
            if (index == 2) context.push('/settings');
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon: const Icon(Icons.chat_bubble),
              label: l10n.chats,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l10n.contacts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({required this.chat, required this.onTap, super.key});

  final ChatPreview chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 7),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 27,
        backgroundColor: AppColors.outgoingBubble,
        child: Text(
          chat.initials,
          style: const TextStyle(
            color: AppColors.brandDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(chat.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            chat.time,
            style: TextStyle(
              color: chat.unread > 0 ? AppColors.brand : Colors.black45,
              fontSize: 12,
            ),
          ),
          if (chat.unread > 0) ...[
            const SizedBox(height: 7),
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.brand,
              child: Text(
                '${chat.unread}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({required this.chat, required this.messages, super.key});

  final ChatPreview chat;
  final LocalMessagesRepository messages;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await widget.messages.sendText(
        conversationId: widget.chat.id,
        body: message,
      );
      _messageController.clear();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.outgoingBubble,
                child: Text(widget.chat.initials),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.name, style: const TextStyle(fontSize: 16)),
                  Text(
                    widget.chat.isOnline
                        ? l10n.onlineNow
                        : l10n.lastSeenRecently,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              tooltip: l10n.callTooltip,
              icon: const Icon(Icons.call_outlined),
            ),
            IconButton(
              onPressed: () {},
              tooltip: l10n.moreTooltip,
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: widget.messages.watchForConversation(widget.chat.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(l10n.contactsImportFailed));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return Center(child: Text(l10n.noMessagesYet));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => MessageBubble(
                      message: messages[index].body ?? '',
                      isMine: messages[index].senderContactId == null,
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      tooltip: l10n.addAttachment,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: l10n.messageHint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isSending ? null : _sendMessage,
                      tooltip: l10n.send,
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, required this.isMine, super.key});

  final String message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: isMine ? AppColors.outgoingBubble : AppColors.incomingBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
        ),
        child: Text(message, style: const TextStyle(color: AppColors.ink)),
      ),
    );
  }
}
