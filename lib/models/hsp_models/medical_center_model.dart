class MedicalCenter {
  final int centerId;
  final int userId;
  final String centerName;
  final String directorName;
  final String bio;
  final String? address;
  final String availabilityTime;
  final String gpsLocation;
  final bool advertise;
  final double? advertisePrice;
  final String? advertiseDuration;
  final String? profileImage;
  final int phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalCenter({
    required this.centerId,
    required this.userId,
    required this.centerName,
    required this.directorName,
    required this.bio,
    this.address,
    required this.availabilityTime,
    required this.gpsLocation,
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
      'centerId': centerId,
      'userId': userId,
      'centerName': centerName,
      'directorName,': directorName,
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
