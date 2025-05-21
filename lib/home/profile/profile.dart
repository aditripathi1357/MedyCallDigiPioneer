import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/home/profile/demographic.dart';
import 'package:medycall/home/profile/lifestyle.dart';
import 'package:medycall/home/profile/medical.dart';
import 'package:medycall/home/profile/terms.dart';
import 'package:medycall/home/profile/privacy.dart';
import 'package:medycall/home/profile/help.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/History/history.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = false;
  int _selectedIndex = 4; // Profile is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Teal/Green header with Profile title
          Container(
            width: double.infinity,
            height: 200,
            color: const Color(0xFF008D83),
            padding: const EdgeInsets.only(
              top: 60,
              left: 16,
            ), // Add left padding
            alignment: Alignment.topLeft, // Align to top-left
            child: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Main content area
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // White rounded card
                  Positioned(
                    top: -40, // Adjusted for better position
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 60, // Reduced to avoid overlap with name
                          bottom: 20,
                        ),
                        child: Column(
                          children: [
                            // Profile Name and Username
                            Text(
                              'Mr. Mohdeseh Shokri',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '@Mohadeseh_shokri',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Horizontal line
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 25,
                              ),
                              height: 1,
                              color: Colors.grey.withOpacity(0.3),
                            ),

                            const SizedBox(height: 10),

                            // Settings list
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingItem(
                                      title: 'Demographic Data',
                                      icon: Icons.person_outline,
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      DemographicDataScreen(),
                                            ),
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Lifestyle',
                                      icon: Icons.favorite_border,
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => LifestyleForm(),
                                            ),
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Medical',
                                      icon: Icons.medical_services_outlined,
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      MedicalInfoScreen(),
                                            ),
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Location',
                                      icon: Icons.location_on_outlined,
                                      onTap: () {},
                                    ),
                                    _buildSettingItem(
                                      title: 'Language',
                                      icon: Icons.language,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Eng',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 5),

                                          Image.asset(
                                            'assets/profile_arrow.png',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                      onTap: () {},
                                    ),
                                    _buildSwitchItem(
                                      title: 'Dark Mode',
                                      icon: Icons.dark_mode_outlined,
                                      value: isDarkMode,
                                      onChanged:
                                          (value) => setState(
                                            () => isDarkMode = value,
                                          ),
                                    ),
                                    _buildSwitchItem(
                                      title: 'Notification',
                                      icon: Icons.notifications_outlined,
                                      value: isNotificationsEnabled,
                                      onChanged:
                                          (value) => setState(
                                            () =>
                                                isNotificationsEnabled = value,
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Privacy Policy',
                                      icon: Icons.privacy_tip_outlined,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    PrivacyPolicyScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildSettingItem(
                                      title: 'Terms',
                                      icon: Icons.description_outlined,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    TermsAndConditionsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildSettingItem(
                                      title: 'Help And Feedback',
                                      icon: Icons.help_outline,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    HelpSupportScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    // Add Log Out option
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Profile picture - positioned to match the image
                  Positioned(
                    top: -80, // Higher position to center on card edge
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 80, // Slightly smaller size
                        height: 80, // Slightly smaller size
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/profile_image.png'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSettingItem({
    required String title,
    IconData? icon, // IconData is now optional
    Widget? customIcon, // For Image.asset or any widget
    Color iconColor = Colors.black54,
    Color textColor = Colors.black,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 45,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              customIcon ?? Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              trailing ??
                  Image.asset(
                    'assets/profile_arrow.png',
                    width: 20,
                    height: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      height: 45, // Made slightly shorter to match image
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14, // Slightly smaller text to match image
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF008D83),
              activeTrackColor: const Color(0xFF008D83).withOpacity(0.5),
            ),
          ],
        ),
      ),
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
}
