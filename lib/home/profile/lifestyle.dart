import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/home/profile/medical.dart';
import 'package:medycall/services/user_service.dart';
import 'package:provider/provider.dart'; // Added for UserProvider
import 'package:medycall/providers/user_provider.dart'; // Added for UserProvider
import 'package:medycall/models/user_model.dart'; // Added for UserModel type hint

class LifestyleForm extends StatefulWidget {
  const LifestyleForm({super.key});

  @override
  State<LifestyleForm> createState() => _LifestyleFormState();
}

class _LifestyleFormState extends State<LifestyleForm> {
  int _selectedIndex = 4; // Profile is selected in bottom nav
  bool _isLoading = false;
  final UserService _userService = UserService();

  // Form field values
  String? smokingValue;
  String? alcoholValue;
  String? activityValue;
  String? dietValue;
  String? occupationValue;

  @override
  void initState() {
    super.initState();
    // Ensure context is available for Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _populateFieldsFromData(Map<String, dynamic> data) {
    setState(() {
      smokingValue = data['smokingHabit'];
      alcoholValue = data['alcoholConsumption'];
      activityValue = data['activityLevel'];
      dietValue = data['dietHabit'];
      occupationValue = data['occupation'];
    });
  }

  Future<void> _loadExistingData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Priority 1: UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      UserModel? providerUser = userProvider.user;
      Map<String, dynamic>? providerLifestyleData;

      if (providerUser != null &&
          providerUser.supabaseUid != null &&
          providerUser.name != null &&
          providerUser.name!.isNotEmpty) {
        // Basic check if profile data exists
        providerLifestyleData = providerUser.getLifestyleData();
      }

      if (providerLifestyleData != null && providerLifestyleData.isNotEmpty) {
        print('LifestyleForm: Loading data from UserProvider');
        _populateFieldsFromData(providerLifestyleData);
      } else {
        // Priority 2: Local Storage
        print(
          'LifestyleForm: UserProvider data not found or incomplete, trying local storage.',
        );
        final localData = await _userService.getLocalLifestyleData();
        if (localData != null && mounted) {
          print('LifestyleForm: Loading data from Local Storage');
          _populateFieldsFromData(localData);
        } else {
          print(
            'LifestyleForm: No data in UserProvider or Local Storage. Using defaults (nulls).',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        print('LifestyleForm: Error loading existing data: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading lifestyle data: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveDataLocallyAndContinue() async {
    setState(() => _isLoading = true);

    try {
      await _userService.saveLifestyleDataLocally(
        smokingHabit: smokingValue,
        alcoholConsumption: alcoholValue,
        activityLevel: activityValue,
        dietHabit: dietValue,
        occupation: occupationValue,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lifestyle data saved locally. Continue to medical information.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MedicalInfoScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save lifestyle data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _skipToMedical() async {
    // Save potentially empty/null data to signify this step was "visited"
    setState(() => _isLoading = true);
    try {
      await _userService.saveLifestyleDataLocally(
        smokingHabit: smokingValue, // Save current (possibly null) selections
        alcoholConsumption: alcoholValue,
        activityLevel: activityValue,
        dietHabit: dietValue,
        occupation: occupationValue,
      );
      if (mounted) {
        print("Lifestyle data (possibly empty from skip) saved locally.");
      }
    } catch (e) {
      if (mounted) {
        print("Error saving lifestyle data on skip: $e");
        // Optionally show a non-blocking error or just log
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MedicalInfoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isStillInitializing =
        _isLoading &&
        smokingValue == null &&
        alcoholValue == null &&
        activityValue == null &&
        dietValue == null &&
        occupationValue == null;

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
                  'Lifestyle',
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  _buildProgressSegment(
                                    isActive: true,
                                  ), // Demographic
                                  const SizedBox(width: 8),
                                  _buildProgressSegment(
                                    isActive: true,
                                  ), // Lifestyle (Current)
                                  const SizedBox(width: 8),
                                  _buildProgressSegment(
                                    isActive: false,
                                  ), // Medical
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionHeader('Smoking Habit'),
                            _buildHorizontalOptions(
                              options: [
                                'Never',
                                'I\'ve Quit',
                                '1-2/Day',
                                '3-5/Day',
                                '5-10/Day',
                                '>10/Day',
                              ],
                              groupValue: smokingValue,
                              onChanged:
                                  (value) =>
                                      setState(() => smokingValue = value),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Colors.grey),
                            const SizedBox(height: 20),
                            _buildSectionHeader('Alcohol Consumption'),
                            _buildHorizontalOptions(
                              options: [
                                'Never',
                                'Rare',
                                'Occasional',
                                'Regular',
                                'Heavy',
                              ],
                              groupValue: alcoholValue,
                              onChanged:
                                  (value) =>
                                      setState(() => alcoholValue = value),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Colors.grey),
                            const SizedBox(height: 20),
                            _buildSectionHeader('Activity Level'),
                            _buildHorizontalOptions(
                              options: ['Low', 'Normal', 'High', 'Very High'],
                              groupValue: activityValue,
                              onChanged:
                                  (value) =>
                                      setState(() => activityValue = value),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Colors.grey),
                            const SizedBox(height: 20),
                            _buildSectionHeader('Diet Habit'),
                            _buildHorizontalOptions(
                              options: [
                                'Vegetarian',
                                'Non-Veg',
                                'Vegan',
                                'Eggetarian',
                              ],
                              groupValue: dietValue,
                              onChanged:
                                  (value) => setState(() => dietValue = value),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Colors.grey),
                            const SizedBox(height: 20),
                            _buildSectionHeader('Occupation'),
                            _buildHorizontalOptions(
                              options: [
                                'IT/Software',
                                'Medical/Healthcare',
                                'Banking/Finance',
                                'Education/Teaching',
                                'Government/Public Sector',
                                'Student',
                                'Homemaker',
                                'Business/Entrepreneur',
                                'Manual Labor',
                                'Retired',
                                'Unemployed',
                                'Other',
                              ],
                              groupValue: occupationValue,
                              onChanged:
                                  (value) =>
                                      setState(() => occupationValue = value),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Your data will be saved to the database only after completing the medical information form.',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  // Added Expanded
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _skipToMedical,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF008D83),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                          color: Color(0xFF008D83),
                                        ),
                                      ),
                                      minimumSize: const Size(
                                        0,
                                        50,
                                      ), // Adjusted
                                    ),
                                    child: Text(
                                      'Skip for Now',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ), // Added SizedBox for spacing
                                Expanded(
                                  // Added Expanded
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : _saveDataLocallyAndContinue,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF008D83),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      minimumSize: const Size(
                                        0,
                                        50,
                                      ), // Adjusted
                                    ),
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(
                                              'Save & Continue',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildHorizontalOptions({
    required List<String> options,
    required String? groupValue,
    required Function(String?) onChanged,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          options.map((option) {
            final isSelected = groupValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF008D83)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF008D83)
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                size: 10,
                                color: Color(0xFF008D83),
                              )
                              : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
              }
            },
          ),
        ),
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () => print('NIROG tapped from Lifestyle Screen'),
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
