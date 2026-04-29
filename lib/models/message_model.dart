class Message {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String messageText;
  final String? messageImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    this.messageImage,
    required this.createdAt,
    required this.updatedAt,
  });
}
