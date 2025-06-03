import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MedyscanPage extends StatefulWidget {
  @override
  State<MedyscanPage> createState() => _MedyscanPageState();
}

class _MedyscanPageState extends State<MedyscanPage> {
  String? pickedFilePath;
  String? pickedFileName;
  int _selectedIndex = 4;
  int? _selectedTopBarIconIndex;
  bool isLoading = false;

  final List<String> _tags = [
    'Brain tumor / Cancer',
    'Alzheimer/ Dementia',
    'Bone Fracture',
    'Spinal Cord',
    'Breast cancer',
    'Blood report',
    'Hair Care',
    'Skin Care',
  ];

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    // For Android 13+, you might need different permissions
    if (!status.isGranted) {
      var mediaStatus = await Permission.photos.request();
      return mediaStatus.isGranted;
    }

    return status.isGranted;
  }

  Future<void> _pickFile() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Request permission first
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        _showPermissionDialog();
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Pick file with error handling
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Check if file path is available
        if (file.path != null) {
          setState(() {
            pickedFilePath = file.path!;
            pickedFileName = file.name;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File selected: ${file.name}'),
              backgroundColor: const Color(0xFF00796B),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Handle case where path is null (Web platform)
          setState(() {
            pickedFileName = file.name;
            // For web, you might need to handle bytes instead of path
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      _showErrorDialog('Failed to pick file. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Request camera permission
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _showPermissionDialog(isCamera: true);
        setState(() {
          isLoading = false;
        });
        return;
      }

      final ImagePicker picker = ImagePicker();
      XFile? pickedPhoto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compress image
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedPhoto != null) {
        setState(() {
          pickedFilePath = pickedPhoto.path;
          pickedFileName = pickedPhoto.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured successfully!'),
            backgroundColor: Color(0xFF00796B),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error taking photo: $e');
      _showErrorDialog('Failed to take photo. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPermissionDialog({bool isCamera = false}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Permission Required',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              isCamera
                  ? 'Camera permission is required to take photos.'
                  : 'Storage permission is required to access files.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text(
                  'Settings',
                  style: GoogleFonts.poppins(color: const Color(0xFF00796B)),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(message, style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(color: const Color(0xFF00796B)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFE2F6F2), Color(0xFF1A998E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.75, 1.0],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildTopBar(userName),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 6,
                          bottom: 0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Medyscane",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF183B36),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 0,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Get an AI-powered diagnosis in minutes",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            380, // Increased height to accommodate better spacing
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle
                            Positioned(
                              top: 25,
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  color: const Color(0x08686163),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Shadow
                            Positioned(
                              bottom: 30,
                              child: Container(
                                width: 120,
                                height: 15,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                            ),
                            // Human body image
                            Positioned(
                              bottom: 40,
                              child: _buildSafeImage(
                                'assets/medyscan/human_body.png',
                                height: 280,
                              ),
                            ),
                            ..._buildTagButtons(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "Upload your report and know the key takeaways\njust in few clicks",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.75),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Show selected file name if any
                      if (pickedFileName != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F6F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00796B),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.description,
                                  color: Color(0xFF00796B),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pickedFileName!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF00796B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      pickedFilePath = null;
                                      pickedFileName = null;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Color(0xFF00796B),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (pickedFileName != null) const SizedBox(height: 16),

                      // Upload/Take photo buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: _optionButton(
                                iconPath: "assets/medyscan/upload_files.png",
                                text: isLoading ? "Loading..." : "Choose file",
                                onTap: isLoading ? () {} : _pickFile,
                                background: const Color(0xFFE2F6F2),
                                isLoading: isLoading,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _optionButton(
                                iconPath: "assets/medyscan/camera.png",
                                text: isLoading ? "Loading..." : "Take photo",
                                onTap: isLoading ? () {} : _takePhoto,
                                background: const Color(0xFFE2F6F2),
                                isLoading: isLoading,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Upload & analyze button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00796B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 0,
                            ),
                            onPressed:
                                (pickedFilePath != null && !isLoading)
                                    ? () {
                                      _showDisclaimerDialog(context);
                                    }
                                    : null,
                            child: Text(
                              "Upload & analyze",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Supported formats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Text(
                              "Supported file formats include PDF, DOC, DOCX,",
                              style: GoogleFonts.poppins(
                                fontSize: 11.4,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "JPG, PNG, and JPEG",
                              style: GoogleFonts.poppins(
                                fontSize: 11.4,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    bool isAcknowledged = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00796B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "This AI-generated diagnosis is for informational purposes only and should not replace professional medical advice. Please consult a qualified healthcare provider for accurate evaluation.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isAcknowledged,
                          activeColor: const Color(0xFF00796B),
                          onChanged:
                              (val) => setState(() {
                                isAcknowledged = val ?? false;
                              }),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'I understand and acknowledge this disclaimer',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF00796B),
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Back",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF00796B),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00796B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed:
                                isAcknowledged
                                    ? () {
                                      // Continue logic here
                                      Navigator.pop(context);
                                      // Add your file processing logic here
                                    }
                                    : null,
                            child: Text(
                              "continue",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Safe image widget with error handling
  Widget _buildSafeImage(String assetPath, {double? width, double? height}) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[600],
            size: (height ?? 100) * 0.3,
          ),
        );
      },
    );
  }

  // Updated tag button positioning to avoid overlapping with body parts
  List<Widget> _buildTagButtons() {
    return [
      // Top row - positioned higher and further out
      Positioned(top: 10, left: 30, child: _optionTagBox(_tags[0])),
      Positioned(top: 10, right: 30, child: _optionTagBox(_tags[1])),

      // Second row - positioned on the sides, away from chest area
      Positioned(top: 70, left: 5, child: _optionTagBox(_tags[2])),
      Positioned(top: 70, right: 5, child: _optionTagBox(_tags[3])),

      // Third row - positioned lower on the sides, away from torso
      Positioned(top: 140, left: 20, child: _optionTagBox(_tags[4])),
      Positioned(top: 140, right: 20, child: _optionTagBox(_tags[5])),

      // Bottom row - positioned much lower, away from leg area
      Positioned(top: 210, left: 40, child: _optionTagBox(_tags[6])),
      Positioned(top: 210, right: 40, child: _optionTagBox(_tags[7])),
    ];
  }

  Widget _optionTagBox(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x08686163),
        border: Border.all(color: const Color(0xFF00796B), width: 1),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black.withOpacity(0.07),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF00796B),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

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

  Widget _optionButton({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
    required Color background,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isLoading ? background.withOpacity(0.5) : background,
          border: Border.all(color: const Color(0xFF00796B)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 2.9,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.019),
            ),
          ],
        ),
        child: Column(
          children: [
            isLoading
                ? const SizedBox(
                  width: 29,
                  height: 29,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00796B),
                    ),
                  ),
                )
                : _buildSafeImage(iconPath, width: 29, height: 29),
            const SizedBox(height: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF00796B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
