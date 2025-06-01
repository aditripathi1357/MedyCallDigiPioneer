// ... other imports in history.dart ...
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medycall/Appointment/appointment.dart'; // Assuming this path is correct
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/menu/yoga.dart';
import 'package:medycall/home/profile/profile.dart'; // Assuming this path is correct
import 'package:medycall/home/home_screen.dart'; // Assuming this path is correct
import 'package:path_provider/path_provider.dart'; // Make sure this is imported
import 'package:path/path.dart' as path;
import 'package:medycall/home/notification/notification.dart'; // Assuming this path is correct
import 'package:medycall/providers/user_provider.dart'; // Assuming this path is correct
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({Key? key}) : super(key: key);
  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class MedicalRecordItem {
  // This remains for OPD/Tele records
  final String name;
  final String date;
  final String type;
  final File file;
  final String recordType;
  MedicalRecordItem({
    required this.name,
    required this.date,
    required this.type,
    required this.file,
    required this.recordType,
  });
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  int _selectedIndex = 3;
  String _selectedRecordType = "OPD";
  final ImagePicker _picker = ImagePicker();
  List<MedicalRecordItem> records = []; // For OPD/Tele

  // For Medyscan (Yoga) sessions
  List<VideoRecordingItem> _medyscanSessionRecords = [];
  bool _isLoadingMedyscanRecords = false;

  @override
  void initState() {
    super.initState();
    // Load initial records based on default selection or fetch all then filter
    if (_selectedRecordType == "Medyscan") {
      _loadMedyscanSessionRecords();
    } else {
      // Your existing logic to load OPD/Tele records if any
    }
  }

  // Method to load Medyscan (Yoga) session recordings
  Future<void> _loadMedyscanSessionRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMedyscanRecords = true;
    });
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(
        '${directory.path}/yoga_sessions',
      ); // Same path as YogaPage

      if (!await recordingsDir.exists()) {
        if (mounted) {
          setState(() {
            _medyscanSessionRecords = [];
            _isLoadingMedyscanRecords = false;
          });
        }
        return;
      }

      final files =
          recordingsDir
              .listSync()
              .where((item) => item.path.endsWith('.mp4'))
              .toList();
      final List<VideoRecordingItem> loadedItems = [];
      for (var entity in files) {
        if (entity is File) {
          int durationSeconds = 0;
          final nameParts = entity.path.split('/').last.split('_');
          final durationPart = nameParts.firstWhere(
            (part) => part.startsWith('DUR') && part.endsWith('s.mp4'),
            orElse: () => '',
          );
          if (durationPart.isNotEmpty) {
            durationSeconds =
                int.tryParse(
                  durationPart.replaceAll('DUR', '').replaceAll('s.mp4', ''),
                ) ??
                0;
          }
          loadedItems.add(
            VideoRecordingItem(
              filePath: entity.path,
              fileName: entity.path.split('/').last,
              dateRecorded: await entity.lastModified(),
              duration: Duration(seconds: durationSeconds),
            ),
          );
        }
      }
      if (mounted) {
        setState(() {
          _medyscanSessionRecords =
              loadedItems..sort(
                (a, b) => b.dateRecorded.compareTo(a.dateRecorded),
              ); // Sort by newest first
          _isLoadingMedyscanRecords = false;
        });
      }
    } catch (e) {
      print("Error loading Medyscan session recordings: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load Medyscan sessions: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        setState(() {
          _isLoadingMedyscanRecords = false;
        });
      }
    }
  }

  // Helper to format duration (can be shared or copied)
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  // Play Medyscan video
  void _playMedyscanVideo(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VideoPlayerPage(
              filePath: filePath,
            ), // Uses VideoPlayerPage from yoga_page.dart
      ),
    );
  }

  // Confirm and delete Medyscan recording
  Future<void> _confirmDeleteMedyscanRecording(
    VideoRecordingItem recording,
  ) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Recording?', style: GoogleFonts.poppins()),
          content: Text(
            'Are you sure you want to delete "${recording.fileName}"?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      _deleteMedyscanRecording(recording);
    }
  }

  Future<void> _deleteMedyscanRecording(VideoRecordingItem recording) async {
    try {
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      if (mounted) {
        setState(() {
          _medyscanSessionRecords.removeWhere(
            (item) => item.filePath == recording.filePath,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${recording.fileName} deleted.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error deleting Medyscan recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete ${recording.fileName}.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';
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
                    (_selectedRecordType == "Medyscan"
                                ? _medyscanSessionRecords.isEmpty
                                : records.isEmpty) &&
                            !_isLoadingMedyscanRecords
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

  int? _selectedTopBarIconIndex;
  Widget _buildTopBar(String userName) {
    // ... (Your existing _buildTopBar code)
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
    // ... (Your existing _buildIcon code)
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

  Widget _buildAddRecordSection() {
    if (_selectedRecordType == "Medyscan") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yoga Session',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.videocam_outlined, color: Colors.white),
              label: Text(
                'Record New Yoga Session',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const YogaPage()),
                ).then((_) {
                  // After returning from YogaPage
                  if (_selectedRecordType == "Medyscan" && mounted) {
                    _loadMedyscanSessionRecords(); // Refresh the list
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: GoogleFonts.poppins(fontSize: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // OPD or Tele
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Record',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
        ],
      );
    }
  }

  Widget _buildNoRecordsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedRecordType == "Medyscan"
              ? 'No Yoga Sessions Found'
              : 'Oops! No Medical Records Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          _selectedRecordType == "Medyscan"
              ? 'Tap below to record a new yoga session.'
              : 'A detailed health history helps doctor diagnose you better',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildRecordTypeSelector(),
        const SizedBox(height: 20),
        _buildAddRecordSection(), // Updated section
        const Spacer(),
        if (_isLoadingMedyscanRecords && _selectedRecordType == "Medyscan")
          Center(child: CircularProgressIndicator())
        else
          Center(
            child: Text(
              _selectedRecordType == "Medyscan"
                  ? 'No yoga sessions recorded yet.'
                  : 'No records uploaded yet',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
              textAlign: TextAlign.center,
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
          _selectedRecordType == "Medyscan"
              ? 'Your Yoga Sessions'
              : 'Your Medical Records',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          _selectedRecordType == "Medyscan"
              ? 'Review your past yoga sessions.'
              : 'A detailed health history helps doctor diagnose you better',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildRecordTypeSelector(),
        const SizedBox(height: 20),
        _buildAddRecordSection(), // Updated section
        const SizedBox(height: 20),
        Text(
          _selectedRecordType == "Medyscan"
              ? 'Recorded Sessions'
              : 'Uploaded Records',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Expanded(child: _buildRecordsList()),
      ],
    );
  }

  Widget _buildRecordTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedRecordType = "OPD";
                  });
                  // Potentially load OPD records here if not already loaded
                },
                // ... OPD Card styling ...
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 67,
                  decoration: BoxDecoration(
                    color:
                        _selectedRecordType == "OPD"
                            ? Color(0xFFE1F5F3)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [/* ... shadows ... */],
                  ),
                  child: Row(
                    /* ... OPD content ... */
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(
                          'assets/homescreen/opd.png',
                          width: 50,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OPD',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color:
                                _selectedRecordType == "OPD"
                                    ? Color(0xFF00796B)
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedRecordType = "Tele";
                  });
                  // Potentially load Tele records here
                },
                // ... Tele Card styling ...
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 67,
                  decoration: BoxDecoration(
                    color:
                        _selectedRecordType == "Tele"
                            ? Color(0xFFE1F5F3)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [/* ... shadows ... */],
                  ),
                  child: Row(
                    /* ... Tele content ... */
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(
                          'assets/homescreen/teleconsultation.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tele-consultation',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color:
                                _selectedRecordType == "Tele"
                                    ? Color(0xFF00796B)
                                    : Colors.black,
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _selectedRecordType = "Medyscan";
                });
                _loadMedyscanSessionRecords(); // Load Medyscan records when selected
              },
              // ... Medyscan Card styling ...
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 170, // Adjust width as needed
                height: 67,
                decoration: BoxDecoration(
                  color:
                      _selectedRecordType == "Medyscan"
                          ? Color(0xFFE1F5F3)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [/* ... shadows ... */],
                ),
                child: Row(
                  /* ... Medyscan content ... */
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Image.asset(
                        'assets/homescreen/medyscan.png', // This icon is used for the Medyscan tab
                        width: 42,
                        height: 42,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Medyscan', // This is the filter name
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color:
                            _selectedRecordType == "Medyscan"
                                ? Color(0xFF00796B)
                                : Colors.black,
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

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // ... (Your existing _buildUploadOption code)
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
    if (_selectedRecordType == "Medyscan") {
      if (_isLoadingMedyscanRecords) {
        return Center(child: CircularProgressIndicator());
      }
      if (_medyscanSessionRecords.isEmpty) {
        return Center(
          child: Text(
            'No Medyscan sessions recorded yet.\nGo to the Medyscan tab to record a session.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        );
      }
      return ListView.builder(
        itemCount: _medyscanSessionRecords.length,
        itemBuilder: (context, index) {
          final recording = _medyscanSessionRecords[index];
          return _buildMedyscanSessionItem(recording);
        },
      );
    } else {
      // OPD or Tele
      final filteredRecords =
          records
              .where((record) => record.recordType == _selectedRecordType)
              .toList();
      if (filteredRecords.isEmpty) {
        return Center(
          child: Text(
            'No ${_selectedRecordType} records yet',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
          ),
        );
      }
      return ListView.builder(
        itemCount: filteredRecords.length,
        itemBuilder: (context, index) {
          final record = filteredRecords[index];
          return _buildRecordItem(
            record,
            index,
          ); // Your existing item builder for OPD/Tele
        },
      );
    }
  }

  // New widget to display Medyscan session items
  Widget _buildMedyscanSessionItem(VideoRecordingItem recording) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(
          Icons.video_library_rounded,
          color: Color(0xFF00796B),
          size: 36,
        ),
        title: Text(
          recording.fileName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          '${DateFormat.yMMMd().add_jm().format(recording.dateRecorded)}\nDuration: ${_formatDuration(recording.duration.inSeconds)}',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.redAccent.shade100,
          ), // Ensure shade100 for safety
          onPressed: () => _confirmDeleteMedyscanRecording(recording),
        ),
        onTap: () => _playMedyscanVideo(recording.filePath),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildRecordItem(MedicalRecordItem record, int index) {
    // ... (Your existing _buildRecordItem code for OPD/Tele)
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [/* ... shadows ... */],
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

  // File interaction methods for OPD/Tele
  Future<void> _takePhoto() async {
    /* ... your existing code ... */
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
    /* ... your existing code ... */
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _addRecord(File(image.path), 'image');
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _pickDocument() async {
    /* ... your existing code ... */
    try {
      final XFile? document = await _picker.pickMedia();
      if (document != null) {
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
    /* ... your existing code ... */
    String fileName = file.path.split('/').last;
    if (fileName.length > 30) {
      fileName = fileName.substring(0, 27) + '...';
    }
    DateTime now = DateTime.now();
    String date = '${now.day}/${now.month}/${now.year}';
    setState(() {
      records.add(
        MedicalRecordItem(
          name: fileName,
          date: date,
          type: type,
          file: file,
          recordType: _selectedRecordType, // Ensure this is OPD or Tele
        ),
      );
    });
  }

  void _deleteRecord(MedicalRecordItem record) {
    /* ... your existing code ... */
    setState(() {
      records.removeWhere((item) => item.file.path == record.file.path);
    });
  }

  void _showErrorDialog(String message) {
    /* ... your existing code ... */
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
