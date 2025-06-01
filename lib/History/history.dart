import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/home/home_screen.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:medycall/home/notification/notification.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({Key? key}) : super(key: key);

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class MedicalRecordItem {
  final String name;
  final String date;
  final String type; // 'image' or 'document'
  final File file;
  final String recordType; // 'OPD' or 'Tele'

  MedicalRecordItem({
    required this.name,
    required this.date,
    required this.type,
    required this.file,
    required this.recordType,
  });
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  int _selectedIndex = 3; // History tab is selected
  String _selectedRecordType = "OPD"; // Default to OPD
  final ImagePicker _picker = ImagePicker();
  List<MedicalRecordItem> records = [];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName =
        userProvider.user?.name ?? 'Guest'; // Default to 'Guest' if no user
    return Scaffold(
      drawer: const Drawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(userName),
              const SizedBox(height: 20),
              Expanded(
                child:
                    records.isEmpty
                        ? _buildNoRecordsContent()
                        : _buildRecordsContent(),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildNoRecordsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oops! No Medical Records Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'A detailed health history helps doctor diagnose you better',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildRecordTypeSelector(),
        const SizedBox(height: 20),
        Text(
          'Add Record',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 14),
        _buildUploadOption(
          icon: Icons.camera_alt_outlined,
          title: 'Take a photo',
          onTap: _takePhoto,
        ),
        const SizedBox(height: 10),
        _buildUploadOption(
          icon: Icons.image_outlined,
          title: 'Upload from gallery',
          onTap: _pickImage,
        ),
        const SizedBox(height: 10),
        _buildUploadOption(
          icon: Icons.file_copy_outlined,
          title: 'Upload files',
          onTap: _pickDocument,
        ),
        const Spacer(),
        Center(
          child: Text(
            'No records uploaded yet',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecordsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Medical Records',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'A detailed health history helps doctor diagnose you better',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildRecordTypeSelector(),
        const SizedBox(height: 20),
        Text(
          'Add Record',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 14),
        _buildUploadOption(
          icon: Icons.camera_alt_outlined,
          title: 'Take a photo',
          onTap: _takePhoto,
        ),
        const SizedBox(height: 10),
        _buildUploadOption(
          icon: Icons.image_outlined,
          title: 'Upload from gallery',
          onTap: _pickImage,
        ),
        const SizedBox(height: 10),
        _buildUploadOption(
          icon: Icons.file_copy_outlined,
          title: 'Upload files',
          onTap: _pickDocument,
        ),
        const SizedBox(height: 20),
        Text(
          'Uploaded Records',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Expanded(child: _buildRecordsList()),
      ],
    );
  }

  Widget _buildRecordTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // OPD Card
        InkWell(
          onTap: () {
            setState(() {
              _selectedRecordType = "OPD";
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 170,
            height: 67,
            decoration: BoxDecoration(
              color:
                  _selectedRecordType == "OPD"
                      ? Color(0xFFE1F5F3)
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
                    color:
                        _selectedRecordType == "OPD"
                            ? Color(0xFF00796B)
                            : Colors.black,
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
              _selectedRecordType = "Tele";
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 170,
            height: 67,
            decoration: BoxDecoration(
              color:
                  _selectedRecordType == "Tele"
                      ? Color(0xFFE1F5F3)
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
                    color:
                        _selectedRecordType == "Tele"
                            ? Color(0xFF00796B)
                            : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    // Filter records based on selected type
    final filteredRecords =
        records
            .where((record) => record.recordType == _selectedRecordType)
            .toList();

    if (filteredRecords.isEmpty) {
      return Center(
        child: Text(
          'No ${_selectedRecordType == "OPD" ? "OPD" : "Tele-consultation"} records yet',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return _buildRecordItem(record, index);
      },
    );
  }

  Widget _buildRecordItem(MedicalRecordItem record, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                record.type == 'image'
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(record.file, fit: BoxFit.cover),
                    )
                    : Icon(Icons.insert_drive_file, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded on ${record.date}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${record.recordType} Record',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF00796B),
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () => _deleteRecord(record),
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
                icon: Image.asset(
                  'assets/homescreen/profile.png',
                  width: 24,
                  height: 24,
                  color:
                      _selectedIndex == 4
                          ? const Color(0xFF00796B)
                          : Colors.grey,
                ),
                label: 'Profile',
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
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
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

  // File interaction methods
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _addRecord(File(photo.path), 'image');
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _addRecord(File(image.path), 'image');
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  // Use image_picker for documents too, as a workaround for file_picker issues
  Future<void> _pickDocument() async {
    try {
      // Use image picker but set mediaType to allow any kind of media
      final XFile? document = await _picker.pickMedia();
      if (document != null) {
        // Determine if it's an image or other document based on extension
        final extension = path.extension(document.path).toLowerCase();
        final isImage = [
          '.jpg',
          '.jpeg',
          '.png',
          '.gif',
          '.webp',
          '.heic',
        ].contains(extension);

        _addRecord(File(document.path), isImage ? 'image' : 'document');
      }
    } catch (e) {
      _showErrorDialog('Failed to pick document: $e');
    }
  }

  void _addRecord(File file, String type) {
    // Get filename from path
    String fileName = file.path.split('/').last;
    if (fileName.length > 30) {
      fileName = fileName.substring(0, 27) + '...';
    }

    // Get current date
    DateTime now = DateTime.now();
    String date = '${now.day}/${now.month}/${now.year}';

    setState(() {
      records.add(
        MedicalRecordItem(
          name: fileName,
          date: date,
          type: type,
          file: file,
          recordType: _selectedRecordType,
        ),
      );
    });
  }

  void _deleteRecord(MedicalRecordItem record) {
    setState(() {
      records.removeWhere((item) => item.file.path == record.file.path);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}
