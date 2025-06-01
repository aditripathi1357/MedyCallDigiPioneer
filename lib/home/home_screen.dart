import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/articles.dart';
import 'package:medycall/home/Payment/coupon.dart';
import 'package:medycall/home/filter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:medycall/home/more.dart';
import 'package:medycall/home/menu/menu.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/profile/profile.dart';
//import 'package:medycall/home/home_screen.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/Speciality/SpecialtyDoctors.dart';
import 'package:medycall/home/notification/notification.dart';

class Doctor {
  final String name;
  final String specialization;
  final String experience;
  final String languages;
  final String imagePath;
  Doctor({
    required this.name,
    required this.specialization,
    required this.experience,
    required this.languages,
    required this.imagePath,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  FilterData filterData = FilterData();

  // Add this method
  void _onFilterApplied(FilterData newFilterData) {
    setState(() {
      filterData = newFilterData;
    });
    // Your filter logic here
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName =
        userProvider.user?.name ?? 'Guest'; // Default to 'Guest' if no user

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(userName),
                const SizedBox(height: 20),
                _buildSearchBox(),
                const SizedBox(height: 20),
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                _buildServiceCategories(),
                const SizedBox(height: 24),
                _buildSpecialties(),
                const SizedBox(height: 24),
                _buildPreviousAppointments(),
                const SizedBox(height: 24),
                _buildFavoriteDoctors(context),
                const SizedBox(height: 24),
                _buildCanceledAppointments(),
                const SizedBox(height: 24),
                _buildMonthlyScheduler(),
                const SizedBox(height: 24),
                _buildHealthTrackerSection(),
                const SizedBox(height: 24),
                _buildArticlesSection(),
                const SizedBox(height: 24),
                _buildCouponsAndOffers(),
              ],
            ),
          ),
        ),
      ),
      drawer: const MenuDrawer(), // This is the correct way to add a drawer
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Add this field to your _HomeScreenState class
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
            Builder(
              builder:
                  (context) => _buildIcon(
                    assetPath: 'assets/homescreen/menu.png',
                    index: 2,
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
            ),
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

  Widget _buildSearchBox() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type Your Keyword Here',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder:
                  (context) => FilterSheet(
                    initialFilterData: filterData,
                    onApplyFilters: _onFilterApplied,
                  ),
            );
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
            maxWidth: 48,
            maxHeight: 48,
          ),
          icon: Image.asset(
            'assets/homescreen/filter.png',
            width: 48,
            height: 48,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: 385,
      height: 175,
      decoration: BoxDecoration(
        color: const Color(0xFF00796B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Polygon background design
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: CustomPaint(
                size: const Size(200, 175),
                // painter: PolygonPainter(),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome To MedyCall!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We offer a range of healthcare services tailored to your needs.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF00796B),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Watch Demo',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      'assets/homescreen/doctor.png',
                      height: 165,
                      width: 180,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book For',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // OPD Card
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoreSpecialties(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 170,
                height: 67,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Image.asset(
                        'assets/homescreen/opd.png',
                        width: 80,
                        height: 57,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'OPD',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tele-consultation Card
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoreSpecialties(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 170,
                height: 67,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Image.asset(
                        'assets/homescreen/teleconsultation.png',
                        width: 42,
                        height: 42,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tele-\nconsultation',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialties() {
    final specialties = [
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Speciality',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        // First row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              specialties
                  .take(4)
                  .map(
                    (specialty) => _buildSpecialtyItem(
                      icon: specialty['icon']!,
                      name: specialty['name']!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SpecialtyDoctorsPage(
                                  specialty: specialty['name']!.replaceAll(
                                    '\n',
                                    ' ',
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
        // Second row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...specialties
                .skip(4)
                .take(3)
                .map(
                  (specialty) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildSpecialtyItem(
                      icon: specialty['icon']!,
                      name: specialty['name']!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SpecialtyDoctorsPage(
                                  specialty: specialty['name']!.replaceAll(
                                    '\n',
                                    ' ',
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            _buildMoreButton(
              onTap: () {
                print('More button tapped');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoreSpecialties(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialtyItem({
    required String icon,
    required String name,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: 80,
        child: Column(
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
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F6F5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '•••',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 0.7,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'More',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Previous Appointments',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              onPressed: () {
                // Handle filter button tap
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
                maxWidth: 30,
                maxHeight: 30,
              ),
              icon: Image.asset(
                'assets/homescreen/filter.png',
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAppointmentCard(
                date: DateTime(2025, 1, 1, 21),
                doctorName: 'Dr. Sneha Patel',
                specialty: 'Physician',
                reason: 'Fever',
                type: 'OPD',
              ),
              _buildAppointmentCard(
                date: DateTime(2025, 1, 1, 21),
                doctorName: 'Dr. John Smith',
                specialty: 'Cardiologist',
                reason: 'Chest Pain',
                type: 'IPD',
              ),
              // Add more cards here
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required DateTime date,
    required String doctorName,
    required String specialty,
    required String reason,
    required String type,
  }) {
    return Container(
      width: 170, // Wider card
      height: 237,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4ECEA),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  DateFormat('d MMMM yyyy').format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal[900],
                  ),
                ),
                Text(
                  DateFormat('EEEE, h a').format(date),
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.teal),
                ),
                const SizedBox(height: 12),

                // Doctor Info
                Text(
                  doctorName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5DEDC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    specialty,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Consultation Reason
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.5, // Line height
                    ),
                    children: [
                      const TextSpan(
                        text: 'Consult for:\n',
                      ), // \n for line break
                      TextSpan(
                        text: '$reason ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Row (Type + Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type:', style: GoogleFonts.poppins(fontSize: 12)),
                  Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 90,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF086861),
                    padding: const EdgeInsets.symmetric(
                      vertical: 2.62,
                      horizontal: 7.87,
                    ),
                    minimumSize: const Size(90, 19.25),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Book Again',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: Colors.white,
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

  // Inside your existing Widget class (e.g., _MyExistingPageState or MyExistingPage)

  // --- Add this _buildDoctorCard method ---
  Widget _buildDoctorCard(
    BuildContext context,
    Doctor doctor,
    bool isFrontCard,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85, // Adjust width as needed
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isFrontCard
                ? const Color(0xFF086861)
                : const Color(0xFF075A54), // Slightly darker for back card
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(doctor.imagePath),
            onBackgroundImageError: (exception, stackTrace) {
              // Consider adding a placeholder or logging for missing assets
              print('Error loading image: ${doctor.imagePath}');
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doctor.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialization,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doctor.experience} Experience',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.languages,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
                if (isFrontCard) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle Book Now for this doctor
                            print('Book Now: ${doctor.name}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF018C7E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle Know More for this doctor
                            print('Know More: ${doctor.name}');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'Know More',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Inside your existing Widget class (e.g., _MyExistingPageState or MyExistingPage)

  // --- Add this _buildFavoriteDoctors method ---
  // You'll need to manage this list of doctors.
  // It could be a state variable, passed in, or fetched from an API.
  final List<Doctor> _favoriteDoctors = [
    // Example Data
    Doctor(
      name: 'Dr. Anya Sharma',
      specialization: 'BDS, MDS (Orthodontics)',
      experience: '10 Years',
      languages: 'English, Hindi',
      imagePath:
          'assets/doctor_anya.png', // Replace with your actual asset path
    ),
    Doctor(
      name: 'Dr. Bansi Patel',
      specialization: 'MBBS, MD (Medicine)',
      experience: '8 Years',
      languages: 'Hindi, English',
      imagePath:
          'assets/ladiesdoctor.png', // Replace with your actual asset path
    ),
    // Add more doctors here if needed
  ];

  Widget _buildFavoriteDoctors(BuildContext context) {
    // Renamed from your original to avoid conflict if it was a top-level function
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // Add padding for the title if desired
          child: Text(
            'Favorite Doctors',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_favoriteDoctors.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'No favorite doctors yet.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height:
                220, // Adjust this based on your card content and desired overlap
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(_favoriteDoctors.length, (index) {
                final doctor = _favoriteDoctors[index];
                // The last doctor in the list is considered the "front" card
                final isFrontCard = index == _favoriteDoctors.length - 1;

                // Calculate offset for stacking. Cards are "pulled" from the right.
                // The front card (last in list) has no offset.
                // The card behind it is offset by 20, the one behind that by 40, etc.
                double rightOffset =
                    (_favoriteDoctors.length - 1 - index) *
                    20.0; // Pushes cards to the left
                double topOffset =
                    (_favoriteDoctors.length - 1 - index) *
                    15.0; // Pushes cards upwards

                return Positioned(
                  // Adjust top and horizontal positioning for the desired stack effect
                  top: topOffset,
                  // Center the stack horizontally, then apply individual offsets
                  // This ensures the front card is centered, and others stack relative to it
                  left: rightOffset, // Pushes cards from the left
                  right:
                      0, // Keep front card aligned to the right within its conceptual space
                  // For a centered stack appearance relative to the SizedBox:
                  // left: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.85) - rightOffset) / 2 + rightOffset,
                  child: _buildDoctorCard(context, doctor, isFrontCard),
                );
              }), // No .reversed needed due to how Positioned works with Stack children order
            ),
          ),
      ],
    );
  }
  // --- End of _buildFavoriteDoctors method ---

  // --- End of _buildDoctorCard method ---
  Widget _buildCanceledAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Canceled Appointments',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              onPressed: () {
                // Handle filter button tap
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
                maxWidth: 30,
                maxHeight: 30,
              ),
              icon: Image.asset(
                'assets/homescreen/filter.png',
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 180,
          child: _buildAppointmentCard(
            date: DateTime(2025, 1, 1, 21), // 9 PM
            doctorName: 'Dr. Sneha Patel',
            specialty: 'Physician',
            reason: 'Fever',
            type: 'OPD',
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyScheduler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Scheduler',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Next Appointment Is On',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          Text(
                            '1 Jan 2025, 9 AM, Wednesday',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to monthly schedule
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text(
                        'See Your Monthly Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Image.asset(
                'assets/homescreen/monthly_schedular.png',
                height: 100,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTrackerSection() {
    final Color tealColor = const Color(0xFF00796B);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 18),
            color: tealColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Go-To Health Trecker",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enjoy The Best Ever Health Trackers All In One Place At Medycall Only!",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Water Buddy
          Row(
            children: [
              const SizedBox(width: 18),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: tealColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Forget To Drink Enough Water?",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: tealColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/homescreen/bottle.png",
                      height: 30,
                      width: 26,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "Water\nBuddy",
                      style: GoogleFonts.poppins(
                        color: tealColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),

          const SizedBox(height: 22),

          // Yoga Teacher row
          Row(
            children: [
              const SizedBox(width: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: tealColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/homescreen/Yoga.png",
                      height: 30,
                      width: 29,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Yoga\nTeacher",
                      style: GoogleFonts.poppins(
                        color: tealColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: tealColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Want To Do Yoga Correctly?",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),

          const SizedBox(height: 22),

          // Diet Guru row
          Row(
            children: [
              const SizedBox(width: 18),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: tealColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Worried About Diet?",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: tealColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/homescreen/diet.png",
                      height: 30,
                      width: 29,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Diet\nGuru",
                      style: GoogleFonts.poppins(
                        color: tealColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildArticlesSection() {
    final List<Map<String, String>> articles = [
      {
        "title": "Latest In Your Area",
        "date": "23 Jun 2023",
        "project": "103",
        "img":
            "https://placehold.co/120x80/png", // Replace with Image.asset if local assets
        "desc":
            "A Hidden Threat? Covid Mutant Tracker, Anti-Cancer Trial Causes The Therm Usisr Shock Surprises. The D106P9Y Antibody Is Suggested In Your Mask.",
      },
      {
        "title": "Latest In Your Area",
        "date": "23 Jun 2023",
        "project": "103",
        "img":
            "https://placehold.co/120x80/png", // Replace with Image.asset if local assets
        "desc":
            "A Hidden Threat? Covid Mutant Tracker, Anti-Cancer Trial Causes The Therm Usisr Shock Surprises. The D106P9Y Antibody Is Suggested In Your Mask.",
      },
    ];

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 15, 0, 7),
            child: Text(
              "Articals", // Keep original for screenshot match
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  articles.map((article) {
                    return InkWell(
                      onTap: () {
                        // TODO: Navigate to next page
                        print('Article tapped. Navigate to full article.');
                      },
                      child: Container(
                        width: 250, // Fixed width for the article container
                        margin: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 0,
                        ),
                        padding: const EdgeInsets.only(bottom: 8),
                        // Removed decoration (border and background styling)
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Keep image rounded
                              child: Image.network(
                                article["img"]!,
                                width: double.infinity,
                                height: 85,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 10, 0),
                              child: Text(
                                article["title"]!,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00796B),
                                  fontSize: 15.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 2, 10, 0),
                              child: Text(
                                "Posted On: ${article["date"]}    Projects: ${article["project"]}",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 7, 10, 0),
                              child: Text(
                                article["desc"]!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.2,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF00796B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    // TODO: Implement navigation to the full article
                                  },
                                  child: Text(
                                    "Read Full Article",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          // Add the "See More" button here
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArticlesScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'See More Articles',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsAndOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Coupons & Offers',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CouponPage()),
                );
              },
              child: Text(
                'See All',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF00796B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your Exclusive Discounts Await!',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        // First row of coupons
        Row(
          children: [
            Expanded(
              child: _buildCouponCard(
                code: 'Flat50',
                description: 'Get 25% off on your first consultation',
                color: const Color(0xFF00796B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCouponCard(
                code: 'HEALTH10',
                description: 'Avail 10% off on all OPD bookings',
                color: const Color(0xFF00796B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row of coupons
        Row(
          children: [
            Expanded(
              child: _buildCouponCard(
                code: 'FAMILYCARE',
                description: '₹100 off on family health checkups',
                color: const Color(0xFF00796B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCouponCard(
                code: 'WELLNESS20',
                description: '20% off on selected lab tests',
                color: const Color(0xFF00796B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCouponCard({
    required String code,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/appointmentcard.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                icon: Container(
                  width: 35,
                  height: 24,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/homescreen/medyscan.png',
                    width: 35,
                    height: 35,
                    color:
                        _selectedIndex == 4
                            ? const Color(0xFF00796B)
                            : Colors.grey,
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
