import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/Appointment/appointment.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // No app bar - using custom top bar instead
      body: SafeArea(
        child: Column(
          children: [
            // Custom top bar as shown in image
            _buildTopBar(),

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
                      'Welcome To MedyCall By Using Our App, You Agree To The Following Terms And Conditions. Please Read Them Carefully.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 1
                    _buildTermSection(
                      '1. Acceptance Of Terms',
                      'By Accessing Or Using MediCall, You Agree To Comply With These Terms & Conditions. If You Do Not Agree, Please Do Not Use Our Services.',
                    ),

                    // Section 2
                    _buildTermSection(
                      '2. User Responsibilities',
                      '• Provide Accurate And Complete Information When Signing Up.\n'
                          '• Keep Your Login Credentials Secure.\n'
                          '• Use The App Only For Personal, Non-Commercial Healthcare Needs.\n'
                          '• Do Not Misuse Or Exploit The Platform For Fraudulent Activities.',
                    ),

                    // Section 3
                    _buildTermSection(
                      '3. Appointments & Cancellations',
                      '• Booking An Appointment Confirms Your Slot With A Doctor.\n'
                          '• Cancellation And Rescheduling Policies May Vary By Provider.\n'
                          '• Late Cancellations Or No-Shows May Incur A Fee.',
                    ),

                    // Section 4
                    _buildTermSection(
                      '4. Payment & Refunds',
                      '• Payments For Consultations, Tests, Or Services Must Be Completed Before The Appointment.\n'
                          '• Refund Policies Depend On The Specific Service And Provider.',
                    ),

                    // Section 5
                    _buildTermSection(
                      '5. Medical Disclaimer',
                      '• MediCall Provides Access To Healthcare Professionals But Does Not Replace Professional Medical Advice.\n'
                          '• Always Consult A Doctor For Serious Health Concerns.\n'
                          '• We Do Not Take Responsibility For Incorrect Diagnoses Or Treatments.',
                    ),

                    // Section 6
                    _buildTermSection(
                      '6. Privacy & Data Protection',
                      '• We Collect And Store Your Data Securely.\n'
                          '• Your Information Will Not Be Shared Without Consent Except As Required By Law.\n'
                          '• Review Our Privacy Policy For More Details.',
                    ),

                    // Section 7
                    _buildTermSection(
                      '7. Limitations Of Liability',
                      '• We Are Not Responsible For Any Medical Outcomes Resulting From The Use Of The App.\n'
                          '• Any Disputes Between Users And Doctors Should Be Resolved Directly Between Them.',
                    ),

                    // Section 8
                    _buildTermSection(
                      '8. Changes To Terms',
                      '• We May Update These Terms At Any Time. Continued Use Of The App Means You Accept The Revised Terms.',
                    ),

                    // Section 9
                    _buildTermSection(
                      '9. Contact Us',
                      '• For Any Questions Or Concerns, Reach Out To Our Support Team At:\n'
                          '• Email: Support@MediCall.com\n'
                          '• Phone: +91 XXXXX XXXXX',
                    ),

                    const SizedBox(height: 80), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTopBar() {
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
                      'Mohadeesh Shokri',
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
            const SizedBox(width: 3),
            GestureDetector(
              onTap: () {
                // Handle image tap
              },
              child: Image.asset(
                'assets/homescreen/notification.png',
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(width: 3),
            const SizedBox(width: 3),
          ],
        ),
      ],
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
