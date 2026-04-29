import 'package:racheeta/features/doctors/models/user_model.dart';

class JobSeekerModel {
  String? id;
  UserModel? user;
  String? specialty;
  String? degree;
  String? degreeImage;
  String? address;
  String? gpsLocation;
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool? isArchived;

  JobSeekerModel(
      {this.id,
      this.user,
      this.specialty,
      this.degree,
      this.degreeImage,
      this.address,
      this.gpsLocation,
      this.createDate,
      this.updateDate,
      this.createUser,
      this.updateUser,
      this.isArchived});

  JobSeekerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new UserModel.fromJson(json['user']) : null;
    specialty = json['specialty'];
    degree = json['degree'];
    degreeImage = json['degree_image'];
    address = json['address'];
    gpsLocation = json['gps_location'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    isArchived = json['is_archived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['specialty'] = this.specialty;
    data['degree'] = this.degree;
    data['degree_image'] = this.degreeImage;
    data['address'] = this.address;
    data['gps_location'] = this.gpsLocation;
    data['create_date'] = this.createDate;
    data['update_date'] = this.updateDate;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['is_archived'] = this.isArchived;
    return data;
  }
}
