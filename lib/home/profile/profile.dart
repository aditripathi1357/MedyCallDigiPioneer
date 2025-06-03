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
// import 'package:firebase_storage/firebase_storage.dart'; // Example for Firebase Storage
// import 'package:path/path.dart' as p; // For getting file extension

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationsEnabled = false;
  int _selectedIndex =
      4; // Profile is selected (assuming this matches your nav bar logic)
  File? _selectedImageFile; // Local file picked by user for preview and upload
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 4;
    // Fetch user profile if not already loaded, to get profileImageUrl
    // Provider.of<UserProvider>(context, listen: false).fetchUserProfile();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) return true;
      var storageStatus =
          await Permission.storage.request(); // For older Android
      if (storageStatus.isGranted) return true;
      return false;
    }
    return true; // iOS permissions are handled differently or implicitly by picker
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final hasExistingImage =
            (userProvider.user?.profileImageUrl != null &&
                userProvider.user!.profileImageUrl!.isNotEmpty) ||
            _selectedImageFile != null;

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
                          _pickImage(ImageSource.gallery);
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
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      if (hasExistingImage)
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

  Future<void> _removeImage() async {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
      _selectedImageFile = null; // Clear local preview immediately
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // Update backend with null or empty string for profileImageUrl
      bool success = await userProvider.updateUserProfileFields({
        'profileImageUrl': null,
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed'),
            backgroundColor: Color(0xFF008D83),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove profile image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Optionally, if backend update failed, revert UI if needed or re-fetch user
        await userProvider.fetchUserProfile(); // Re-sync with server state
      }
    } catch (e) {
      print('Error removing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing profile image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      await userProvider.fetchUserProfile();
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isUploading) return;

    bool hasPermission = true;
    if (source == ImageSource.gallery) {
      hasPermission = await _requestPermissions();
    } else if (source == ImageSource.camera) {
      var cameraStatus = await Permission.camera.request();
      hasPermission = cameraStatus.isGranted;
    }

    if (!hasPermission) {
      _showPermissionDialog();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        if (mounted) {
          setState(() {
            _selectedImageFile = File(image.path);
            _isUploading = true; // Start loading indicator
          });
        }

        // --- Conceptual Image Upload Step ---
        // You need to implement this part.
        // Example: String? imageUrl = await _uploadFileToStorage(_selectedImageFile!);
        // For now, we'll simulate a delay and a placeholder URL.

        // Simulating upload
        await Future.delayed(const Duration(seconds: 2));
        // String? imageUrl = "https://example.com/path/to/uploaded/image.jpg"; // Placeholder

        // ** REPLACE THE ABOVE SIMULATION WITH YOUR ACTUAL UPLOAD LOGIC **
        // Example with a hypothetical upload function:
        String? imageUrl;
        try {
          // imageUrl = await uploadImageToFirebaseStorage(_selectedImageFile!); // Your actual upload function
          // For demonstration, let's assume upload is successful and gives a URL.
          // In a real app, if _selectedImageFile is null, handle it.
          if (_selectedImageFile != null) {
            // This is a placeholder for your actual upload logic
            // You would use firebase_storage, supabase_storage, or a custom backend.
            print(
              "Conceptual upload: Pretend uploading ${_selectedImageFile!.path}",
            );
            imageUrl =
                "https://via.placeholder.com/150/008D83/FFFFFF?Text=Uploaded+${DateTime.now().second}";
          }
        } catch (uploadError) {
          print("Error during conceptual upload: $uploadError");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: $uploadError'),
              backgroundColor: Colors.red,
            ),
          );
          if (mounted) {
            setState(() {
              _isUploading = false;
              // _selectedImageFile = null; // Optionally clear preview if upload fails critically
            });
          }
          return;
        }
        // --- End of Conceptual Image Upload Step ---

        if (imageUrl != null) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          bool success = await userProvider.updateUserProfileFields({
            'profileImageUrl': imageUrl,
          });
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated successfully!'),
                backgroundColor: Color(0xFF008D83),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save image URL. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            // Optionally revert _selectedImageFile or re-fetch user data
            await userProvider.fetchUserProfile();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get image URL after upload.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // --- Placeholder for actual image upload logic ---
  // Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
  //   try {
  //     String fileName = p.basename(imageFile.path);
  //     Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/${userProvider.user!.id}/$fileName');
  //     UploadTask uploadTask = storageRef.putFile(imageFile);
  //     TaskSnapshot snapshot = await uploadTask;
  //     return await snapshot.ref.getDownloadURL();
  //   } catch (e) {
  //     print("Firebase upload error: $e");
  //     return null;
  //   }
  // }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'This app needs access to your photos and/or camera to change your profile picture. Please grant permission in app settings.',
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
    // It's better to get UserProvider once in build if used multiple times.
    // Use Consumer<UserProvider> for parts that need to rebuild on change.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
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
          Expanded(
            child: Container(
              color:
                  isDarkMode
                      ? const Color(0xFF121212)
                      : const Color(0xFFF5F5F5),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 20,
                    right: 20,
                    bottom: 20, // Adjust if content overflows
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
                        padding: const EdgeInsets.only(
                          top: 70,
                          bottom: 20,
                        ), // Increased top padding for name
                        child: Consumer<UserProvider>(
                          // Use Consumer for reactive UI
                          builder: (context, userProvider, child) {
                            final userName = userProvider.user?.name ?? 'Guest';
                            final userEmail =
                                userProvider.user?.email ?? '@guest';
                            return Column(
                              children: [
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
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                                          onTap:
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          PrivacyPolicyScreen(),
                                                ),
                                              ),
                                        ),
                                        _buildSettingItem(
                                          title: 'Terms',
                                          icon: Icons.description_outlined,
                                          onTap:
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const TermsAndConditionsScreen(),
                                                ),
                                              ),
                                        ),
                                        _buildSettingItem(
                                          title: 'Help And Feedback',
                                          icon: Icons.help_outline,
                                          onTap:
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const HelpSupportScreen(),
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -80, // Adjust to align with the card's new top padding
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 10, // Center the 80x80 image inside 100x100
                              top: 10,
                              child: Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  Widget imageWidget;
                                  if (_selectedImageFile != null) {
                                    // Previewing newly picked image
                                    imageWidget = Image.file(
                                      _selectedImageFile!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                                  } else if (userProvider
                                              .user
                                              ?.profileImageUrl !=
                                          null &&
                                      userProvider
                                          .user!
                                          .profileImageUrl!
                                          .isNotEmpty) {
                                    imageWidget = Image.network(
                                      userProvider.user!.profileImageUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildProfileImagePlaceholder(),
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF008D83),
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    imageWidget =
                                        _buildProfileImagePlaceholder();
                                  }

                                  return GestureDetector(
                                    onTap:
                                        _isUploading
                                            ? null
                                            : _showImageSourceDialog,
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
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(child: imageWidget),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:
                                      _isUploading
                                          ? null
                                          : _showImageSourceDialog,
                                  borderRadius: BorderRadius.circular(14),
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
                                    child:
                                        _isUploading
                                            ? const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Icon(
                                              Icons.edit,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfileImagePlaceholder() {
    return Image.asset(
      'assets/profile_image.png', // Your placeholder asset
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback for the placeholder itself
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey[300],
          child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
        );
      },
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
