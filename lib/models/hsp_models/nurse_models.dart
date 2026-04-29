class Nurse {
  final int nurseId;
  final int userId;
  final String name;
  final String specialty;
  final String bio;
  final String degree;
  final String gpsLocation;
  final String address;
  final String availabilityTime;
  final bool advertise;
  final double? advertisePrice;
  final String? advertiseDuration;
  final String? profileImage;
  final int phoneNumber;
  final bool homeVisit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Nurse({
    required this.nurseId,
    required this.userId,
    required this.name,
    required this.gpsLocation,
    required this.specialty,
    required this.bio,
    required this.degree,
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
      'beautyCenterId': nurseId,
      'userId': userId,
      'name': name,
      'specialty': specialty,
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
