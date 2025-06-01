import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/Speciality/HospitalListing.dart';
import 'package:medycall/home/Speciality/DoctorProfile.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/filter.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';

class SpecialtyDoctorsPage extends StatefulWidget {
  final String specialty;

  const SpecialtyDoctorsPage({super.key, required this.specialty});

  @override
  State<SpecialtyDoctorsPage> createState() => _SpecialtyDoctorsPageState();
}

class _SpecialtyDoctorsPageState extends State<SpecialtyDoctorsPage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'OPD';
  int _selectedTab = 0; // 0 for Doctor, 1 for Hospital

  // Mock data for doctors - replace with data from your database
  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Bansi Patel',
      'specialty': 'Physician',
      'qualification': 'MBBS, MD (Medicine)',
      'rating': 4.8,
      'experience': '8 Years',
      'patients': '5482 patient Examined',
      'languages': 'Hindi, English',
      'hospital': 'Lifecare Hospital',
      'address': '2nd floor, ABC complex, SP ring road, Junagadh',
      'nextAvailable': '01: 30 PM - 21 Jan, Wed',
      'image': 'assets/doctors/doctor1.png',
    },
    {
      'name': 'Dr. Bansi Patel',
      'specialty': 'Physician',
      'qualification': 'MBBS, MD (Medicine)',
      'rating': 4.8,
      'experience': '8 Years',
      'patients': '5482 patient Examined',
      'languages': 'Hindi, English',
      'hospital': 'Lifecare Hospital',
      'address': '2nd floor, ABC complex, SP ring road, Junagadh',
      'nextAvailable': '01: 30 PM - 21 Jan, Wed',
      'image': 'assets/doctors/doctor1.png',
    },
  ];
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
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Widget
            buildLocationWidget(),
            _buildAppointmentTabs(),

            // Back Button and Specialty Name
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.specialty,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar and filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
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
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
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
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
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
              ),
            ),

            // OPD and Tele-consultation filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // OPD Card
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'OPD';
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 170,
                      height: 67,
                      decoration: BoxDecoration(
                        color:
                            _selectedFilter == 'OPD'
                                ? const Color(0xFFE7F6F5)
                                : Colors.white,
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
                      setState(() {
                        _selectedFilter = 'Tele-consultation';
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 170,
                      height: 67,
                      decoration: BoxDecoration(
                        color:
                            _selectedFilter == 'Tele-consultation'
                                ? const Color(0xFFE7F6F5)
                                : Colors.white,
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
            ),

            // Doctor List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return buildDoctorCard(doctor);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppointmentTabs() {
    return Center(
      child: Container(
        width: 250, // Adjust width as needed
        decoration: BoxDecoration(
          color: const Color(0x086861CC).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Doctor tab is already selected, no navigation needed
                  setState(() {
                    _selectedTab = 0;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF00796B,
                    ), // Always selected since we're on Doctor page
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Doctor',
                      style: GoogleFonts.poppins(
                        color:
                            Colors.white, // Always white since always selected
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to Hospital page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HospitalListingScreen(
                            specialty: widget.specialty,
                          ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Not selected
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Hospital',
                      style: GoogleFonts.poppins(
                        color: const Color(
                          0xFF00796B,
                        ), // Teal color for unselected
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Info Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Doctor details section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Image - Using original filename
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/specialties/doctor2.png',
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Doctor Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    doctor['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                // Like and Share buttons with absolutely no gap
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {}, // Handle like
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        9,
                                      ), // Centers the 18x18 icon in 36x36 area
                                      child: SvgPicture.asset(
                                        'assets/specialties/likespec.svg',
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {}, // Handle share
                                    child: Padding(
                                      padding: const EdgeInsets.all(9),
                                      child: SvgPicture.asset(
                                        'assets/specialties/sharespec.svg',
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                // Removed the Spacer() here
                                Image.asset(
                                  'assets/specialties/verified.png',
                                  width: 27,
                                  height: 27,
                                ),
                              ],
                            ),
                            Text(
                              doctor['specialty'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              doctor['qualification'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index < doctor['rating'].floor()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${doctor['experience']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  height: 14,
                                  width: 1,
                                  color: Colors.grey[400],
                                ),
                                Text(
                                  doctor['patients'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DoctorProfileScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00796B),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(80, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
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
                      ),
                    ),
                  ],
                ),

                // Languages - Fixed positioning
                Container(
                  padding: const EdgeInsets.only(
                    left: 18.0,
                    bottom: 12.0,
                    right: 18.0,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        doctor['languages'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Hospital Info
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFF00796B),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['hospital'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              doctor['address'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/specialties/map.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Next available slot and Book Now button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next available at',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            doctor['nextAvailable'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorProfileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
