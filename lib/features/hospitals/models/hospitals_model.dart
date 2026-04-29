import '../../doctors/models/user_model.dart';

class HospitalModel {
  String? id;
  UserModel? user;
  String? createDate;
  String? updateDate;
  bool? isArchived;
  String? hospitalName;
  String? specialty;
  String? administration;
  String? bio;
  String? address;
  String? availabilityTime;
  String? gpsLocation;
  bool? advertise;
  String? advertisePrice;
  String? advertiseDuration;
  Null? profileImage;
  String? phoneNumber;
  Null? createUser;
  Null? updateUser;

  HospitalModel(
      {this.id,
      this.user,
      this.createDate,
      this.updateDate,
      this.isArchived,
      this.hospitalName,
      this.specialty,
      this.administration,
      this.bio,
      this.address,
      this.availabilityTime,
      this.gpsLocation,
      this.advertise,
      this.advertisePrice,
      this.advertiseDuration,
      this.profileImage,
      this.phoneNumber,
      this.createUser,
      this.updateUser});

  HospitalModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new UserModel.fromJson(json['user']) : null;
    createDate = json['create_date'];
    updateDate = json['update_date'];
    isArchived = json['is_archived'];
    hospitalName = json['hospital_name'];
    specialty = json['specialty'];
    administration = json['administration'];
    bio = json['bio'];
    address = json['address'];
    availabilityTime = json['availability_time'];
    gpsLocation = json['gps_location'];
    advertise = json['advertise'];
    advertisePrice = json['advertise_price'];
    advertiseDuration = json['advertise_duration'];
    profileImage = json['profile_image'];
    phoneNumber = json['phone_number'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['create_date'] = this.createDate;
    data['update_date'] = this.updateDate;
    data['is_archived'] = this.isArchived;
    data['hospital_name'] = this.hospitalName;
    data['specialty'] = this.specialty;
    data['administration'] = this.administration;
    data['bio'] = this.bio;
    data['address'] = this.address;
    data['availability_time'] = this.availabilityTime;
    data['gps_location'] = this.gpsLocation;
    data['advertise'] = this.advertise;
    data['advertise_price'] = this.advertisePrice;
    data['advertise_duration'] = this.advertiseDuration;
    data['profile_image'] = this.profileImage;
    data['phone_number'] = this.phoneNumber;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    return data;
  }
}
