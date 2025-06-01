import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _selectedIndex = 0;
  int? _selectedTopBarIconIndex;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0, // Remove default app bar height
      ),
      body: Column(
        children: [
          _buildCompactTopBar(userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildFAQSection(),
                  const SizedBox(height: 24),
                  _buildContactSection(),
                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildCompactTopBar(String userName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Compact Profile Section
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00796B).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                  'assets/homescreen/home_profile.png',
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Compact User Info
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Hi, ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCompactIcon(
                    assetPath: 'assets/homescreen/pencil.png',
                    index: 0,
                    size: 16,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            // Notification Icon
            _buildCompactIcon(
              assetPath: 'assets/homescreen/notification.png',
              index: 1,
              size: 20,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TabNavigatorScreen(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactIcon({
    required String assetPath,
    required int index,
    required VoidCallback onTap,
    double size = 20,
  }) {
    final bool isSelected = _selectedTopBarIconIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTopBarIconIndex = index);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _selectedTopBarIconIndex = null);
        });
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF00796B).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(assetPath, width: size, height: size),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00796B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                color: const Color(0xFF00796B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Help & Support',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00796B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'We\'re here to assist you with any questions or concerns. Find quick solutions below or contact our support team.',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.quiz_outlined, color: const Color(0xFF00796B), size: 20),
            const SizedBox(width: 8),
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildProfessionalFAQItem(
          icon: Icons.calendar_today_outlined,
          title: 'Appointments & Bookings',
          subtitle:
              'Learn how to book, reschedule, or cancel appointments with ease.',
          color: const Color(0xFF4CAF50),
        ),

        _buildProfessionalFAQItem(
          icon: Icons.payment_outlined,
          title: 'Payments & Refunds',
          subtitle:
              'Understanding payment methods, applying coupons, and refund processes.',
          color: const Color(0xFF2196F3),
        ),

        _buildProfessionalFAQItem(
          icon: Icons.security_outlined,
          title: 'Insurance & Claims',
          subtitle:
              'Adding insurance details and utilizing coverage for medical services.',
          color: const Color(0xFF9C27B0),
        ),

        _buildProfessionalFAQItem(
          icon: Icons.person_outline,
          title: 'Account & Profile',
          subtitle:
              'Managing your profile, updating information, and privacy settings.',
          color: const Color(0xFFFF9800),
        ),

        _buildProfessionalFAQItem(
          icon: Icons.bug_report_outlined,
          title: 'Technical Support',
          subtitle:
              'Troubleshooting login issues, OTP problems, and app performance.',
          color: const Color(0xFFF44336),
        ),
      ],
    );
  }

  Widget _buildProfessionalFAQItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Handle FAQ item tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening $title section...'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00796B),
            const Color(0xFF00796B).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00796B).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Need More Help?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Our support team is available 24/7 to assist you with any questions or concerns.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle chat support
                  },
                  icon: Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text('Live Chat'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF00796B),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle call support
                  },
                  icon: Icon(Icons.phone_outlined, size: 18),
                  label: Text('Call Us'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 8,
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
                icon: Image.asset(
                  'assets/homescreen/appointment.png',
                  width: 24,
                  height: 24,
                  color:
                      _selectedIndex == 1
                          ? const Color(0xFF00796B)
                          : Colors.grey,
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
                  'assets/homescreen/medyscan.png',
                  width: 24,
                  height: 24,
                  color:
                      _selectedIndex == 4
                          ? const Color(0xFF00796B)
                          : Colors.grey,
                ),
                label: 'Medyscan',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF00796B),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              if (index != 2) {
                setState(() => _selectedIndex = index);

                // Navigate based on index
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentScreen(),
                      ),
                    );
                    break;
                  case 3:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalHistoryPage(),
                      ),
                    );
                    break;
                  case 4:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MedyscanPage()),
                    );
                    break;
                }
              }
            },
          ),
        ),
        // Centered NIROG image
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () {
              print('NIROG tapped');
              // Add your NIROG button action here
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/homescreen/nirog.png',
                width: 51,
                height: 54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
