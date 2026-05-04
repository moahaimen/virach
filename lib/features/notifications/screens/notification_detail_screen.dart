import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'package:racheeta/core/config/app_config.dart';

import '../../screens/hsp_profile_reservation_screen.dart';
import '../model/notification_model.dart';
import '../../offers/models/offers_model.dart';
import '../../offers/providers/offers_provider.dart';
import '../../offers/screens/offer_details_screen.dart';
import '../../../models/offer_model.dart' show Offer;

class NotificationDetailScreen extends StatefulWidget {
  final NoticationsModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final Dio _dio = Dio();

  Map<String, dynamic>? _senderUser;
  Map<String, dynamic>? _hspMap;
  OffersModel? _currentOfferDto;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      if (token.isNotEmpty) {
        _dio.options.headers['Authorization'] = '${AppConfig.authorizationPrefix} $token';
      }

      final n = widget.notification;

      if (n.type == NotificationType.offer) {
        final offersProv = context.read<OffersRetroDisplayGetProvider>();
        await offersProv.getOffers(forPatient: true);
        final all = offersProv.offers;

        final picked = _pickOfferForNotification(n, all);
        _currentOfferDto = picked;

        final senderId = picked?.serviceProviderId;
        if (senderId != null && senderId.isNotEmpty) {
          _senderUser = await _fetchUser(senderId);
          final type = _extractRoleType(_senderUser?['role']);
          final details = _extractRoleDetails(_senderUser?['role']);
          if (_isCenterRole(type)) {
            _hspMap = _buildHspFromUser(_senderUser!, type, details);
          }
        }
      } else if (n.type == NotificationType.request) {
        final senderId = (n.createUser?.trim().isNotEmpty == true
            ? n.createUser
            : (n.updateUser?.trim().isNotEmpty == true ? n.updateUser : n.user))
            ?.trim();

        if (senderId != null && senderId.isNotEmpty) {
          _senderUser = await _fetchUser(senderId);
          _hspMap = await _fetchCenterByUserId(senderId);
        }
      } else {
        final senderId = (n.createUser?.trim().isNotEmpty == true
            ? n.createUser
            : (n.updateUser?.trim().isNotEmpty == true ? n.updateUser : null))
            ?.trim();
        if (senderId != null) _senderUser = await _fetchUser(senderId);
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'فشل تحميل التفاصيل';
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchUser(String id) async {
    try {
      final r = await _dio.get('${AppConfig.baseUrl}users/$id/');
      if (r.statusCode == 200) return Map<String, dynamic>.from(r.data as Map);
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _fetchCenterByUserId(String userId) async {
    Future<Map<String, dynamic>?> tryPath(String path) async {
      try {
        final r = await _dio.get('${AppConfig.baseUrl}$path/', queryParameters: {'user': userId});
        if (r.statusCode == 200 && r.data is List && (r.data as List).isNotEmpty) {
          return Map<String, dynamic>.from((r.data as List).first as Map);
        }
      } catch (_) {}
      return null;
    }
    return await tryPath('medical-center') ?? await tryPath('medical_center');
  }

  OffersModel? _pickOfferForNotification(NoticationsModel n, List<OffersModel> all) {
    if (all.isEmpty) return null;
    OffersModel? best;
    double bestScore = -1e9;
    for (final o in all) {
      final title = (o.offerTitle ?? '').toLowerCase();
      final desc = (o.offerDescription ?? '').toLowerCase();
      final combined = '$title $desc';
      final textScore = _jaccard(n.notificationText, combined);
      final score = textScore; 
      if (score > bestScore) {
        bestScore = score;
        best = o;
      }
    }
    return best;
  }

  double _jaccard(String a, String b) {
    final sa = a.toLowerCase().split(' ').toSet();
    final sb = b.toLowerCase().split(' ').toSet();
    if (sa.isEmpty || sb.isEmpty) return 0.0;
    final inter = sa.intersection(sb).length.toDouble();
    final union = sa.union(sb).length.toDouble();
    return inter / union;
  }

  String _extractRoleType(dynamic role) {
    if (role is String) return role;
    if (role is Map) return (role['type'] ?? role['name'] ?? '').toString();
    return '';
  }

  Map<String, dynamic>? _extractRoleDetails(dynamic role) {
    if (role is Map && role['details'] is Map) return Map<String, dynamic>.from(role['details'] as Map);
    return null;
  }

  bool _isCenterRole(String type) => const {
    'medical_center', 'hospital', 'pharmacy', 'laboratory', 'beauty_center',
  }.contains(type);

  Map<String, dynamic> _buildHspFromUser(Map<String, dynamic> user, String type, Map<String, dynamic>? details) {
    return {
      'id': (details?['id'] ?? user['id']).toString(),
      'name': details?['center_name'] ?? details?['name'] ?? user['full_name'] ?? 'مركز طبي',
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

  Offer _toOffer(OffersModel m) => Offer(
    id: m.id,
    name: m.offerTitle ?? '—',
    image: (m.offerImage?.isNotEmpty ?? false) ? m.offerImage! : 'assets/banner1.jpg',
    discount: '${m.discountPercentage ?? '0'}%',
    price: m.discountedPrice ?? '0',
    oldPrice: m.originalPrice ?? '0',
    rating: 4.8,
    reviews: 5,
    location: 'العراق',
    doctorName: m.serviceProviderType ?? '—',
    description: m.offerDescription,
    offerType: m.offerType,
    periodOfTime: m.periodOfTime,
    startDateFormatted: m.startDate?.split('T').first,
    endDateFormatted: m.endDate?.split('T').first,
  );

  @override
  Widget build(BuildContext context) {
    final created = DateFormat('yyyy-MM-dd • hh:mm a').format(widget.notification.createDate);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(title: const Text('تفاصيل الإشعار')),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_senderUser != null) ...[
                      RacheetaCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: RacheetaColors.mintLight,
                              backgroundImage: _senderUser!['profile_image'] != null && _senderUser!['profile_image'].toString().startsWith('http')
                                  ? NetworkImage(_senderUser!['profile_image'] as String)
                                  : null,
                              child: _senderUser!['profile_image'] == null ? const Icon(Icons.person, color: RacheetaColors.primary) : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_senderUser!['full_name'] ?? 'مستخدم', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(_extractRoleType(_senderUser!['role']), style: const TextStyle(color: RacheetaColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            if (_hspMap != null)
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HSPProfileReservationPage(hsp: _hspMap!))),
                                child: const Text('زيارة'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    RacheetaCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('محتوى التنبيه', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: RacheetaColors.textSecondary)),
                          const SizedBox(height: 12),
                          Text(widget.notification.notificationText, style: const TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.bold, color: RacheetaColors.textPrimary)),
                          const Divider(height: 32),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: RacheetaColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(created, style: const TextStyle(fontSize: 12, color: RacheetaColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (widget.notification.type == NotificationType.offer && _currentOfferDto != null) ...[
                      const SizedBox(height: 24),
                      const RacheetaSectionHeader(title: 'العرض المرتبط'),
                      RacheetaCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: _toOffer(_currentOfferDto!)))),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _currentOfferDto!.offerImage ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: RacheetaColors.mintLight),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_currentOfferDto!.offerTitle ?? 'بدون عنوان', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text('${_currentOfferDto!.discountedPrice} د.ع', style: const TextStyle(color: RacheetaColors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_back_ios_new, size: 16, color: RacheetaColors.textSecondary),
                          ],
                        ),
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 24),
                      Center(child: Text(_error!, style: const TextStyle(color: RacheetaColors.danger))),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
