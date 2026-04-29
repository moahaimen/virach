class Offer {
  final String? id;            // ← NEW  (backend offer-id)
  final String  name;
  final String  image;
  final String  discount;
  final String  price;
  final String  oldPrice;
  final double  rating;
  final int     reviews;
  final String  location;
  final String  doctorName;

  // Details
  final String? description;
  final String? offerType;
  final String? periodOfTime;
  final String? startDateFormatted;
  final String? endDateFormatted;

  Offer({
    this.id,                                // ← add here
    required this.name,
    required this.image,
    required this.discount,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.doctorName,
    this.description,
    this.offerType,
    this.periodOfTime,
    this.startDateFormatted,
    this.endDateFormatted,
  });
}
