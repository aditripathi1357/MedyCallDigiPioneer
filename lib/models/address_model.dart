class AddressModel {
  final String? id; // Nullable for new addresses not yet saved
  final String type;
  final String? houseNumber;
  final String? street;
  final String? landmark;
  final String? area;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    this.id,
    required this.type,
    this.houseNumber,
    this.street,
    this.landmark,
    this.area,
    required this.city,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      type: json['type'] ?? 'Other',
      houseNumber: json['houseNumber'],
      street: json['street'],
      landmark: json['landmark'],
      area: json['area'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'houseNumber': houseNumber,
      'street': street,
      'landmark': landmark,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      // createdAt and updatedAt are usually handled by the server
    };
  }

  // Helper to create a display string
  String get displayAddressShort {
    List<String> parts = [];
    if (houseNumber != null && houseNumber!.isNotEmpty) parts.add(houseNumber!);
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (area != null && area!.isNotEmpty) parts.add(area!);
    return parts.join(', ');
  }

  String get displayAddressFull {
    List<String> parts = [];
    if (houseNumber != null && houseNumber!.isNotEmpty) parts.add(houseNumber!);
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (landmark != null && landmark!.isNotEmpty)
      parts.add('Near ${landmark!}');
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.where((p) => p.isNotEmpty).join(', ');
  }
}
