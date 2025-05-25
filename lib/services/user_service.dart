import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medycall/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static const String _baseUrl = 'http://192.168.29.104:3000/api/users';
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user's Supabase UID
  String? getCurrentUserUid() {
    final user = _supabase.auth.currentUser;
    return user?.id;
  }

  // Get current user's email
  String? getCurrentUserEmail() {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  // Get common headers (no authentication needed for API)
  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // Helper method to clean phone numbers
  String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '').trim();
  }

  // Check if user profile exists
  Future<bool> userExists() async {
    try {
      final user = await getUserProfile();
      return user != null;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Save demographic data to local storage
  Future<void> saveDemographicDataLocally({
    required String email,
    String? phone,
    String? title,
    required String name,
    required DateTime birthDate,
    required String gender,
    String? bloodGroup,
    int? height,
    int? weight,
    String? maritalStatus,
    required String contactNumber,
    String? alternateNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clean phone numbers
      final cleanContactNumber = _cleanPhoneNumber(contactNumber);
      final cleanAlternateNumber =
          alternateNumber != null ? _cleanPhoneNumber(alternateNumber) : null;

      final demographicData = {
        'email': email,
        if (phone != null) 'phone': phone,
        if (title != null) 'title': title,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (maritalStatus != null) 'maritalStatus': maritalStatus,
        'contactNumber': cleanContactNumber,
        if (cleanAlternateNumber != null)
          'alternateNumber': cleanAlternateNumber,
      };

      await prefs.setString('demographic_data', jsonEncode(demographicData));
      print('Demographic data saved locally');
    } catch (e) {
      print('Error saving demographic data locally: $e');
      rethrow;
    }
  }

  // Save lifestyle data to local storage
  Future<void> saveLifestyleDataLocally({
    String? smokingHabit,
    String? alcoholConsumption,
    String? activityLevel,
    String? dietHabit,
    String? occupation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lifestyleData = {
        if (smokingHabit != null) 'smokingHabit': smokingHabit,
        if (alcoholConsumption != null)
          'alcoholConsumption': alcoholConsumption,
        if (activityLevel != null) 'activityLevel': activityLevel,
        if (dietHabit != null) 'dietHabit': dietHabit,
        if (occupation != null) 'occupation': occupation,
      };

      await prefs.setString('lifestyle_data', jsonEncode(lifestyleData));
      print('Lifestyle data saved locally');
    } catch (e) {
      print('Error saving lifestyle data locally: $e');
      rethrow;
    }
  }

  // Save medical data to local storage
  Future<void> saveMedicalDataLocally({
    List<String>? allergies,
    List<String>? medications,
    List<String>? chronicDiseases,
    List<String>? injuries,
    List<String>? surgeries,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final medicalData = {
        'allergies': allergies ?? [],
        'medications': medications ?? [],
        'chronicDiseases': chronicDiseases ?? [],
        'injuries': injuries ?? [],
        'surgeries': surgeries ?? [],
      };

      await prefs.setString('medical_data', jsonEncode(medicalData));
      print('Medical data saved locally');
    } catch (e) {
      print('Error saving medical data locally: $e');
      rethrow;
    }
  }

  // Get locally stored data
  Future<Map<String, dynamic>?> getLocalDemographicData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('demographic_data');
      if (dataString != null) {
        return jsonDecode(dataString);
      }
      return null;
    } catch (e) {
      print('Error getting local demographic data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLocalLifestyleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('lifestyle_data');
      if (dataString != null) {
        return jsonDecode(dataString);
      }
      return null;
    } catch (e) {
      print('Error getting local lifestyle data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLocalMedicalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('medical_data');
      if (dataString != null) {
        return jsonDecode(dataString);
      }
      return null;
    } catch (e) {
      print('Error getting local medical data: $e');
      return null;
    }
  }

  // Submit all form data (combine all three forms and send to API)
  Future<UserModel?> submitAllFormsData() async {
    try {
      final currentUserUid = getCurrentUserUid();
      if (currentUserUid == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      // Get all locally stored data
      final demographicData = await getLocalDemographicData();
      final lifestyleData = await getLocalLifestyleData();
      final medicalData = await getLocalMedicalData();

      if (demographicData == null) {
        throw Exception('Demographic data is required');
      }

      // Combine all data into a single request body
      final requestBody = {
        'supabaseUid': currentUserUid,
        // Flatten all the data - no nested structure
        ...demographicData,
        if (lifestyleData != null) ...lifestyleData,
        if (medicalData != null) ...medicalData,
      };

      print('Submitting complete user data: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check if response has 'user' field or direct user data
        final userData = responseData['user'] ?? responseData;

        // Clear local storage after successful submission
        await clearLocalData();

        return UserModel.fromJson(userData);
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        throw Exception(
          'Failed to submit user data (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('Error submitting all forms data: $e');
      rethrow;
    }
  }

  // Save or update demographic data (direct API call - if needed for individual updates)
  Future<UserModel?> saveDemographicData({
    required String email,
    String? phone,
    String? title,
    required String name,
    required DateTime birthDate,
    required String gender,
    String? bloodGroup,
    int? height,
    int? weight,
    String? maritalStatus,
    required String contactNumber,
    String? alternateNumber,
  }) async {
    try {
      final currentUserUid = getCurrentUserUid();
      if (currentUserUid == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      // Clean phone numbers
      final cleanContactNumber = _cleanPhoneNumber(contactNumber);
      final cleanAlternateNumber =
          alternateNumber != null ? _cleanPhoneNumber(alternateNumber) : null;

      if (cleanContactNumber.isEmpty) {
        throw Exception('Contact number is required');
      }

      final requestBody = {
        'supabaseUid': currentUserUid,
        'email': email,
        if (phone != null) 'phone': phone,
        if (title != null) 'title': title,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (maritalStatus != null) 'maritalStatus': maritalStatus,
        'contactNumber': cleanContactNumber,
        if (cleanAlternateNumber != null)
          'alternateNumber': cleanAlternateNumber,
      };

      print('Saving demographic data: ${jsonEncode(requestBody)}');

      // Check if user exists to determine if we should POST or PUT
      final userExistsFlag = await userExists();
      final method = userExistsFlag ? 'PUT' : 'POST';

      http.Response response;
      if (method == 'PUT') {
        response = await http.put(
          Uri.parse(_baseUrl),
          headers: _getHeaders(),
          body: jsonEncode(requestBody),
        );
      } else {
        response = await http.post(
          Uri.parse(_baseUrl),
          headers: _getHeaders(),
          body: jsonEncode(requestBody),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        return UserModel.fromJson(userData);
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        throw Exception(
          'Failed to save demographic data (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('Error saving demographic data: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      final currentUserUid = getCurrentUserUid();
      if (currentUserUid == null) {
        print('User not authenticated');
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl?uid=$currentUserUid'),
        headers: _getHeaders(),
      );

      print('Get profile response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        return UserModel.fromJson(userData);
      } else if (response.statusCode == 404) {
        // User not found, return null
        print('User profile not found (404)');
        return null;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        throw Exception(
          'Failed to get user profile (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update specific fields (helper method)
  Future<UserModel?> updateUserField(Map<String, dynamic> updates) async {
    try {
      final currentUserUid = getCurrentUserUid();
      if (currentUserUid == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      // Add supabaseUid to updates
      updates['supabaseUid'] = currentUserUid;

      print('Updating user fields: ${jsonEncode(updates)}');

      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        return UserModel.fromJson(userData);
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        throw Exception(
          'Failed to update user fields (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('Error updating user fields: $e');
      rethrow;
    }
  }

  // Clear all local storage data
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('demographic_data');
      await prefs.remove('lifestyle_data');
      await prefs.remove('medical_data');
      print('Local data cleared');
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  // Helper method to extract error messages from response
  String _extractErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      return errorData['message'] ?? errorData['error'] ?? responseBody;
    } catch (e) {
      return responseBody;
    }
  }

  // Sign out and clear data
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await clearLocalData();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get specific data sections from stored user
  Future<Map<String, dynamic>?> getDemographicData() async {
    final user = await getUserProfile();
    return user?.getDemographicData();
  }

  Future<Map<String, dynamic>?> getLifestyleData() async {
    final user = await getUserProfile();
    return user?.getLifestyleData();
  }

  Future<Map<String, dynamic>?> getMedicalData() async {
    final user = await getUserProfile();
    return user?.getMedicalData();
  }

  // Check if all forms are filled locally
  Future<Map<String, bool>> checkLocalFormsStatus() async {
    return {
      'demographic': await getLocalDemographicData() != null,
      'lifestyle': await getLocalLifestyleData() != null,
      'medical': await getLocalMedicalData() != null,
    };
  }

  // Get progress percentage
  Future<double> getFormProgress() async {
    final status = await checkLocalFormsStatus();
    final completedForms = status.values.where((completed) => completed).length;
    return completedForms / 3.0; // 3 total forms
  }

  // Method to save demographic data from UserProvider to SharedPreferences
  Future<void> saveDemographicFromProvider(
    Map<String, dynamic> demographicData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('demographic_data', jsonEncode(demographicData));
      print('Demographic data saved from provider to SharedPreferences');
    } catch (e) {
      print('Error saving demographic data from provider: $e');
      rethrow;
    }
  }

  // Method to save lifestyle data from UserProvider to SharedPreferences
  Future<void> saveLifestyleFromProvider(
    Map<String, dynamic> lifestyleData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lifestyle_data', jsonEncode(lifestyleData));
      print('Lifestyle data saved from provider to SharedPreferences');
    } catch (e) {
      print('Error saving lifestyle data from provider: $e');
      rethrow;
    }
  }

  // Method to save medical data from UserProvider to SharedPreferences
  Future<void> saveMedicalFromProvider(Map<String, dynamic> medicalData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('medical_data', jsonEncode(medicalData));
      print('Medical data saved from provider to SharedPreferences');
    } catch (e) {
      print('Error saving medical data from provider: $e');
      rethrow;
    }
  }

  // Comprehensive method to handle form completion flow
  Future<UserModel?> handleFormCompletionFlow({
    Map<String, dynamic>? demographicData,
    Map<String, dynamic>? lifestyleData,
    Map<String, dynamic>? medicalData,
  }) async {
    try {
      // Save any provided data locally first
      if (demographicData != null) {
        await saveDemographicFromProvider(demographicData);
      }
      if (lifestyleData != null) {
        await saveLifestyleFromProvider(lifestyleData);
      }
      if (medicalData != null) {
        await saveMedicalFromProvider(medicalData);
      }

      // Check if all three forms are completed
      final formsStatus = await checkLocalFormsStatus();
      final allFormsCompleted =
          formsStatus['demographic']! &&
          formsStatus['lifestyle']! &&
          formsStatus['medical']!;

      if (allFormsCompleted) {
        // Submit all data to the API
        return await submitAllFormsData();
      } else {
        print('Not all forms completed yet. Current status: $formsStatus');
        return null;
      }
    } catch (e) {
      print('Error in form completion flow: $e');
      rethrow;
    }
  }
}
