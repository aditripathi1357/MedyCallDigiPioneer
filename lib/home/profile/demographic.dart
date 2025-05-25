import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medycall/home/profile/lifestyle.dart'; // Assuming LifestyleForm is correctly named and located
import 'package:medycall/services/user_service.dart';
import 'package:provider/provider.dart'; // Added for UserProvider
import 'package:medycall/providers/user_provider.dart'; // Added for UserProvider
import 'package:medycall/models/user_model.dart'; // Added for UserModel type hint

class DemographicDataScreen extends StatefulWidget {
  const DemographicDataScreen({Key? key}) : super(key: key);

  @override
  State<DemographicDataScreen> createState() => _DemographicDataScreenState();
}

class _DemographicDataScreenState extends State<DemographicDataScreen> {
  int _selectedIndex = 4; // Profile is selected
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  bool _isLoading = false;

  // Form fields - Initialized with defaults
  String _title = 'Mr.';
  String _name = '';
  DateTime _birthDate = DateTime.now().subtract(
    const Duration(days: 365 * 25),
  ); // Default to 25 years ago
  String _gender = 'Male';
  String _bloodGroup = 'O+';
  String _height = '';
  String _weight = '';
  String _maritalStatus = 'Single';
  String _contactNumber = '';
  String _alternateNumber = '';
  String _email = '';

  final List<String> _titles = ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Prof.'];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    // Ensure context is available for Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeEmail(); // Sets initial email from auth
      await _loadExistingData(); // Loads from provider or local storage
    });
  }

  Future<void> _initializeEmail() async {
    final currentUserEmail = _userService.getCurrentUserEmail();
    if (mounted) {
      setState(() {
        _email = currentUserEmail ?? _email;
      });
    }
  }

  void _populateFieldsFromData(Map<String, dynamic> data) {
    setState(() {
      _title = data['title'] ?? _title;
      _name = data['name'] ?? _name;
      if (data['birthDate'] != null && data['birthDate'].isNotEmpty) {
        try {
          _birthDate = DateTime.parse(data['birthDate']);
        } catch (e) {
          print("Error parsing birthDate from data: ${data['birthDate']}");
          // Keep default or current _birthDate
        }
      }
      _gender = data['gender'] ?? _gender;
      _bloodGroup = data['bloodGroup'] ?? _bloodGroup;
      _height = data['height']?.toString() ?? _height;
      _weight = data['weight']?.toString() ?? _weight;
      _maritalStatus = data['maritalStatus'] ?? _maritalStatus;
      _contactNumber = data['contactNumber'] ?? _contactNumber;
      _alternateNumber = data['alternateNumber'] ?? _alternateNumber;
      // Email from loaded data takes precedence over auth email if available
      _email = data['email'] ?? _email;
    });
  }

  Future<void> _loadExistingData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Priority 1: UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      UserModel? providerUser = userProvider.user;
      Map<String, dynamic>? providerDemographicData;

      // Check if the user object in provider has actual profile data
      if (providerUser != null &&
          providerUser.supabaseUid != null &&
          providerUser.name != null &&
          providerUser.name!.isNotEmpty) {
        providerDemographicData = providerUser.getDemographicData();
      }

      if (providerDemographicData != null &&
          providerDemographicData.isNotEmpty) {
        print('DemographicDataScreen: Loading data from UserProvider');
        _populateFieldsFromData(providerDemographicData);
      } else {
        // Priority 2: Local Storage (for in-progress forms)
        print(
          'DemographicDataScreen: UserProvider data not found or incomplete, trying local storage.',
        );
        final localData = await _userService.getLocalDemographicData();
        if (localData != null && mounted) {
          print('DemographicDataScreen: Loading data from Local Storage');
          _populateFieldsFromData(localData);
        } else {
          print(
            'DemographicDataScreen: No data in UserProvider or Local Storage. Using defaults/auth email.',
          );
          // Fields will retain defaults or email from _initializeEmail if not overridden
        }
      }
    } catch (e) {
      if (mounted) {
        print(
          'DemographicDataScreen: Error loading existing data: ${e.toString()}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading existing data: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  int get _age {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    if (now.month < _birthDate.month ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age > 0 ? age : 0;
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save(); // Ensure all onSaved callbacks are triggered

    setState(() => _isLoading = true);

    try {
      await _userService.saveDemographicDataLocally(
        email: _email,
        title: _title,
        name: _name,
        birthDate: _birthDate,
        gender: _gender,
        bloodGroup:
            _bloodGroup.isNotEmpty && _bloodGroup != 'Unknown'
                ? _bloodGroup
                : null,
        height: _height.isNotEmpty ? int.tryParse(_height) : null,
        weight: _weight.isNotEmpty ? int.tryParse(_weight) : null,
        maritalStatus: _maritalStatus.isNotEmpty ? _maritalStatus : null,
        contactNumber: _contactNumber,
        alternateNumber: _alternateNumber.isNotEmpty ? _alternateNumber : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demographic data saved locally'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LifestyleForm()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _skipForNow() async {
    _formKey.currentState!.save(); // Save current values even if skipping

    if (_name.isEmpty || _email.isEmpty || _contactNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Name, Email, and Contact Number are required to save progress.',
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _userService.saveDemographicDataLocally(
        email: _email,
        name: _name,
        birthDate: _birthDate,
        gender: _gender,
        contactNumber: _contactNumber,
        title: _title.isNotEmpty ? _title : null,
        bloodGroup:
            _bloodGroup.isNotEmpty && _bloodGroup != 'Unknown'
                ? _bloodGroup
                : null,
        height: _height.isNotEmpty ? int.tryParse(_height) : null,
        weight: _weight.isNotEmpty ? int.tryParse(_weight) : null,
        maritalStatus: _maritalStatus.isNotEmpty ? _maritalStatus : null,
        alternateNumber: _alternateNumber.isNotEmpty ? _alternateNumber : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current progress saved locally'),
            backgroundColor: Colors.blueAccent,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LifestyleForm()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save progress: ${e.toString()}')),
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
    // Initial loading condition for the main content
    bool isStillInitializing = _isLoading && _name.isEmpty && _email.isEmpty;

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
                  'Demographic Data',
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Name'),
                              Row(
                                children: [
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value:
                                          _titles.contains(_title)
                                              ? _title
                                              : _titles.first,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      elevation: 16,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _title = newValue!;
                                        });
                                      },
                                      items:
                                          _titles.map<DropdownMenuItem<String>>(
                                            (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            },
                                          ).toList(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey(
                                        _name,
                                      ), // Helps update if _name changes externally
                                      initialValue: _name,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 15,
                                            ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Name is required';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _name = value ?? '',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Birth Date'),
                                        InkWell(
                                          onTap: () => _selectDate(context),
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 15,
                                                  ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  DateFormat(
                                                    'dd MMMM yyyy',
                                                  ).format(_birthDate),
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Age'),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 15,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '$_age Years',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildLabel('Gender'),
                              DropdownButtonFormField<String>(
                                value:
                                    [
                                          'Male',
                                          'Female',
                                          'Other',
                                        ].contains(_gender)
                                        ? _gender
                                        : 'Male',
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15,
                                  ),
                                ),
                                items:
                                    [
                                      'Male',
                                      'Female',
                                      'Other',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _gender = newValue!;
                                  });
                                },
                                onSaved: (value) => _gender = value ?? 'Male',
                              ),
                              const SizedBox(height: 20),
                              _buildLabel('Blood Group (Optional)'),
                              DropdownButtonFormField<String>(
                                value:
                                    [
                                          'A+',
                                          'A-',
                                          'B+',
                                          'B-',
                                          'AB+',
                                          'AB-',
                                          'O+',
                                          'O-',
                                          'Unknown',
                                        ].contains(_bloodGroup)
                                        ? _bloodGroup
                                        : 'O+',
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15,
                                  ),
                                ),
                                items:
                                    [
                                      'A+',
                                      'A-',
                                      'B+',
                                      'B-',
                                      'AB+',
                                      'AB-',
                                      'O+',
                                      'O-',
                                      'Unknown',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _bloodGroup = newValue!;
                                  });
                                },
                                onSaved: (value) => _bloodGroup = value ?? 'O+',
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Height (Cm, Optional)'),
                                        TextFormField(
                                          key: ValueKey('height_$_height'),
                                          initialValue: _height,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            suffixText: 'Cm',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 15,
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              final heightVal = int.tryParse(
                                                value,
                                              );
                                              if (heightVal == null ||
                                                  heightVal <= 0 ||
                                                  heightVal > 300) {
                                                return 'Enter valid height';
                                              }
                                            }
                                            return null;
                                          },
                                          onSaved:
                                              (value) => _height = value ?? '',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Weight (Kg, Optional)'),
                                        TextFormField(
                                          key: ValueKey('weight_$_weight'),
                                          initialValue: _weight,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            suffixText: 'Kgs',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 15,
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              final weightVal = int.tryParse(
                                                value,
                                              );
                                              if (weightVal == null ||
                                                  weightVal <= 0 ||
                                                  weightVal > 500) {
                                                return 'Enter valid weight';
                                              }
                                            }
                                            return null;
                                          },
                                          onSaved:
                                              (value) => _weight = value ?? '',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildLabel('Marital Status (Optional)'),
                              DropdownButtonFormField<String>(
                                value:
                                    [
                                          'Single',
                                          'Married',
                                          'Divorced',
                                          'Widowed',
                                          'Separated',
                                        ].contains(_maritalStatus)
                                        ? _maritalStatus
                                        : 'Single',
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15,
                                  ),
                                ),
                                items:
                                    [
                                      'Single',
                                      'Married',
                                      'Divorced',
                                      'Widowed',
                                      'Separated',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _maritalStatus = newValue!;
                                  });
                                },
                                onSaved:
                                    (value) =>
                                        _maritalStatus = value ?? 'Single',
                              ),
                              const SizedBox(height: 20),
                              _buildLabel('Contact Number'),
                              TextFormField(
                                key: ValueKey('contact_$_contactNumber'),
                                initialValue: _contactNumber,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  prefixText: '+91 ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Contact number is required';
                                  }
                                  if (value.length != 10) {
                                    return 'Enter valid 10-digit number';
                                  }
                                  return null;
                                },
                                onSaved:
                                    (value) => _contactNumber = value ?? '',
                              ),
                              const SizedBox(height: 20),
                              _buildLabel('Alternate Number (Optional)'),
                              TextFormField(
                                key: ValueKey('alt_contact_$_alternateNumber'),
                                initialValue: _alternateNumber,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  prefixText: '+91 ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15,
                                  ),
                                ),
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      value.length != 10) {
                                    return 'Enter valid 10-digit number';
                                  }
                                  return null;
                                },
                                onSaved:
                                    (value) => _alternateNumber = value ?? '',
                              ),
                              const SizedBox(height: 20),
                              _buildLabel('Email'),
                              TextFormField(
                                key: ValueKey('email_$_email'),
                                initialValue: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Enter valid email address';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _email = value ?? '',
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    // Added Expanded
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _skipForNow,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xFF008D83,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF008D83),
                                          ),
                                        ),
                                        minimumSize: const Size(
                                          0,
                                          50,
                                        ), // Adjusted
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        'Skip for Now',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
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
                                          _isLoading ? null : _saveAndContinue,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF008D83,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        minimumSize: const Size(
                                          0,
                                          50,
                                        ), // Adjusted
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      child:
                                          _isLoading
                                              ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Text(
                                                'Save & Continue',
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                textAlign: TextAlign.center,
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
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
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
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
          ),
        ),
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () {
              print('NIROG button tapped from Demographic Screen');
            },
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
