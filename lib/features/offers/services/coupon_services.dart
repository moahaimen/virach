// lib/features/offers/services/coupon_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../models/offer_model.dart';   // ← UI model
import '../models/coupon_model.dart';

class CouponService with ChangeNotifier {
  static const _key = 'coupons';
  final _uuid = const Uuid();

  List<Coupon> _coupons = [];
  List<Coupon> get coupons => _coupons;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      _coupons = (jsonDecode(raw) as List)
          .map((e) => Coupon.fromJson(e))
          .toList();
    }
  }

  /// ---- CREATE locally (no backend yet) ----
  /// lib/features/offers/services/coupon_service.dart
  /// -----------------------------------------------
  /// add userName parameter & store it in the coupon
  Future<Coupon> create({
    required Offer  offer,
    required String userName,      // 🔸 NEW
  }) async {
    final c = Coupon(
      id       : _uuid.v4(),
      code     : _uuid.v4().substring(0, 8).toUpperCase(),
      offerId  : offer.id ?? '',
      discount : offer.discount,
      userName : userName,         // 🔸 save the name
      created  : DateTime.now(),
    );

    _coupons.add(c);
    await _persist();
    notifyListeners();
    return c;
  }


  Future<void> markUsed(String id) async {
    final idx = _coupons.indexWhere((c) => c.id == id);
    if (idx != -1) _coupons[idx] = _coupons[idx].copyWith(used: true);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      _key,
      jsonEncode(_coupons.map((c) => c.toJson()).toList()),
    );
  }
}
