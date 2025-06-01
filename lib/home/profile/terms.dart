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

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  int _selectedIndex = 0;

  int? _selectedTopBarIconIndex;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,
      // No app bar - using custom top bar instead
      body: SafeArea(
        child: Column(
          children: [
            // Custom top bar as shown in image
            _buildTopBar(userName),

            // Back button and title row
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: Color(0xFF37847E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Terms & Conditions',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF37847E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content with terms and conditions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to MedyCall. By using our app, you agree to the following terms and conditions. Please read them carefully.',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 1
                    _buildTermSection(
                      '1. Acceptance of Terms',
                      'By accessing or using MedyCall, you agree to comply with these terms and conditions. If you do not agree, please do not use our services.',
                    ),

                    // Section 2
                    _buildTermSection(
                      '2. User Responsibilities',
                      '• Provide accurate and complete information when signing up\n'
                          '• Keep your login credentials secure\n'
                          '• Use the app only for personal, non-commercial healthcare needs\n'
                          '• Do not misuse or exploit the platform for fraudulent activities',
                    ),

                    // Section 3
                    _buildTermSection(
                      '3. Appointments & Cancellations',
                      '• Booking an appointment confirms your slot with a doctor\n'
                          '• Cancellation and rescheduling policies may vary by provider\n'
                          '• Late cancellations or no-shows may incur a fee',
                    ),

                    // Section 4
                    _buildTermSection(
                      '4. Payment & Refunds',
                      '• Payments for consultations, tests, or services must be completed before the appointment\n'
                          '• Refund policies depend on the specific service and provider\n'
                          '• All fees are clearly displayed before booking',
                    ),

                    // Section 5
                    _buildTermSection(
                      '5. Medical Disclaimer',
                      '• MedyCall provides access to healthcare professionals but does not replace professional medical advice\n'
                          '• Always consult a doctor for serious health concerns\n'
                          '• We do not take responsibility for incorrect diagnoses or treatments\n'
                          '• Emergency situations require immediate medical attention',
                    ),

                    // Section 6
                    _buildTermSection(
                      '6. Privacy & Data Protection',
                      '• We collect and store your data securely in accordance with applicable laws\n'
                          '• Your information will not be shared without consent except as required by law\n'
                          '• Review our Privacy Policy for more details\n'
                          '• You have the right to access and update your personal information',
                    ),

                    // Section 7
                    _buildTermSection(
                      '7. Limitation of Liability',
                      '• We are not responsible for any medical outcomes resulting from the use of the app\n'
                          '• Any disputes between users and doctors should be resolved directly between them\n'
                          '• Our liability is limited to the maximum extent permitted by law',
                    ),

                    // Section 8
                    _buildTermSection(
                      '8. Intellectual Property',
                      '• All content, trademarks, and intellectual property on MedyCall are owned by us or our licensors\n'
                          '• You may not reproduce, distribute, or create derivative works without permission\n'
                          '• User-generated content remains your property but grants us usage rights',
                    ),

                    // Section 9
                    _buildTermSection(
                      '9. Service Availability',
                      '• We strive to maintain service availability but cannot guarantee uninterrupted access\n'
                          '• Scheduled maintenance will be communicated in advance when possible\n'
                          '• We reserve the right to modify or discontinue services',
                    ),

                    // Section 10
                    _buildTermSection(
                      '10. Changes to Terms',
                      '• We may update these terms at any time with reasonable notice\n'
                          '• Continued use of the app means you accept the revised terms\n'
                          '• Major changes will be highlighted and communicated to users',
                    ),

                    // Section 11
                    _buildTermSection(
                      '11. Governing Law',
                      '• These terms are governed by the laws of India\n'
                          '• Any disputes will be subject to the jurisdiction of Indian courts\n'
                          '• We will attempt to resolve disputes through mediation before litigation',
                    ),

                    // Section 12
                    _buildTermSection(
                      '12. Contact Us',
                      'For any questions or concerns, reach out to our support team:\n\n'
                          '📧 Email: support@medycall.com\n'
                          '📞 Phone: +91 XXXXX XXXXX\n'
                          '🕒 Support Hours: Monday to Friday, 9:00 AM to 6:00 PM IST',
                    ),

                    const SizedBox(height: 80), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF37847E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
      ],
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
                                  color: Colors.black87,
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
