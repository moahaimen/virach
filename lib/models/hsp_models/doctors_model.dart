class Doctor {
  final int doctorId;
  final int userId;
  final String name;
  final String specialty;
  final String degrees;
  final String bio;
  final String address;
  final String availabilityTime;
  final bool advertise;
  final double? advertisePrice;
  final String? advertiseDuration;
  final String? profileImage;
  final int phoneNumber;
  final bool isInternational;
  final String? country;
  final bool homeVisit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.doctorId,
    required this.userId,
    required this.name,
    required this.specialty,
    required this.degrees,
    required this.bio,
    required this.address,
    required this.availabilityTime,
    required this.advertise,
    this.advertisePrice,
    this.advertiseDuration,
    this.profileImage,
    required this.phoneNumber,
    required this.isInternational,
    this.country,
    required this.homeVisit,
    required this.createdAt,
    required this.updatedAt,
  });
}
