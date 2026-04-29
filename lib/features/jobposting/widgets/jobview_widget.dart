// job_view_mappers.dart
import '../../applicants/models/job_details.dart';
import '../models/jobposting_model.dart';

/// واجهة تصف الحقول التي نحتاجها لعرض بطاقة الوظيفة
abstract class IJobView {
  String? get title;
  String? get location;
  String? get description;
  String? get qualifications;
  String? get salary;
}

/// امتداد على JobPostingModel
extension JobPostingMapper on JobPostingModel /* implements IJobView ⬅️ احذفها */ {
  String? get title          => jobTitle;
  String? get location       => jobLocation;
  String? get description    => jobDescription;
  String? get qualifications => this.qualifications;
  String? get salary         => salary?.toString();
}

/// امتداد على JobDetails
extension JobDetailsMapper on JobDetails /* implements IJobView */ {
  String? get title          => jobTitle;
  String? get location       => jobLocation;
  String? get description    => jobDescription;
  String? get qualifications => this.qualifications;
  String? get salary         => salary?.toString();
}
