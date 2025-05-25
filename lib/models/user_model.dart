class UserModel {
  // Basic user info
  final String? id;
  final String email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? supabaseUid;

  // Demographic Data
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

  UserModel({
    this.id,
    required this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.supabaseUid,
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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      phone: json['phone'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      supabaseUid: json['supabaseUid'],
      // Demographic data
      title: json['title'],
      name: json['name'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      height: json['height'],
      weight: json['weight'],
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
    };
  }

  // Helper method to get only demographic data
  Map<String, dynamic> getDemographicData() {
    return {
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

  // Method to create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? supabaseUid,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supabaseUid: supabaseUid ?? this.supabaseUid,
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
    );
  }
}
