import 'package:flutter/foundation.dart';
import 'package:medycall/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medycall/services/user_service.dart'; // Assuming UserService is in services folder

class UserProvider with ChangeNotifier {
  UserModel? _user;
  Map<String, dynamic>? _demographicData;
  Map<String, dynamic>? _lifestyleData;
  Map<String, dynamic>? _medicalData;
  String? _authToken;

  // Instance of UserService. Ideally, this would be injected.
  final UserService _userService = UserService();

  // Getters
  UserModel? get user => _user;
  Map<String, dynamic>? get demographicDataFromMap => _demographicData;
  Map<String, dynamic>? get lifestyleDataFromMap => _lifestyleData;
  Map<String, dynamic>? get medicalDataFromMap => _medicalData;
  String? get authToken => _authToken;

  bool get isAuthenticated => _authToken != null && _user != null;

  void setUser(UserModel user) {
    _user = user; // UserModel now includes profileImageUrl
    _demographicData = user.getDemographicData();
    _lifestyleData = user.getLifestyleData();
    _medicalData = user.getMedicalData();
    // If profileImageUrl was stored in SharedPreferences by _saveUserModelToLocal,
    // you might want to update a local _profileImageUrl variable here too,
    // but it's better to rely on _user.profileImageUrl.
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _demographicData = null;
    _lifestyleData = null;
    _medicalData = null;
    notifyListeners();
  }

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
      notifyListeners();
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

  void setDemographicData(Map<String, dynamic> data) {
    _demographicData = data;
    _user = createUserModelFromStoredData();
    notifyListeners();
  }

  void setLifestyleData(Map<String, dynamic> data) {
    _lifestyleData = data;
    _user = createUserModelFromStoredData();
    notifyListeners();
  }

  void setMedicalData(Map<String, dynamic> data) {
    _medicalData = data;
    _user = createUserModelFromStoredData();
    notifyListeners();
  }

  Map<String, dynamic>? getDemographicData() {
    return _user?.getDemographicData();
  }

  Map<String, dynamic>? getLifestyleData() {
    return _user?.getLifestyleData();
  }

  Map<String, dynamic>? getMedicalData() {
    return _user?.getMedicalData();
  }

  Map<String, dynamic> getCompleteProfileDataFromMaps() {
    Map<String, dynamic> completeData = {};
    if (_demographicData != null) completeData.addAll(_demographicData!);
    if (_lifestyleData != null) completeData.addAll(_lifestyleData!);
    if (_medicalData != null) completeData.addAll(_medicalData!);
    // profileImageUrl is not explicitly in these maps by default from UserService._saveUserModelToLocal
    // It would be part of _user object directly.
    return completeData;
  }

  UserModel createUserModelFromStoredData() {
    final completeData = getCompleteProfileDataFromMaps();
    // profileImageUrl will be sourced from existing _user object's profileImageUrl
    // or will be null if not set/fetched.
    // If profileImageUrl was stored in one of the local data maps (e.g., demographicData),
    // you would retrieve it from completeData['profileImageUrl'] here.
    return UserModel(
      // Basic info might come from _user or be reconstructed if needed
      id: _user?.id,
      supabaseUid: _user?.supabaseUid,
      firebaseUid: _user?.firebaseUid,
      createdAt: _user?.createdAt,
      updatedAt: _user?.updatedAt,
      profileImageUrl:
          completeData['profileImageUrl'] ??
          _user?.profileImageUrl, // Get from map or existing _user

      email: completeData['email'] ?? _user?.email,
      phone: completeData['phone'] ?? _user?.phone,

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

      smokingHabit: completeData['smokingHabit'] ?? _user?.smokingHabit,
      alcoholConsumption:
          completeData['alcoholConsumption'] ?? _user?.alcoholConsumption,
      activityLevel: completeData['activityLevel'] ?? _user?.activityLevel,
      dietHabit: completeData['dietHabit'] ?? _user?.dietHabit,
      occupation: completeData['occupation'] ?? _user?.occupation,

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
      addresses:
          _user?.addresses ??
          [], // Assuming addresses are part of the main _user object
    );
  }

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
    _removeTokenFromPrefs();
    notifyListeners();
  }

  bool hasAnyStoredDataMaps() {
    return _demographicData != null ||
        _lifestyleData != null ||
        _medicalData != null;
  }

  bool isProfileCompleteViaMaps() {
    return _demographicData != null &&
        _lifestyleData != null &&
        _medicalData != null;
  }

  Future<bool> validateSession() async {
    if (_authToken == null) {
      return false;
    }
    return true;
  }

  // Method to update user profile fields, including profileImageUrl
  Future<bool> updateUserProfileFields(
    Map<String, dynamic> dataToUpdate,
  ) async {
    if (_user == null) return false;
    try {
      UserModel? updatedUser = await _userService.updateUserFields(
        dataToUpdate,
      );
      if (updatedUser != null) {
        setUser(updatedUser); // This updates _user and notifies listeners
        return true;
      }
      return false;
    } catch (e) {
      print("[UserProvider.updateUserProfileFields] Error: $e");
      return false;
    }
  }

  // Method to fetch user profile from server and update provider
  Future<void> fetchUserProfile() async {
    try {
      UserModel? userModel = await _userService.getUserProfile();
      if (userModel != null) {
        setUser(userModel);
      } else {
        // Handle case where user profile couldn't be fetched, maybe clear user
        // clearUser();
      }
    } catch (e) {
      print("[UserProvider.fetchUserProfile] Error: $e");
    }
  }
}
