import '../../doctors/models/user_model.dart';
import 'job_details.dart';

class ApplicantsModel {
  /// ──────────── primary fields ────────────
  String? id;
  String? job;              // UUID of the JobPosting
  String? resume;           // short text or URL
  String? coverLetter;      // short text
  String? applicationStatus; // submitted / accepted / rejected

  JobDetails? jobDetails;   // populated only when backend expands it

  /// ──────────── applicant info ────────────
  /// • If the backend returns a nested user object, it lands in `jobSeekerUser`.
  /// • If it returns only the UUID, it lands in `jobSeekerId`.
  UserModel? jobSeekerUser;
  String?    jobSeekerId;

  /// ──────────── metadata (read‑only) ───────
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool?   isArchived;

  ApplicantsModel({
    this.id,
    this.job,
    this.resume,
    this.coverLetter,
    this.applicationStatus,
    this.jobDetails,
    this.jobSeekerUser,
    this.jobSeekerId,
    this.createDate,
    this.updateDate,
    this.createUser,
    this.updateUser,
    this.isArchived,
  });

  /*──────────────────────────────────────────
   * factory  fromJson
   *────────────────────────────────────────*/
  factory ApplicantsModel.fromJson(Map<String, dynamic> json) {
    final seekerRaw = json['job_seeker'];

    // Decide whether we received a nested map or a plain string
    UserModel? user;
    String?    seekerId;

    if (seekerRaw is Map<String, dynamic>) {
      user      = UserModel.fromJson(seekerRaw);
      seekerId  = seekerRaw['id']?.toString();
    } else if (seekerRaw is String) {
      seekerId  = seekerRaw;
    }

    return ApplicantsModel(
      id:                json['id'],
      job:               json['job'],
      resume:            json['resume'],
      coverLetter:       json['cover_letter'],
      applicationStatus: json['application_status'],
      jobDetails:        json['job_details'] != null
          ? JobDetails.fromJson(json['job_details'])
          : null,
      jobSeekerUser:     user,
      jobSeekerId:       seekerId,
      createDate:        json['create_date'],
      updateDate:        json['update_date'],
      createUser:        json['create_user'],
      updateUser:        json['update_user'],
      isArchived:        json['is_archived'],
    );
  }

  /*──────────────────────────────────────────
   * toJson → used for POST / PATCH
   *────────────────────────────────────────*/
  Map<String, dynamic> toJson() => {
    'job':               job,
    'resume':            resume,
    'cover_letter':      coverLetter,
    'application_status':applicationStatus,
    // backend only needs the UUID of the job_seeker
    'job_seeker':        jobSeekerUser?.id ?? jobSeekerId,
  };
}
