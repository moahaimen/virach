import 'package:flutter/material.dart';

/// يبنى صفاً من 5 نجوم اعتماداً على [rating].
///
/// - يقبل كسور نصفية (3.5 مثلاً → ⭐⭐⭐✰☆).
/// - [size] حجم الأيقونة (افتراضى 20).
List<Widget> buildStars(double? rating, {double size = 20}) {
  final r = (rating ?? 0).clamp(0, 5);           // تأمين القيم
  return List.generate(5, (i) {
    // نجمة ممتلئة
    if (i < r.floor()) {
      return Icon(Icons.star, color: Colors.orange, size: size);
    }
    // نصف نجمة (0.5 أو أكثر)
    if (i == r.floor() && (r - r.floor()) >= .5) {
      return Icon(Icons.star_half, color: Colors.orange, size: size);
    }
    // نجمة فارغة
    return Icon(Icons.star_border, color: Colors.orange, size: size);
  });
}
