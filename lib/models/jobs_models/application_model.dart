// Application Model
class Application {
  final int applicationId;
  final int jobSeekerId;
  final int jobId;
  final String? resume;
  final String? coverLetter;
  final String applicationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Application({
    required this.applicationId,
    required this.jobSeekerId,
    required this.jobId,
    this.resume,
    this.coverLetter,
    required this.applicationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationId: json['applicationId'],
      jobSeekerId: json['jobSeekerId'],
      jobId: json['jobId'],
      resume: json['resume'],
      coverLetter: json['coverLetter'],
      applicationStatus: json['applicationStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'applicationId': applicationId,
        'jobSeekerId': jobSeekerId,
        'jobId': jobId,
        'resume': resume,
        'coverLetter': coverLetter,
        'applicationStatus': applicationStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
