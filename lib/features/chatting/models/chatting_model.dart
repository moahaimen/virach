class ChattingModel {
  String? id;
  String? sender;
  String? receiver;
  String? messageText;
  String? messageImage;
  String? createDate;
  String? updateDate;
  String? createUser;
  String? updateUser;
  bool? isArchived;

  ChattingModel(
      {this.id,
      this.sender,
      this.receiver,
      this.messageText,
      this.messageImage,
      this.createDate,
      this.updateDate,
      this.createUser,
      this.updateUser,
      this.isArchived});

  ChattingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender = json['sender'];
    receiver = json['receiver'];
    messageText = json['message_text'];
    messageImage = json['message_image'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    isArchived = json['is_archived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sender'] = this.sender;
    data['receiver'] = this.receiver;
    data['message_text'] = this.messageText;
    data['message_image'] = this.messageImage;
    data['create_date'] = this.createDate;
    data['update_date'] = this.updateDate;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['is_archived'] = this.isArchived;
    return data;
  }
}
