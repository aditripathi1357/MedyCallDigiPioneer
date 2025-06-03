import 'package:flutter/material.dart';

// Filter data model to hold all filter values
class FilterData {
  int searchForIndex;
  RangeValues distance;
  RangeValues price;
  RangeValues experience;
  Set<int> selectedLanguages;
  int gender;
  DateTime? selectedDate;
  TimeOfDay? timeFrom;
  TimeOfDay? timeTo;

  FilterData({
    this.searchForIndex = 0,
    this.distance = const RangeValues(5, 300),
    this.price = const RangeValues(50, 1100),
    this.experience = const RangeValues(5, 10),
    this.selectedLanguages = const {0, 1, 2},
    this.gender = 1,
    this.selectedDate,
    this.timeFrom = const TimeOfDay(hour: 11, minute: 30),
    this.timeTo = const TimeOfDay(hour: 17, minute: 30),
  }) {
    selectedDate ??= DateTime.now();
  }

  FilterData copyWith({
    int? searchForIndex,
    RangeValues? distance,
    RangeValues? price,
    RangeValues? experience,
    Set<int>? selectedLanguages,
    int? gender,
    DateTime? selectedDate,
    TimeOfDay? timeFrom,
    TimeOfDay? timeTo,
  }) {
    return FilterData(
      searchForIndex: searchForIndex ?? this.searchForIndex,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      experience: experience ?? this.experience,
      selectedLanguages: selectedLanguages ?? Set.from(this.selectedLanguages),
      gender: gender ?? this.gender,
      selectedDate: selectedDate ?? this.selectedDate,
      timeFrom: timeFrom ?? this.timeFrom,
      timeTo: timeTo ?? this.timeTo,
    );
  }

  int get activeFiltersCount {
    int count = 0;
    // Count non-default values
    if (searchForIndex != 0) count++;
    if (distance.start != 5 || distance.end != 300) count++;
    if (price.start != 50 || price.end != 1100) count++;
    if (experience.start != 5 || experience.end != 10) count++;
    if (!selectedLanguages.containsAll([0, 1, 2]) ||
        selectedLanguages.length != 3)
      count++;
    if (gender != 1) count++;
    if (selectedDate?.day != DateTime.now().day) count++;
    return count;
  }
}

class FilterSheet extends StatefulWidget {
  final FilterData initialFilterData;
  final Function(FilterData) onApplyFilters;

  const FilterSheet({
    super.key,
    required this.initialFilterData,
    required this.onApplyFilters,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterData currentFilter;

  final List<String> languages = [
    'English',
    'Hindi',
    'Gujarati',
    'Marathi',
    'Tamil',
    'Telugu',
    'Malayalam',
    'Kannada',
    'Bengali',
  ];

  final List<String> searchOptions = ['Doctor', 'Clinic', 'Hospital'];
  final List<String> genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    currentFilter = widget.initialFilterData.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentFilter = FilterData();
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchForSection(),
                      _buildDivider(),
                      _buildDistanceSection(),
                      _buildDivider(),
                      _buildPriceSection(),
                      _buildDivider(),
                      _buildExperienceSection(),
                      _buildDivider(),
                      _buildLanguageSection(),
                      _buildDivider(),
                      _buildGenderSection(),
                      _buildDivider(),
                      _buildAvailabilitySection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Apply Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApplyFilters(currentFilter);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchForSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search For',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children:
                searchOptions.asMap().entries.map((entry) {
                  return _buildToggleButton(entry.value, entry.key);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distance From Your Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: currentFilter.distance,
          min: 0,
          max: 500,
          divisions: 100,
          labels: RangeLabels(
            "${currentFilter.distance.start.round()} Km",
            "${currentFilter.distance.end.round()} Km",
          ),
          activeColor: Colors.teal,
          onChanged: (value) => setState(() => currentFilter.distance = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0 Km',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${currentFilter.distance.start.round()} - ${currentFilter.distance.end.round()} Km',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '500 Km',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Fee',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: currentFilter.price,
          min: 50,
          max: 5000,
          divisions: 100,
          labels: RangeLabels(
            "₹${currentFilter.price.start.round()}",
            "₹${currentFilter.price.end.round()}",
          ),
          activeColor: Colors.teal,
          onChanged: (value) => setState(() => currentFilter.price = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹50',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '₹${currentFilter.price.start.round()} - ₹${currentFilter.price.end.round()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '₹5000',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Years Of Experience',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: currentFilter.experience,
          min: 0,
          max: 50,
          divisions: 50,
          labels: RangeLabels(
            "${currentFilter.experience.start.round()} Years",
            "${currentFilter.experience.end.round()} Years",
          ),
          activeColor: Colors.teal,
          onChanged:
              (value) => setState(() => currentFilter.experience = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0 Years',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${currentFilter.experience.start.round()} - ${currentFilter.experience.end.round()} Years',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '50+ Years',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Languages',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              languages.asMap().entries.map((entry) {
                final index = entry.key;
                final language = entry.value;
                final isSelected = currentFilter.selectedLanguages.contains(
                  index,
                );
                return FilterChip(
                  label: Text(language),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        currentFilter.selectedLanguages.add(index);
                      } else {
                        currentFilter.selectedLanguages.remove(index);
                      }
                    });
                  },
                  selectedColor: Colors.teal.withOpacity(0.2),
                  checkmarkColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.teal : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doctor Gender',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children:
                genderOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final gender = entry.value;
                  final isSelected = currentFilter.gender == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => currentFilter.gender = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal : Colors.transparent,
                          borderRadius: BorderRadius.horizontal(
                            left:
                                index == 0
                                    ? const Radius.circular(25)
                                    : Radius.zero,
                            right:
                                index == 1
                                    ? const Radius.circular(25)
                                    : Radius.zero,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          gender,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight:
                                isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Date section
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'Day',
                          currentFilter.selectedDate?.day ?? DateTime.now().day,
                          1,
                          31,
                          (value) {
                            if (currentFilter.selectedDate != null) {
                              setState(() {
                                currentFilter.selectedDate = DateTime(
                                  currentFilter.selectedDate!.year,
                                  currentFilter.selectedDate!.month,
                                  value,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateField(
                          'Month',
                          currentFilter.selectedDate?.month ??
                              DateTime.now().month,
                          1,
                          12,
                          (value) {
                            if (currentFilter.selectedDate != null) {
                              setState(() {
                                currentFilter.selectedDate = DateTime(
                                  currentFilter.selectedDate!.year,
                                  value,
                                  currentFilter.selectedDate!.day,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildDateField(
                    '',
                    currentFilter.selectedDate?.year ?? DateTime.now().year,
                    DateTime.now().year - 10,
                    DateTime.now().year + 10,
                    (value) {
                      if (currentFilter.selectedDate != null) {
                        setState(() {
                          currentFilter.selectedDate = DateTime(
                            value,
                            currentFilter.selectedDate!.month,
                            currentFilter.selectedDate!.day,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Time section - now in the same row level as date fields
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildTimeField('From', currentFilter.timeFrom),
                  const SizedBox(height: 8),
                  _buildTimeField('To', currentFilter.timeTo),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD3F0ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: List.generate(max - min + 1, (index) {
                final itemValue = min + index;
                return DropdownMenuItem<int>(
                  value: itemValue,
                  child: Text(itemValue.toString().padLeft(2, '0')),
                );
              }),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() {
                if (label == 'From') {
                  currentFilter.timeFrom = picked;
                } else {
                  currentFilter.timeTo = picked;
                }
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD3F0ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time?.format(context) ?? '--:--',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String text, int index) {
    final isSelected = currentFilter.searchForIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => currentFilter.searchForIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: Colors.grey[300], height: 1),
    );
  }
}

// Example usage - Main page that uses the filter
class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  // Filter data instance
  FilterData filterData = FilterData();

  // Sample data for demonstration
  List<Map<String, dynamic>> allDoctors = [
    {
      'name': 'Dr. John Smith',
      'specialty': 'Cardiologist',
      'experience': 8,
      'fee': 500,
      'distance': 2.5,
      'gender': 0, // 0 = Male, 1 = Female
      'languages': [0, 1], // English, Hindi
    },
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Dermatologist',
      'experience': 12,
      'fee': 800,
      'distance': 5.2,
      'gender': 1,
      'languages': [0, 2], // English, Gujarati
    },
    // Add more sample doctors...
  ];

  List<Map<String, dynamic>> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = List.from(allDoctors);
  }

  // Callback function when filters are applied
  void _onFilterApplied(FilterData newFilterData) {
    setState(() {
      filterData = newFilterData;
    });
    _applyFiltersToResults();
  }

  // Apply filters to the doctor list
  void _applyFiltersToResults() {
    setState(() {
      filteredDoctors =
          allDoctors.where((doctor) {
            // Apply distance filter
            if (doctor['distance'] < filterData.distance.start ||
                doctor['distance'] > filterData.distance.end) {
              return false;
            }

            // Apply price filter
            if (doctor['fee'] < filterData.price.start ||
                doctor['fee'] > filterData.price.end) {
              return false;
            }

            // Apply experience filter
            if (doctor['experience'] < filterData.experience.start ||
                doctor['experience'] > filterData.experience.end) {
              return false;
            }

            // Apply gender filter
            if (doctor['gender'] != filterData.gender) {
              return false;
            }

            // Apply language filter
            List<int> doctorLanguages = List<int>.from(doctor['languages']);
            bool hasMatchingLanguage = doctorLanguages.any(
              (lang) => filterData.selectedLanguages.contains(lang),
            );

            if (!hasMatchingLanguage) {
              return false;
            }

            return true;
          }).toList();
    });
  }

  // Show filter bottom sheet
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => FilterSheet(
            initialFilterData: filterData,
            onApplyFilters: _onFilterApplied,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Filter button with badge
          Stack(
            children: [
              IconButton(
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.filter_list),
              ),
              if (filterData.activeFiltersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${filterData.activeFiltersCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter summary bar
          if (filterData.activeFiltersCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.teal.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filterData.activeFiltersCount} filters applied • ${filteredDoctors.length} results',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        filterData = FilterData();
                      });
                      _applyFiltersToResults();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // Search results
          Expanded(
            child:
                filteredDoctors.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No doctors found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.teal,
                                      child: Text(
                                        doctor['name'][3], // First letter after "Dr. "
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            doctor['specialty'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.work,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${doctor['experience']} years exp'),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${doctor['distance']} km'),
                                    const Spacer(),
                                    Text(
                                      '₹${doctor['fee']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterSheet,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
    );
  }
}

// Main app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Filter Demo',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const DoctorSearchPage(),
    );
  }
}

void main() {
  runApp(const MyApp());
}
