import 'package:racheeta/features/reservations/models/patient_model.dart';

class ReservationModel {
  String? id;
  PatientModel? patient;
  String? serviceProviderType;
  String? serviceProviderId;
  String? appointmentDate;
  String? appointmentTime;
  String? status;
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool? isArchived;

  // Field for storing fetched service provider data
  Map<String, dynamic>? hspUser;

  ReservationModel({
    this.id,
    this.patient,
    this.serviceProviderType,
    this.serviceProviderId,
    this.appointmentDate,
    this.appointmentTime,
    this.status,
    this.createDate,
    this.updateDate,
    this.createUser,
    this.updateUser,
    this.isArchived,
    this.hspUser,
  });

  ReservationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    patient =
        json['patient'] != null ? PatientModel.fromJson(json['patient']) : null;
    serviceProviderType = json['service_provider_type'];
    serviceProviderId = json['service_provider_id'];
    appointmentDate = json['appointment_date'];
    appointmentTime = json['appointment_time'];
    status = json['status'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    isArchived = json['is_archived'];
    // This line is added so that when cached data is loaded, hspUser is restored.
    hspUser = json['hsp_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    if (this.patient != null) {
      data['patient'] = this.patient!.toJson();
    }
    data['service_provider_type'] = this.serviceProviderType;
    data['service_provider_id'] = this.serviceProviderId;
    data['appointment_date'] = this.appointmentDate;
    data['appointment_time'] = this.appointmentTime;
    data['status'] = this.status;
    data['create_date'] = this.createDate;
    data['update_date'] = this.updateDate;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['is_archived'] = this.isArchived;
    if (this.hspUser != null) {
      data['hsp_user'] = this.hspUser;
    }
    return data;
  }
}
