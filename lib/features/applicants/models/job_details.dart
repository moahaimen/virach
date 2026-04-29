class JobDetails {
  String? id;
  String? serviceProvider;
  String? serviceProviderType;
  String? jobTitle;
  String? jobDescription;
  String? qualifications;
  dynamic salary; // can be null or a number
  String? jobLocation;
  String? jobStatus;
  bool? isArchived;

  JobDetails({
    this.id,
    this.serviceProvider,
    this.serviceProviderType,
    this.jobTitle,
    this.jobDescription,
    this.qualifications,
    this.salary,
    this.jobLocation,
    this.jobStatus,
    this.isArchived,
  });

  factory JobDetails.fromJson(Map<String, dynamic> json) {
    return JobDetails(
      id: json['id'],
      serviceProvider: json['service_provider'],
      serviceProviderType: json['service_provider_type'],
      jobTitle: json['job_title'],
      jobDescription: json['job_description'],
      qualifications: json['qualifications'],
      salary: json['salary'],
      jobLocation: json['job_location'],
      jobStatus: json['job_status'],
      isArchived: json['is_archived'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_provider': serviceProvider,
      'service_provider_type': serviceProviderType,
      'job_title': jobTitle,
      'job_description': jobDescription,
      'qualifications': qualifications,
      'salary': salary,
      'job_location': jobLocation,
      'job_status': jobStatus,
      'is_archived': isArchived,
    };
  }
}
