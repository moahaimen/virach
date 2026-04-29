class Review {
  final int reviewId;
  final int userId;
  final String serviceProviderType;
  final int serviceProviderId;
  final int rating;
  final String reviewText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.reviewId,
    required this.userId,
    required this.serviceProviderType,
    required this.serviceProviderId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    required this.updatedAt,
  });
}
