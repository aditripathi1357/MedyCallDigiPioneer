import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/home/home_screen.dart';
//import 'package:medycall/home/home_screen.dart';
import 'package:medycall/History/history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Data model for an article
class Article {
  final String title;
  final String subtitle;
  final String imagePath;
  final String description;

  Article({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.description,
  });
}

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
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

  // Dummy data for articles
  // Replace 'assets/covid_article_placeholder.png' with your actual asset paths
  final List<Article> _articles = [
    Article(
      title: 'Latest In Your Area',
      subtitle: 'Posted On: 25 Jan 2025\nProjon Nesto Jibon',
      imagePath:
          'assets/covid_article_placeholder.png', // Replace with your image
      description:
          'Ahmedabad Reported 3 Covid Positive Today And Quarantine Them Under Strict Surveillance. The Citizens Of Ahmedabad Is Suggested To Wear Mask.',
    ),
    Article(
      title: 'Latest In Your Area',
      subtitle: 'Posted On: 24 Jan 2025\nHealth Tips Weekly',
      imagePath:
          'assets/covid_article_placeholder.png', // Replace with your image
      description:
          'Another important health update concerning the local community, preventative measures and wellness advice. Stay informed and healthy.',
    ),
    Article(
      title: 'Latest In Your Area',
      subtitle: 'Posted On: 23 Jan 2025\nCommunity Wellness Drive',
      imagePath:
          'assets/covid_article_placeholder.png', // Replace with your image
      description:
          'Details about the upcoming community wellness drive. Participate to learn more about healthy living and get free check-ups.',
    ),
  ];

  // Your provided buildLocationWidget
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

  // Widget to build a single article card
  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      elevation: 1.0, // Subtle shadow
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00796B), // Teal color
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        article.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Color(0xFF00796B)),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // Handle share action
                    print('Share button pressed for ${article.title}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                article.imagePath,
                height: 150, // Adjust height as needed
                width: double.infinity,
                fit: BoxFit.cover,
                // Error builder for placeholder if image fails to load
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
                height: 1.4, // Line height
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Read Full Article action
                  print('Read Full Article pressed for ${article.title}');
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => FullArticlePage(article: article)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B), // Teal color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text('Read Full Article'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the list of article cards
  Widget _buildArticleListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        return _buildArticleCard(_articles[index]);
      },
    );
  }

  // Your provided _buildBottomNavigationBar
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F5,
      ), // Light grey background for the screen
      body: SafeArea(
        // Ensures content is not obscured by system UI
        child: Column(
          children: [
            buildLocationWidget(), // Your top location bar
            Expanded(
              child: _buildArticleListView(), // The list of article cards
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(), // Your bottom navigation bar
    );
  }
}
