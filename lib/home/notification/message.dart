import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  final VoidCallback? onSwitchToReminders;

  const MessagesScreen({Key? key, this.onSwitchToReminders}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int? _selectedTopBarIconIndex;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName =
        userProvider.user?.name ?? 'Guest'; // Default to 'Guest' if no user
    final List<MessageItem> messages = [
      MessageItem(
        sender: 'Lifecare Hospital',
        message: 'Hello Mohadeseh Shokri. We Are Here To Inform...',
        date: DateTime(2025, 2, 14),
        isFromUser: false,
      ),
      MessageItem(
        sender: 'You',
        message: 'Hello Mohadeseh Shokri. We Are Here To Inform...',
        date: DateTime(2025, 2, 10),
        isFromUser: true,
      ),
      MessageItem(
        sender: 'Lifestyle Hospital',
        message: 'Hello Mohadeseh Shokri. We Are Here To Inform...',
        date: DateTime(2025, 2, 8),
        isFromUser: false,
      ),
      MessageItem(
        sender: 'Care Hospital',
        message: 'Hello Mohadeseh Shokri. We Are Here To Inform...',
        date: DateTime(2025, 2, 5),
        isFromUser: false,
      ),
      MessageItem(
        sender: 'You',
        message: 'Hello Mohadeseh Shokri. We Are Here To Inform...',
        date: DateTime(2025, 2, 1),
        isFromUser: true,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopBar(userName),
            const SizedBox(height: 16),
            _buildTabBar(context, selected: 1),
            const SizedBox(height: 16),
            _buildMessageFilters(),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Expanded(child: _buildMessagesList(messages)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - wrap in Expanded to prevent overflow
        Expanded(
          flex: 3, // Give more space to the left side
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  'assets/homescreen/home_profile.png',
                ),
              ),
              const SizedBox(width: 12),
              // Wrap the Column in Expanded to handle text overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Color(0xFF37847E),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Wrap username in Flexible to handle long names
                        Flexible(
                          child: Text(
                            userName, // Use the passed userName here
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow:
                                TextOverflow
                                    .ellipsis, // Add ellipsis for long names
                          ),
                        ),
                        const SizedBox(width: 3),
                        _buildIcon(
                          assetPath: 'assets/homescreen/pencil.png',
                          index: 0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Right side icons
        Row(
          mainAxisSize: MainAxisSize.min, // Important: minimize the size
          children: [
            _buildIcon(
              assetPath: 'assets/homescreen/notification.png',
              index: 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TabNavigatorScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Builder(
              builder:
                  (context) => _buildIcon(
                    assetPath: 'assets/homescreen/menu.png',
                    index: 2,
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon({
    required String assetPath,
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _selectedTopBarIconIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Set this icon as selected, but only temporarily
          _selectedTopBarIconIndex = index;
        });

        // Clear selection after a short delay (visual feedback)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _selectedTopBarIconIndex = null;
            });
          }
        });

        // Execute the original onTap action
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF37847E).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          assetPath,
          width: 30,
          height: 30,
          color: isSelected ? const Color(0xFF37847E) : null,
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, {required int selected}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: widget.onSwitchToReminders,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected == 0 ? const Color(0xFF116D66) : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Reminders',
                    style: GoogleFonts.poppins(
                      color: selected == 0 ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected == 1 ? const Color(0xFF116D66) : Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  'Messages',
                  style: GoogleFonts.poppins(
                    color: selected == 1 ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFilters() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.list, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'All Messages',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.send, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Sent Messages',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.inbox, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Received',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList(List<MessageItem> messages) {
    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final message = messages[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border:
                index == 4
                    ? Border(
                      top: BorderSide(
                        color: Colors.blue[200]!,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      bottom: BorderSide(
                        color: Colors.blue[200]!,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    )
                    : null,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor:
                  message.isFromUser
                      ? const Color(0xFF37847E)
                      : Colors.grey[300],
              child: Icon(
                message.isFromUser ? Icons.person : Icons.local_hospital,
                color: message.isFromUser ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            title: Text(
              message.sender,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              message.message,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(message.date),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                if (!message.isFromUser)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF37847E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 12,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.grey[600],
                      size: 12,
                    ),
                  ),
              ],
            ),
            onTap: () {
              _openMessageDetail(message);
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openMessageDetail(MessageItem message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              message.sender,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(message.message, style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(color: const Color(0xFF37847E)),
                ),
              ),
              if (!message.isFromUser)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _replyToMessage(message);
                  },
                  child: Text(
                    'Reply',
                    style: GoogleFonts.poppins(color: const Color(0xFF37847E)),
                  ),
                ),
            ],
          ),
    );
  }

  void _replyToMessage(MessageItem message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Reply to ${message.sender}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reply sent to ${message.sender}',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Send',
                  style: GoogleFonts.poppins(color: const Color(0xFF37847E)),
                ),
              ),
            ],
          ),
    );
  }
}

class MessageItem {
  final String sender;
  final String message;
  final DateTime date;
  final bool isFromUser;

  MessageItem({
    required this.sender,
    required this.message,
    required this.date,
    required this.isFromUser,
  });
}
