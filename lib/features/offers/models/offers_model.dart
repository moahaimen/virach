
class OffersModel {
  String? id;
  String? serviceProviderId;
  String? serviceProviderType;
  String? offerTitle;
  String? offerDescription;
  String? offerType;
  String? offerImage;
  String? discountPercentage;
  String? originalPrice;
  String? discountedPrice;
  String? periodOfTime;
  String? startDate;
  String? endDate;
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool? isArchived;

  OffersModel(
      {this.id,
        this.serviceProviderId,
        this.serviceProviderType,
        this.offerTitle,
        this.offerDescription,
        this.offerType,
        this.offerImage,
        this.discountPercentage,
        this.originalPrice,
        this.discountedPrice,
        this.periodOfTime,
        this.startDate,
        this.endDate,
        this.createDate,
        this.updateDate,
        this.createUser,
        this.updateUser,
        this.isArchived});

  OffersModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceProviderId = json['service_provider_id'];
    serviceProviderType = json['service_provider_type'];
    offerTitle = json['offer_title'];
    offerDescription = json['offer_description'];
    offerType = json['offer_type'];
    offerImage = json['offer_image'];
    discountPercentage = json['discount_percentage'];
    originalPrice = json['original_price'];
    discountedPrice = json['discounted_price'];
    periodOfTime = json['period_of_time'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    isArchived = json['is_archived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['service_provider_id'] = this.serviceProviderId;
    data['service_provider_type'] = this.serviceProviderType;
    data['offer_title'] = this.offerTitle;
    data['offer_description'] = this.offerDescription;
    data['offer_type'] = this.offerType;
    data['offer_image'] = this.offerImage;
    data['discount_percentage'] = this.discountPercentage;
    data['original_price'] = this.originalPrice;
    data['discounted_price'] = this.discountedPrice;
    data['period_of_time'] = this.periodOfTime;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['create_date'] = this.createDate;
    data['update_date'] = this.updateDate;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['is_archived'] = this.isArchived;
    return data;
  }
}
