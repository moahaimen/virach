// lib/features/notifications/screens/notification_detail_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui' as ui show TextDirection;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/hsp_profile_reservation_screen.dart';
import '../model/notification_model.dart';

// Offers
import '../../offers/models/offers_model.dart';
import '../../offers/providers/offers_provider.dart';
import '../../offers/screens/offer_details_screen.dart';
import '../../../models/offer_model.dart' show Offer;

class NotificationDetailScreen extends StatefulWidget {
  final NoticationsModel notification;
  const NotificationDetailScreen({Key? key, required this.notification})
      : super(key: key);

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  static const _base = 'https://racheeta.pythonanywhere.com';
  final Dio _dio = Dio();

  Map<String, dynamic>? _senderUser;         // always the SENDER now
  Map<String, dynamic>? _hspMap;             // optional center card
  OffersModel? _currentOfferDto;             // ONLY the matched offer

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  // ---------------------------------------------------------------------------
  // LOAD
  // ---------------------------------------------------------------------------
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _senderUser = null;
      _hspMap = null;
      _currentOfferDto = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      if (token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'JWT $token';
      }

      final n = widget.notification;

      if (n.type == NotificationType.offer) {
        // 1) get offers (global) and pick ONE that matches this notification
        final offersProv = context.read<OffersRetroDisplayGetProvider>();
        await offersProv.getOffers(forPatient: true); // all offers
        final all = offersProv.offers;

        final picked = _pickOfferForNotification(n, all);
        _currentOfferDto = picked;

        // 2) sender is the offer's service_provider_id (NO recipient fallback)
        final senderId = picked?.serviceProviderId;
        if (senderId != null && senderId.isNotEmpty) {
          _senderUser = await _fetchUser(senderId);

          // if sender looks like a "center role", build center card
          final type = _extractRoleType(_senderUser?['role']);
          final details = _extractRoleDetails(_senderUser?['role']);
          if (_isCenterRole(type)) {
            _hspMap = _buildHspFromUser(_senderUser!, type, details);
          }
        }
      } else if (n.type == NotificationType.request) {
        // For requests we show the medical center name using the user id in the payload
        final senderId = (n.createUser?.trim().isNotEmpty == true
            ? n.createUser
            : (n.updateUser?.trim().isNotEmpty == true ? n.updateUser : n.user))
            ?.trim();

        if (senderId != null && senderId.isNotEmpty) {
          _senderUser = await _fetchUser(senderId);
          _hspMap = await _fetchCenterByUserId(senderId);
        }
      } else {
        // reservation/other – just show text + best-effort sender if we have creator
        final senderId = (n.createUser?.trim().isNotEmpty == true
            ? n.createUser
            : (n.updateUser?.trim().isNotEmpty == true ? n.updateUser : null))
            ?.trim();
        if (senderId != null) _senderUser = await _fetchUser(senderId);
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'فشل تحميل التفاصيل: $e';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // API helpers
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> _fetchUser(String id) async {
    try {
      final r = await _dio.get('$_base/user/$id/');
      if (r.statusCode == 200 && r.data is Map) {
        return Map<String, dynamic>.from(r.data as Map);
      }
    } on DioError {
      final r2 = await _dio.get('$_base/users/$id/');
      if (r2.statusCode == 200 && r2.data is Map) {
        return Map<String, dynamic>.from(r2.data as Map);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchCenterByUserId(String userId) async {
    Future<Map<String, dynamic>?> _try(String path) async {
      final r = await _dio.get('$_base/$path/', queryParameters: {'user': userId});
      if (r.statusCode == 200 && r.data is List && (r.data as List).isNotEmpty) {
        return Map<String, dynamic>.from((r.data as List).first as Map);
      }
      return null;
    }

    try {
      return await _try('medical-center') ?? await _try('medical_center');
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Matching logic: pick **one** offer
  // ---------------------------------------------------------------------------
  OffersModel? _pickOfferForNotification(
      NoticationsModel n, List<OffersModel> all) {
    if (all.isEmpty) return null;

    OffersModel? best;
    double bestScore = -1e9;

    for (final o in all) {
      final title = (o.offerTitle ?? '').toLowerCase();
      final desc = (o.offerDescription ?? '').toLowerCase();
      final combined = '$title $desc';

      final textScore = _jaccard(n.notificationText, combined); // 0..1
      final dateScore =
      _dateProximity(n.createDate, _parseDate(o.createDate) ?? _parseDate(o.startDate));
      final active = _isActive(o, at: n.createDate) ? 0.2 : 0.0;

      final score = 0.7 * textScore + 0.3 * dateScore + active;
      if (score > bestScore) {
        bestScore = score;
        best = o;
      }
    }

    return best;
  }

  DateTime? _parseDate(String? iso) => iso == null ? null : DateTime.tryParse(iso);

  bool _isActive(OffersModel o, {required DateTime at}) {
    final s = _parseDate(o.startDate);
    final e = _parseDate(o.endDate);
    if (s == null || e == null) return false;
    return !at.isBefore(s) && !at.isAfter(e);
  }

  double _dateProximity(DateTime a, DateTime? b) {
    if (b == null) return 0;
    final diffMin = (a.difference(b)).abs().inMinutes.toDouble();
    const max = 3 * 24 * 60.0; // 3 days
    final s = 1.0 - (diffMin / max);
    return s.clamp(0.0, 1.0);
  }

  Set<String> _tokens(String s) => s
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9\u0600-\u06FF]+'))
      .where((t) => t.length >= 2)
      .toSet();

  double _jaccard(String a, String b) {
    final sa = _tokens(a);
    final sb = _tokens(b);
    if (sa.isEmpty || sb.isEmpty) return 0.0;
    final inter = sa.intersection(sb).length.toDouble();
    final union = sa.union(sb).length.toDouble();
    return union == 0 ? 0.0 : inter / union;
  }

  // ---------------------------------------------------------------------------
  // Role helpers
  // ---------------------------------------------------------------------------
  String _extractRoleType(dynamic role) {
    if (role is String) return role;
    if (role is Map) return (role['type'] ?? role['name'] ?? '').toString();
    return '';
  }

  Map<String, dynamic>? _extractRoleDetails(dynamic role) {
    if (role is Map && role['details'] is Map) {
      return Map<String, dynamic>.from(role['details'] as Map);
    }
    return null;
  }

  bool _isCenterRole(String type) => const {
    'medical_center',
    'hospital',
    'pharmacy',
    'laboratory',
    'beauty_center',
  }.contains(type);

  Map<String, dynamic> _buildHspFromUser(
      Map<String, dynamic> user, String type, Map<String, dynamic>? details) {
    final name = details?['center_name'] ??
        details?['name'] ??
        user['full_name'] ??
        'مركز طبي';

    return {
      'id': (details?['id'] ?? user['id']).toString(),
      'name': name,
      'address': details?['address'] ?? user['address'] ?? '',
      'gps_location': details?['gps_location'] ?? user['gps_location'],
      'profile_image': user['profile_image'],
      'phone_number': details?['phone_number'] ?? user['phone_number'],
      'hspType': type,
      'rating': details?['rating'] ?? 4.4,
      'reviews': details?['reviews'] ?? 12,
      'bio': details?['description'] ?? 'لا توجد نبذة متاحة.',
      'user': user['id'],
    };
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------
  ImageProvider _avatarOf(Map<String, dynamic>? user) {
    final url = user?['profile_image']?.toString();
    if (url != null && url.startsWith('http')) {
      return NetworkImage(url);
    }
    return const AssetImage('assets/icons/doctor.png');
  }

  Widget _netImg(String? url, {double w = 72, double h = 72}) {
    final ph = Container(
      width: w,
      height: h,
      color: Colors.black12,
      child: const Icon(Icons.image_not_supported, color: Colors.black38),
    );
    if (url == null || !url.startsWith('http')) return ph;

    return Image.network(
      url,
      width: w,
      height: h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ph,
      loadingBuilder: (_, child, p) =>
      p == null ? child : SizedBox(width: w, height: h, child: const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))),
    );
  }

  Offer _toOffer(OffersModel m) => Offer(
    id: m.id,
    name: m.offerTitle ?? '—',
    image: (m.offerImage?.isNotEmpty ?? false)
        ? m.offerImage!
        : 'assets/banner1.jpg',
    discount: '${m.discountPercentage ?? '0'}%',
    price: m.discountedPrice ?? '0',
    oldPrice: m.originalPrice ?? '0',
    rating: 4.5,
    reviews: 0,
    location: '—',
    doctorName: m.serviceProviderType ?? '—',
    description: m.offerDescription,
    offerType: m.offerType,
    periodOfTime: m.periodOfTime,
    startDateFormatted: m.startDate?.split('T').first,
    endDateFormatted: m.endDate?.split('T').first,
  );

  void _openOfferDetails(OffersModel dto) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: _toOffer(dto))),
    );
  }

  void _openCenter() {
    if (_hspMap == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HSPProfileReservationPage(hsp: _hspMap!)),
    );
  }

  String _fmt(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('dd-MM-yyyy').format(d);
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.04),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final created = DateFormat('yyyy-MM-dd  •  hh:mm a').format(n.createDate);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الإشعار')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // SENDER HEADER (correct sender for offers)
          if (_senderUser != null) ...[
            Row(
              children: [
                CircleAvatar(radius: 26, backgroundImage: _avatarOf(_senderUser)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((_senderUser!['full_name'] ?? 'مستخدم') as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_extractRoleType(_senderUser!['role']),
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                if (_hspMap != null)
                  TextButton.icon(
                    onPressed: _openCenter,
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('زيارة المركز'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // NOTIFICATION TEXT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('نص الإشعار',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                Text(n.notificationText,
                    style: const TextStyle(fontSize: 15, height: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text('أُنشئ في:  $created',
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),

          // TYPE-SPECIFIC
          if (n.type == NotificationType.offer) ...[
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.local_offer),
                SizedBox(width: 6),
                Text('تفاصيل العرض', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),

            if (_currentOfferDto == null)
              const Text(
                'لم نتمكّن من تحديد عرض محدد من هذا الإشعار.',
                style: TextStyle(color: Colors.black54),
              )
            else
              _offerCard(_currentOfferDto!),
          ] else if (n.type == NotificationType.request) ...[
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.person_add_alt),
                SizedBox(width: 6),
                Text('تفاصيل الجهة الطالبة',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            if (_hspMap == null)
              const Text('لم يتم العثور على مركز طبي مرتبط بهذا المستخدم.',
                  style: TextStyle(color: Colors.black54))
            else
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openCenter,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _netImg((_hspMap!['profile_image'] ?? '') as String?, w: 40, h: 40),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((_hspMap!['name'] ?? 'مركز طبي') as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                (_hspMap!['address'] ?? '') as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left),
                      ],
                    ),
                  ),
                ),
              ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red),
                          textDirection: ui.TextDirection.ltr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }

  // single offer card
  Widget _offerCard(OffersModel o) {
    final img   = (o.offerImage ?? '').toString();
    final title = (o.offerTitle ?? '').toString();
    final desc  = (o.offerDescription ?? '').toString();
    final type  = (o.offerType ?? '').toString();
    final orig  = (o.originalPrice ?? '').toString();
    final discP = (o.discountPercentage ?? '').toString();
    final disc  = (o.discountedPrice ?? '').toString();
    final start = (o.startDate ?? '').toString();
    final end   = (o.endDate ?? '').toString();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openOfferDetails(o),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _netImg(img, w: 72, h: 72),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _chip('النوع: $type'),
                        _chip('السعر: $orig'),
                        _chip('خصم: $discP%'),
                        _chip('بعد الخصم: $disc'),
                        _chip('من ${_fmt(start)} إلى ${_fmt(end)}'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }
}
