class DoctorAPI {
  String? id;
  String? user;
  String? specialty;
  String? degrees;
  String? bio;
  String? address;
  String? availabilityTime;
  bool? advertise;
  double? advertisePrice;
  int? advertiseDuration;
  bool? isInternational;
  String? country;
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool? isArchived;

  DoctorAPI({
    this.id,
    this.user,
    this.specialty,
    this.degrees,
    this.bio,
    this.address,
    this.availabilityTime,
    this.advertise,
    this.advertisePrice,
    this.advertiseDuration,
    this.isInternational,
    this.country,
    this.createDate,
    this.updateDate,
    this.createUser,
    this.updateUser,
    this.isArchived,
  });

  DoctorAPI.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    specialty = json['specialty'];
    degrees = json['degrees'];
    bio = json['bio'];
    address = json['address'];
    availabilityTime = json['availability_time'];
    advertise = json['advertise'];
    advertisePrice = json['advertise_price'];
    advertiseDuration = json['advertise_duration'];
    isInternational = json['is_international'];
    country = json['country'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    isArchived = json['is_archived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['specialty'] = specialty;
    data['degrees'] = degrees;
    data['bio'] = bio;
    data['availability_time'] = availabilityTime;
    data['advertise'] = advertise;
    data['is_international'] = isInternational;
    data['country'] = country;
    return data;
  }
}
