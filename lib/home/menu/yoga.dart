// lib/yoga_page.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:medycall/Appointment/appointment.dart';
import 'package:medycall/History/history.dart';
import 'package:medycall/home/Speciality/changelocation.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

class VideoRecordingItem {
  final String filePath;
  final String fileName;
  final DateTime dateRecorded;
  final Duration duration;

  VideoRecordingItem({
    required this.filePath,
    required this.fileName,
    required this.dateRecorded,
    required this.duration,
  });
}

class YogaPage extends StatefulWidget {
  const YogaPage({Key? key}) : super(key: key);
  static const String routeName = '/yoga';

  @override
  _YogaPageState createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> with WidgetsBindingObserver {
  int _selectedIndex = 4;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  List<VideoRecordingItem> _savedRecordings = [];
  bool _isAttemptingToInitializeCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionsAndInitializeCamera();
    _loadSavedRecordings();
  }

  Future<void> _requestPermissionsAndInitializeCamera() async {
    try {
      Map<Permission, PermissionStatus> statuses =
          await [
            Permission.camera,
            Permission.microphone,
            if (Platform.isAndroid) Permission.storage,
          ].request();

      bool allGranted =
          (statuses[Permission.camera]?.isGranted ?? false) &&
          (statuses[Permission.microphone]?.isGranted ?? false) &&
          (Platform.isIOS || (statuses[Permission.storage]?.isGranted ?? true));

      if (allGranted) {
        await _initializeCamera();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Camera, microphone and storage permissions are required',
                style: GoogleFonts.poppins(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Permission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error requesting permissions: $e',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isAttemptingToInitializeCamera = true;
      });

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      await _cameraController?.dispose();

      _cameraController = CameraController(
        _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        ),
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isAttemptingToInitializeCamera = false;
        });
      }
    } catch (e) {
      print('Camera init error: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isAttemptingToInitializeCamera = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Camera initialization failed: $e',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (cameraController.value.isRecordingVideo) {
        _stopRecording(saveFile: false);
      }
      cameraController.dispose();
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_isCameraInitialized && mounted) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadSavedRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/yogasessions');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
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
          _savedRecordings =
              loadedItems
                ..sort((a, b) => b.dateRecorded.compareTo(a.dateRecorded));
        });
      }
    } catch (e) {
      print("Error loading saved recordings: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load saved sessions: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRecording) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsElapsed++;
      });
    });
  }

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

  Future<void> _startRecording() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot start recording: Camera is not initialized.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
      return;
    }

    if (_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      await _cameraController!.prepareForVideoRecording();
      await _cameraController!.startVideoRecording();

      if (mounted) {
        setState(() {
          _isRecording = true;
        });
      }

      _startTimer();
      print("Recording started");
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error starting recording: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
      _timer?.cancel();
    }
  }

  Future<void> _stopRecording({bool saveFile = true}) async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isRecordingVideo) {
      return;
    }

    _timer?.cancel();
    final int recordedDurationSeconds = _secondsElapsed;

    if (mounted) {
      setState(() {
        _isRecording = false;
        _secondsElapsed = 0;
      });
    }

    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();

      if (!saveFile) {
        print('Recording stopped without saving: ${videoFile.path}');
        return;
      }

      print('Video recorded to temporary path: ${videoFile.path}');
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/yoga_sessions');

      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      final String fileName =
          'yogasession${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}_DUR${recordedDurationSeconds}s.mp4';
      final String newPath = '${recordingsDir.path}/$fileName';

      await File(videoFile.path).copy(newPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session saved: $fileName',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        _loadSavedRecordings();
      }
    } catch (e) {
      print('Error stopping/saving recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving session: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }
  }

  Widget buildLocationWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF0F8F8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(
              'assets/location.png',
              width: 24,
              height: 24,
              color: const Color(0xFF00796B),
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.location_on,
                    color: Color(0xFF00796B),
                    size: 24,
                  ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patel Colony',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Junagadh',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationChangePage(),
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
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  'Change Location',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
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
                  errorBuilder:
                      (c, e, s) => Icon(
                        Icons.home,
                        color:
                            _selectedIndex == 0
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
                      ),
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
                  errorBuilder:
                      (c, e, s) => Icon(
                        Icons.calendar_today,
                        color:
                            _selectedIndex == 1
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
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
                  errorBuilder:
                      (c, e, s) => Icon(
                        Icons.history,
                        color:
                            _selectedIndex == 3
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
                      ),
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
                  errorBuilder:
                      (c, e, s) => Icon(
                        Icons.camera_alt,
                        color:
                            _selectedIndex == 4
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                        size: 24,
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
              if (index == 2) {
                print('NIROG (center visual item) tapped');
                return;
              }

              if (_selectedIndex == index && index != 4) return;

              if (_isRecording && _selectedIndex == 4 && index != 4) {
                _stopRecording(saveFile: true);
              }

              setState(() {
                _selectedIndex = index;
              });

              switch (index) {
                case 0:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                  break;
                case 1:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentScreen(),
                    ),
                  );
                  break;
                case 3:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicalHistoryPage(),
                    ),
                  );
                  break;
                case 4:
                  if (ModalRoute.of(context)?.settings.name !=
                      YogaPage.routeName) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const YogaPage(),
                        settings: RouteSettings(name: YogaPage.routeName),
                      ),
                    );
                  } else {
                    if (!_isCameraInitialized) {
                      _requestPermissionsAndInitializeCamera();
                    }
                    _loadSavedRecordings();
                  }
                  break;
              }
            },
          ),
        ),
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () {
              print('NIROG image tapped');
            },
            child: Image.asset(
              'assets/homescreen/nirog.png',
              width: 51,
              height: 54,
              errorBuilder:
                  (c, e, s) => Container(
                    width: 51,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "N",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYogaSessionUI() {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Initializing Camera...", style: GoogleFonts.poppins()),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          color: const Color(0xFF00695C),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_secondsElapsed),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _stopRecording(saveFile: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(
                  'End Session',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[200],
          width: double.infinity,
          child: Text(
            "Hey Clara, You Are Doing It Perfectly, Just Stretch Your Arms Upwards, Near To Your Ear...",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.videocam_outlined, color: Colors.white),
              label:
                  _isAttemptingToInitializeCamera
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Initializing...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        'Start Yoga Session',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              onPressed:
                  _isAttemptingToInitializeCamera
                      ? null
                      : () async {
                        if (_isCameraInitialized &&
                            _cameraController != null &&
                            _cameraController!.value.isInitialized) {
                          await _startRecording();
                        } else {
                          await _requestPermissionsAndInitializeCamera();

                          if (_isCameraInitialized &&
                              _cameraController != null &&
                              _cameraController!.value.isInitialized) {
                            await _startRecording();
                          }
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: GoogleFonts.poppins(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Saved Yoga Sessions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _savedRecordings.isEmpty
                    ? Center(
                      child: Text(
                        'No yoga sessions recorded yet.\nTap "Start Yoga Session" to begin!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _savedRecordings.length,
                      itemBuilder: (context, index) {
                        final recording = _savedRecordings[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.video_library_rounded,
                              color: Color(0xFF00796B),
                              size: 36,
                            ),
                            title: Text(
                              recording.fileName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              '${DateFormat.yMMMd().add_jm().format(recording.dateRecorded)}\nDuration: ${_formatDuration(recording.duration.inSeconds)}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent[100],
                              ),
                              onPressed:
                                  () => _confirmDeleteRecording(recording),
                            ),
                            onTap: () => _playVideo(recording.filePath),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRecording(VideoRecordingItem recording) async {
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
      _deleteRecording(recording);
    }
  }

  Future<void> _deleteRecording(VideoRecordingItem recording) async {
    try {
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _savedRecordings.removeWhere(
          (item) => item.filePath == recording.filePath,
        );
      });

      if (mounted) {
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
      print("Error deleting recording: $e");
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

  void _playVideo(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(filePath: filePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 12),
        child: buildLocationWidget(),
      ),
      body: SafeArea(
        child: _isRecording ? _buildYogaSessionUI() : _buildInitialContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String filePath;

  const VideoPlayerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
        _controller.play();
      }
    });
    _controller.addListener(() {
      if (mounted && _isPlaying != _controller.value.isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Playback', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF00796B),
        elevation: 2,
      ),
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                _controller.value.isInitialized) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    _ControlsOverlay(controller: _controller),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: EdgeInsets.only(top: 5.0, bottom: 15.0),
                      colors: VideoProgressColors(
                        playedColor: Color(0xFF00796B),
                        bufferedColor: Colors.white54,
                        backgroundColor: Colors.black26,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                "Error loading video: ${snapshot.error}",
                style: GoogleFonts.poppins(),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!mounted) return;
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child:
              controller.value.isPlaying
                  ? SizedBox.shrink()
                  : Container(
                    color: Colors.black26,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 80.0,
                        semanticLabel: 'Play',
                      ),
                    ),
                  ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
