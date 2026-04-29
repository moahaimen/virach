import '../../doctors/models/user_model.dart';

class BeautyCentersModel {
  String? id;
  UserModel? user;
  String? createDate;
  String? updateDate;
  bool? isArchived;
  String? centerName;
  String? bio;
  String? address;
  String? availabilityTime;
  String? gpsLocation;
  bool? advertise;
  String? advertisePrice;
  String? advertiseDuration;
  String? createUser;
  String? updateUser;

  // Computed getter for profile image
  String? get profileImage => user?.profileImage;

  BeautyCentersModel({
    this.id,
    this.user,
    this.createDate,
    this.updateDate,
    this.isArchived,
    this.centerName,
    this.bio,
    this.address,
    this.availabilityTime,
    this.gpsLocation,
    this.advertise,
    this.advertisePrice,
    this.advertiseDuration,
    this.createUser,
    this.updateUser,
  });

  factory BeautyCentersModel.fromJson(Map<String, dynamic> json) {
    return BeautyCentersModel(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      createDate: json['create_date'],
      updateDate: json['update_date'],
      isArchived: json['is_archived'],
      centerName: json['center_name'],
      bio: json['bio'],
      address: json['address'],
      availabilityTime: json['availability_time'],
      gpsLocation: json['gps_location'],
      advertise: json['advertise'],
      advertisePrice: json['advertise_price'],
      advertiseDuration: json['advertise_duration'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'create_date': createDate,
      'update_date': updateDate,
      'is_archived': isArchived,
      'center_name': centerName,
      'bio': bio,
      'address': address,
      'availability_time': availabilityTime,
      'gps_location': gpsLocation,
      'advertise': advertise,
      'advertise_price': advertisePrice,
      'advertise_duration': advertiseDuration,
      'create_user': createUser,
      'update_user': updateUser,
    };
  }
}
