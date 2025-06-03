import 'package:medycall/models/address_model.dart'; // Make sure this path is correct

class UserModel {
  // Basic user info
  final String? id;
  final String? email; // Made optional
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? supabaseUid;
  final String? firebaseUid; // New field
  final String? profileImageUrl; // New field for profile image

  // Demographic Data
  // ... (rest of the fields remain the same)
  final String? title;
  final String? name;
  final DateTime? birthDate;
  final String? gender;
  final String? bloodGroup;
  final int? height;
  final int? weight;
  final String? maritalStatus;
  final String? contactNumber;
  final String? alternateNumber;

  // Lifestyle Data
  final String? smokingHabit;
  final String? alcoholConsumption;
  final String? activityLevel;
  final String? dietHabit;
  final String? occupation;

  // Medical Data
  final List<String> allergies;
  final List<String> medications;
  final List<String> chronicDiseases;
  final List<String> injuries;
  final List<String> surgeries;

  // Addresses
  final List<AddressModel> addresses;

  UserModel({
    this.id,
    this.email, // No longer required
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.supabaseUid,
    this.firebaseUid, // Added to constructor
    this.profileImageUrl, // Added to constructor
    // Demographic fields
    this.title,
    this.name,
    this.birthDate,
    this.gender,
    this.bloodGroup,
    this.height,
    this.weight,
    this.maritalStatus,
    this.contactNumber,
    this.alternateNumber,

    // Lifestyle fields
    this.smokingHabit,
    this.alcoholConsumption,
    this.activityLevel,
    this.dietHabit,
    this.occupation,

    // Medical fields
    this.allergies = const [],
    this.medications = const [],
    this.chronicDiseases = const [],
    this.injuries = const [],
    this.surgeries = const [],
    this.addresses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      supabaseUid: json['supabaseUid'],
      firebaseUid: json['firebaseUid'],
      profileImageUrl: json['profileImageUrl'], // Added for profile image
      // Demographic data
      title: json['title'],
      name: json['name'],
      birthDate:
          json['birthDate'] != null
              ? DateTime.tryParse(json['birthDate'])
              : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      maritalStatus: json['maritalStatus'],
      contactNumber: json['contactNumber'],
      alternateNumber: json['alternateNumber'],

      // Lifestyle data
      smokingHabit: json['smokingHabit'],
      alcoholConsumption: json['alcoholConsumption'],
      activityLevel: json['activityLevel'],
      dietHabit: json['dietHabit'],
      occupation: json['occupation'],

      // Medical data
      allergies:
          json['allergies'] != null ? List<String>.from(json['allergies']) : [],
      medications:
          json['medications'] != null
              ? List<String>.from(json['medications'])
              : [],
      chronicDiseases:
          json['chronicDiseases'] != null
              ? List<String>.from(json['chronicDiseases'])
              : [],
      injuries:
          json['injuries'] != null ? List<String>.from(json['injuries']) : [],
      surgeries:
          json['surgeries'] != null ? List<String>.from(json['surgeries']) : [],
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map(
                (addressJson) =>
                    AddressModel.fromJson(addressJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'supabaseUid': supabaseUid,
      'firebaseUid': firebaseUid,
      'profileImageUrl': profileImageUrl, // Added for profile image
      // Demographic data
      'title': title,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'maritalStatus': maritalStatus,
      'contactNumber': contactNumber,
      'alternateNumber': alternateNumber,

      // Lifestyle data
      'smokingHabit': smokingHabit,
      'alcoholConsumption': alcoholConsumption,
      'activityLevel': activityLevel,
      'dietHabit': dietHabit,
      'occupation': occupation,

      // Medical data
      'allergies': allergies,
      'medications': medications,
      'chronicDiseases': chronicDiseases,
      'injuries': injuries,
      'surgeries': surgeries,
      'addresses': addresses.map((address) => address.toJson()).toList(),
    };
  }

  // Helper method to get only demographic data
  Map<String, dynamic> getDemographicData() {
    return {
      'email': email,
      'phone': phone,
      'title': title,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'maritalStatus': maritalStatus,
      'contactNumber': contactNumber,
      'alternateNumber': alternateNumber,
    };
  }

  // Helper method to get only lifestyle data
  Map<String, dynamic> getLifestyleData() {
    return {
      'smokingHabit': smokingHabit,
      'alcoholConsumption': alcoholConsumption,
      'activityLevel': activityLevel,
      'dietHabit': dietHabit,
      'occupation': occupation,
    };
  }

  // Helper method to get only medical data
  Map<String, dynamic> getMedicalData() {
    return {
      'allergies': allergies,
      'medications': medications,
      'chronicDiseases': chronicDiseases,
      'injuries': injuries,
      'surgeries': surgeries,
    };
  }

  AddressModel? get defaultOrFirstAddress {
    if (addresses.isEmpty) return null;
    try {
      return addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return addresses.first;
    }
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? supabaseUid,
    String? firebaseUid,
    String? profileImageUrl, // Added profileImageUrl
    String? title,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? bloodGroup,
    int? height,
    int? weight,
    String? maritalStatus,
    String? contactNumber,
    String? alternateNumber,
    String? smokingHabit,
    String? alcoholConsumption,
    String? activityLevel,
    String? dietHabit,
    String? occupation,
    List<String>? allergies,
    List<String>? medications,
    List<String>? chronicDiseases,
    List<String>? injuries,
    List<String>? surgeries,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supabaseUid: supabaseUid ?? this.supabaseUid,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      profileImageUrl:
          profileImageUrl ?? this.profileImageUrl, // Added profileImageUrl
      title: title ?? this.title,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      contactNumber: contactNumber ?? this.contactNumber,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      activityLevel: activityLevel ?? this.activityLevel,
      dietHabit: dietHabit ?? this.dietHabit,
      occupation: occupation ?? this.occupation,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      injuries: injuries ?? this.injuries,
      surgeries: surgeries ?? this.surgeries,
      addresses: addresses ?? this.addresses,
    );
  }
}
