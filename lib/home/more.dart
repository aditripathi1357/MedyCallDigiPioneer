import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/Speciality/SpecialtyDoctors.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/home/home_screen.dart'; // Import the specialty doctors page
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MoreSpecialties extends StatefulWidget {
  const MoreSpecialties({super.key});

  @override
  State<MoreSpecialties> createState() => _MoreSpecialtiesState();
}

class _MoreSpecialtiesState extends State<MoreSpecialties> {
  int _selectedIndex = 0;
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
      appBar: null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Widget
            buildLocationWidget(),

            // Specialty Heading
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Specialty',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Specialties Grid
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children:
                          specialties
                              .map(
                                (specialty) => buildSpecialtyItem(
                                  icon: specialty['icon'] as String,
                                  name: specialty['name'] as String,
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 30),
                    // Symptoms Input
                    Text(
                      'Write About Your Symptoms',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'For Example, I Feel Fever At Night Only Etc.',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle proceed button tap
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Proceed',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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

  Widget buildSpecialtyItem({required String icon, required String name}) {
    return InkWell(
      onTap: () {
        // Navigate to SpecialtyDoctorsPage when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    SpecialtyDoctorsPage(specialty: name.replaceAll('\n', ' ')),
          ),
        );
      },
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F6F5),
                shape: BoxShape.circle,
              ),
              child: Image.asset(icon, width: 40, height: 40),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
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
}

// List of all specialties with icons
final List<Map<String, String>> specialties = [
  {'icon': 'assets/specialties/general.png', 'name': 'General\nPhysician'},
  {'icon': 'assets/specialties/neurologist.png', 'name': 'Neurologist'},
  {'icon': 'assets/specialties/nutritionist.png', 'name': 'Nutritionist'},
  {'icon': 'assets/specialties/dentist.png', 'name': 'Dentist'},
  {'icon': 'assets/specialties/pediatrician.png', 'name': 'Pediatrician'},
  {'icon': 'assets/specialties/radiologist.png', 'name': 'Radiologist'},
  {
    'icon': 'assets/specialties/ophthalmologist.png',
    'name': 'Ophthalmo\nLogist',
  },
  {'icon': 'assets/specialties/cardiologist.png', 'name': 'Cardio\nLogist'},
  {'icon': 'assets/specialties/orthopedic.png', 'name': 'Ortho\nPedics'},
  {
    'icon': 'assets/specialties/gastroenterologist.png',
    'name': 'Gastro\nEnterologist',
  },
  {'icon': 'assets/specialties/ent.png', 'name': 'ENT'},
  {'icon': 'assets/specialties/nephrologist.png', 'name': 'Nephro\nLogist'},
  {'icon': 'assets/specialties/gynecologist.png', 'name': 'Gyneco\nLogist'},
  {'icon': 'assets/specialties/pulmonologist.png', 'name': 'Pulmono\nLogist'},
  {'icon': 'assets/specialties/dermatologist.png', 'name': 'Dermato\nLogist'},
  {'icon': 'assets/specialties/others.png', 'name': 'Others'},
];
