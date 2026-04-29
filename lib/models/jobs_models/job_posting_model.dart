class JobPosting {
  final int jobId;
  final int serviceProviderId;
  final String serviceProviderType;
  final String jobTitle;
  final String jobDescription;
  final String qualifications;
  final double? salary;
  final String jobLocation;
  final String jobStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobPosting({
    required this.jobId,
    required this.serviceProviderId,
    required this.serviceProviderType,
    required this.jobTitle,
    required this.jobDescription,
    required this.qualifications,
    this.salary,
    required this.jobLocation,
    required this.jobStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      jobId: json['jobId'],
      serviceProviderId: json['serviceProviderId'],
      serviceProviderType: json['serviceProviderType'],
      jobTitle: json['jobTitle'],
      jobDescription: json['jobDescription'],
      qualifications: json['qualifications'],
      salary: json['salary'] != null ? double.parse(json['salary']) : null,
      jobLocation: json['jobLocation'],
      jobStatus: json['jobStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'serviceProviderId': serviceProviderId,
        'serviceProviderType': serviceProviderType,
        'jobTitle': jobTitle,
        'jobDescription': jobDescription,
        'qualifications': qualifications,
        'salary': salary,
        'jobLocation': jobLocation,
        'jobStatus': jobStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
