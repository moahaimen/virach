class JobPostingModel {
  String? id;
  String? serviceProvider;
  String? serviceProviderType;
  String? jobTitle;
  String? jobDescription;
  String? qualifications;
  String? salary;
  String? jobLocation;
  String? jobStatus;
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool? isArchived;

  int? applicantsCount; // ✅ NEW FIELD

  JobPostingModel({
    this.id,
    this.serviceProvider,
    this.serviceProviderType,
    this.jobTitle,
    this.jobDescription,
    this.qualifications,
    this.salary,
    this.jobLocation,
    this.jobStatus,
    this.createDate,
    this.updateDate,
    this.createUser,
    this.updateUser,
    this.isArchived,
    this.applicantsCount, // ✅ CONSTRUCTOR
  });

  JobPostingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceProvider = json['service_provider'];
    serviceProviderType = json['service_provider_type'];
    jobTitle = json['job_title'];
    jobDescription = json['job_description'];
    qualifications = json['qualifications'];
    salary = json['salary'];
    jobLocation = json['job_location'];
    jobStatus = json['job_status'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    isArchived = json['is_archived'];
    applicantsCount = json['applicants_count']; // ✅ JSON PARSE
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_provider'] = serviceProvider;
    data['service_provider_type'] = serviceProviderType;
    data['job_title'] = jobTitle;
    data['job_description'] = jobDescription;
    data['qualifications'] = qualifications;
    data['salary'] = salary;
    data['job_location'] = jobLocation;
    data['job_status'] = jobStatus;
    data['applicants_count'] = applicantsCount; // ✅ INCLUDE IN OUTPUT
    return data;
  }
}
