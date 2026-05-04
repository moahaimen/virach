import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../../applicants/models/applicants_model.dart';
import '../../applicants/providers/applicants_provider.dart';
import '../../jobseeker/providers/jobseeker_provider.dart';
import '../../jobseeker/screens/job_seeker_profile_form_page.dart';
import '../models/jobposting_model.dart';

class JobDetailsPage extends StatefulWidget {
  final JobPostingModel job;
  final Map<String, dynamic> userData;

  const JobDetailsPage({
    super.key,
    required this.job,
    required this.userData,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = false;
  Map<String, String> _userData = {};
  int _applyCount = 0;
  DateTime? _lastApplyTimestamp;
  DateTime? _blockTimestamp;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userData = {
          "jobseeker_id": prefs.getString("jobseeker_id") ?? "",
          "full_name": prefs.getString("full_name") ?? "مستخدم مجهول",
          "email": prefs.getString("email") ?? "غير معروف",
        };
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {}
  }

  LatLng? _parseGpsLocation(String? gpsLocation) {
    if (gpsLocation == null || gpsLocation.trim().isEmpty) return null;
    try {
      final s = gpsLocation.trim();
      final m = RegExp(r'^\s*([+-]?\d+(\.\d+)?)\s*[, ]\s*([+-]?\d+(\.\d+)?)\s*$').firstMatch(s);
      if (m != null) {
        final lat = double.tryParse(m.group(1)!);
        final lon = double.tryParse(m.group(3)!);
        if (lat != null && lon != null) return LatLng(lat, lon);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _applyForJob() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      _showError('⚠️ لا يوجد حساب مستخدم');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jobSeekerProvider = Provider.of<JobSeekerRetroDisplayGetProvider>(context, listen: false);
      final jobSeeker = await jobSeekerProvider.fetchCurrentJobSeekerByUserID();

      if (jobSeeker == null) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        final shouldCreate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("ملف الباحث عن عمل مفقود"),
            content: const Text("لا يمكنك التقديم على الوظيفة حالياً لأنك لم تنشئ ملفاً كباحث عن عمل. هل ترغب بإنشاء الملف الآن؟"),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("لا")),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("نعم")),
            ],
          ),
        );

        if (shouldCreate == true) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => JobSeekerProfileFormPage()));
        }
        return;
      }

      final now = DateTime.now();
      if (_lastApplyTimestamp != null && now.difference(_lastApplyTimestamp!).inSeconds < 30) {
        _showError('⏳ انتظر 30 ثانية بين كل تقديم');
        setState(() => _isLoading = false);
        return;
      }

      if (_applyCount >= 3 && _blockTimestamp != null && now.difference(_blockTimestamp!).inMinutes < 5) {
        _showError('⛔ أعد المحاولة بعد 5 دقائق');
        setState(() => _isLoading = false);
        return;
      }

      final applicant = ApplicantsModel(
        jobSeekerId: userId,
        job: widget.job.id,
        resume: jobSeeker.degree ?? '',
        coverLetter: jobSeeker.specialty ?? '',
        applicationStatus: 'submitted',
      );

      final provider = Provider.of<ApplicantsProvider>(context, listen: false);
      final result = await provider.createApplicant(applicant);

      if (result != null) {
        _showInfo('✅ تم التقديم على الوظيفة بنجاح');
        _applyCount++;
        _lastApplyTimestamp = now;
        if (_applyCount == 1) _blockTimestamp = now;
      } else {
        throw Exception("فشل في إرسال الطلب");
      }
    } catch (e) {
      _showError('❌ حدث خطأ أثناء التقديم');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: RacheetaColors.danger));
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: RacheetaColors.primary));
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final jobGps = _parseGpsLocation(job.jobLocation) ?? const LatLng(33.3152, 44.3661);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: RacheetaColors.primary,
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('assets/job_header.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: RacheetaColors.mintLight)),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black26, Colors.transparent, Colors.black54],
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(job.jobTitle ?? 'تفاصيل الوظيفة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RacheetaCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.jobTitle ?? 'عنوان غير متوفر', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              Text(job.serviceProviderType ?? 'مزود خدمة صحية', style: const TextStyle(color: RacheetaColors.primary, fontWeight: FontWeight.bold)),
                              const Divider(height: 32),
                              _detailRow(Icons.location_on_outlined, 'الموقع', job.jobLocation ?? 'غير محدد'),
                              if (job.salary != null) ...[
                                const SizedBox(height: 12),
                                _detailRow(Icons.monetization_on_outlined, 'الراتب', '${job.salary} د.ع'),
                              ],
                              if (job.qualifications != null) ...[
                                const SizedBox(height: 12),
                                _detailRow(Icons.school_outlined, 'المؤهلات', job.qualifications!),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        RacheetaCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الوصف الوظيفي', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 12),
                              Text(job.jobDescription ?? 'لا يوجد وصف متاح.', style: const TextStyle(fontSize: 15, height: 1.6)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const RacheetaSectionHeader(title: 'موقع العمل'),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                FlutterMap(
                                  options: MapOptions(initialCenter: jobGps, initialZoom: 14),
                                  children: [
                                    TileLayer(
                                      urlTemplate: "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
                                      subdomains: const ['a', 'b', 'c', 'd'],
                                      userAgentPackageName: 'com.racheeta.app',
                                    ),
                                    MarkerLayer(markers: [
                                      Marker(point: jobGps, width: 40, height: 40, child: const Icon(Icons.location_on, color: RacheetaColors.danger, size: 40)),
                                    ]),
                                  ],
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Column(
                                    children: [
                                      _mapIconButton(Icons.directions_car, Colors.green, () => _openNavigation('careem', jobGps)),
                                      const SizedBox(height: 8),
                                      _mapIconButton(Icons.map, Colors.blue, () => _openNavigation('waze', jobGps)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _applyForJob,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('قدّم الآن على هذه الوظيفة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RacheetaColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: RacheetaColors.textSecondary)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _openNavigation(String app, LatLng target) async {
    String url = app == 'careem' 
      ? 'careem://rides?pickup=my_location&dropoff_latitude=${target.latitude}&dropoff_longitude=${target.longitude}'
      : 'https://waze.com/ul?ll=${target.latitude},${target.longitude}&navigate=yes';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
