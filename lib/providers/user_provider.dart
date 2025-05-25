import 'package:flutter/foundation.dart';
import 'package:medycall/models/user_model.dart'; // Ensure UserModel has getDemographicData(), getLifestyleData(), getMedicalData() methods
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  Map<String, dynamic>? _demographicData;
  Map<String, dynamic>? _lifestyleData;
  Map<String, dynamic>? _medicalData;
  String? _authToken;

  // Getters
  UserModel? get user => _user;
  // The direct getters for _demographicData, _lifestyleData, _medicalData
  // are kept, as they are now synced with the _user object.
  Map<String, dynamic>? get demographicDataFromMap => _demographicData;
  Map<String, dynamic>? get lifestyleDataFromMap => _lifestyleData;
  Map<String, dynamic>? get medicalDataFromMap => _medicalData;
  String? get authToken => _authToken;

  // Check if user is authenticated
  bool get isAuthenticated => _authToken != null && _user != null;

  // User management
  void setUser(UserModel user) {
    _user = user;
    // Populate individual data maps from the primary UserModel
    // Assumes UserModel has methods to extract these sections as Maps.
    // If UserModel stores these as maps directly, access them.
    // Otherwise, UserModel needs methods like user.getDemographicDataMap().
    _demographicData =
        user.getDemographicData(); // Example: user.getDemographicData()
    _lifestyleData =
        user.getLifestyleData(); // Example: user.getLifestyleData()
    _medicalData = user.getMedicalData(); // Example: user.getMedicalData()
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _demographicData = null;
    _lifestyleData = null;
    _medicalData = null;
    // Keep auth token unless a full sign-out is intended (see clearAllData)
    notifyListeners();
  }

  // Token management
  void setAuthToken(String token) {
    _authToken = token;
    _saveTokenToPrefs(token);
    notifyListeners();
  }

  void clearAuthToken() {
    _authToken = null;
    _removeTokenFromPrefs();
    notifyListeners();
  }

  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _authToken = token;
      notifyListeners(); // Notify so UI can react if needed (e.g., attempt to load user)
    }
  }

  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _removeTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Data section management
  void setDemographicData(Map<String, dynamic> data) {
    _demographicData = data;
    // Update the main user model from the combined stored data
    _user = createUserModelFromStoredData();
    notifyListeners();
  }

  void setLifestyleData(Map<String, dynamic> data) {
    _lifestyleData = data;
    // Update the main user model from the combined stored data
    _user = createUserModelFromStoredData();
    notifyListeners();
  }

  void setMedicalData(Map<String, dynamic> data) {
    _medicalData = data;
    // Update the main user model from the combined stored data
    _user = createUserModelFromStoredData();
    notifyListeners();
  }

  // Data retrieval methods from the UserModel (preferred way if _user is populated)
  // These methods provide data directly from the _user object if it exists.
  Map<String, dynamic>? getDemographicData() {
    return _user?.getDemographicData();
  }

  Map<String, dynamic>? getLifestyleData() {
    return _user?.getLifestyleData();
  }

  Map<String, dynamic>? getMedicalData() {
    return _user?.getMedicalData();
  }

  // Profile completion methods
  Map<String, dynamic> getCompleteProfileDataFromMaps() {
    Map<String, dynamic> completeData = {};
    if (_demographicData != null) completeData.addAll(_demographicData!);
    if (_lifestyleData != null) completeData.addAll(_lifestyleData!);
    if (_medicalData != null) completeData.addAll(_medicalData!);
    return completeData;
  }

  UserModel createUserModelFromStoredData() {
    final completeData = getCompleteProfileDataFromMaps();

    // Ensure UserModel constructor and fromJson handle potentially missing fields gracefully.
    // The field mapping here should accurately reflect your UserModel structure.
    return UserModel(
      // Supabase UID might be set separately or be part of the UserModel constructor/fields
      // supabaseUid: _user?.supabaseUid, // Or fetched from auth service if not in these maps
      email:
          completeData['email'] ??
          _user?.email ??
          '', // Prioritize map data, fallback to existing user email
      phone:
          completeData['phone'] ??
          _user
              ?.phone, // Assuming 'phone' is the correct key from demographic data for UserModel.phone
      // Demographic fields from _demographicData
      title: completeData['title'] ?? _user?.title,
      name: completeData['name'] ?? _user?.name,
      birthDate:
          completeData['birthDate'] != null
              ? DateTime.tryParse(completeData['birthDate'])
              : _user?.birthDate,
      gender: completeData['gender'] ?? _user?.gender,
      bloodGroup: completeData['bloodGroup'] ?? _user?.bloodGroup,
      height: completeData['height'] ?? _user?.height,
      weight: completeData['weight'] ?? _user?.weight,
      maritalStatus: completeData['maritalStatus'] ?? _user?.maritalStatus,
      contactNumber: completeData['contactNumber'] ?? _user?.contactNumber,
      alternateNumber:
          completeData['alternateNumber'] ?? _user?.alternateNumber,

      // Lifestyle fields from _lifestyleData
      smokingHabit: completeData['smokingHabit'] ?? _user?.smokingHabit,
      alcoholConsumption:
          completeData['alcoholConsumption'] ?? _user?.alcoholConsumption,
      activityLevel: completeData['activityLevel'] ?? _user?.activityLevel,
      dietHabit: completeData['dietHabit'] ?? _user?.dietHabit,
      occupation: completeData['occupation'] ?? _user?.occupation,

      // Medical fields from _medicalData
      allergies: List<String>.from(
        completeData['allergies'] ?? _user?.allergies ?? [],
      ),
      medications: List<String>.from(
        completeData['medications'] ?? _user?.medications ?? [],
      ),
      chronicDiseases: List<String>.from(
        completeData['chronicDiseases'] ?? _user?.chronicDiseases ?? [],
      ),
      injuries: List<String>.from(
        completeData['injuries'] ?? _user?.injuries ?? [],
      ),
      surgeries: List<String>.from(
        completeData['surgeries'] ?? _user?.surgeries ?? [],
      ),
    );
  }

  // Clear methods
  void clearStoredDataMaps() {
    _demographicData = null;
    _lifestyleData = null;
    _medicalData = null;
    notifyListeners();
  }

  void clearAllData() {
    _user = null;
    _demographicData = null;
    _lifestyleData = null;
    _medicalData = null;
    _authToken = null;
    _removeTokenFromPrefs(); // ensure token is also cleared from persistence
    notifyListeners();
  }

  // Status check methods
  bool hasAnyStoredDataMaps() {
    return _demographicData != null ||
        _lifestyleData != null ||
        _medicalData != null;
  }

  bool isProfileCompleteViaMaps() {
    // Checks if all three underlying maps are populated.
    // The main _user object might be a more direct check if it's always kept whole.
    return _demographicData != null &&
        _lifestyleData != null &&
        _medicalData != null;
  }

  // Session validation
  Future<bool> validateSession() async {
    if (_authToken == null) {
      return false;
    }
    // Add additional validation logic here if needed (e.g., token expiry check)
    return true;
  }
}
