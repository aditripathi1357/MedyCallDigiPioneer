import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedSearchFor;
  String? selectedDistance;
  String? selectedPrice;
  String? selectedExperience;
  List<String> selectedLanguages = [];
  String? selectedGender;
  String? selectedAvailabilityDay;
  String? selectedAvailabilityMonth;
  String? selectedAvailabilityTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(
              title: "Search For",
              options: ["Doctor", "Clinic", "Hospital"],
              selected: selectedSearchFor,
              onSelect: (value) => setState(() => selectedSearchFor = value),
            ),
            const SizedBox(height: 16),
            _buildFilterSection(
              title: "Distance From Your Location",
              options: ["0 Km", "5 Km From Your Location", "500 Km"],
              selected: selectedDistance,
              onSelect: (value) => setState(() => selectedDistance = value),
            ),
            const SizedBox(height: 16),
            _buildFilterSection(
              title: "Price",
              options: ["50", "200", "1100", "5000"],
              selected: selectedPrice,
              onSelect: (value) => setState(() => selectedPrice = value),
            ),
            const SizedBox(height: 16),
            _buildFilterSection(
              title: "Years Of Experience",
              options: ["0", "5 Years", "10 Years", "50"],
              selected: selectedExperience,
              onSelect: (value) => setState(() => selectedExperience = value),
            ),
            const SizedBox(height: 16),
            Text(
              "Language",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                "English",
                "Marathi",
                "Malayalam",
                "Hindi",
                "Tamil",
                "Kamad",
                "Gujarati",
                "Telugu",
                "Bengali",
              ]
                  .map((language) => FilterChip(
                        label: Text(language),
                        selected: selectedLanguages.contains(language),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            selectedLanguages.add(language);
                          } else {
                            selectedLanguages.remove(language);
                          }
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            _buildFilterSection(
              title: "Gender",
              options: ["Male", "Female"],
              selected: selectedGender,
              onSelect: (value) => setState(() => selectedGender = value),
            ),
            const SizedBox(height: 16),
            Text(
              "Availability",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDropdownButton(["Day", "Month", "11"], (value) {
                  setState(() => selectedAvailabilityDay = value);
                }, selectedAvailabilityDay),
                const SizedBox(width: 8),
                _buildDropdownButton(["15", "06", "2025"], (value) {
                  setState(() => selectedAvailabilityMonth = value);
                }, selectedAvailabilityMonth),
                const SizedBox(width: 8),
                Text(
                  "To",
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDropdownButton(["30 AM", "30 PM"], (value) {
                  setState(() => selectedAvailabilityTime = value);
                }, selectedAvailabilityTime),
                const SizedBox(width: 8),
                Text(
                  "05 : 30 PM",
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF086861),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Apply",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selected,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map((option) => ChoiceChip(
                    label: Text(option),
                    selected: selected == option,
                    onSelected: (selected) => onSelect(option),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownButton(
    List<String> items,
    Function(String?) onChanged,
    String? selectedValue,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        hint: Text(items.first),
        icon: const Icon(Icons.arrow_drop_down),
        underline: const SizedBox(),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
