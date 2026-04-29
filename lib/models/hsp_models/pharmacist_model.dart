class Pharmacist {
  final int pharmacistId;
  final int userId;
  final String pharmacyName;
  final String address;
  final String bio;
  final String availabilityTime;
  final String gpsLocation;
  final bool onDutyPharmacy;
  final bool advertise;
  final double? advertisePrice;
  final String? advertiseDuration;
  final String? profileImage;
  final int phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pharmacist({
    required this.pharmacistId,
    required this.userId,
    required this.pharmacyName,
    required this.address,
    required this.bio,
    required this.availabilityTime,
    required this.gpsLocation,
    required this.onDutyPharmacy,
    required this.advertise,
    this.advertisePrice,
    this.advertiseDuration,
    this.profileImage,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });
  // Add this method to convert the object to a map
  Map<String, dynamic> toMap() {
    return {
      'pharmacistId': pharmacistId,
      'userId': userId,
      'pharmacyName': pharmacyName,
      'bio': bio,
      'address': address,
      'availabilityTime': availabilityTime,
      'gpsLocation': gpsLocation,
      'advertise': advertise,
      'advertisePrice': advertisePrice,
      'advertiseDuration': advertiseDuration,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
