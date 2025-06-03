import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medycall/models/user_model.dart'; // Ensure this path is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa; // Aliased
import 'package:firebase_auth/firebase_auth.dart' as fa; // Aliased

class UserService {
  static const String _baseUrl =
      'https://4ae7-2405-201-402b-d070-c139-11e9-1952-7863.ngrok-free.app/api/users'; // Ensure this is your correct API base URL

  final supa.SupabaseClient _supabase = supa.Supabase.instance.client;
  final fa.FirebaseAuth _firebaseAuth = fa.FirebaseAuth.instance;

  // --- Enhanced Logging for Auth ID ---
  Future<void> setPrimaryAuthId(
    String uid,
    String authMethod,
    String? email,
    String? phone,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    print(
      '[UserService.setPrimaryAuthId] Attempting to set UID: "$uid", Method: "$authMethod", Email: "$email", Phone: "$phone"',
    );
    if (uid.isEmpty) {
      print(
        '[UserService.setPrimaryAuthId] ERROR: UID is empty. Aborting set.',
      );
      return;
    }
    if (authMethod.isEmpty) {
      print(
        '[UserService.setPrimaryAuthId] ERROR: authMethod is empty. Aborting set.',
      );
      return;
    }
    await prefs.setString('primary_auth_uid', uid);
    await prefs.setString('primary_auth_method', authMethod);

    final testUid = prefs.getString('primary_auth_uid');
    final testMethod = prefs.getString('primary_auth_method');
    print(
      '[UserService.setPrimaryAuthId] VERIFY READ AFTER SET - UID: "$testUid", Method: "$testMethod"',
    );

    if (email != null) {
      await prefs.setString('primary_auth_email', email);
    } else {
      await prefs.remove('primary_auth_email');
    }
    if (phone != null) {
      await prefs.setString('primary_auth_phone', phone);
    } else {
      await prefs.remove('primary_auth_phone');
    }
    print(
      '[UserService.setPrimaryAuthId] Successfully stored primary auth ID.',
    );
  }

  Future<Map<String, String?>?> getPrimaryAuthId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('primary_auth_uid');
    final method = prefs.getString('primary_auth_method');
    final email = prefs.getString('primary_auth_email');
    final phone = prefs.getString('primary_auth_phone');
    print(
      '[UserService.getPrimaryAuthId] Retrieved from SharedPreferences - UID: "$uid", Method: "$method", Email: "$email", Phone: "$phone"',
    );
    if (uid != null && uid.isNotEmpty && method != null && method.isNotEmpty) {
      print('[UserService.getPrimaryAuthId] Valid auth info found.');
      return {'uid': uid, 'method': method, 'email': email, 'phone': phone};
    }
    print(
      '[UserService.getPrimaryAuthId] No valid primary auth ID found (UID or method might be null/empty).',
    );
    return null;
  }

  // --- End of Enhanced Logging ---

  String? getCurrentSupabaseUserUid() {
    final user = _supabase.auth.currentUser;
    return user?.id;
  }

  String? getCurrentFirebaseUserUid() {
    final user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  String? getCurrentAuthUserEmail() {
    final supaUser = _supabase.auth.currentUser;
    if (supaUser?.email != null) return supaUser!.email;
    final fireUser = _firebaseAuth.currentUser;
    if (fireUser?.email != null) return fireUser!.email;
    return null;
  }

  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '').trim();
  }

  Future<UserModel?> saveInitialSupabaseUser({
    required String supabaseUid,
    required String name,
    required String email,
    String? profileImageUrl, // Added
  }) async {
    try {
      print(
        '[UserService.saveInitialSupabaseUser] Called with supabaseUid: "$supabaseUid", name: "$name", email: "$email", profileImageUrl: "$profileImageUrl"',
      );
      final requestBody = {
        'supabaseUid': supabaseUid,
        'name': name,
        'email': email,
        if (profileImageUrl != null)
          'profileImageUrl': profileImageUrl, // Added
      };
      print(
        '[UserService.saveInitialSupabaseUser] Saving initial Supabase user to server: ${jsonEncode(requestBody)}',
      );
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );
      print(
        '[UserService.saveInitialSupabaseUser] Response Status: ${response.statusCode}',
      );
      print(
        '[UserService.saveInitialSupabaseUser] Response Body: ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        if (userData == null) {
          print(
            '[UserService.saveInitialSupabaseUser] Error: User data not found in response.',
          );
          throw Exception(
            'User data not found in response after saving initial Supabase user.',
          );
        }
        final userModel = UserModel.fromJson(userData as Map<String, dynamic>);
        await _saveUserModelToLocal(userModel);
        print(
          '[UserService.saveInitialSupabaseUser] Successfully saved and processed initial Supabase user.',
        );
        return userModel;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        print(
          '[UserService.saveInitialSupabaseUser] Error: Failed to save - $errorMessage',
        );
        throw Exception(
          'Failed to save initial Supabase user (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('[UserService.saveInitialSupabaseUser] Exception: $e');
      rethrow;
    }
  }

  Future<UserModel?> saveInitialFirebaseUser({
    required String firebaseUid,
    required String name,
    required String phone,
    String? email,
    String? profileImageUrl, // Added
  }) async {
    try {
      await setPrimaryAuthId(firebaseUid, 'firebase', email, phone);
      print(
        '[UserService.saveInitialFirebaseUser] Called with firebaseUid: "$firebaseUid", name: "$name", phone: "$phone", email: "$email", profileImageUrl: "$profileImageUrl"',
      );
      final requestBody = {
        'firebaseUid': firebaseUid,
        'name': name,
        'phone': _cleanPhoneNumber(phone),
        if (email != null && email.isNotEmpty) 'email': email,
        if (profileImageUrl != null)
          'profileImageUrl': profileImageUrl, // Added
      };
      print(
        '[UserService.saveInitialFirebaseUser] Saving initial Firebase user to server: ${jsonEncode(requestBody)}',
      );
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );
      print(
        '[UserService.saveInitialFirebaseUser] Response Status: ${response.statusCode}',
      );
      print(
        '[UserService.saveInitialFirebaseUser] Response Body: ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        if (userData == null) {
          print(
            '[UserService.saveInitialFirebaseUser] Error: User data not found in response.',
          );
          throw Exception(
            'User data not found in response after saving initial Firebase user.',
          );
        }
        final userModel = UserModel.fromJson(userData as Map<String, dynamic>);
        await _saveUserModelToLocal(userModel);
        print(
          '[UserService.saveInitialFirebaseUser] Successfully saved and processed initial Firebase user.',
        );
        return userModel;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        print(
          '[UserService.saveInitialFirebaseUser] Error: Failed to save - $errorMessage',
        );
        throw Exception(
          'Failed to save initial Firebase user (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('[UserService.saveInitialFirebaseUser] Exception: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithFirebase({
    required String firebaseUid,
    required String phone,
  }) async {
    print(
      '[UserService.signInWithFirebase] Attempting sign-in with firebaseUid: "$firebaseUid", phone: "$phone"',
    );
    try {
      final String apiUrl = '$_baseUrl?firebaseUid=$firebaseUid';
      print('[UserService.signInWithFirebase] Fetching user from: $apiUrl');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getHeaders(),
      );
      print(
        '[UserService.signInWithFirebase] Response status: ${response.statusCode}',
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userData =
            responseData is Map && responseData.containsKey('user')
                ? responseData['user']
                : (responseData is Map ? responseData : null);
        if (userData != null) {
          final userModel = UserModel.fromJson(
            userData as Map<String, dynamic>,
          );
          await setPrimaryAuthId(
            firebaseUid,
            'firebase',
            userModel.email,
            phone,
          );
          await _saveUserModelToLocal(userModel);
          print(
            '[UserService.signInWithFirebase] Successfully signed in and processed user. UID: $firebaseUid',
          );
          return userModel;
        } else {
          print(
            '[UserService.signInWithFirebase] User data not found or in unexpected structure in response for UID: $firebaseUid',
          );
          return null;
        }
      } else if (response.statusCode == 404) {
        print(
          '[UserService.signInWithFirebase] User not found on server (404) for UID: $firebaseUid',
        );
        return null;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        print(
          '[UserService.signInWithFirebase] Error: Failed to fetch user (${response.statusCode}) for UID: $firebaseUid - $errorMessage',
        );
        return null;
      }
    } catch (e) {
      print(
        '[UserService.signInWithFirebase] Exception during sign-in for UID: $firebaseUid - $e',
      );
      return null;
    }
  }

  Future<UserModel?> submitAllFormsData() async {
    print(
      '[UserService.submitAllFormsData] Attempting to submit all forms data.',
    );
    try {
      final authInfo = await getPrimaryAuthId();
      if (authInfo == null ||
          authInfo['uid'] == null ||
          authInfo['uid']!.isEmpty) {
        print(
          '[UserService.submitAllFormsData] Error: User not authenticated or UID not found/empty in authInfo.',
        );
        throw Exception(
          'User not authenticated or UID not found. Please login again.',
        );
      }
      final primaryUid = authInfo['uid']!;
      final authMethod = authInfo['method']!;
      print(
        '[UserService.submitAllFormsData] Using UID: "$primaryUid", Method: "$authMethod" for submission.',
      );

      // Retrieve locally stored data, which might not include profileImageUrl
      // if it was updated separately or if _saveUserModelToLocal doesn't store it directly.
      // The UserProvider should hold the most up-to-date UserModel.
      // For submission, we reconstruct the user or get it from UserProvider.
      // Here, we rely on local form data + auth info. If profileImageUrl needs to be included,
      // it should be fetched from a more holistic local storage of UserModel or passed in.
      // For now, this function as-is might not send profileImageUrl unless it's part of demographicData locally.

      final demographicData = await getLocalDemographicData();
      final lifestyleData = await getLocalLifestyleData();
      final medicalData = await getLocalMedicalData();
      // Potentially load current UserModel from local full storage if available
      // UserModel? currentUser = await getLocalUserModel(); // Hypothetical
      // String? profileImageUrl = currentUser?.profileImageUrl;

      if (demographicData == null ||
          (demographicData['email'] == null && authMethod == 'supabase') ||
          demographicData['name'] == null) {
        print(
          '[UserService.submitAllFormsData] Error: Essential demographic data missing.',
        );
        throw Exception(
          'Essential demographic data (e.g. email for Supabase, name) is required.',
        );
      }

      final requestBody = {
        if (authMethod == 'supabase') 'supabaseUid': primaryUid,
        if (authMethod == 'firebase') 'firebaseUid': primaryUid,
        ...demographicData,
        if (lifestyleData != null) ...lifestyleData,
        if (medicalData != null) ...medicalData,
        // if (profileImageUrl != null) 'profileImageUrl': profileImageUrl, // Add if logic is in place to get it
      };

      if (demographicData['email'] == null && authInfo['email'] != null) {
        requestBody['email'] = authInfo['email'];
      }
      if (demographicData['phone'] == null && authInfo['phone'] != null) {
        requestBody['phone'] = _cleanPhoneNumber(authInfo['phone']!);
      }

      print(
        '[UserService.submitAllFormsData] Submitting complete user data: ${jsonEncode(requestBody)}',
      );
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );
      print(
        '[UserService.submitAllFormsData] Response Status: ${response.statusCode}',
      );
      print('[UserService.submitAllFormsData] Response Body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        if (userData == null) {
          print(
            '[UserService.submitAllFormsData] Error: User data not found in response post-submission.',
          );
          throw Exception(
            'User data not found in response after submitting all forms.',
          );
        }
        final userModel = UserModel.fromJson(userData as Map<String, dynamic>);
        await _saveUserModelToLocal(userModel);
        print(
          '[UserService.submitAllFormsData] Successfully submitted and processed all forms data.',
        );
        return userModel;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        print(
          '[UserService.submitAllFormsData] Error: Failed to submit - $errorMessage',
        );
        throw Exception(
          'Failed to submit user data (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('[UserService.submitAllFormsData] Exception: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile() async {
    print('[UserService.getUserProfile] Attempting to get user profile.');
    try {
      final authInfo = await getPrimaryAuthId();
      if (authInfo == null ||
          authInfo['uid'] == null ||
          authInfo['uid']!.isEmpty) {
        print(
          '[UserService.getUserProfile] Error: User not authenticated or UID not found/empty.',
        );
        return null;
      }
      final primaryUid = authInfo['uid']!;
      final authMethod = authInfo['method']!;
      print(
        '[UserService.getUserProfile] Using UID: "$primaryUid", Method: "$authMethod" for profile fetch.',
      );
      String apiUrl;
      if (authMethod == 'supabase') {
        apiUrl = '$_baseUrl?uid=$primaryUid';
      } else if (authMethod == 'firebase') {
        apiUrl = '$_baseUrl?firebaseUid=$primaryUid';
      } else {
        final email = authInfo['email'];
        if (email != null) {
          apiUrl = '$_baseUrl?email=$email';
          print(
            '[UserService.getUserProfile] Using email "$email" as fallback for profile fetch.',
          );
        } else {
          print(
            '[UserService.getUserProfile] Error: Cannot determine API URL - No suitable identifier.',
          );
          return null;
        }
      }
      print('[UserService.getUserProfile] Getting user profile from: $apiUrl');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getHeaders(),
      );
      print(
        '[UserService.getUserProfile] Response status: ${response.statusCode}',
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userData =
            responseData is Map && responseData.containsKey('user')
                ? responseData['user']
                : (responseData is Map ? responseData : null);
        if (userData != null) {
          final user = UserModel.fromJson(
            userData as Map<String, dynamic>,
          ); // This will parse profileImageUrl
          await _saveUserModelToLocal(user);
          print(
            '[UserService.getUserProfile] Successfully fetched and processed user profile.',
          );
          return user;
        }
        print(
          '[UserService.getUserProfile] User data not found or in unexpected structure in response.',
        );
        return null;
      } else if (response.statusCode == 404) {
        print(
          '[UserService.getUserProfile] User profile not found on server (404).',
        );
        return null;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        print(
          '[UserService.getUserProfile] Error: Failed to get user profile (${response.statusCode}): $errorMessage',
        );
        return null;
      }
    } catch (e) {
      print('[UserService.getUserProfile] Exception: $e');
      return null;
    }
  }

  Future<UserModel?> updateUserFields(Map<String, dynamic> updates) async {
    print('[UserService.updateUserFields] Attempting to update user fields.');
    try {
      final authInfo = await getPrimaryAuthId();
      if (authInfo == null ||
          authInfo['uid'] == null ||
          authInfo['uid']!.isEmpty) {
        print(
          '[UserService.updateUserFields] Error: User not authenticated or UID not found/empty.',
        );
        throw Exception('User not authenticated. Please login again.');
      }
      final primaryUid = authInfo['uid']!;
      final authMethod = authInfo['method']!;
      print(
        '[UserService.updateUserFields] Using UID: "$primaryUid", Method: "$authMethod" for update.',
      );
      final requestBody = {
        if (authMethod == 'supabase') 'supabaseUid': primaryUid,
        if (authMethod == 'firebase') 'firebaseUid': primaryUid,
        if (authMethod != 'supabase' &&
            authMethod != 'firebase' &&
            authInfo['email'] != null)
          'email': authInfo['email'],
        ...updates, // updates will contain profileImageUrl if being updated
      };
      print(
        '[UserService.updateUserFields] Updating user fields on server: ${jsonEncode(requestBody)}',
      );
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );
      print(
        '[UserService.updateUserFields] Response Status: ${response.statusCode}',
      );
      print('[UserService.updateUserFields] Response Body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData;
        if (userData == null) {
          print(
            '[UserService.updateUserFields] Error: User data not found in response post-update.',
          );
          throw Exception(
            'User data not found in response after updating fields.',
          );
        }
        final userModel = UserModel.fromJson(
          userData as Map<String, dynamic>,
        ); // Will parse profileImageUrl
        await _saveUserModelToLocal(userModel);
        print(
          '[UserService.updateUserFields] Successfully updated and processed user fields.',
        );
        return userModel;
      } else {
        final errorMessage = _extractErrorMessage(response.body);
        print(
          '[UserService.updateUserFields] Error: Failed to update - $errorMessage',
        );
        throw Exception(
          'Failed to update user fields on server (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('[UserService.updateUserFields] Exception: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    print('[UserService.signOut] Attempting to sign out user.');
    try {
      await _supabase.auth.signOut().catchError(
        (e) => print("[UserService.signOut] Supabase signout error: $e"),
      );
      await _firebaseAuth.signOut().catchError(
        (e) => print("[UserService.signOut] Firebase signout error: $e"),
      );
      final prefs = await SharedPreferences.getInstance();
      print(
        '[UserService.signOut] Clearing primary auth identifiers from SharedPreferences.',
      );
      await prefs.remove('primary_auth_uid');
      await prefs.remove('primary_auth_method');
      await prefs.remove('primary_auth_email');
      await prefs.remove('primary_auth_phone');
      await prefs.remove('auth_token');
      // await prefs.remove('user_model_data'); // If you save the whole model
      await clearLocalData();
      print(
        '[UserService.signOut] User signed out, local data and auth identifiers cleared.',
      );
    } catch (e) {
      print('[UserService.signOut] Exception: $e');
      rethrow;
    }
  }

  Future<UserModel?> syncUserProfileToLocal() async {
    print(
      '[UserService.syncUserProfileToLocal] Attempting to sync user profile to local storage...',
    );
    try {
      final authInfo = await getPrimaryAuthId();
      if (authInfo == null) {
        print(
          "[UserService.syncUserProfileToLocal] No primary auth info found, cannot sync profile.",
        );
        await clearLocalData();
        return null;
      }
      final userModel =
          await getUserProfile(); // Fetches the latest from server, including profileImageUrl
      if (userModel != null) {
        print(
          '[UserService.syncUserProfileToLocal] User profile fetched from server. UID: ${userModel.supabaseUid ?? userModel.firebaseUid}',
        );
        await _saveUserModelToLocal(userModel); // Saves parts of it locally
        // Consider saving the full userModel stringified to SharedPreferences for easier full retrieval
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('user_model_data', jsonEncode(userModel.toJson()));
        print(
          '[UserService.syncUserProfileToLocal] User profile successfully synced to local storage.',
        );
        return userModel;
      } else {
        print(
          '[UserService.syncUserProfileToLocal] No user profile found on server to sync.',
        );
        return null;
      }
    } catch (e) {
      print('[UserService.syncUserProfileToLocal] Error during sync: $e');
      return null;
    }
  }

  Future<void> _saveUserModelToLocal(UserModel userModel) async {
    try {
      print(
        '[UserService._saveUserModelToLocal] Saving UserModel to local SharedPreferences. Email: "${userModel.email}", Phone: "${userModel.phone}"',
      );
      // The current _saveUserModelToLocal saves demographic, lifestyle, and medical data.
      // profileImageUrl is not part of these. If you want to persist it using this fragmented approach,
      // you'd need to add it to one of the maps (e.g., demographic_data) or save it separately.
      // For now, this function doesn't explicitly save profileImageUrl to its own SharedPreferences key.
      // It relies on UserProvider holding the full model in memory after fetch/update.

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
        // If you want to store profileImageUrl with demographic data:
        // 'profileImageUrl': userModel.profileImageUrl,
      };
      demoDataForLocal.removeWhere((key, value) => value == null);
      await saveDemographicMapToLocal(demoDataForLocal);

      Map<String, dynamic> lifestyleDataForLocal = userModel.getLifestyleData();
      lifestyleDataForLocal.removeWhere((key, value) => value == null);
      await saveLifestyleMapToLocal(lifestyleDataForLocal);

      Map<String, dynamic> medicalDataForLocal = userModel.getMedicalData();
      await saveMedicalMapToLocal(medicalDataForLocal);

      // Consider saving profileImageUrl separately or as part of a full UserModel JSON string
      // final prefs = await SharedPreferences.getInstance();
      // if (userModel.profileImageUrl != null) {
      //   await prefs.setString('profile_image_url', userModel.profileImageUrl!);
      // } else {
      //   await prefs.remove('profile_image_url');
      // }

      print(
        '[UserService._saveUserModelToLocal] UserModel data (parts) saved to local SharedPreferences.',
      );
    } catch (e) {
      print(
        '[UserService._saveUserModelToLocal] Error saving UserModel to local SharedPreferences: $e',
      );
    }
  }

  // --- Local Data Helpers ---
  // ... (saveDemographicDataLocally, saveLifestyleDataLocally, saveMedicalDataLocally remain as they are)
  // ... (getLocalDemographicData, getLocalLifestyleData, getLocalMedicalData remain as they are)
  // ... (clearLocalData remains as it is)

  Future<void> saveDemographicDataLocally({
    String? email,
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
    // String? profileImageUrl, // If adding here
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanContactNumber = _cleanPhoneNumber(contactNumber);
      final cleanAlternateNumber =
          alternateNumber != null ? _cleanPhoneNumber(alternateNumber) : null;
      final Map<String, dynamic> demographicData = {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty)
          'phone': _cleanPhoneNumber(phone),
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
        // if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };
      demographicData.removeWhere((key, value) => value == null);
      await prefs.setString('demographic_data', jsonEncode(demographicData));
      print(
        '[UserService.saveDemographicDataLocally] Demographic data saved locally: $demographicData',
      );
    } catch (e) {
      print('[UserService.saveDemographicDataLocally] Error: $e');
      rethrow;
    }
  }

  Future<void> saveLifestyleDataLocally({
    String? smokingHabit,
    String? alcoholConsumption,
    String? activityLevel,
    String? dietHabit,
    String? occupation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> lifestyleData = {
        if (smokingHabit != null) 'smokingHabit': smokingHabit,
        if (alcoholConsumption != null)
          'alcoholConsumption': alcoholConsumption,
        if (activityLevel != null) 'activityLevel': activityLevel,
        if (dietHabit != null) 'dietHabit': dietHabit,
        if (occupation != null) 'occupation': occupation,
      };
      lifestyleData.removeWhere((key, value) => value == null);
      await prefs.setString('lifestyle_data', jsonEncode(lifestyleData));
      print(
        '[UserService.saveLifestyleDataLocally] Lifestyle data saved locally.',
      );
    } catch (e) {
      print('[UserService.saveLifestyleDataLocally] Error: $e');
      rethrow;
    }
  }

  Future<void> saveMedicalDataLocally({
    List<String>? allergies,
    List<String>? medications,
    List<String>? chronicDiseases,
    List<String>? injuries,
    List<String>? surgeries,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> medicalData = {
        'allergies': allergies ?? [],
        'medications': medications ?? [],
        'chronicDiseases': chronicDiseases ?? [],
        'injuries': injuries ?? [],
        'surgeries': surgeries ?? [],
      };
      await prefs.setString('medical_data', jsonEncode(medicalData));
      print('[UserService.saveMedicalDataLocally] Medical data saved locally.');
    } catch (e) {
      print('[UserService.saveMedicalDataLocally] Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getLocalDemographicData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('demographic_data');
      if (dataString != null)
        return jsonDecode(dataString) as Map<String, dynamic>;
      return null;
    } catch (e) {
      print('[UserService.getLocalDemographicData] Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLocalLifestyleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('lifestyle_data');
      if (dataString != null)
        return jsonDecode(dataString) as Map<String, dynamic>;
      return null;
    } catch (e) {
      print('[UserService.getLocalLifestyleData] Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLocalMedicalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('medical_data');
      if (dataString != null)
        return jsonDecode(dataString) as Map<String, dynamic>;
      return null;
    } catch (e) {
      print('[UserService.getLocalMedicalData] Error: $e');
      return null;
    }
  }

  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('demographic_data');
      await prefs.remove('lifestyle_data');
      await prefs.remove('medical_data');
      // await prefs.remove('profile_image_url'); // if stored separately
      // await prefs.remove('user_model_data'); // if storing full model string
      print('[UserService.clearLocalData] Local user form data cleared.');
    } catch (e) {
      print('[UserService.clearLocalData] Error: $e');
    }
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      return errorData['error'] as String? ??
          errorData['details'] as String? ??
          errorData['message'] as String? ??
          responseBody;
    } catch (e) {
      return responseBody;
    }
  }

  Future<Map<String, dynamic>?> getDemographicDataFromLocal() async {
    return await getLocalDemographicData();
  }

  Future<Map<String, dynamic>?> getLifestyleDataFromLocal() async {
    return await getLocalLifestyleData();
  }

  Future<Map<String, dynamic>?> getMedicalDataFromLocal() async {
    return await getLocalMedicalData();
  }

  Future<Map<String, bool>> checkLocalFormsStatus() async {
    return {
      'demographic': await getLocalDemographicData() != null,
      'lifestyle': await getLocalLifestyleData() != null,
      'medical': await getLocalMedicalData() != null,
    };
  }

  Future<double> getFormProgress() async {
    final status = await checkLocalFormsStatus();
    final completedForms = status.values.where((completed) => completed).length;
    return completedForms / 3.0;
  }

  Future<void> saveDemographicMapToLocal(
    Map<String, dynamic> demographicData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // If profileImageUrl is part of demographicData map, it will be saved here.
      await prefs.setString('demographic_data', jsonEncode(demographicData));
      print(
        '[UserService.saveDemographicMapToLocal] Demographic map saved to SharedPreferences.',
      );
    } catch (e) {
      print('[UserService.saveDemographicMapToLocal] Error: $e');
      rethrow;
    }
  }

  Future<void> saveLifestyleMapToLocal(
    Map<String, dynamic> lifestyleData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lifestyle_data', jsonEncode(lifestyleData));
      print(
        '[UserService.saveLifestyleMapToLocal] Lifestyle map saved to SharedPreferences.',
      );
    } catch (e) {
      print('[UserService.saveLifestyleMapToLocal] Error: $e');
      rethrow;
    }
  }

  Future<void> saveMedicalMapToLocal(Map<String, dynamic> medicalData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('medical_data', jsonEncode(medicalData));
      print(
        '[UserService.saveMedicalMapToLocal] Medical map saved to SharedPreferences.',
      );
    } catch (e) {
      print('[UserService.saveMedicalMapToLocal] Error: $e');
      rethrow;
    }
  }

  Future<UserModel?> handleFormCompletionFlow({
    Map<String, dynamic>? demographicData,
    Map<String, dynamic>? lifestyleData,
    Map<String, dynamic>? medicalData,
    // String? profileImageUrl, // Could be passed here too
  }) async {
    print(
      '[UserService.handleFormCompletionFlow] Starting form completion flow.',
    );
    try {
      if (demographicData != null) {
        // if (profileImageUrl != null && demographicData['profileImageUrl'] == null) {
        //   demographicData['profileImageUrl'] = profileImageUrl;
        // }
        await saveDemographicMapToLocal(demographicData);
      }
      if (lifestyleData != null) await saveLifestyleMapToLocal(lifestyleData);
      if (medicalData != null) await saveMedicalMapToLocal(medicalData);

      final formsStatus = await checkLocalFormsStatus();
      print(
        '[UserService.handleFormCompletionFlow] Forms status: $formsStatus',
      );
      final allFormsCompleted = formsStatus.values.every(
        (completed) => completed,
      );

      if (allFormsCompleted) {
        print(
          '[UserService.handleFormCompletionFlow] All forms completed locally, submitting to server...',
        );
        // submitAllFormsData will pick up from local storage.
        // If profileImageUrl was saved to demographic_data, it will be included.
        return await submitAllFormsData();
      } else {
        print(
          '[UserService.handleFormCompletionFlow] Not all forms completed locally. Data saved locally.',
        );
        return null;
      }
    } catch (e) {
      print('[UserService.handleFormCompletionFlow] Exception: $e');
      rethrow;
    }
  }
}
