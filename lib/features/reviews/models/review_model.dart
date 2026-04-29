class ReviewModel {
  String? id;
  String? user;
  String? serviceProviderType;
  int? serviceProviderId;
  int? rating;
  String? reviewText;
  String? createDate;
  String? updateDate;
  String? createUser;
  Null? updateUser;
  bool? isArchived;

  ReviewModel(
      {this.id,
      this.user,
      this.serviceProviderType,
      this.serviceProviderId,
      this.rating,
      this.reviewText,
      this.createDate,
      this.updateDate,
      this.createUser,
      this.updateUser,
      this.isArchived});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    serviceProviderType = json['service_provider_type'];
    serviceProviderId = json['service_provider_id'];
    rating = json['rating'];
    reviewText = json['review_text'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    isArchived = json['is_archived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user'] = this.user;
    data['service_provider_type'] = this.serviceProviderType;
    data['service_provider_id'] = this.serviceProviderId;
    data['rating'] = this.rating;
    data['review_text'] = this.reviewText;
    data['create_date'] = this.createDate;
    data['update_date'] = this.updateDate;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['is_archived'] = this.isArchived;
    return data;
  }
}
