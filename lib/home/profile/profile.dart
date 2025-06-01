import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/home/profile/demographic.dart';
import 'package:medycall/home/profile/lifestyle.dart';
import 'package:medycall/home/profile/medical.dart';
import 'package:medycall/home/profile/terms.dart';
import 'package:medycall/home/profile/privacy.dart';
import 'package:medycall/home/profile/help.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:medycall/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:medycall/History/history.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationsEnabled = false;
  int _selectedIndex = 0; // Profile is selected
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Set the selected index to 4 for Profile tab
    _selectedIndex = 4;
  }

  // Function to request permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Try photos permission first (for Android 13+)
      var photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) {
        return true;
      }

      // Fallback to storage permission (for older Android versions)
      var storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      return false;
    }
    return true; // iOS handles permissions automatically
  }

  // Function to show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Image Source',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(
                          Icons.photo_library,
                          color: Color(0xFF008D83),
                        ),
                        title: const Text('Gallery'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromGallery();
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF008D83),
                        ),
                        title: const Text('Camera'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromCamera();
                        },
                      ),
                      if (_selectedImage != null)
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text('Remove Photo'),
                          onTap: () {
                            Navigator.pop(context);
                            _removeImage();
                          },
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to remove image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile image removed'),
        backgroundColor: Color(0xFF008D83),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      // Request permissions first
      bool hasPermission = await _requestPermissions();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Color(0xFF008D83),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: Please try again'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      // Request camera permission
      var cameraStatus = await Permission.camera.request();
      if (cameraStatus.isGranted) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: Color(0xFF008D83),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      print('Error picking image from camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: Please try again'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to show permission dialog
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'This app needs access to your photos and camera to change your profile picture. Please grant permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text(
                'Settings',
                style: TextStyle(color: Color(0xFF008D83)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Teal/Green header with Profile title
          Container(
            width: double.infinity,
            height: 200,
            color: const Color(0xFF008D83),
            padding: const EdgeInsets.only(top: 60, left: 16),
            alignment: Alignment.topLeft,
            child: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Main content area
          Expanded(
            child: Container(
              color:
                  isDarkMode
                      ? const Color(0xFF121212)
                      : const Color(0xFFF5F5F5),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // White rounded card
                  Positioned(
                    top: -40,
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDarkMode
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60, bottom: 20),
                        child: Column(
                          children: [
                            // Profile Name and Username
                            Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              '@Mohadeseh_shokri',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDarkMode ? Colors.grey[400] : Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Horizontal line
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 25,
                              ),
                              height: 1,
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.3),
                            ),

                            const SizedBox(height: 10),

                            // Settings list
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingItem(
                                      title: 'Demographic Data',
                                      icon: Icons.person_outline,
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const DemographicDataScreen(),
                                            ),
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Lifestyle',
                                      icon: Icons.favorite_border,
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const LifestyleForm(),
                                            ),
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Medical',
                                      icon: Icons.medical_services_outlined,
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const MedicalInfoScreen(),
                                            ),
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Location',
                                      icon: Icons.location_on_outlined,
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const LocationChangePage(),
                                            ),
                                          ),
                                    ),
                                    _buildSettingItem(
                                      title: 'Language',
                                      icon: Icons.language,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Eng',
                                            style: TextStyle(
                                              color:
                                                  isDarkMode
                                                      ? Colors.grey[400]
                                                      : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.grey,
                                          ),
                                        ],
                                      ),
                                      onTap: () {},
                                    ),
                                    _buildSwitchItem(
                                      title: 'Dark Mode',
                                      icon: Icons.dark_mode_outlined,
                                      value: themeProvider.isDarkMode,
                                      onChanged:
                                          (value) =>
                                              themeProvider.setTheme(value),
                                    ),
                                    _buildSwitchItem(
                                      title: 'Notification',
                                      icon: Icons.notifications_outlined,
                                      value: isNotificationsEnabled,
                                      onChanged:
                                          (value) => setState(() {
                                            isNotificationsEnabled = value;
                                          }),
                                    ),
                                    _buildSettingItem(
                                      title: 'Privacy Policy',
                                      icon: Icons.privacy_tip_outlined,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    PrivacyPolicyScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildSettingItem(
                                      title: 'Terms',
                                      icon: Icons.description_outlined,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const TermsAndConditionsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildSettingItem(
                                      title: 'Help And Feedback',
                                      icon: Icons.help_outline,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const HelpSupportScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Profile picture with edit functionality - FIXED
                  Positioned(
                    top: -80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          // Profile image container (clickable)
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    _selectedImage != null
                                        ? Image.file(
                                          _selectedImage!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.asset(
                                          'assets/profile_image.png',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          },
                                        ),
                              ),
                            ),
                          ),
                          // Edit button positioned at bottom-right - FIXED CLICKABILITY
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                print('Edit button tapped!'); // Debug print
                                _showImageSourceDialog();
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF008D83),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSettingItem({
    required String title,
    IconData? icon,
    Widget? customIcon,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return SizedBox(
      height: 45,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              customIcon ?? Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return SizedBox(
      height: 45,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF008D83),
              activeTrackColor: const Color(0xFF008D83).withOpacity(0.5),
              inactiveThumbColor: isDarkMode ? Colors.grey[600] : null,
              inactiveTrackColor: isDarkMode ? Colors.grey[800] : null,
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
