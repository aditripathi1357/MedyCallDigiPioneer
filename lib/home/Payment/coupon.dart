import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/home/payment/makepayment.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({Key? key}) : super(key: key);

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  int _selectedIndex = 2; // NIROG selected by default
  int? _expandedCouponIndex; // Track which coupon is expanded, null if none

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(userName),
              const SizedBox(height: 20),
              _buildApplyCouponSection(),
              const SizedBox(height: 20),
              Expanded(child: _buildCouponsList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  int? _selectedTopBarIconIndex;

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

  Widget _buildApplyCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey[700]),
            Text(
              'Apply Coupon',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Coupon Code',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Apply',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00796B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCouponsList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildExpandableCouponCard(0),
          const SizedBox(height: 16),
          _buildExpandableCouponCard(1),
        ],
      ),
    );
  }

  Widget _buildExpandableCouponCard(int index) {
    bool isExpanded = _expandedCouponIndex == index;

    return Column(
      children: [
        // The coupon card
        _buildCouponCard(index),

        // Terms and conditions below the specific coupon if expanded
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildTermsAndConditions(),
          ),
      ],
    );
  }

  Widget _buildCouponCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left green part with "FIRST" text
          Container(
            width: 60,
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFF00A19A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(
                  'FIRST50',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Right part with coupon details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '457826',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Get ₹50 off on your\nfirst consultation.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Barcode image
                      Container(
                        width: 100,
                        height: 30,
                        child: Image.asset(
                          'assets/barcode.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Spacer(),
                      // Know more button - toggle the specific coupon's expansion
                      TextButton(
                        onPressed: () {
                          setState(() {
                            // If this coupon is already expanded, collapse it
                            // Otherwise, expand this one (which automatically collapses any other)
                            if (_expandedCouponIndex == index) {
                              _expandedCouponIndex = null;
                            } else {
                              _expandedCouponIndex = index;
                            }
                          });
                        },
                        child: Text(
                          'know more',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xFF00A19A),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      // Redeem button
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Redeem',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms and Conditions applied',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildTermItem('Offer is valid only on selected clinics'),
          _buildTermItem(
            'Coupon code can be applied only once in 2 hr on this hospital.',
          ),
          _buildTermItem('Offer valid till 11 Dec 2025, 11:59 PM.'),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
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
