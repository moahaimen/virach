/// lib/features/offers/models/coupon_model.dart   (single source of truth)
class Coupon {
  final String id;           // UUID
  final String code;         // Human-readable / QR
  final String offerId;
  final String discount;     // e.g. "10%"
  final String userName;     // 🔸 new
  final DateTime created;
  final bool used;

  Coupon({
    required this.id,
    required this.code,
    required this.offerId,
    required this.discount,
    required this.userName,   // 🔸 new
    required this.created,
    this.used = false,
  });

  /* ------------------- helpers ------------------- */

  Coupon copyWith({
    String?  id,
    String?  code,
    String?  offerId,
    String?  discount,
    String?  userName,        // 🔸
    DateTime? created,
    bool?    used,
  }) =>
      Coupon(
        id       : id       ?? this.id,
        code     : code     ?? this.code,
        offerId  : offerId  ?? this.offerId,
        discount : discount ?? this.discount,
        userName : userName ?? this.userName,   // 🔸
        created  : created  ?? this.created,
        used     : used     ?? this.used,
      );

  @override
  String toString() =>
      'Coupon(code:$code, user:$userName, offer:$offerId, used:$used)';

  /* ----------------- serialization --------------- */

  Map<String, dynamic> toJson() => {
    'id'      : id,
    'code'    : code,
    'offerId' : offerId,
    'discount': discount,
    'userName': userName,                 // 🔸
    'created' : created.toIso8601String(),
    'used'    : used,
  };

  factory Coupon.fromJson(Map<String, dynamic> j) => Coupon(
    id       : j['id'],
    code     : j['code'],
    offerId  : j['offerId'],
    discount : j['discount'],
    userName : j['userName'],             // 🔸
    created  : DateTime.parse(j['created']),
    used     : j['used'] ?? false,
  );
}
