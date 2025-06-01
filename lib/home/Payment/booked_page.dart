import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/home/payment/rescheduled_page.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/home/payment/canceled_page.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

class BookedPage extends StatefulWidget {
  const BookedPage({super.key});

  @override
  State<BookedPage> createState() => _BookedPageState();
}

class _BookedPageState extends State<BookedPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildCompactTopBar(userName),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBackNavigation(),
                      const SizedBox(height: 24),
                      _buildSuccessCard(),
                      const SizedBox(height: 32),
                      _buildRescheduleSection(),
                      const SizedBox(height: 24),
                      _buildCancelSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  int? _selectedTopBarIconIndex;

  Widget _buildCompactTopBar(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ), // Reduced padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - wrap in Expanded to prevent overflow
          Expanded(
            flex: 3, // Give more space to the left side
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16, // Slightly smaller radius
                  backgroundImage: AssetImage(
                    'assets/homescreen/home_profile.png',
                  ),
                ),
                const SizedBox(width: 10), // Reduced spacing
                // Wrap the Column in Expanded to handle text overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: GoogleFonts.poppins(
                          fontSize: 12, // Slightly smaller font
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
                                fontSize: 14, // Slightly smaller font
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
            ],
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(4), // Reduced padding
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF37847E).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6), // Smaller radius
        ),
        child: Image.asset(
          assetPath,
          width: 24, // Smaller icon size
          height: 24,
          color: isSelected ? const Color(0xFF37847E) : null,
        ),
      ),
    );
  }

  Widget _buildBackNavigation() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF37847E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF37847E),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Appointment Confirmation',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 40,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Booking Confirmed!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your appointment has been successfully scheduled. You will receive a confirmation notification as your appointment time approaches.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 20,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need to Reschedule?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Change to the earliest available time slot',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RescheduledPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Reschedule Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 20,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to Attend?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Cancel in advance to avoid fees and help others book',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => CanceledPage()),
                // );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cancel Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
