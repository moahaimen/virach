// JobSeeker Model
class JobSeeker {
  final int jobSeekerId;
  final String fullName;
  final int phoneNumber;
  final String? profileImage;
  final String specialty;
  final String degree;
  final String? degreeImage;
  final String? address;
  final String email;
  final String password;
  final String? gpsLocation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime birthDate; // Adding a birthDate to calculate age

  JobSeeker({
    required this.jobSeekerId,
    required this.fullName,
    required this.phoneNumber,
    this.profileImage,
    required this.specialty,
    required this.degree,
    this.degreeImage,
    this.address,
    required this.email,
    required this.password,
    this.gpsLocation,
    required this.createdAt,
    required this.updatedAt,
    required this.birthDate, // Add birth date
  });

  factory JobSeeker.fromJson(Map<String, dynamic> json) {
    return JobSeeker(
      jobSeekerId: json['jobSeekerId'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      specialty: json['specialty'],
      degree: json['degree'],
      degreeImage: json['degreeImage'],
      address: json['address'],
      email: json['email'],
      password: json['password'],
      gpsLocation: json['gpsLocation'],
      birthDate: DateTime(1980, 8, 1),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'jobSeekerId': jobSeekerId,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'profileImage': profileImage,
        'specialty': specialty,
        'degree': degree,
        'degreeImage': degreeImage,
        'address': address,
        'email': email,
        'password': password,
        'gpsLocation': gpsLocation,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
  // Calculate the age based on the birth date
  int get age {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
