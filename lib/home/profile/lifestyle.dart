import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medycall/home/profile/medical.dart';

class LifestyleForm extends StatefulWidget {
  const LifestyleForm({super.key});

  @override
  State<LifestyleForm> createState() => _LifestyleFormState();
}

class _LifestyleFormState extends State<LifestyleForm> {
  int _selectedIndex = 0;
  String? smokingValue;
  String? alcoholValue;
  String? activityValue;
  String? dietValue;
  String? occupationValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008D83),
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

          // White card
          Expanded(
            child: Container(
              width: 393,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Smoking Habit
                    Text(
                      'Smoking Habit',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalOptions(
                      options: [
                        'Never',
                        'I\'ve Quit',
                        '1-2/Day',
                        '3-5/Day',
                        '5-10/Day',
                        '>10/Day'
                      ],
                      groupValue: smokingValue,
                      onChanged: (value) =>
                          setState(() => smokingValue = value),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 20),

                    // Alcohol
                    Text(
                      'Alcohol',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalOptions(
                      options: [
                        'Never',
                        'Rare',
                        'Occasional',
                        'Regular',
                        'Heavy'
                      ],
                      groupValue: alcoholValue,
                      onChanged: (value) =>
                          setState(() => alcoholValue = value),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 20),

                    // Activity Level
                    Text(
                      'Activity Level',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalOptions(
                      options: ['Low', 'Normal', 'High', 'Very High'],
                      groupValue: activityValue,
                      onChanged: (value) =>
                          setState(() => activityValue = value),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 20),

                    // Diet Habit
                    Text(
                      'Diet Habit',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalOptions(
                      options: ['Vegetarian', 'Non-Veg', 'Vegan'],
                      groupValue: dietValue,
                      onChanged: (value) => setState(() => dietValue = value),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 20),

                    // Occupation
                    Text(
                      'Occupation',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalOptions(
                      options: [
                        'IT',
                        'Medical',
                        'Banking',
                        'Education',
                        'Politics',
                        'Student',
                        'Home Maker',
                        'Business',
                        'Other'
                      ],
                      groupValue: occupationValue,
                      onChanged: (value) =>
                          setState(() => occupationValue = value),
                    ),
                    const SizedBox(height: 40),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MedicalInfoScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF008D83),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFF008D83)),
                            ),
                            minimumSize: const Size(150, 50),
                          ),
                          child: Text(
                            'Skip for Now',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MedicalInfoScreen()),
                            );
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
                            'Save & Continue',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w900,
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

  Widget _buildHorizontalOptions({
    required List<String> options,
    required String? groupValue,
    required Function(String?) onChanged,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: option,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF008D83),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              option,
              style: GoogleFonts.roboto(
                fontSize: 16, // Changed from 14 to 16
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
                  color: _selectedIndex == 0
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
                    color: _selectedIndex == 1
                        ? const Color(0xFF00796B)
                        : Colors.grey,
                  ),
                ),
                label: 'Appointment',
              ),
              BottomNavigationBarItem(
                icon: const SizedBox(
                  width: 24,
                  height: 24,
                ),
                label: 'NIROG',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/homescreen/history.png',
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 3
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
                  color: _selectedIndex == 4
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
