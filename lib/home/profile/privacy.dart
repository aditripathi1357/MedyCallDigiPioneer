import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/Appointment/appointment.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  int _selectedIndex = 0;
  int? _selectedTopBarIconIndex;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Top Bar
          _buildTopBar(userName),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy Policy Title
                  Text(
                    'Privacy Policy',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateTime.now().toString().substring(0, 10)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Introduction
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37847E).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF37847E).withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      'Welcome To MedyCall! Your Privacy Is Important To Us. This Privacy Policy Explains How We Collect, Use, And Protect Your Information. By Using Our App, You Agree To The Terms Outlined Below.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 1
                  _buildSectionTitle('1. Information We Collect'),
                  const SizedBox(height: 12),
                  Text(
                    'When You Use MedyCall, We Collect The Following Types Of Information:',
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildSubSectionTitle('A. Personal Information'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint(
                          'Name, Phone Number, Email Address, And Date Of Birth.',
                        ),
                        _buildBulletPoint(
                          'Medical History And Health Records (If Provided).',
                        ),
                        _buildBulletPoint(
                          'Payment Details For Transactions (Handled Securely).',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSubSectionTitle('B. Non-Personal Information'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint(
                          'Device Details (IP Address, OS Version, App Usage Data).',
                        ),
                        _buildBulletPoint(
                          'Location Data (if Enabled For Finding Nearby Doctors).',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 2
                  _buildSectionTitle('2. How We Use Your Information'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint(
                          'Facilitate Appointment Bookings And Teleconsultations.',
                        ),
                        _buildBulletPoint(
                          'Provide Personalized Healthcare Recommendations.',
                        ),
                        _buildBulletPoint(
                          'Process Payments And Generate Invoices.',
                        ),
                        _buildBulletPoint(
                          'Improve User Experience And App Functionality.',
                        ),
                        _buildBulletPoint(
                          'Send Appointment Reminders, Updates, And Promotional Offers (You Can Opt Out).',
                        ),
                        _buildBulletPoint(
                          'Ensure Security, Prevent Fraud, And Comply With Legal Requirements.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 3
                  _buildSectionTitle('3. Data Sharing and Disclosure'),
                  const SizedBox(height: 8),
                  Text(
                    'We do not sell, trade, or rent your personal information to third parties. However, we may share your information in the following circumstances:',
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint(
                          'With healthcare providers for appointment and consultation purposes.',
                        ),
                        _buildBulletPoint(
                          'With payment processors for secure transaction handling.',
                        ),
                        _buildBulletPoint(
                          'When required by law or to protect our rights and safety.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 4
                  _buildSectionTitle('4. Data Security'),
                  const SizedBox(height: 8),
                  Text(
                    'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Section 5
                  _buildSectionTitle('5. Your Rights'),
                  const SizedBox(height: 8),
                  Text(
                    'You have the right to access, update, or delete your personal information. Contact us if you wish to exercise these rights.',
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Section 6
                  _buildSectionTitle('6. Contact Us'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Have questions about this Privacy Policy?',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'privacy@medycall.com',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTopBar(String userName) {
    return Container(
      // padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Left side - Profile section
            Expanded(
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF37847E).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(
                        'assets/homescreen/home_profile.png',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hello,',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF37847E),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  // color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildIcon(
                              assetPath: 'assets/homescreen/pencil.png',
                              index: 0,
                              size: 18,
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

            // Right side - Notification icon
            _buildIcon(
              assetPath: 'assets/homescreen/notification.png',
              index: 1,
              size: 24,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TabNavigatorScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon({
    required String assetPath,
    required int index,
    required VoidCallback onTap,
    double size = 24,
  }) {
    final bool isSelected = _selectedTopBarIconIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTopBarIconIndex = index;
        });

        // Clear selection after animation
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _selectedTopBarIconIndex = null;
            });
          }
        });

        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF37847E).withOpacity(0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(assetPath, width: size, height: size),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF37847E),
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF37847E),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
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
                    MaterialPageRoute(builder: (context) => MedyscanPage()),
                  );
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
            child: Image.asset(
              'assets/homescreen/nirog.png',
              width: 51,
              height: 54,
            ),
          ),
        ),
      ],
    );
  }
}
