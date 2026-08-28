import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17212B);
    return MaterialApp(
      title: 'وصلة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A884),
          surface: const Color(0xFFF7F9F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F8),
          foregroundColor: ink,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
        useMaterial3: true,
      ),
      home: const ChatsPage(),
    );
  }
}

class ChatPreview {
  ChatPreview({
    required this.name,
    required this.preview,
    required this.time,
    required this.initials,
    this.unread = 0,
    this.isOnline = false,
  });

  final String name;
  String preview;
  final String time;
  final String initials;
  final int unread;
  final bool isOnline;
}

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final _searchController = TextEditingController();
  final _chats = [
    ChatPreview(
      name: 'سارة أحمد',
      preview: 'تمام، نلتقي بعد قليل',
      time: '10:42 ص',
      initials: 'س',
      unread: 2,
      isOnline: true,
    ),
    ChatPreview(
      name: 'فريق المشروع',
      preview: 'أحمد: أرسلت النسخة الجديدة',
      time: 'أمس',
      initials: 'ف',
      unread: 5,
    ),
    ChatPreview(
      name: 'محمد خالد',
      preview: 'شكرًا لك!',
      time: 'الأحد',
      initials: 'م',
    ),
  ];
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleChats = _chats
        .where((chat) => chat.name.contains(_query.trim()))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'وصلة',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              tooltip: 'الإعدادات',
              icon: const Icon(Icons.settings_outlined),
            ),
            IconButton(
              onPressed: () {},
              tooltip: 'محادثة جديدة',
              icon: const Icon(Icons.edit_square),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text(
              'محادثاتك',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17212B),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'ابحث في محادثاتك',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            if (visibleChats.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 64),
                child: Center(child: Text('لا توجد محادثات مطابقة')),
              )
            else
              ...visibleChats.map(
                (chat) => ChatTile(
                  chat: chat,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatPage(chat: chat),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'المحادثات',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'جهات الاتصال',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'حسابي',
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
        backgroundColor: const Color(0xFFD9F4EC),
        child: Text(
          chat.initials,
          style: const TextStyle(
            color: Color(0xFF007D65),
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
              color: chat.unread > 0 ? const Color(0xFF008F76) : Colors.black45,
              fontSize: 12,
            ),
          ),
          if (chat.unread > 0) ...[
            const SizedBox(height: 7),
            CircleAvatar(
              radius: 10,
              backgroundColor: const Color(0xFF00A884),
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
  const ChatPage({required this.chat, super.key});

  final ChatPreview chat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _messages = <String>[
    'مرحبًا! كيف حالك؟',
    'بخير، أتمنى أن تكون بخير أيضًا',
    'تمام، نلتقي بعد قليل',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add(message);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFD9F4EC),
                child: Text(widget.chat.initials),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.name, style: const TextStyle(fontSize: 16)),
                  Text(
                    widget.chat.isOnline ? 'متصل الآن' : 'آخر ظهور مؤخرًا',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              tooltip: 'مكالمة صوتية',
              icon: const Icon(Icons.call_outlined),
            ),
            IconButton(
              onPressed: () {},
              tooltip: 'المزيد',
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) => MessageBubble(
                  message: _messages[index],
                  isMine: index.isOdd,
                ),
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
                      tooltip: 'إضافة مرفق',
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالة...',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sendMessage,
                      tooltip: 'إرسال',
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
          color: isMine ? const Color(0xFF00A884) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMine ? Colors.white : const Color(0xFF17212B),
          ),
        ),
      ),
    );
  }
}
