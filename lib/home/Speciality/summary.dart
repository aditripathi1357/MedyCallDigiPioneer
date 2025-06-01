import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/home/Speciality/bookslot.dart';
import 'package:medycall/home/payment/coupon.dart';
import 'package:medycall/home/payment/makepayment.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AppointmentSummaryScreen extends StatefulWidget {
  const AppointmentSummaryScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentSummaryScreen> createState() =>
      _AppointmentSummaryScreenState();
}

class _AppointmentSummaryScreenState extends State<AppointmentSummaryScreen> {
  int _selectedIndex = 1; // Setting appointment tab as selected

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            buildLocationWidget(),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Appointment Summery',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildSectionHeader('patient Details'),
                      const SizedBox(height: 12),
                      buildDetailRow('Patient Name', userName),
                      const SizedBox(height: 12),
                      buildDetailRow('Contact Number', '+91 11111 11111'),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Colors.grey),
                      const SizedBox(height: 20),
                      buildSectionHeader('Doctor Details'),
                      const SizedBox(height: 12),
                      buildDetailRow('Doctor Name', 'Dr. aaa bbb'),
                      const SizedBox(height: 12),
                      buildDetailRow(
                        'Address',
                        'Lifecare Hospital, SP ring road, Delhi, India',
                        hasEditButton: false,
                      ),
                      const SizedBox(height: 12),
                      buildDetailRow(
                        'Mode of Consult',
                        'Offline OPD',
                        hasEditButton: false,
                      ),
                      const SizedBox(height: 16),
                      buildAppointmentTime(),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Colors.grey),
                      const SizedBox(height: 20),
                      buildSectionHeader(
                        "Apply Coupon",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CouponPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Colors.grey),
                      const SizedBox(height: 16),
                      buildTotalAmount(),
                      const SizedBox(height: 24),
                      buildProceedButton(),
                      const SizedBox(height: 16),
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

  Widget buildLocationWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Image.asset(
              'assets/location.png',
              width: 30,
              height: 30,
              color: const Color(0xFF00796B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patel Colony',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Junagadh',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationChangePage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change Location',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buildDetailRow(
    String label,
    String value, {
    bool hasEditButton = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (hasEditButton)
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Edit',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildAppointmentTime() {
    return Row(
      children: [
        Image.asset(
          'assets/specialties/calendarsummary.png',
          width: 30,
          height: 30,
          color: const Color(0xFF00796B),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '22 Jan 2025, Wednesday',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                '10:30 AM to 10:45 AM',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SlotBookingScreen()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Change',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Amount',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          '300 /-',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00796B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Proceed to Pay',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
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
