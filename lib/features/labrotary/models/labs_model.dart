import '../../doctors/models/user_model.dart';

class LabsModel {
  String? id;
  UserModel? user;
  String? createDate;
  String? updateDate;
  bool? isArchived;
  String? laboratoryName;
  String? availableTests;
  String? bio;
  String? address;
  String? availabilityTime;
  String? gpsLocation;
  bool? advertise;
  String? advertisePrice;
  String? advertiseDuration;
  String? profileImage;
  String? phoneNumber;
  String? createUser;
  String? updateUser;

  LabsModel(
      {this.id,
      this.user,
      this.createDate,
      this.updateDate,
      this.isArchived,
      this.laboratoryName,
      this.availableTests,
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

  LabsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new UserModel.fromJson(json['user']) : null;
    createDate = json['create_date'];
    updateDate = json['update_date'];
    isArchived = json['is_archived'];
    laboratoryName = json['laboratory_name'];
    availableTests = json['available_tests'];
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
    data['laboratory_name'] = this.laboratoryName;
    data['available_tests'] = this.availableTests;
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
