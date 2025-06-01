import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/services/user_service.dart';
import 'package:medycall/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:medycall/providers/user_provider.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  int _selectedIndex = 4; // Profile is selected
  final UserService _userService = UserService();
  bool _isLoading = false;

  // Medical data state
  List<String> allergies = [];
  List<String> medications = [];
  List<String> chronicDiseases = [];
  List<String> injuries = [];
  List<String> surgeries = [];

  // Controllers for text fields
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicationsController = TextEditingController();
  final TextEditingController chronicDiseasesController =
      TextEditingController();
  final TextEditingController injuriesController = TextEditingController();
  final TextEditingController surgeriesController = TextEditingController();

  // Focus nodes
  final FocusNode allergiesFocus = FocusNode();
  final FocusNode medicationsFocus = FocusNode();
  final FocusNode chronicDiseasesFocus = FocusNode();
  final FocusNode injuriesFocus = FocusNode();
  final FocusNode surgeriesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  @override
  void dispose() {
    allergiesController.dispose();
    medicationsController.dispose();
    chronicDiseasesController.dispose();
    injuriesController.dispose();
    surgeriesController.dispose();

    allergiesFocus.dispose();
    medicationsFocus.dispose();
    chronicDiseasesFocus.dispose();
    injuriesFocus.dispose();
    surgeriesFocus.dispose();
    super.dispose();
  }

  void _populateFieldsFromData(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      allergies = List<String>.from(data['allergies'] ?? []);
      medications = List<String>.from(data['medications'] ?? []);
      chronicDiseases = List<String>.from(data['chronicDiseases'] ?? []);
      injuries = List<String>.from(data['injuries'] ?? []);
      surgeries = List<String>.from(data['surgeries'] ?? []);
    });
  }

  Future<void> _loadExistingData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      UserModel? providerUser = userProvider.user;
      Map<String, dynamic>? providerMedicalData;

      if (providerUser != null &&
          providerUser.supabaseUid != null &&
          (providerUser.name != null && providerUser.name!.isNotEmpty)) {
        providerMedicalData = providerUser.getMedicalData();
      }

      if (providerMedicalData != null && providerMedicalData.isNotEmpty) {
        print('MedicalInfoScreen: Loading data from UserProvider');
        _populateFieldsFromData(providerMedicalData);
      } else {
        print(
          'MedicalInfoScreen: UserProvider data not found or incomplete, trying local storage.',
        );
        final localData = await _userService.getLocalMedicalData();
        if (localData != null && mounted) {
          print('MedicalInfoScreen: Loading data from Local Storage');
          _populateFieldsFromData(localData);
        } else {
          print(
            'MedicalInfoScreen: No data in UserProvider or Local Storage. Using defaults (empty lists).',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        print(
          'MedicalInfoScreen: Error loading existing data: ${e.toString()}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading medical data: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitData() async {
    setState(() => _isLoading = true);

    try {
      // Ensure any text in input fields is added to tags before saving
      _addTagFromController(allergiesController, allergies, allergiesFocus);
      _addTagFromController(
        medicationsController,
        medications,
        medicationsFocus,
      );
      _addTagFromController(
        chronicDiseasesController,
        chronicDiseases,
        chronicDiseasesFocus,
      );
      _addTagFromController(injuriesController, injuries, injuriesFocus);
      _addTagFromController(surgeriesController, surgeries, surgeriesFocus);

      // Save medical data locally first
      await _userService.saveMedicalDataLocally(
        allergies:
            allergies.isNotEmpty
                ? allergies
                : null, // Pass null if empty, or [] if backend prefers
        medications: medications.isNotEmpty ? medications : null,
        chronicDiseases: chronicDiseases.isNotEmpty ? chronicDiseases : null,
        injuries: injuries.isNotEmpty ? injuries : null,
        surgeries: surgeries.isNotEmpty ? surgeries : null,
      );

      // Now, submit ALL forms data (Demographic, Lifestyle, Medical) to the server
      final UserModel? submittedUser = await _userService.submitAllFormsData();

      if (submittedUser != null && mounted) {
        // Update the UserProvider with the complete user data from the server
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUser(submittedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All profile data submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to a relevant screen, e.g., home or profile overview
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (mounted) {
        // Handle case where submission might have occurred but no user data returned,
        // or if submitAllFormsData itself indicates a failure not caught as an exception.
        throw Exception(
          'Failed to submit all forms data or user data not returned.',
        );
      }
    } catch (e) {
      if (mounted) {
        print('MedicalInfoScreen: Submission failed: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _skipAndSubmit() async {
    setState(() => _isLoading = true);
    try {
      // Save medical data locally as empty lists to signify skip
      await _userService.saveMedicalDataLocally(
        allergies: [],
        medications: [],
        chronicDiseases: [],
        injuries: [],
        surgeries: [],
      );

      // Submit all forms data (Demographic, Lifestyle, and skipped Medical)
      final UserModel? submittedUser = await _userService.submitAllFormsData();

      if (submittedUser != null && mounted) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUser(submittedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile data (with skipped medical info) submitted.',
            ),
            backgroundColor: Colors.blueAccent,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (mounted) {
        throw Exception(
          'Failed to submit forms data after skipping or user data not returned.',
        );
      }
    } catch (e) {
      if (mounted) {
        print(
          'MedicalInfoScreen: Submission after skipping failed: ${e.toString()}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission after skipping failed: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isStillInitializing =
        _isLoading &&
        allergies.isEmpty &&
        medications.isEmpty &&
        chronicDiseases.isEmpty &&
        injuries.isEmpty &&
        surgeries.isEmpty &&
        allergiesController.text.isEmpty; // Check controller too

    return Scaffold(
      backgroundColor: const Color(0xFF008D83),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 133,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Medical Information',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child:
                  isStillInitializing
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // Progress Indicator
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  _buildProgressSegment(
                                    isActive: true,
                                  ), // Demographic
                                  const SizedBox(width: 8),
                                  _buildProgressSegment(
                                    isActive: true,
                                  ), // Lifestyle
                                  const SizedBox(width: 8),
                                  _buildProgressSegment(
                                    isActive: true,
                                  ), // Medical (Current)
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildHorizontalTagInput(
                              'Allergies (Optional)',
                              allergies,
                              allergiesController,
                              allergiesFocus,
                            ),
                            const SizedBox(height: 20),
                            _buildHorizontalTagInput(
                              'Current Medications (Optional)',
                              medications,
                              medicationsController,
                              medicationsFocus,
                            ),
                            const SizedBox(height: 20),
                            _buildHorizontalTagInput(
                              'Chronic Diseases (Optional)',
                              chronicDiseases,
                              chronicDiseasesController,
                              chronicDiseasesFocus,
                            ),
                            const SizedBox(height: 20),
                            _buildHorizontalTagInput(
                              'Past Injuries (Optional)',
                              injuries,
                              injuriesController,
                              injuriesFocus,
                            ),
                            const SizedBox(height: 20),
                            _buildHorizontalTagInput(
                              'Past Surgeries (Optional)',
                              surgeries,
                              surgeriesController,
                              surgeriesFocus,
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        _isLoading ? null : _skipAndSubmit,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF008D83),
                                      ),
                                      foregroundColor: const Color(0xFF008D83),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      minimumSize: const Size(0, 50),
                                    ),
                                    child: Text(
                                      'Skip & Submit',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF008D83),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      minimumSize: const Size(0, 50),
                                    ),
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : Text(
                                              'Submit All Data',
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProgressSegment({required bool isActive}) {
    return Container(
      width: 30,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF008D83) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHorizontalTagInput(
    String title,
    List<String> tagList,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...tagList.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: GoogleFonts.roboto(color: Colors.teal.shade900),
                  ),
                  backgroundColor: Colors.teal.shade50,
                  deleteIconColor: Colors.teal.shade700,
                  onDeleted: () => setState(() => tagList.remove(tag)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                );
              }).toList(),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 150,
                ), // Ensure field is wide enough
                child: IntrinsicWidth(
                  // Let TextField take necessary width
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: GoogleFonts.roboto(),
                    decoration: InputDecoration(
                      hintText:
                          tagList.isEmpty
                              ? 'Type and press Enter...'
                              : 'Add more...',
                      hintStyle: GoogleFonts.roboto(
                        color: Colors.grey.shade500,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ), // Adjust padding
                    ),
                    onSubmitted: (value) {
                      _addTagFromController(controller, tagList, focusNode);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addTagFromController(
    TextEditingController controller,
    List<String> tagList,
    FocusNode focusNode,
  ) {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        if (!tagList.contains(controller.text.trim())) {
          // Avoid duplicate tags
          tagList.add(controller.text.trim());
        }
        controller.clear();
        focusNode.requestFocus(); // Keep focus on the input field
      });
    } else {
      focusNode.requestFocus(); // If empty, just ensure focus remains
    }
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
              const BottomNavigationBarItem(
                icon: SizedBox(width: 24, height: 24),
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
                setState(() => _selectedIndex = index);
                // Add navigation logic here
              }
            },
          ),
        ),
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () => print('NIROG tapped from Medical Screen'),
            child: Image.asset(
              'assets/homescreen/nirog.png',
              width: 51,
              height: 54,
            ),
          ),
        ),
      ],
    );
  }
}
