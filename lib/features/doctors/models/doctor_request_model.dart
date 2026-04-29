// lib/features/doctors/models/doctor_request_model.dart

class DoctorRequestModel {
  final String   id;
  final String   doctorId;
  final String   centerId;
  final bool     doctorApproved;
  final bool     centerApproved;
  final bool     rejected;
  final DateTime createDate;

  // NEW FIELDS
  final String   doctorName;
  final String   specialty;
  final String?  profileImage;

  DoctorRequestModel({
    required this.id,
    required this.doctorId,
    required this.centerId,
    required this.doctorApproved,
    required this.centerApproved,
    required this.rejected,
    required this.createDate,
    required this.doctorName,
    required this.specialty,
    this.profileImage,
  });

  factory DoctorRequestModel.fromJson(Map<String, dynamic> json) {
    final doctorJson = json['doctor']      as Map<String, dynamic>;
    final userJson   = doctorJson['user']  as Map<String, dynamic>;
    final centerJson = json['center']      as Map<String, dynamic>;

    return DoctorRequestModel(
      id             : json['id']                    as String,
      doctorId       : doctorJson['id']              as String,
      centerId       : centerJson['id']              as String,
      doctorApproved : json['doctor_approved']       as bool,
      centerApproved : json['center_approved']       as bool,
      rejected       : json['rejected']              as bool,
      createDate     : DateTime.parse(json['create_date'] as String),
      doctorName     : userJson['full_name']         as String,
      specialty      : doctorJson['specialty']       as String,
      profileImage   : userJson['profile_image']     as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id'               : id,
      'doctor_approved'  : doctorApproved,
      'center_approved'  : centerApproved,
      'rejected'         : rejected,
      'create_date'      : createDate.toIso8601String(),
      'doctor'           : {
        'id'            : doctorId,
        'specialty'     : specialty,
        'user'          : {
          'full_name'   : doctorName,
          'profile_image': profileImage,
        },
      },
      'center'           : {
        'id'            : centerId,
      },
    };
  }
}
