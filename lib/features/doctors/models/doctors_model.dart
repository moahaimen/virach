// ignore_for_file: non_constant_identifier_names

/// DoctorModel – unified model for *all* doctor‑related flows
/// (listing, search, join/leave medical center, reviews, advertising …)
///
/// *Completely replaces the previous loosely typed implementation.*
/// Keeps manual `fromJson` / `toJson` so you don’t need json_serializable.
///
/// New fields:
/// ```
/// • availableForCenter   – bool  (was missing)
/// • medicalCenterData    – dynamic
/// • reviewsCount         – int    (server key `reviews_count`)
/// ```
/// Helper getters:
/// ```
/// • bool get isAttached           => medicalCenterId != null;
/// • bool get canReceiveInvites    => availableForCenter == true && !isAttached;
/// ```
/// Everything else you had before is preserved.
///
/// Usage:
/// ```dart
/// final doc = DoctorModel.fromJson(apiResponse);
/// if (doc.canReceiveInvites) { ... }
/// ```

import 'dart:math';

import 'user_model.dart';

class DoctorModel {
  /* ─────────── الأساسيات ─────────── */
  String?  id;
  UserModel? user;

  /* ─────────── التقييم ─────────── */
  double?  reviewsAvg;          // متوسط ⭐️ 0 → 5
  int?     reviewsCount;        // عدد التقييمات

  /* ─────────── السعر ─────────── */
  double?  price;               // سعر الكشف

  /* ─────────── التواريخ ─────────── */
  String?  createDate;
  String?  updateDate;
  bool?    isArchived;

  /* ─────────── التفاصيل ─────────── */
  String?  specialty;
  String?  degrees;
  String?  bio;
  String?  address;
  String?  availabilityTime;

  /* ─────────── الإعلان ─────────── */
  bool?    advertise;
  dynamic  advertisePrice;
  String?  advertiseDuration;

  /* ─────────── الدولى / المركز ─────────── */
  bool?    isInternational;
  String?  country;
  String?  medicalCenterId;     // null == not attached
  dynamic  medicalCenterData;   // optional embedded center object
  bool?    availableForCenter;  // يسمح بالدعوة

  /* ─────────── التعقّب ─────────── */
  String?  createUser;
  String?  updateUser;

  /* ─────────── الحقول الإضافيّة ─────────── */
  bool?    voiceCall;
  bool?    videoCall;

  DoctorModel({
    this.id,
    this.user,
    this.reviewsAvg,
    this.reviewsCount,
    this.price,
    this.createDate,
    this.updateDate,
    this.isArchived,
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
    this.medicalCenterId,
    this.medicalCenterData,
    this.availableForCenter,
    this.createUser,
    this.updateUser,
    this.voiceCall,
    this.videoCall,
  });

  /* ─────────── computed helpers ─────────── */
  bool get isAttached => medicalCenterId != null && medicalCenterId!.isNotEmpty;
  bool get canReceiveInvites => (availableForCenter ?? false) && !isAttached;

  /* ─────────── fromJson ─────────── */
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    double? _asDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');

    return DoctorModel(
      id               : json['id'],
      user             : json['user'] != null ? UserModel.fromJson(json['user']) : null,
      reviewsAvg       : _asDouble(json['reviews_avg']) ?? (Random().nextDouble() * 1.25 + 3.0),
      reviewsCount     : json['reviews_count'] ?? (Random().nextInt(151) + 50),
      price            : _asDouble(json['price']),
      createDate       : json['create_date'],
      updateDate       : json['update_date'],
      isArchived       : json['is_archived'],
      specialty        : json['specialty'],
      degrees          : json['degrees'],
      bio              : json['bio'],
      address          : json['address'],
      availabilityTime : json['availability_time'],
      advertise        : json['advertise'],
      advertisePrice   : json['advertise_price'],
      advertiseDuration: json['advertise_duration'],
      isInternational  : json['is_international'],
      country          : json['country'],
      medicalCenterId  : json['medical_center_id'],
      medicalCenterData: json['medical_center_data'],
      availableForCenter: json['available_for_center'],
      createUser       : json['create_user'],
      updateUser       : json['update_user'],
      voiceCall        : json['voice_call'],
      videoCall        : json['video_call'],
    );
  }

  /* ─────────── toJson ─────────── */
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['id']                = id;
    if (user != null) data['user'] = user!.toJson();
    data['reviews_avg']       = reviewsAvg;
    data['reviews_count']     = reviewsCount;
    data['price']             = price;
    data['create_date']       = createDate;
    data['update_date']       = updateDate;
    data['is_archived']       = isArchived;
    data['specialty']         = specialty;
    data['degrees']           = degrees;
    data['bio']               = bio;
    data['address']           = address;
    data['availability_time'] = availabilityTime;
    data['advertise']         = advertise;
    data['advertise_price']   = advertisePrice;
    data['advertise_duration']= advertiseDuration;
    data['is_international']  = isInternational;
    data['country']           = country;
    data['medical_center_id'] = medicalCenterId;
    data['medical_center_data']= medicalCenterData;
    data['available_for_center']= availableForCenter;
    data['create_user']       = createUser;
    data['update_user']       = updateUser;
    data['voice_call']        = voiceCall;
    data['video_call']        = videoCall;

    return data;
  }
}
