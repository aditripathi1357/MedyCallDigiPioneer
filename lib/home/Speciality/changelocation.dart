import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medycall/Medyscan/medyscan.dart';
import 'package:medycall/home/profile/profile.dart'; // Ensure this path is correct
import 'package:medycall/home/home_screen.dart'; // Ensure this path is correct
import 'package:medycall/History/history.dart'; // Ensure this path is correct
import 'package:medycall/Appointment/appointment.dart'; // Ensure this path is correct
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationChangePage extends StatefulWidget {
  const LocationChangePage({Key? key}) : super(key: key);

  @override
  State<LocationChangePage> createState() => _LocationChangePageState();
}

class _LocationChangePageState extends State<LocationChangePage> {
  int _selectedIndex = 1;
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(37.422, -122.084);
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
    'type': 'Home',
    'houseNo': '', // Added to store house number locally
    'street': '', // Added to store street locally
    'landmark': '', // Added to store landmark locally
  };
  String _selectedLocationType = 'Home';

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
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

  Future<void> _saveLocationLocally(Map<String, String> location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = json.encode(location);
      await prefs.setString('saved_location', locationString);
      print('Location saved locally: $location');
    } catch (e) {
      print('Error saving location locally: $e');
    }
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = prefs.getString('saved_location');
      if (locationString != null) {
        final savedLocation =
            json.decode(locationString) as Map<String, dynamic>;
        final typedLocation = savedLocation.map(
          (key, value) => MapEntry(key, value.toString()),
        );

        if (mounted) {
          setState(() {
            _location = typedLocation;
            _selectedLocationType = typedLocation['type'] ?? 'Home';

            // Populate manual form fields if a saved location was loaded
            _houseNoController.text = typedLocation['houseNo'] ?? '';
            _streetController.text = typedLocation['street'] ?? '';
            _landmarkController.text = typedLocation['landmark'] ?? '';
            _areaController.text = typedLocation['area'] ?? '';
            _cityController.text = typedLocation['city'] ?? '';
            _stateController.text = typedLocation['state'] ?? '';
            _pincodeController.text = typedLocation['pincode'] ?? '';
          });
          await _geocodeAddressAndUpdateMap(
            _location,
          ); // Use _location directly
        }
        print('Location loaded locally: $typedLocation');
      }
    } catch (e) {
      print('Error loading location locally: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

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
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        }
        if (_mapController != null) {
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
            'houseNo': place.subThoroughfare ?? '', // Populate house number
            'street': place.street ?? '', // Populate street
            'landmark': '', // Cannot easily reverse geocode landmark
            'area': place.subLocality ?? place.locality ?? 'Unknown area',
            'city':
                place.locality ?? place.subAdministrativeArea ?? 'Unknown city',
            'state': place.administrativeArea ?? _location['state'] ?? '',
            'pincode': place.postalCode ?? _location['pincode'] ?? '',
            'type': _location['type'] ?? _selectedLocationType,
          };
          // Pre-fill manual form fields with reverse geocoded data
          _houseNoController.text = _location['houseNo']!;
          _streetController.text = _location['street']!;
          _landmarkController.text = _location['landmark']!;
          _areaController.text = _location['area']!;
          _cityController.text = _location['city']!;
          _stateController.text = _location['state']!;
          _pincodeController.text = _location['pincode']!;
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
        Location searchedLocation = locations.first;
        LatLng newPosition = LatLng(
          searchedLocation.latitude,
          searchedLocation.longitude,
        );

        if (_mapController != null) {
          await _mapController!.animateCamera(
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

  Future<void> _geocodeAddressAndUpdateMap(Map<String, String> address) async {
    final fullAddress = [
      address['houseNo'],
      address['street'],
      address['landmark'],
      address['area'],
      address['city'],
      address['state'],
      address['pincode'],
    ].where((element) => element != null && element.isNotEmpty).join(', ');

    if (fullAddress.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(fullAddress);
      if (locations.isNotEmpty) {
        Location geoCodedLocation = locations.first;
        LatLng newPosition = LatLng(
          geoCodedLocation.latitude,
          geoCodedLocation.longitude,
        );

        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: newPosition, zoom: 15),
            ),
          );
        }
        if (mounted) {
          setState(() {
            _currentPosition = newPosition;
          });
        }
      } else {
        print('Geocoding failed for address: $fullAddress');
      }
    } catch (e) {
      print('Error during geocoding for map update: $e');
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
    // Optional: Update marker position as map moves
    // setState(() {
    //   _currentPosition = position.target;
    // });
  }

  // Optional: Reverse geocode when map becomes idle after movement
  // void _onCameraIdle() async {
  //   setState(() {
  //     _currentPosition = _mapController?.cameraPosition.target ?? _currentPosition;
  //   });
  //   await _updateLocationFromCoordinates(
  //     _currentPosition.latitude,
  //     _currentPosition.longitude,
  //   );
  // }

  void _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      final completeAddressParts = [
        _houseNoController.text,
        _streetController.text,
        _landmarkController.text,
        _areaController.text,
        _cityController.text,
        _stateController.text,
        _pincodeController.text,
      ].where((element) => element.isNotEmpty);

      final completeAddress = completeAddressParts.join(', ');

      final Map<String, String> savedLocation = {
        'houseNo': _houseNoController.text,
        'street': _streetController.text,
        'landmark': _landmarkController.text,
        'area': _areaController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'type': _selectedLocationType,
        'fullAddress': completeAddress,
      };

      setState(() {
        _location = savedLocation;
      });

      await _geocodeAddressAndUpdateMap(
        _location,
      ); // Use _location to update map

      await _saveLocationLocally(_location);

      setState(() {
        _showManualForm = false;
      });

      // Navigator.pop(context, _location); // Consider if you want to pop automatically
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                      // Display the combined address for the app bar
                      [
                                _location['houseNo'],
                                _location['street'],
                                _location['landmark'],
                                _location['area'],
                              ]
                              .where(
                                (element) =>
                                    element != null && element.isNotEmpty,
                              )
                              .join(', ')
                              .isNotEmpty
                          ? [
                                _location['houseNo'],
                                _location['street'],
                                _location['landmark'],
                                _location['area'],
                              ]
                              .where(
                                (element) =>
                                    element != null && element.isNotEmpty,
                              )
                              .join(', ')
                          : 'Unknown Area',
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
        children: [
          Column(
            children: [
              Container(
                height: 300,
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
                      _isLoading && _mapController == null
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
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Icon(
                            Icons.location_pin,
                            color: const Color(0xFF00796B),
                            size: 40,
                          ),
                        ),
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
              const Spacer(),
              if (!_showManualForm)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await _getCurrentLocation();
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
                          await _saveLocationLocally(_location);
                          // Pass the location when navigating back
                          Navigator.pop(context, _location);
                        } else if (!_isLoading) {
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
              SizedBox(height: _showManualForm ? 0 : 16),
            ],
          ),
          if (_showManualForm)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.height * 0.85,
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                                  : Colors.grey[700],
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
          const SizedBox(height: 10),
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
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
      ],
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
                  'assets/homescreen/medyscan.png',
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
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              if (index == 2) {
                print('NIROG tapped - Special Action');
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
              // Navigate to other screens and pass the location
              switch (index) {
                case 0:
                  // Replace with your actual HomeScreen constructor that accepts location
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                  break;
                case 1:
                  if (ModalRoute.of(context)?.settings.name != '/appointment') {
                    // Replace with your actual AppointmentScreen constructor that accepts location
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentScreen(),
                        settings: const RouteSettings(name: '/appointment'),
                      ),
                    );
                  }
                  break;
                case 3:
                  // Replace with your actual MedicalHistoryPage constructor that accepts location
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalHistoryPage(),
                    ),
                  );
                  break;
                case 4:
                  // Replace with your actual MedyscanPage constructor that accepts location
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
          top: -20,
          child: GestureDetector(
            onTap: () {
              print('NIROG Tapped from Stack');
            },
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image.asset(
                'assets/homescreen/nirog.png',
                width: 51,
                height: 54,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => const CircleAvatar(
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
