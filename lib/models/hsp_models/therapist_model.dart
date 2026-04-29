class Therapist {
  final int therapistId;
  final int userId;
  final String name;
  final String gpsLocation;

  final String degree;
  final String bio;
  final String? address;
  final String availabilityTime;
  final bool advertise;
  final double? advertisePrice;
  final String? advertiseDuration;
  final String? profileImage;
  final int phoneNumber;
  final bool homeVisit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Therapist({
    required this.therapistId,
    required this.userId,
    required this.name,
    required this.degree,
    required this.bio,
    required this.gpsLocation,
    required this.address,
    required this.availabilityTime,
    required this.advertise,
    this.advertisePrice,
    this.advertiseDuration,
    this.profileImage,
    required this.phoneNumber,
    required this.homeVisit,
    required this.createdAt,
    required this.updatedAt,
  });
  // Add this method to convert the object to a map
  Map<String, dynamic> toMap() {
    return {
      'therapistId': therapistId,
      'userId': userId,
      'name': name,
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
