class Hospital {
  final int hospitalId;
  final int userId;
  final String hospitalName;
  final String specialty;
  final String administration;
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

  Hospital({
    required this.hospitalId,
    required this.userId,
    required this.hospitalName,
    required this.specialty,
    required this.administration,
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
      'hospitalId': hospitalId,
      'userId': userId,
      'hospitalName': hospitalName,
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
