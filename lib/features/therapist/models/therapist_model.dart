import '../../doctors/models/user_model.dart';

class TherapistModel {
  String? id;
  UserModel? user;
  String? specialty;
  String? bio;
  String? address;
  String? availabilityTime;
  bool? advertise;
  String? advertisePrice;
  String? advertiseDuration;
  String? profileImage;
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool? isArchived;

  TherapistModel(
      {this.id,
      this.user,
      this.specialty,
      this.bio,
      this.address,
      this.availabilityTime,
      this.advertise,
      this.advertisePrice,
      this.advertiseDuration,
      this.profileImage,
      this.createDate,
      this.updateDate,
      this.createUser,
      this.updateUser,
      this.isArchived});

  TherapistModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      user = json['user'] != null && json['user'] is Map
          ? UserModel.fromJson(json['user'])
          : null;
      specialty = json['specialty'];
      bio = json['bio'];
      address = json['address'];
      availabilityTime = json['availability_time'];
      advertise = json['advertise'];
      advertisePrice = json['advertise_price'];
      advertiseDuration = json['advertise_duration'];
      profileImage = json['profile_image'];
      createDate = json['create_date'];
      updateDate = json['update_date'];
      createUser = json['create_user'];
      updateUser = json['update_user'];
      isArchived = json['is_archived'];
    } catch (e) {
      print("Error parsing TherapistModel: $e");
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user'] = this.user;
    data['specialty'] = this.specialty;
    data['bio'] = this.bio;
    data['address'] = this.address;
    data['availability_time'] = this.availabilityTime;
    data['advertise'] = this.advertise;
    data['advertise_price'] = this.advertisePrice;
    data['advertise_duration'] = this.advertiseDuration;
    data['profile_image'] = this.profileImage;
    data['create_date'] = this.createDate;
    data['update_date'] = this.updateDate;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['is_archived'] = this.isArchived;
    return data;
  }
}
