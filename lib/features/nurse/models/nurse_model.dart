import 'package:racheeta/features/doctors/models/user_model.dart';

class NurseModel {
  String? id;
  UserModel? user;
  String? createDate;
  String? updateDate;
  bool? isArchived;
  String? specialty;
  String? bio;
  String? address;
  String? availabilityTime;
  bool? advertise;
  String? advertisePrice;
  String? advertiseDuration;
  String? createUser;
  String? updateUser;

  NurseModel(
      {this.id,
      this.user,
      this.createDate,
      this.updateDate,
      this.isArchived,
      this.specialty,
      this.bio,
      this.address,
      this.availabilityTime,
      this.advertise,
      this.advertisePrice,
      this.advertiseDuration,
      this.createUser,
      this.updateUser});

  NurseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new UserModel.fromJson(json['user']) : null;
    createDate = json['create_date'];
    updateDate = json['update_date'];
    isArchived = json['is_archived'];
    specialty = json['specialty'];
    bio = json['bio'];
    address = json['address'];
    availabilityTime = json['availability_time'];
    advertise = json['advertise'];
    advertisePrice = json['advertise_price'];
    advertiseDuration = json['advertise_duration'];
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
    data['specialty'] = this.specialty;
    data['bio'] = this.bio;
    data['address'] = this.address;
    data['availability_time'] = this.availabilityTime;
    data['advertise'] = this.advertise;
    data['advertise_price'] = this.advertisePrice;
    data['advertise_duration'] = this.advertiseDuration;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    return data;
  }
}
