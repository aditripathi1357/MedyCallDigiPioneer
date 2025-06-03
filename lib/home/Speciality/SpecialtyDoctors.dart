import 'dart:convert';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/Speciality/HospitalListing.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/filter.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SpecialtyDoctorsPage extends StatefulWidget {
  final String specialty;

  const SpecialtyDoctorsPage({super.key, required this.specialty});

  @override
  State<SpecialtyDoctorsPage> createState() => _SpecialtyDoctorsPageState();
}

class _SpecialtyDoctorsPageState extends State<SpecialtyDoctorsPage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'OPD';

  // Create screenshot controllers for each doctor card

  final Map<int, ScreenshotController> _screenshotControllers = {};

  // Initialize keys for each doctor

  @override
  void initState() {
    super.initState();

    // Initialize screenshot controllers for each doctor

    for (int i = 0; i < _doctors.length; i++) {
      _screenshotControllers[i] = ScreenshotController();
    }
  }

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

      // Add coordinates for more precise location
      'latitude': 21.5222, // Junagadh coordinates

      'longitude': 70.4579,
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

      'latitude': 21.5222,

      'longitude': 70.4579,
    },
  ];

  // Function to get current location

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check location permission

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Location permission denied')));

          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission permanently denied')),
        );

        return null;
      }

      // Get current position

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting current location')));

      return null;
    }
  }

  // Function to open Google Maps with directions

  Future<void> _openGoogleMaps(Map<String, dynamic> doctor) async {
    try {
      Position? currentPosition = await _getCurrentLocation();

      String googleMapsUrl;

      if (currentPosition != null) {
        // Open with directions from current location to doctor's location

        if (doctor['latitude'] != null && doctor['longitude'] != null) {
          // Use coordinates if available

          googleMapsUrl =
              'https://www.google.com/maps/dir/${currentPosition.latitude},${currentPosition.longitude}/${doctor['latitude']},${doctor['longitude']}/@${doctor['latitude']},${doctor['longitude']},15z';
        } else {
          // Use address if coordinates not available

          String encodedAddress = Uri.encodeComponent(
            '${doctor['hospital']}, ${doctor['address']}',
          );

          googleMapsUrl =
              'https://www.google.com/maps/dir/${currentPosition.latitude},${currentPosition.longitude}/$encodedAddress';
        }
      } else {
        // Fallback: Just show the doctor's location without directions

        if (doctor['latitude'] != null && doctor['longitude'] != null) {
          googleMapsUrl =
              'https://www.google.com/maps/search/?api=1&query=${doctor['latitude']},${doctor['longitude']}';
        } else {
          String encodedAddress = Uri.encodeComponent(
            '${doctor['hospital']}, ${doctor['address']}',
          );

          googleMapsUrl =
              'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
        }
      }

      final Uri url = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open Google Maps')));
      }
    } catch (e) {
      print('Error opening Google Maps: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening Google Maps')));
    }
  }

  FilterData filterData = FilterData();

  void _onFilterApplied(FilterData newFilterData) {
    setState(() {
      filterData = newFilterData;
    });
  }

  // Method to capture and share doctor card as image

  Future<void> _shareCardAsImage(int doctorIndex) async {
    try {
      // Show loading indicator

      showDialog(
        context: context,

        barrierDismissible: false,

        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Capture the screenshot

      final Uint8List? imageBytes = await _screenshotControllers[doctorIndex]!
          .capture(delay: const Duration(milliseconds: 100), pixelRatio: 2.0);

      // Hide loading indicator

      if (mounted) Navigator.pop(context);

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save to temporary directory

      final Directory tempDir = await getTemporaryDirectory();

      final String fileName =
          'doctor_card_${DateTime.now().millisecondsSinceEpoch}.png';

      final File file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(imageBytes);

      // Share the image

      await Share.shareXFiles(
        [XFile(file.path)],

        text: 'Check out this doctor: ${_doctors[doctorIndex]['name']}',

        subject: 'Doctor Information - ${_doctors[doctorIndex]['name']}',
      );

      // Clean up file after sharing

      Future.delayed(const Duration(seconds: 30), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      // Hide loading indicator if still showing

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('Error sharing card as image: $e');

      // Show error message and fallback to text

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share as image, sharing as text instead'),

            backgroundColor: Colors.orange,
          ),
        );

        _shareAsText(doctorIndex);
      }
    }
  }

  // Fallback text sharing method

  void _shareAsText(int doctorIndex) {
    final doctor = _doctors[doctorIndex];

    Share.share(
      'Check out this doctor:\n\n'
      'Name: ${doctor['name']}\n'
      'Specialty: ${doctor['specialty']}\n'
      'Hospital: ${doctor['hospital']}\n'
      'Address: ${doctor['address']}\n'
      'Rating: ${doctor['rating']}\n'
      'Experience: ${doctor['experience']}\n'
      'Patients Examined: ${doctor['patients']}\n'
      'Languages: ${doctor['languages']}\n'
      'Next Available: ${doctor['nextAvailable']}',

      subject: 'Doctor Information',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            buildLocationWidget(),

            _buildAppointmentTabs(),

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

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,

                vertical: 16.0,
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
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

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),

                itemCount: _doctors.length,

                itemBuilder: (context, index) {
                  final doctor = _doctors[index];

                  return buildDoctorCard(doctor, index);
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
        width: 250,

        decoration: BoxDecoration(
          color: const Color(0x086861CC).withOpacity(0.05),

          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {});
                },

                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),

                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B),

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Center(
                    child: Text(
                      'Doctor',

                      style: GoogleFonts.poppins(
                        color: Colors.white,

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
                    color: Colors.transparent,

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Center(
                    child: Text(
                      'Hospital',

                      style: GoogleFonts.poppins(
                        color: const Color(0xFF00796B),

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
    return FutureBuilder<Map<String, String>>(
      future: _loadLocationData(),

      builder: (context, snapshot) {
        Map<String, String> location =
            snapshot.data ??
            {
              'area': 'Unknown Area',

              'city': 'Unknown City',

              'houseNo': '',

              'street': '',

              'landmark': '',
            };

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
                        displayArea,

                        style: GoogleFonts.poppins(
                          fontSize: 16,

                          fontWeight: FontWeight.w600,

                          color: Colors.black,
                        ),

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        displayCity,

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
                      final result = await Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => const LocationChangePage(),
                        ),
                      );

                      if (result != null && mounted) {
                        setState(() {});
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

  Widget buildDoctorCard(Map<String, dynamic> doctor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      child: Screenshot(
        controller: _screenshotControllers[index]!,

        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),

                      child: Image.asset(
                        'assets/specialties/doctor2.png',

                        width: 80,

                        height: 120,

                        fit: BoxFit.cover,

                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 80,

                              height: 120,

                              color: Colors.grey[300],

                              child: const Icon(Icons.person, size: 40),
                            ),
                      ),
                    ),
                  ),

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

                              Material(
                                type: MaterialType.transparency,

                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),

                                  onTap: () {}, // Handle like

                                  child: Padding(
                                    padding: const EdgeInsets.all(9),

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

                                  onTap: () => _shareCardAsImage(index),

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

                              Container(
                                width: 27,

                                height: 27,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),

                                child: Image.asset(
                                  'assets/specialties/verified.png',

                                  width: 18,

                                  height: 18,
                                ),
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
                            children: List.generate(
                              5,

                              (starIndex) => Icon(
                                starIndex < doctor['rating'].floor()
                                    ? Icons.star
                                    : Icons.star_border,

                                color: Colors.amber,

                                size: 14,
                              ),
                            ),
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

                              Expanded(
                                child: Text(
                                  doctor['patients'],

                                  style: GoogleFonts.poppins(
                                    fontSize: 12,

                                    fontWeight: FontWeight.w500,

                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,

                            child: ElevatedButton(
                              onPressed: () {},

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

                    // Updated map icon with tap functionality
                    Material(
                      type: MaterialType.transparency,

                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),

                        onTap: () => _openGoogleMaps(doctor),

                        child: Padding(
                          padding: const EdgeInsets.all(4),

                          child: SvgPicture.asset(
                            'assets/specialties/map.svg',

                            width: 18,

                            height: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                      onPressed: () {},

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
