import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/home/home_screen.dart'; // Add fl_chart: ^0.68.0 to your pubspec.yaml

// pubspec.yaml dependencies:
// dependencies:
//   flutter:
//     sdk: flutter
//   google_fonts: ^6.2.1
//   fl_chart: ^0.68.0 # Or latest version

//   assets:
//     - assets/
//     - assets/menu/
//     - assets/homescreen/
//     - assets/location.png # Make sure this specific file is in assets/

// Dummy pages for navigation

class WaterReminderPage extends StatefulWidget {
  const WaterReminderPage({super.key});

  @override
  State<WaterReminderPage> createState() => _WaterReminderPageState();
}

class _WaterReminderPageState extends State<WaterReminderPage> {
  int _selectedIndex = 0;
  int _glassesDrunk =
      4; // Initial value based on "You Have Drank 4 Glass Today..."
  final int _dailyTarget = 10;
  List<bool> _glassStates = List.generate(
    10,
    (index) => index < 4,
  ); // First 4 are filled

  // Data for the bar chart - Saturday's value will be _glassesDrunk
  List<BarChartGroupData> get _barData => [
    _makeGroupData(0, 6, isTouched: false), // Sun
    _makeGroupData(1, 10, isTouched: false), // Mon
    _makeGroupData(2, 7, isTouched: false), // Tue
    _makeGroupData(3, 8, isTouched: false), // Wed
    _makeGroupData(4, 4, isTouched: false), // Thu
    _makeGroupData(5, 9, isTouched: false), // Fri
    _makeGroupData(
      6,
      _glassesDrunk.toDouble(),
      isTouched: true,
    ), // Sat (dynamic)
  ];

  BarChartGroupData _makeGroupData(int x, double y, {bool isTouched = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color:
              isTouched
                  ? const Color(0xFF00796B)
                  : Colors.teal.withOpacity(0.5),
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  void _toggleGlass(int index) {
    setState(() {
      _glassStates[index] = !_glassStates[index];
      _glassesDrunk = _glassStates.where((state) => state == true).length;
    });
  }

  Widget _buildBottomNavigationBar() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 80, // Add explicit height
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
              fontSize: 10, // Smaller font size
              fontWeight: FontWeight.w400,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10, // Smaller font size
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

  Widget buildLocationWidget() {
    // User provided code for buildLocationWidget
    // Ensure 'assets/location.png' exists
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F8), // Light mint/cyan background
        // borderRadius: BorderRadius.circular(4), // Original image doesn't show rounded corners for this bar
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), // Adjusted padding
        child: Row(
          children: [
            Image.asset(
              'assets/location.png',
              width: 24, // Adjusted size
              height: 24, // Adjusted size
              color: const Color(0xFF00796B), // Teal color
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.location_on,
                    color: Color(0xFF00796B),
                    size: 24,
                  ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patel Colony',
                    style: GoogleFonts.poppins(
                      fontSize: 15, // Adjusted size
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Junagadh',
                    style: GoogleFonts.poppins(
                      fontSize: 11, // Adjusted size
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 28, // Adjusted size
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationChangePage(),
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
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  'Change Location',
                  style: GoogleFonts.poppins(
                    fontSize: 10, // Adjusted size
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            buildLocationWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hey Alex Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hey, Alex....',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Time To Hydrate Your Body Again!',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Image.asset(
                          'assets/menu/waterdoctor.png',
                          height: 100, // Adjust as needed
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height: 100,
                                width: 80,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Your Body Needs Water Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00796B), // Teal color
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Body Needs Water More Than You Think',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Let's Build The Habit Together",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // You Have Drank X Glass Today...
                    Center(
                      child: Text(
                        'You Have Drank $_glassesDrunk Glass Today...',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Water Glasses Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _toggleGlass(index),
                            child: Image.asset(
                              _glassStates[index]
                                  ? 'assets/menu/filledglass.png'
                                  : 'assets/menu/emptyglass.png',
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      _glassStates[index]
                                          ? Icons.local_drink
                                          : Icons.add_circle_outline,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Drank Today vs Daily Target
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$_glassesDrunk Glass',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Drank Today',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Column(
                          children: [
                            Text(
                              '$_dailyTarget Glass',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Daily Target',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Reminder Message
                    if (_glassesDrunk < _dailyTarget / 2) // Example condition
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE), // Light pink
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "you haven't drank much. ",
                              style: GoogleFonts.poppins(
                                color: Colors.red[700],
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle Set Reminder tap
                                print("Set Reminder tapped");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Set Reminder functionality to be implemented.',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Set remainder?',
                                style: GoogleFonts.poppins(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Best and Worst Record
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Best Record',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '10 Glasses 😊',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Worst Record',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '1 Glass 😟',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Statistics Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statistics',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'This Week ▾',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              _dailyTarget.toDouble() +
                              2, // Max Y value for the chart
                          minY: 0,
                          groupsSpace: 20,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final days = [
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      days[value.toInt()],
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[300]!,
                                strokeWidth: 0.5,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          barGroups: _barData,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Explore Medycall Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00796B), // Teal color
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Explore The Best Ever Health Tracker Only On Medycall',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Extra space at the bottom
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
}
