import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/home/payment/booked_page.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedIndex = 1; // Assuming this is the Appointment page
  String? _selectedPaymentMethod;
  int? _selectedTopBarIconIndex;

  // Payment method icons mapping
  final Map<String, IconData> _paymentIcons = {
    'Google Pay': Icons.payment,
    'Paytm': Icons.account_balance_wallet,
    'BHIM Pay': Icons.qr_code,
    'PhonePe': Icons.phone_android,
    'Amazon Pay': Icons.shopping_cart,
    'Airtel Payments Bank': Icons.sim_card,
    'Mobikwik': Icons.account_balance_wallet_outlined,
    'Phone Pay': Icons.phone_android,
    'NetBanking': Icons.account_balance,
    'Credit & Debit Cards': Icons.credit_card,
  };

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(userName),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
                const SizedBox(width: 10),
                Text(
                  'Make Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pay Of Appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment methods sections
            _buildPaymentMethodSection('UPI', [
              'Google Pay',
              'Paytm',
              'BHIM Pay',
              'PhonePe',
            ]),

            _buildPaymentMethodSection('Wallet', [
              'Amazon Pay',
              'Airtel Payments Bank',
              'Mobikwik',
              'Phone Pay',
            ]),

            _buildPaymentMethodSection('Other', [
              'NetBanking',
              'Credit & Debit Cards',
            ]),

            const SizedBox(height: 20),

            // Payment summary
            _buildPaymentSummary(),

            const SizedBox(height: 20),

            // Payment buttons
            _buildPaymentButtons(),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildPaymentMethodSection(String title, List<String> options) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        children: [
          Column(
            children:
                options.map((option) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _paymentIcons[option] ?? Icons.payment,
                          size: 20,
                          color: const Color(0xFF00796B),
                        ),
                      ),
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Radio<String>(
                        value: option,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        activeColor: const Color(0xFF00796B),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      children: [
        _buildPaymentRow('Appointment Cost', '300'),
        _buildPaymentRow('Booking Cost', '5'),
        _buildPaymentRow('Coupen', '- 100', isDiscount: true),
        _buildPaymentRow('Tax', '10'),
        Divider(height: 20, thickness: 1, color: Colors.grey.shade300),
        _buildPaymentRow('Total', '205', isTotal: true),
      ],
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color:
                  isDiscount
                      ? Colors.green
                      : (isTotal ? Colors.black : Colors.black87),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Handle Pay Later
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF00796B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Pay Later',
              style: GoogleFonts.poppins(
                color: const Color(0xFF00796B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookedPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00796B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Make payment',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Smaller and more compact top bar
  Widget _buildTopBar(String userName) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 10), // Reduced padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - more compact
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16, // Reduced from 20
                  backgroundImage: AssetImage(
                    'assets/homescreen/home_profile.png',
                  ),
                ),
                const SizedBox(width: 8), // Reduced from 12
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Added this
                    children: [
                      Text(
                        'Hello,',
                        style: GoogleFonts.poppins(
                          fontSize: 12, // Reduced from 14
                          color: Color(0xFF37847E),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 14, // Reduced from 16
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
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
          // Right side icons - more compact
          Row(
            mainAxisSize: MainAxisSize.min,
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
          _selectedTopBarIconIndex = index;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _selectedTopBarIconIndex = null;
            });
          }
        });

        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(4), // Reduced from 5
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF37847E).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6), // Reduced from 8
        ),
        child: Image.asset(
          assetPath,
          width: 24, // Reduced from 30
          height: 24, // Reduced from 30
          color: isSelected ? const Color(0xFF37847E) : null,
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
