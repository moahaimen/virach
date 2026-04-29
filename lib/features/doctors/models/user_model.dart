import 'package:racheeta/features/doctors/models/doctors_model.dart';

class UserModel {
  String? id;
  String? lastLogin;
  bool? isSuperuser;
  String? createDate;
  String? updateDate;
  bool? isArchived;
  String? email;
  String? password;
  String? fullName;
  String? role;
  String? profileImage;
  String? gpsLocation;
  String? phoneNumber;
  bool? isActive;
  bool? isStaff;
  String? gender;
  String? firebaseUid;

  /// 🔔 NEW – device‑token for push notifications
  String? fcm;

  String? createUser;
  String? updateUser;
  List<dynamic>? groups;
  List<dynamic>? userPermissions;

  // If the user *is* a doctor, we embed the doctor profile
  DoctorModel? doctorProfile;

  UserModel({
    this.id,
    this.lastLogin,
    this.isSuperuser,
    this.createDate,
    this.updateDate,
    this.isArchived,
    this.email,
    this.password,
    this.fullName,
    this.role,
    this.profileImage,
    this.gpsLocation,
    this.phoneNumber,
    this.isActive,
    this.isStaff,
    this.gender,
    this.firebaseUid,
    this.fcm, // ⬅️  add to constructor
    this.createUser,
    this.updateUser,
    this.groups,
    this.userPermissions,
    this.doctorProfile,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastLogin = json['last_login'];
    isSuperuser = json['is_superuser'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    isArchived = json['is_archived'];
    email = json['email'];
    password = json['password'];
    fullName = json['full_name'];
    role = json['role'];
    profileImage = json['profile_image'];
    gpsLocation = json['gps_location'];
    phoneNumber = json['phone_number'];
    isActive = json['is_active'];
    isStaff = json['is_staff'];
    gender = json['gender'];
    firebaseUid = json['firebase_uid'];
    fcm = json['fcm']; // ⬅️  parse token
    createUser = json['create_user'];
    updateUser = json['update_user'];
    groups = json['groups'] ?? [];
    userPermissions = json['user_permissions'] ?? [];

    if (json['doctor_profile'] != null) {
      doctorProfile = DoctorModel.fromJson(json['doctor_profile']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['last_login'] = lastLogin;
    data['is_superuser'] = isSuperuser;
    data['create_date'] = createDate;
    data['update_date'] = updateDate;
    data['is_archived'] = isArchived;
    data['email'] = email;
    data['password'] = password;
    data['full_name'] = fullName;
    data['role'] = role;
    data['profile_image'] = profileImage;
    data['gps_location'] = gpsLocation;
    data['phone_number'] = phoneNumber;
    data['is_active'] = isActive;
    data['is_staff'] = isStaff;
    data['gender'] = gender;
    data['firebase_uid'] = firebaseUid;
    data['fcm'] = fcm; // ⬅️  include token
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['groups'] = groups;
    data['user_permissions'] = userPermissions;

    if (doctorProfile != null) {
      data['doctor_profile'] = doctorProfile!.toJson();
    }
    return data;
  }
}
