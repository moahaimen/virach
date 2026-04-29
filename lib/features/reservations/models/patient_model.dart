class PatientModel {
  String? id;
  DateTime? lastLogin;
  bool? isSuperuser;
  DateTime? createDate;
  DateTime? updateDate;
  bool? isArchived;
  String? email;
  String? fullName;
  String? role;
  String? profileImage;
  String? gpsLocation;
  String? phoneNumber;
  bool? isActive;
  bool? isStaff;
  String? gender;
  String? createUser;
  String? updateUser;
  List<dynamic>? groups;
  List<dynamic>? userPermissions;
  String? fcm; // Added field for FCM token

  PatientModel({
    this.id,
    this.lastLogin,
    this.isSuperuser,
    this.createDate,
    this.updateDate,
    this.isArchived,
    this.email,
    this.fullName,
    this.role,
    this.profileImage,
    this.gpsLocation,
    this.phoneNumber,
    this.isActive,
    this.isStaff,
    this.gender,
    this.createUser,
    this.updateUser,
    this.groups,
    this.userPermissions,
    this.fcm,
  });

  PatientModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    lastLogin = json['last_login'] != null
        ? DateTime.tryParse(json['last_login'])
        : null;
    isSuperuser = json['is_superuser'] as bool?;
    createDate = json['create_date'] != null
        ? DateTime.tryParse(json['create_date'])
        : null;
    updateDate = json['update_date'] != null
        ? DateTime.tryParse(json['update_date'])
        : null;
    isArchived = json['is_archived'] as bool?;
    email = json['email'] as String?;
    fullName = json['full_name'] as String?;
    role = json['role'] as String?;
    profileImage = json['profile_image'] as String?;
    gpsLocation = json['gps_location'] as String?;
    phoneNumber = json['phone_number'] as String?;
    isActive = json['is_active'] as bool?;
    isStaff = json['is_staff'] as bool?;
    gender = json['gender'] as String?;
    createUser = json['create_user'] as String?;
    updateUser = json['update_user'] as String?;
    groups = json['groups'] != null ? List<dynamic>.from(json['groups']) : [];
    userPermissions = json['user_permissions'] != null
        ? List<dynamic>.from(json['user_permissions'])
        : [];
    fcm = json['fcm'] as String?; // Parse the FCM token from JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['last_login'] = lastLogin?.toIso8601String();
    data['is_superuser'] = isSuperuser;
    data['create_date'] = createDate?.toIso8601String();
    data['update_date'] = updateDate?.toIso8601String();
    data['is_archived'] = isArchived;
    data['email'] = email;
    data['full_name'] = fullName;
    data['role'] = role;
    data['profile_image'] = profileImage;
    data['gps_location'] = gpsLocation;
    data['phone_number'] = phoneNumber;
    data['is_active'] = isActive;
    data['is_staff'] = isStaff;
    data['gender'] = gender;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['groups'] = groups ?? [];
    data['user_permissions'] = userPermissions ?? [];
    data['fcm'] = fcm; // Include FCM token when converting to JSON
    return data;
  }
}
