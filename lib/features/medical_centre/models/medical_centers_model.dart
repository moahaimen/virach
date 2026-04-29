// lib/features/medical_centre/models/medical_centers_model.dart

import '../../doctors/models/doctors_model.dart';
import '../../doctors/models/user_model.dart';

class MedicalCentersModel {
  final String?           id;
  final List<DoctorModel>? doctors;
  final UserModel?        user;
  final String?           createDate;
  final String?           updateDate;
  final bool?             isArchived;
  final String?           centerName;
  final String?           directorName;
  final String?           bio;
  final String?           address;
  final String?           availabilityTime;
  final bool?             advertise;
  final dynamic           advertisePrice;
  final dynamic           advertiseDuration;
  final dynamic           createUser;
  final dynamic           updateUser;

  MedicalCentersModel({
    this.id,
    this.doctors,
    this.user,
    this.createDate,
    this.updateDate,
    this.isArchived,
    this.centerName,
    this.directorName,
    this.bio,
    this.address,
    this.availabilityTime,
    this.advertise,
    this.advertisePrice,
    this.advertiseDuration,
    this.createUser,
    this.updateUser,
  });

  factory MedicalCentersModel.fromJson(Map<String, dynamic> json) {
    return MedicalCentersModel(
      id               : json['id']                as String?,
      doctors: (json['doctors'] as List?)
          ?.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      user             : json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createDate       : json['create_date']       as String?,
      updateDate       : json['update_date']       as String?,
      isArchived       : json['is_archived']       as bool?,
      centerName       : json['center_name']       as String?,
      directorName     : json['director_name']     as String?,
      bio              : json['bio']               as String?,
      address          : json['address']           as String?,
      availabilityTime : json['availability_time'] as String?,
      advertise        : json['advertise']         as bool?,
      advertisePrice   : json['advertise_price'],
      advertiseDuration: json['advertise_duration'],
      createUser       : json['create_user'],
      updateUser       : json['update_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id'                : id,
      'doctors'           : doctors?.map((d) => d.toJson()).toList(),
      'user'              : user?.toJson(),
      'create_date'       : createDate,
      'update_date'       : updateDate,
      'is_archived'       : isArchived,
      'center_name'       : centerName,
      'director_name'     : directorName,
      'bio'               : bio,
      'address'           : address,
      'availability_time' : availabilityTime,
      'advertise'         : advertise,
      'advertise_price'   : advertisePrice,
      'advertise_duration': advertiseDuration,
      'create_user'       : createUser,
      'update_user'       : updateUser,
    };
  }

  // Convenience getters
  String? get profileImage => user?.profileImage;
  String? get phoneNumber  => user?.phoneNumber;
  String? get gpsLocation  => user?.gpsLocation;
  String? get fullName     => user?.fullName;
}
