import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medycall/models/user_model.dart'; // Assuming this path is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static const String _baseUrl =
      'http://192.168.29.104:3000/api/users'; // Ensure this is your correct API base URL
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

  // Get common headers
  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // Helper method to clean phone numbers
  String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '').trim();
  }

  // Check if user profile exists in the backend
  Future<bool> userExistsInBackend() async {
    try {
      final user = await getUserProfile(); // This hits the backend
      return user != null;
    } catch (e) {
      print('Error checking if user exists in backend: $e');
      return false; // Assuming error means not found or inaccessible
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
        if (cleanAlternateNumber != null && cleanAlternateNumber.isNotEmpty)
          'alternateNumber': cleanAlternateNumber,
      };
      // Remove null values before saving
      demographicData.removeWhere((key, value) => value == null);

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
      // Remove null values before saving
      lifestyleData.removeWhere((key, value) => value == null);

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
        return jsonDecode(dataString) as Map<String, dynamic>;
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
        return jsonDecode(dataString) as Map<String, dynamic>;
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
        return jsonDecode(dataString) as Map<String, dynamic>;
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

      final demographicData = await getLocalDemographicData();
      final lifestyleData = await getLocalLifestyleData();
      final medicalData = await getLocalMedicalData();

      if (demographicData == null ||
          demographicData['email'] == null ||
          demographicData['name'] == null) {
        // Basic validation, ensure core demographic fields are present
        throw Exception(
          'Essential demographic data (email, name) is required to submit.',
        );
      }

      final requestBody = {
        'supabaseUid': currentUserUid,
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
        final userData = responseData['user'] ?? responseData;
        final userModel = UserModel.fromJson(userData);

        // IMPORTANT: After successful submission, sync server data back to local
        await _saveUserModelToLocal(userModel);

        return userModel;
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

  // Save or update demographic data (direct API call)
  // This method is for individual updates if necessary, typically after initial profile creation.
  Future<UserModel?> saveDemographicDataToServer({
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
        if (cleanAlternateNumber != null && cleanAlternateNumber.isNotEmpty)
          'alternateNumber': cleanAlternateNumber,
      };
      requestBody.removeWhere((key, value) => value == null);

      print('Saving demographic data to server: ${jsonEncode(requestBody)}');

      // User profile might exist or not. API handles upsert via POST or specific PUT.
      // The current route.ts POST does upsert. PUT is for general updates.
      // For simplicity using POST which handles create/update based on supabaseUid.
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        final userModel = UserModel.fromJson(userData);
        await _saveUserModelToLocal(userModel); // Sync back
        return userModel;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        throw Exception(
          'Failed to save demographic data to server (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('Error saving demographic data to server: $e');
      rethrow;
    }
  }

  // Get user profile from backend
  Future<UserModel?> getUserProfile() async {
    try {
      final currentUserUid = getCurrentUserUid();
      if (currentUserUid == null) {
        print('User not authenticated for getUserProfile');
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl?uid=$currentUserUid'),
        headers: _getHeaders(),
      );

      print('Get profile response status: ${response.statusCode}');
      // print('Get profile response body: ${response.body}'); // Potentially verbose

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // The API returns { success: true, user: {...} }
        if (responseData['success'] == true && responseData['user'] != null) {
          return UserModel.fromJson(responseData['user']);
        } else if (responseData['user'] != null) {
          // Fallback if 'success' isn't there but 'user' is
          return UserModel.fromJson(responseData['user']);
        }
        // If structure is just the user object directly
        // return UserModel.fromJson(responseData);
        print('User data not found in expected structure in response.');
        return null;
      } else if (response.statusCode == 404) {
        print('User profile not found on server (404)');
        return null;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        print(
          'Failed to get user profile (${response.statusCode}): $errorMessage',
        );
        return null; // Return null on error instead of throwing to allow graceful handling
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null; // Return null on exception
    }
  }

  // Update specific fields (generic PUT request)
  Future<UserModel?> updateUserFields(Map<String, dynamic> updates) async {
    try {
      final currentUserUid = getCurrentUserUid();
      if (currentUserUid == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      final requestBody = {'supabaseUid': currentUserUid, ...updates};
      // It's good practice to ensure email isn't accidentally changed this way
      // unless specifically intended by the `updates` map.
      // The PUT request in route.ts allows updating by supabaseUid or email.

      print('Updating user fields on server: ${jsonEncode(requestBody)}');

      final response = await http.put(
        Uri.parse(
          _baseUrl,
        ), // Assumes PUT to base URL with supabaseUid handles update
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        final userModel = UserModel.fromJson(userData);
        await _saveUserModelToLocal(userModel); // Sync back
        return userModel;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        throw Exception(
          'Failed to update user fields on server (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('Error updating user fields on server: $e');
      rethrow;
    }
  }

  // Clear all local SharedPreferences data related to user forms
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('demographic_data');
      await prefs.remove('lifestyle_data');
      await prefs.remove('medical_data');
      print('Local user form data cleared');
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  // Helper method to extract error messages from API response
  String _extractErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      return errorData['error'] ??
          errorData['details'] ??
          errorData['message'] ??
          responseBody;
    } catch (e) {
      // If parsing fails, return the raw response body
      return responseBody;
    }
  }

  // Sign out: clears Supabase session and local data
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await clearLocalData(); // Clear local form data on sign out
      print('User signed out and local data cleared.');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get specific data sections from locally stored UserModel (if available)
  // These methods now primarily rely on local SharedPreferences.
  Future<Map<String, dynamic>?> getDemographicDataFromLocal() async {
    return await getLocalDemographicData();
  }

  Future<Map<String, dynamic>?> getLifestyleDataFromLocal() async {
    return await getLocalLifestyleData();
  }

  Future<Map<String, dynamic>?> getMedicalDataFromLocal() async {
    return await getLocalMedicalData();
  }

  // Check status of locally filled forms
  Future<Map<String, bool>> checkLocalFormsStatus() async {
    return {
      'demographic': await getLocalDemographicData() != null,
      'lifestyle': await getLocalLifestyleData() != null,
      'medical': await getLocalMedicalData() != null,
    };
  }

  // Calculate form completion progress based on local data
  Future<double> getFormProgress() async {
    final status = await checkLocalFormsStatus();
    final completedForms = status.values.where((completed) => completed).length;
    return completedForms / 3.0; // Assuming 3 main forms/sections
  }

  // --- Methods to save data from a Provider/State to SharedPreferences ---
  // These are used by syncUserProfileToLocal or if a UserProvider updates local storage
  Future<void> saveDemographicMapToLocal(
    Map<String, dynamic> demographicData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Ensure essential fields like email/name are present if expected by forms
      await prefs.setString('demographic_data', jsonEncode(demographicData));
      print('Demographic map saved to SharedPreferences');
    } catch (e) {
      print('Error saving demographic map to SharedPreferences: $e');
      rethrow;
    }
  }

  Future<void> saveLifestyleMapToLocal(
    Map<String, dynamic> lifestyleData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lifestyle_data', jsonEncode(lifestyleData));
      print('Lifestyle map saved to SharedPreferences');
    } catch (e) {
      print('Error saving lifestyle map to SharedPreferences: $e');
      rethrow;
    }
  }

  Future<void> saveMedicalMapToLocal(Map<String, dynamic> medicalData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('medical_data', jsonEncode(medicalData));
      print('Medical map saved to SharedPreferences');
    } catch (e) {
      print('Error saving medical map to SharedPreferences: $e');
      rethrow;
    }
  }

  // --- NEW AND MODIFIED METHODS FOR SYNCING PROFILE ---

  // Helper to save a complete UserModel's data to local SharedPreferences
  Future<void> _saveUserModelToLocal(UserModel userModel) async {
    try {
      // Construct demographic map for local storage
      Map<String, dynamic> demoDataForLocal = {
        'email': userModel.email,
        'phone': userModel.phone,
        'title': userModel.title,
        'name': userModel.name,
        'birthDate': userModel.birthDate?.toIso8601String(),
        'gender': userModel.gender,
        'bloodGroup': userModel.bloodGroup,
        'height': userModel.height,
        'weight': userModel.weight,
        'maritalStatus': userModel.maritalStatus,
        'contactNumber': userModel.contactNumber,
        'alternateNumber': userModel.alternateNumber,
      };
      demoDataForLocal.removeWhere((key, value) => value == null);
      await saveDemographicMapToLocal(demoDataForLocal);

      // Construct lifestyle map
      Map<String, dynamic> lifestyleDataForLocal =
          userModel.getLifestyleData(); // Uses UserModel's helper
      lifestyleDataForLocal.removeWhere((key, value) => value == null);
      await saveLifestyleMapToLocal(lifestyleDataForLocal);

      // Construct medical map
      Map<String, dynamic> medicalDataForLocal =
          userModel.getMedicalData(); // Uses UserModel's helper
      await saveMedicalMapToLocal(medicalDataForLocal);

      print('UserModel data saved to local SharedPreferences.');
    } catch (e) {
      print('Error saving UserModel to local SharedPreferences: $e');
      // Decide if rethrow is needed or just log.
    }
  }

  // **KEY METHOD**: Fetches user profile from backend and populates local SharedPreferences.
  // Call this after login or on app start if user is authenticated.
  Future<UserModel?> syncUserProfileToLocal() async {
    print('Attempting to sync user profile to local storage...');
    try {
      final userModel = await getUserProfile(); // Fetches from backend API

      if (userModel != null) {
        print(
          'User profile fetched from server. UID: ${userModel.supabaseUid}',
        );
        await _saveUserModelToLocal(userModel);
        print('User profile successfully synced to local storage.');
        return userModel;
      } else {
        print('No user profile found on server to sync. Clearing local data.');
        // If no profile on server, good idea to clear local data to avoid stale info.
        // However, consider if user was halfway through filling forms offline - this would wipe it.
        // For the scenario "data not showing after re-login", clearing is often desired.
        await clearLocalData();
        return null;
      }
    } catch (e) {
      print('Error during syncUserProfileToLocal: $e');
      // Potentially notify user or retry. For now, just log.
      return null;
    }
  }

  // Comprehensive method to handle form completion flow (modified to use server sync)
  Future<UserModel?> handleFormCompletionFlow({
    Map<String, dynamic>? demographicData, // Data from form page
    Map<String, dynamic>? lifestyleData, // Data from form page
    Map<String, dynamic>? medicalData, // Data from form page
  }) async {
    try {
      // Save any provided data to local SharedPreferences first
      if (demographicData != null) {
        // Ensure this map is structured correctly, similar to saveDemographicDataLocally
        await saveDemographicMapToLocal(demographicData);
      }
      if (lifestyleData != null) {
        await saveLifestyleMapToLocal(lifestyleData);
      }
      if (medicalData != null) {
        await saveMedicalMapToLocal(medicalData);
      }

      final formsStatus = await checkLocalFormsStatus();
      final allFormsCompleted =
          formsStatus['demographic']! &&
          formsStatus['lifestyle']! &&
          formsStatus['medical']!;

      if (allFormsCompleted) {
        print('All forms completed locally, submitting to server...');
        // submitAllFormsData will combine local data, send to API, and then sync back.
        return await submitAllFormsData();
      } else {
        print(
          'Not all forms completed locally. Current status: $formsStatus. Data saved locally.',
        );
        // Return null, indicating data is saved locally but not submitted yet.
        // The UI should reflect that data is saved but pending full completion/submission.
        return null;
      }
    } catch (e) {
      print('Error in form completion flow: $e');
      rethrow;
    }
  }
}
