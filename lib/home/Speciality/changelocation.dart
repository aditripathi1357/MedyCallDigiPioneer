import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medycall/Medyscan/medyscan.dart'; // Assuming these paths are correct
import 'package:medycall/home/profile/profile.dart'; // Assuming these paths are correct
import 'package:medycall/home/home_screen.dart'; // Assuming these paths are correct
import 'package:medycall/History/history.dart'; // Assuming these paths are correct
import 'package:medycall/Appointment/appointment.dart'; // Assuming these paths are correct
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationChangePage extends StatefulWidget {
  const LocationChangePage({Key? key}) : super(key: key);

  @override
  State<LocationChangePage> createState() => _LocationChangePageState();
}

class _LocationChangePageState extends State<LocationChangePage> {
  int _selectedIndex =
      1; // Assuming this is for the bottom nav bar, adjust if needed
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(37.422, -122.084); // Default position
  bool _isLoading = true;
  bool _showSearchBar = false;
  bool _showManualForm = false;

  final TextEditingController _searchLocationController =
      TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, String> _location = {
    'area': 'Loading...',
    'city': 'Please wait',
    'state': '',
    'pincode': '',
    'type': 'Home', // Default type
  };
  String _selectedLocationType = 'Home';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchLocationController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _updateLocationFromCoordinates(
          position.latitude,
          position.longitude,
        );
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        if (_mapController != null) {
          // Await camera animation
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentPosition, zoom: 15),
            ),
          );
        }
      } catch (e) {
        print('Error getting location: $e');
        if (mounted) {
          setState(() {
            _location['area'] = "Error";
            _location['city'] = "Could not fetch location";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print('Location permission denied');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _location['area'] = "Permission Denied";
          _location['city'] = "Location access needed";
        });
      }
    }
  }

  Future<void> _updateLocationFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (mounted && placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _location = {
            'area': place.street ?? place.subLocality ?? 'Unknown area',
            'city':
                place.locality ?? place.subAdministrativeArea ?? 'Unknown city',
            'state': place.administrativeArea ?? _location['state'] ?? '',
            'pincode': place.postalCode ?? _location['pincode'] ?? '',
            'type': _location['type'] ?? _selectedLocationType,
          };
          _streetController.text = place.street ?? '';
          _areaController.text = place.subLocality ?? place.locality ?? '';
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _pincodeController.text = place.postalCode ?? '';
        });
      } else if (mounted) {
        setState(() {
          _location['area'] = "Address not found";
          _location['city'] = "Try searching or manual entry";
        });
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
      if (mounted) {
        setState(() {
          _location['area'] = "Geocoding Error";
          _location['city'] = "Failed to get address details";
        });
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location searchedLocation =
            locations.first; // Renamed to avoid conflict
        LatLng newPosition = LatLng(
          searchedLocation.latitude,
          searchedLocation.longitude,
        );
        if (_mapController != null) {
          await _mapController!.animateCamera(
            // Await camera animation
            CameraUpdate.newCameraPosition(
              CameraPosition(target: newPosition, zoom: 15),
            ),
          );
        }
        await _updateLocationFromCoordinates(
          searchedLocation.latitude,
          searchedLocation.longitude,
        );
        if (mounted) {
          setState(() {
            _currentPosition = newPosition;
            _showSearchBar = false;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location not found. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error searching location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error finding location. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (!_isLoading && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 15),
        ),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    // Debounce or limit frequency if this causes performance issues
    // setState(() {
    //   _currentPosition = position.target;
    // });
  }

  // void _onCameraIdle() async {
  //   // Update _currentPosition state first for visual feedback if marker is tied to it
  //   setState(() {
  //     _currentPosition =
  //         _mapController?.cameraPosition.target ?? _currentPosition;
  //   });
  //   await _updateLocationFromCoordinates(
  //     _currentPosition.latitude,
  //     _currentPosition.longitude,
  //   );
  // }

  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      final completeAddress = [
        _houseNoController.text,
        _streetController.text,
        _landmarkController.text,
        _areaController.text,
      ].where((element) => element.isNotEmpty).join(', ');

      final Map<String, String> savedLocation = {
        'area':
            completeAddress.isNotEmpty ? completeAddress : _areaController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'type': _selectedLocationType,
      };
      // Update the main _location state before popping
      setState(() {
        _location = savedLocation;
      });
      Navigator.pop(context, _location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            _isLoading
                ? Text(
                  'Fetching Location...',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _location['area'] ?? 'Unknown Area',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_location['city'] != null &&
                        _location['city']!.isNotEmpty)
                      Text(
                        _location['city']!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
        centerTitle: false,
      ),
      body: Stack(
        // Use Stack for overlaying the manual form
        children: [
          // Main content (Map, buttons)
          Column(
            children: [
              // Map Section
              Container(
                height: 300, // Adjust as needed, or make it flexible
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _isLoading &&
                              _mapController ==
                                  null // Show progress only if map not yet initialized
                          ? const Center(child: CircularProgressIndicator())
                          : GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 15,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            compassEnabled: false,
                            onCameraMove: _onCameraMove,
                            // onCameraIdle: _onCameraIdle,
                          ),
                      const Icon(
                        Icons.location_pin,
                        color: Color(0xFF00796B),
                        size: 40,
                      ),
                      if (_showSearchBar)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: _buildSearchBar(),
                        ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Column(
                          children: [
                            _buildMapButton(
                              icon: Icons.gps_fixed,
                              onPressed: _getCurrentLocation,
                              backgroundColor: Colors.white,
                              iconColor: const Color(0xFF00796B),
                            ),
                            const SizedBox(height: 8),
                            _buildMapButton(
                              icon: Icons.search,
                              onPressed: () {
                                setState(() {
                                  _showSearchBar = !_showSearchBar;
                                });
                              },
                              backgroundColor: const Color(0xFF00796B),
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Manual Location Form Toggle
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showManualForm = !_showManualForm;
                          });
                        },
                        icon: Icon(
                          _showManualForm
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        label: const Text('Enter Address Manually'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00796B),
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF00796B)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(), // Pushes the button to the bottom if content is less
              // "Use Current Location" button, only if manual form is not shown
              if (!_showManualForm)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await _getCurrentLocation(); // This updates _location and _isLoading

                      if (mounted) {
                        final area = _location['area'];
                        final city = _location['city'];
                        bool hasValidArea =
                            area != null &&
                            area != 'Unknown area' &&
                            area != 'Loading...' &&
                            area != 'Permission Denied' &&
                            area != 'Error' &&
                            area != 'Geocoding Error' &&
                            area != 'Address not found' &&
                            area.isNotEmpty;
                        bool hasValidCity =
                            city != null &&
                            city != 'Please wait' &&
                            city != 'Could not fetch location' &&
                            city != 'Location access needed' &&
                            city != 'Failed to get address details' &&
                            city != 'Try searching or manual entry' &&
                            city.isNotEmpty;

                        if (hasValidArea && hasValidCity) {
                          Navigator.pop(context, _location);
                        } else if (!_isLoading) {
                          // Only show snackbar if not still loading (e.g. error in _getCurrentLocation resolved)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _location['area'] == 'Permission Denied'
                                    ? 'Location permission is required.'
                                    : 'Fetched location details are incomplete or invalid. Please verify or enter manually.',
                              ),
                            ),
                          );
                        }
                        // Ensure isLoading is false if we are not popping and _getCurrentLocation might not have set it.
                        if (mounted && _isLoading) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Use Current Location',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              // Bottom padding to ensure button is above bottom nav bar if it's very tall
              SizedBox(height: _showManualForm ? 0 : 16),
            ],
          ),

          // Manual Form Overlay
          if (_showManualForm)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    height:
                        MediaQuery.of(context).size.height *
                        0.85, // Adjusted height
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                    ), // Max width for larger screens
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Header with close button
                        Container(
                          padding: const EdgeInsets.all(16), // Reduced padding
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Enter Address Manually',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showManualForm = false;
                                  });
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        // Form content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              16,
                              16,
                            ), // Adjusted padding
                            child: _buildManualLocationForm(),
                          ),
                        ),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchLocationController,
        decoration: InputDecoration(
          hintText: 'Search location',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00796B)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _showSearchBar = false;
                _searchLocationController.clear();
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
        onSubmitted: _searchLocation,
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildManualLocationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Type Selection
          Text(
            'Location Type',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children:
                ['Home', 'Work', 'Other'].map((type) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: type != 'Other' ? 8 : 0),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: _selectedLocationType == type,
                        onSelected: (selected) {
                          if (selected) {
                            // Ensure onSelected is only called when selected is true
                            setState(() {
                              _selectedLocationType = type;
                            });
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: const Color(0xFF00796B).withOpacity(0.2),
                        labelStyle: GoogleFonts.poppins(
                          color:
                              _selectedLocationType == type
                                  ? const Color(0xFF00796B)
                                  : Colors.grey[700], // Darker for unselected
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color:
                                _selectedLocationType == type
                                    ? const Color(0xFF00796B)
                                    : Colors.grey[400]!,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFormField(
                    controller: _houseNoController,
                    label: 'House/Flat/Office No',
                    hint: 'Enter house/flat number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter house/flat number';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _streetController,
                    label: 'Street/Road Name',
                    hint: 'Enter street or road name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter street name';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _landmarkController,
                    label: 'Landmark (Optional)',
                    hint: 'Near hospital, mall, etc.',
                  ),
                  _buildFormField(
                    controller: _areaController,
                    label: 'Area/Locality',
                    hint: 'Enter area or locality',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter area/locality';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'Enter city',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter city';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          controller: _stateController,
                          label: 'State',
                          hint: 'Enter state',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter state';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    controller: _pincodeController,
                    label: 'PIN Code',
                    hint: 'Enter 6-digit PIN code',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter PIN code';
                      }
                      if (value.length != 6) {
                        return 'PIN code must be 6 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10), // Space before save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Address',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true, // Add a subtle background
            fillColor: Colors.white, // Or Colors.grey[100]
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // buildLocationWidget is removed as its content is now in AppBar

  Widget _buildBottomNavigationBar() {
    // Assuming your asset paths are correct and exist in pubspec.yaml
    // Using placeholder icons if assets are not available for this example
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 80, // Increased height to accommodate labels better if needed
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
                      (context, error, stackTrace) => Icon(
                        Icons.home,
                        color:
                            _selectedIndex == 0
                                ? const Color(0xFF00796B)
                                : Colors.grey,
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
                      (context, error, stackTrace) => Icon(
                        Icons.calendar_today,
                        color:
                            _selectedIndex == 1
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                      ),
                ),
                label: 'Appointment',
              ),
              const BottomNavigationBarItem(
                icon: SizedBox(width: 24, height: 24), // Placeholder for NIROG
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
                      (context, error, stackTrace) => Icon(
                        Icons.history,
                        color:
                            _selectedIndex == 3
                                ? const Color(0xFF00796B)
                                : Colors.grey,
                      ),
                ),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/homescreen/medyscan.png', // Corrected from profile to medyscan
                  width: 24,
                  height: 24,
                  color:
                      _selectedIndex == 4
                          ? const Color(0xFF00796B)
                          : Colors.grey,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.document_scanner,
                        color:
                            _selectedIndex == 4
                                ? const Color(0xFF00796B)
                                : Colors.grey,
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
              fontWeight: FontWeight.w500, // Slightly bolder for selected
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            backgroundColor: Colors.white, // Explicitly set
            elevation: 0, // Handled by the container's shadow
            onTap: (index) {
              if (index == 2) {
                // NIROG button (center)
                print('NIROG tapped - Special Action');
                // Navigator.push(context, MaterialPageRoute(builder: (context) => NirogPage())); // Example
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
              // Navigate to other screens
              switch (index) {
                case 0:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  ); // Use pushReplacement if it's a main tab
                  break;
                case 1:
                  if (ModalRoute.of(context)?.settings.name != '/appointment') {
                    // Prevent pushing if already on it
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppointmentScreen(),
                        settings: RouteSettings(name: '/appointment'),
                      ),
                    );
                  }
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicalHistoryPage(),
                    ),
                  );
                  break;
                case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedyscanPage()),
                  );
                  break;
              }
            },
          ),
        ),
        Positioned(
          top: -20, // Adjust if necessary based on BottomNavBar height
          child: GestureDetector(
            onTap: () {
              print('NIROG Tapped from Stack');
              // Handle NIROG tap, e.g., navigate or show a dialog
              // This is the actual tap target for the protruding item
              // setState(() { _selectedIndex = 2; }); // Optional: select it visually
              // Navigator.push(context, MaterialPageRoute(builder: (context) => NirogPage())); // Example
            },
            child: Container(
              // Added container for better tap area and potential styling
              padding: const EdgeInsets.all(
                4.0,
              ), // Add padding if image is too small
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // color: Colors.white, // Optional: if you want a background behind the image
                // boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)]
              ),
              child: Image.asset(
                'assets/homescreen/nirog.png',
                width: 51,
                height: 54, // Ensure aspect ratio is good
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF00796B),
                      child: Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
