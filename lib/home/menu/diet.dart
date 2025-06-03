import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MealTrackerPage extends StatefulWidget {
  const MealTrackerPage({Key? key}) : super(key: key);

  @override
  State<MealTrackerPage> createState() => _MealTrackerPageState();
}

class _MealTrackerPageState extends State<MealTrackerPage> {
  int _selectedIndex = 0;
  String selectedMealType = '';
  List<String> mealTags = ['Breakfast', 'Lunch', 'Snacks', 'Drinks', 'Dinner'];
  Future<Map<String, String>> _loadLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = prefs.getString('saved_location');

      if (locationString != null) {
        final savedLocation =
            json.decode(locationString) as Map<String, dynamic>;
        return savedLocation.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }
    } catch (e) {
      print('Error loading location: $e');
    }

    // Return default values if no saved location
    return {
      'area': 'Unknown Area',
      'city': 'Unknown City',
      'houseNo': '',
      'street': '',
      'landmark': '',
      'state': '',
      'pincode': '',
      'type': 'Home',
    };
  }

  String _getAreaText(Map<String, String> location) {
    // Create same display as LocationChangePage app bar
    final parts =
        [
          location['houseNo'],
          location['street'],
          location['landmark'],
          location['area'],
        ].where((part) => part != null && part.isNotEmpty).toList();

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return location['area'] ?? 'Unknown Area';
  }

  String _getCityText(Map<String, String> location) {
    return location['city'] ?? 'Unknown City';
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting and header
                      buildGreetingSection(),
                      const SizedBox(height: 20),

                      // Health info card
                      buildHealthInfoCard(),
                      const SizedBox(height: 20),

                      // Meal input section
                      buildMealInputSection(),
                      const SizedBox(height: 20),

                      // Summary section
                      buildSummarySection(),
                      const SizedBox(height: 20),

                      // Meal breakdown cards
                      buildMealBreakdownCards(),
                      const SizedBox(height: 20),

                      // CTA Banner
                      buildCTABanner(),
                      const SizedBox(height: 100), // Extra space for bottom nav
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
    return FutureBuilder<Map<String, String>>(
      future: _loadLocationData(), // This loads saved location
      builder: (context, snapshot) {
        // Get location data or use defaults
        Map<String, String> location =
            snapshot.data ??
            {
              'area': 'Unknown Area',
              'city': 'Unknown City',
              'houseNo': '',
              'street': '',
              'landmark': '',
            };

        // Create display text same as LocationChangePage
        String displayArea = _getAreaText(location);
        String displayCity = _getCityText(location);

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
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.location_on,
                        size: 30,
                        color: Color(0xFF00796B),
                      ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayArea, // This will show combined address
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        displayCity, // This will show city
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    onPressed: () async {
                      // Navigate to LocationChangePage
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationChangePage(),
                        ),
                      );

                      // Refresh the page when coming back
                      if (result != null && mounted) {
                        setState(() {}); // This refreshes the widget
                      }
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
      },
    );
  }

  Widget buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey, Alex...',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s Check How Healthy Your Meal Was Today',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget buildHealthInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00796B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Healthy Diet Provides Essential Nutrients That Fuel Your Body, Boost Immunity, And Support Overall Growth And Development.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            child: Image.asset(
              'assets/doctor_image.png',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMealInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell Us, What Did You Eat...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Meal image placeholder
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fastfood, color: Colors.orange[800], size: 30),
          ),
          const SizedBox(height: 16),

          // Meal type tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mealTags.map((tag) => buildMealTag(tag)).toList(),
          ),
          const SizedBox(height: 16),

          // Text input
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              'Add another Meal',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildActionButton('Images', Colors.grey[600]!),
              buildActionButton('Upload Recipe', Colors.grey[600]!),
              buildActionButton('Voice', Colors.grey[600]!),
              buildActionButton('Get Meal Plan', const Color(0xFF00796B)),
              buildActionButton('Submit', const Color(0xFF00796B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMealTag(String tag) {
    bool isSelected = selectedMealType == tag;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMealType = isSelected ? '' : tag;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00796B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00796B) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          tag,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildActionButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color == const Color(0xFF00796B) ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: color == const Color(0xFF00796B) ? Colors.white : color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Here Is Your Summary',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        // Fixed: Wrap the text in Expanded or use flexible text handling
        Text(
          'Not Bad, But It Is Time To Choose A Better And Healthier Meal',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          maxLines: 2, // Allow text to wrap to multiple lines
          overflow: TextOverflow.ellipsis, // Handle overflow gracefully
        ),
        const SizedBox(height: 16),

        // Circular progress and score
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: 0.81,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '1098',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Kcal',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  'Your Health Score',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '81/100',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00796B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMealBreakdownCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for cards
        double availableWidth = constraints.maxWidth;
        double cardWidth =
            (availableWidth - 24) / 3; // 24 for spacing between 3 cards

        if (cardWidth < 100) {
          // Stack vertically on very small screens
          return Column(
            children: [
              buildMealCard(
                'Breakfast',
                'Rice',
                'Peanut Butter',
                'Omelet',
                '523 Kcal',
                Colors.orange[100]!,
              ),
              const SizedBox(height: 12),
              buildMealCard(
                'Lunch',
                'Soybean',
                'Lentils (Dal)',
                'Salad',
                '602 Kcal',
                Colors.green[100]!,
              ),
              const SizedBox(height: 12),
              buildMealCard(
                'Snacks',
                'Nuts',
                'Yogurt & Honey',
                'Smoothie',
                '421 Kcal',
                Colors.blue[100]!,
              ),
            ],
          );
        } else {
          // Show horizontally with flexible sizing
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 1,
                  child: buildMealCard(
                    'Breakfast',
                    'Rice',
                    'Peanut Butter',
                    'Omelet',
                    '523 Kcal',
                    Colors.orange[100]!,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 1,
                  child: buildMealCard(
                    'Lunch',
                    'Soybean',
                    'Lentils (Dal)',
                    'Salad',
                    '602 Kcal',
                    Colors.green[100]!,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 1,
                  child: buildMealCard(
                    'Snacks',
                    'Nuts',
                    'Yogurt & Honey',
                    'Smoothie',
                    '421 Kcal',
                    Colors.blue[100]!,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildMealCard(
    String title,
    String item1,
    String item2,
    String item3,
    String calories,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item1,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
          ),
          Text(
            item2,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
          ),
          Text(
            item3,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          // Fixed: Stack the calories and edit button vertically for narrow cards
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                calories,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.black87,
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

  Widget buildCTABanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00796B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Explore The Best Ever Health Tracker Only On Medycall',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
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
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.home,
                        color:
                            _selectedIndex == 0
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
                      ),
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
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.calendar_today,
                        color:
                            _selectedIndex == 1
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
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
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.history,
                        color:
                            _selectedIndex == 3
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
                      ),
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
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.local_hospital,
                        color:
                            _selectedIndex == 4
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
                      ),
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
                // Add navigation logic here
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
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 51,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00796B),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
