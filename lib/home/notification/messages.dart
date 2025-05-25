import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIROG App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MessagesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedIndex = 0;
  int _selectedTabIndex = 1; // 0 for Reminders, 1 for Messages

  final List<MessageItem> _messages = [
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(userName),
              const SizedBox(height: 16),

              // Tabs for Reminders and Messages
              _buildTabSection(),
              const SizedBox(height: 16),

              // Message filters
              _buildMessageFilters(),
              const SizedBox(height: 8),

              // Divider before messages
              const Divider(height: 1, thickness: 1, color: Colors.grey),

              // Messages List
              Expanded(child: _buildMessagesList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopBar(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/person.png'),
            ),
            const SizedBox(width: 12),
            Column(
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
                    Text(
                      userName, // Use the passed userName here
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    GestureDetector(
                      onTap: () {
                        // Handle image tap
                      },
                      child: Image.asset(
                        'assets/homescreen/pencil.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // Handle notification tap
              },
              child: Image.asset(
                'assets/homescreen/notification.png',
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    final activeColor = const Color(0xFF116D66);
    final inactiveColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          // Reminders Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Reminders',
                    style: GoogleFonts.poppins(
                      color:
                          _selectedTabIndex == 0
                              ? Colors.white
                              : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Messages Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Messages',
                    style: GoogleFonts.poppins(
                      color:
                          _selectedTabIndex == 1
                              ? Colors.white
                              : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.separated(
      itemCount: _messages.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final message = _messages[index];
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message.sender,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          message.isFromUser
                              ? Colors.black
                              : const Color(0xFF116D66),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${message.date.day} ${_getMonthName(message.date.month)}. ${message.date.year}, ${_getDayName(message.date.weekday)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message.message,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF116D66)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF116D66),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/homescreen/home.png',
                  width: 24,
                  height: 24,
                  color:
                      _selectedIndex == 0
                          ? const Color(0xFF00796B)
                          : Colors.grey,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Image.asset(
                    'assets/homescreen/appointment.png',
                    width: 24,
                    height: 24,
                    color:
                        _selectedIndex == 1
                            ? const Color(0xFF00796B)
                            : Colors.grey,
                  ),
                ),
                label: 'Appointment',
              ),
              BottomNavigationBarItem(
                icon: const SizedBox(width: 24, height: 24),
                label: 'NIROG',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/homescreen/history.png',
                  width: 24,
                  height: 24,
                  color:
                      _selectedIndex == 3
                          ? const Color(0xFF00796B)
                          : Colors.grey,
                ),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/homescreen/profile.png',
                  width: 24,
                  height: 24,
                  color:
                      _selectedIndex == 4
                          ? const Color(0xFF00796B)
                          : Colors.grey,
                ),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF00796B),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 13.8,
              fontWeight: FontWeight.w400,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 13.8,
              fontWeight: FontWeight.w400,
            ),
            onTap: (index) {
              if (index != 2) {
                setState(() {
                  _selectedIndex = index;
                });

                // Navigate based on index
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentScreen(),
                    ),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalHistoryPage(),
                    ),
                  );
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                }
              }
            },
          ),
        ),
        // Centered NIROG image
        Positioned(
          top: -20,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('NIROG tapped');
                  // Add your NIROG button action here
                },
                child: Image.asset(
                  'assets/homescreen/nirog.png',
                  width: 51,
                  height: 54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }

  String _getDayName(int weekday) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[weekday - 1];
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

// Dummy screens for navigation
class DummyScreen extends StatelessWidget {
  final String title;

  const DummyScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}
