import '../../doctors/models/user_model.dart';

class PharmaModel {
  String? id;
  UserModel? user;
  String? createDate;
  String? updateDate;
  bool? isArchived;
  String? pharmacyName;
  String? address;
  String? bio;
  String? gpsLocation;
  bool? advertise;
  String? advertisePrice;
  String? advertiseDuration;
  String? profileImage;
  String? createUser;
  String? updateUser;

  /* 🔑 NEW */
  bool? sentinel;                 // true  → صيدلية حارس

  PharmaModel({
    this.id,
    this.user,
    this.createDate,
    this.updateDate,
    this.isArchived,
    this.pharmacyName,
    this.address,
    this.bio,
    this.gpsLocation,
    this.advertise,
    this.advertisePrice,
    this.advertiseDuration,
    this.profileImage,
    this.createUser,
    this.updateUser,
    this.sentinel,                // ← include in constructor
  });

  PharmaModel.fromJson(Map<String, dynamic> json) {
    id                = json['id'];
    user              = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    createDate        = json['create_date'];
    updateDate        = json['update_date'];
    isArchived        = json['is_archived'];
    pharmacyName      = json['pharmacy_name'];
    address           = json['address'];
    bio               = json['bio'];
    gpsLocation       = json['gps_location'];
    advertise         = json['advertise'];
    advertisePrice    = json['advertise_price'];
    advertiseDuration = json['advertise_duration'];
    profileImage      = json['profile_image'];
    createUser        = json['create_user'];
    updateUser        = json['update_user'];

    /* 🔑 NEW */
    sentinel          = json['sentinel'];           // adjust key if backend is different
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id']                 = id;
    if (user != null) data['user'] = user!.toJson();
    data['create_date']        = createDate;
    data['update_date']        = updateDate;
    data['is_archived']        = isArchived;
    data['pharmacy_name']      = pharmacyName;
    data['address']            = address;
    data['bio']                = bio;
    data['gps_location']       = gpsLocation;
    data['advertise']          = advertise;
    data['advertise_price']    = advertisePrice;
    data['advertise_duration'] = advertiseDuration;
    data['profile_image']      = profileImage;
    data['create_user']        = createUser;
    data['update_user']        = updateUser;

    /* 🔑 NEW */
    data['sentinel']           = sentinel;

    return data;
  }
}
