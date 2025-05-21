import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicalInfoScreen extends StatefulWidget {
  @override
  _MedicalInfoScreenState createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  int _selectedIndex = 2; // NIROG is selected by default

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

  // Focus nodes to maintain focus after adding tags
  final FocusNode allergiesFocus = FocusNode();
  final FocusNode medicationsFocus = FocusNode();
  final FocusNode chronicDiseasesFocus = FocusNode();
  final FocusNode injuriesFocus = FocusNode();
  final FocusNode surgeriesFocus = FocusNode();

  @override
  void dispose() {
    // Dispose controllers and focus nodes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008D83), // Header color
      body: Column(
        children: [
          SizedBox(
            width: 393,
            height: 133,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Medical',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // White card
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHorizontalTagInput(
                      'Allergies',
                      allergies,
                      allergiesController,
                      allergiesFocus,
                    ),
                    const SizedBox(height: 20),
                    _buildHorizontalTagInput(
                      'Medication',
                      medications,
                      medicationsController,
                      medicationsFocus,
                    ),
                    const SizedBox(height: 20),
                    _buildHorizontalTagInput(
                      'Chronic Disease',
                      chronicDiseases,
                      chronicDiseasesController,
                      chronicDiseasesFocus,
                    ),
                    const SizedBox(height: 20),
                    _buildHorizontalTagInput(
                      'Injuries',
                      injuries,
                      injuriesController,
                      injuriesFocus,
                    ),
                    const SizedBox(height: 20),
                    _buildHorizontalTagInput(
                      'Surgeries',
                      surgeries,
                      surgeriesController,
                      surgeriesFocus,
                    ),
                    const SizedBox(height: 40),
                    // Submit button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Process any remaining text in controllers before saving
                          _addRemainingTextAsTags();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008D83),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(150, 50),
                        ),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w900,
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
      bottomNavigationBar: _buildBottomNavigationBar(),
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
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Expand the wrap and text field horizontally
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Display all existing tags
                    ...tagList.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: Color(0xFFE0F2F1), // Light green color
                        deleteIconColor: Colors.grey[600],
                        onDeleted: () {
                          setState(() {
                            tagList.remove(tag);
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelPadding: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.all(0),
                      );
                    }).toList(),

                    // Add inline text field that grows with content
                    IntrinsicWidth(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText:
                              tagList.isEmpty
                                  ? 'Add ${title.toLowerCase()}'
                                  : '',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              tagList.add(value.trim());
                              controller.clear();
                              // Keep focus on the text field after adding a tag
                              focusNode.requestFocus();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addRemainingTextAsTags() {
    setState(() {
      // Add any remaining text in controllers as tags
      _addTagFromController(allergiesController, allergies);
      _addTagFromController(medicationsController, medications);
      _addTagFromController(chronicDiseasesController, chronicDiseases);
      _addTagFromController(injuriesController, injuries);
      _addTagFromController(surgeriesController, surgeries);
    });
  }

  void _addTagFromController(
    TextEditingController controller,
    List<String> tagList,
  ) {
    if (controller.text.trim().isNotEmpty) {
      tagList.add(controller.text.trim());
      controller.clear();
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
            selectedLabelStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13.8,
              fontWeight: FontWeight.w400,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13.8,
              fontWeight: FontWeight.w400,
            ),
            onTap: (index) {
              if (index != 2) {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
          ),
        ),
        Positioned(
          top: -20,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('NIROG tapped');
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Image.asset(
                    'assets/homescreen/nirog.png',
                    width: 51,
                    height: 54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
