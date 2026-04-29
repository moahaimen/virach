import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../applicants/models/applicants_model.dart';
import '../../applicants/providers/applicants_provider.dart';
import '../../jobseeker/providers/jobseeker_provider.dart';
import '../../jobseeker/screens/job_seeker_profile_form_page.dart';
import '../models/jobposting_model.dart';

class JobDetailsPage extends StatefulWidget {
  final JobPostingModel job;
  final Map<String, dynamic> userData;

  const JobDetailsPage({
    Key? key,
    required this.job,
    required this.userData,
  }) : super(key: key);

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = false;
  Map<String, String> _userData = {};
  DateTime? _selectedDate;
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
    setState(() {
      _userData = {
        "jobseeker_id": prefs.getString("jobseeker_id") ?? "",
        "full_name": prefs.getString("full_name") ?? "مستخدم مجهول",
        "email": prefs.getString("email") ?? "غير معروف",
        "phone_number": prefs.getString("phone_number") ?? "غير معروف",
        "degree": prefs.getString("degree") ?? "غير محدد",
        "specialty": prefs.getString("specialty") ?? "غير محدد",
        "address": prefs.getString("address") ?? "غير متوفر",
        "gender": prefs.getString("gender") ?? "غير معروف",
      };
      print('the userdata is $_userData');
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Error fetching current location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch current location')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  LatLng? _parseGpsLocation(String? gpsLocation) {
    if (gpsLocation == null) return null;
    try {
      final parts = gpsLocation.split(' ');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint("Error parsing GPS location: $e");
    }
    return null;
  }

// ─── JobDetailsPage.dart ──────────────────────────────────────────
//   Future<void> _applyForJob() async {
//     final now = DateTime.now();
//     if (_lastApplyTimestamp != null &&
//         now.difference(_lastApplyTimestamp!).inSeconds < 30) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('لقد قدمت طلباً للتو. انتظر 30 ثانية.')),
//       );
//       return;
//     }
//     if (_applyCount >= 3) {
//       if (_blockTimestamp != null &&
//           now.difference(_blockTimestamp!).inMinutes < 5) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('لقد قدمت عدة طلبات. انتظر 5 دقائق.')),
//         );
//         return;
//       } else {
//         _applyCount = 0;
//         _blockTimestamp = null;
//       }
//     }
//
//     // 🆕 ❶ احصل على UUID الخاص بالـ User (الذي يمثل job_seeker في الـ Applications)
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('user_id');
//     debugPrint('▶️ Applying with user_id = $userId');
//     if (userId == null || userId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('⚠️ لم يتم العثور على حساب المستخدم')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       // ❷ جهّز الخريطة الكاملة للـ Job كما يطلبه الـ Backend
//       final jobPayload = {
//         'id': widget.job.id,
//         'service_provider': widget.job.serviceProvider,
//         'service_provider_type': widget.job.serviceProviderType,
//         'job_title': widget.job.jobTitle,
//         'job_description': widget.job.jobDescription,
//         'qualifications': widget.job.qualifications,
//         'job_location': widget.job.jobLocation,
//       };
//       debugPrint('🔍 [JobDetailsPage] jobPayload: $jobPayload');
//
//       // ❸ ابني الموديل مستخدمًا الخريطة
//       final applicantModel = ApplicantsModel(
//         jobSeeker: userId,
//         job: jobPayload, // ← هنا نوصل الخريطة الكاملة
//         resume: _userData['degree'] ?? '',
//         coverLetter: _userData['specialty'] ?? '',
//         applicationStatus: 'submitted',
//       );
//
//       // ❹ أرسل الطلب
//       final provider = Provider.of<ApplicantsProvider>(context, listen: false);
//       final created = await provider.createApplicant(applicantModel);
//
//       if (created != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('✅ تم إرسال طلبك بنجاح')),
//         );
//         _applyCount++;
//         _lastApplyTimestamp = now;
//         if (_applyCount == 1) _blockTimestamp = now;
//       } else {
//         throw Exception('createApplicant returned null');
//       }
//     } catch (e) {
//       debugPrint('Error applying to job: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('فشل في إرسال الطلب. حاول مرة أخرى.')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

  Future<void> _applyForJob() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا يوجد حساب مستخدم')),
      );
      return;
    }

    final jobSeekerProvider = Provider.of<JobSeekerRetroDisplayGetProvider>(context, listen: false);
    final jobSeeker = await jobSeekerProvider.fetchCurrentJobSeekerByUserID();

    if (jobSeeker == null) {
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobSeekerProfileFormPage()),
        );
      }
      return;
    }

    final now = DateTime.now();
    if (_lastApplyTimestamp != null && now.difference(_lastApplyTimestamp!).inSeconds < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ انتظر 30 ثانية بين كل تقديم')),
      );
      return;
    }

    if (_applyCount >= 3 && _blockTimestamp != null && now.difference(_blockTimestamp!).inMinutes < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⛔ أعد المحاولة بعد 5 دقائق')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final applicant = ApplicantsModel(
        jobSeekerId: userId,               // 🔑 يجب أن يكون معرف المستخدم نفسه
        job: widget.job.id,              // 🔑 أرسل UUID فقط وليس كائنًا
        resume: jobSeeker.degree ?? '',
        coverLetter: jobSeeker.specialty ?? '',
        applicationStatus: 'submitted',
      );

      final provider = Provider.of<ApplicantsProvider>(context, listen: false);
      final result = await provider.createApplicant(applicant);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم التقديم على الوظيفة')),
        );
        _applyCount++;
        _lastApplyTimestamp = now;
        if (_applyCount == 1) _blockTimestamp = now;
      } else {
        throw Exception("فشل في إرسال الطلب");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ حدث خطأ أثناء التقديم')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }




  // Redesigned info card widget
  Widget _buildInfoCard(String title, String content, {IconData? icon}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.blueAccent, size: 28),
            if (icon != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(LatLng jobGps) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: jobGps,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: jobGps,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Column(
              children: [
                _buildMapButton('كريم', Colors.green,
                    () => _openNavigation('careem', jobGps)),
                const SizedBox(height: 10),
                _buildMapButton(
                    'بلي', Colors.grey, () => _openNavigation('baly', jobGps)),
                const SizedBox(height: 10),
                _buildMapButton(
                    'ويز', Colors.blue, () => _openNavigation('waze', jobGps)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  Future<void> _openNavigation(String app, LatLng target) async {
    String url;
    if (app == 'careem') {
      url =
          'careem://rides?pickup=my_location&dropoff_latitude=${target.latitude}&dropoff_longitude=${target.longitude}';
    } else if (app == 'baly') {
      final currentLat = _currentLocation?.latitude ?? 0.0;
      final currentLng = _currentLocation?.longitude ?? 0.0;
      final balyUri = Uri(
        scheme: 'https',
        host: 'baly.app',
        queryParameters: {
          'pickup_latitude': currentLat.toString(),
          'pickup_longitude': currentLng.toString(),
          'dropoff_latitude': target.latitude.toString(),
          'dropoff_longitude': target.longitude.toString(),
        },
      );
      url = balyUri.toString();
    } else {
      // waze
      final wazeUri = Uri(
        scheme: 'https',
        host: 'waze.com',
        path: '/ul',
        queryParameters: {
          'll': '${target.latitude},${target.longitude}',
          'navigate': 'yes',
        },
      );
      url = wazeUri.toString();
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint("Could not launch navigation app: $app");
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final applicantName = widget.userData["full_name"] ?? "Unknown";
    final jobGps = _parseGpsLocation(job.jobLocation) ??
        _parseGpsLocation("40.7128 -74.0060")!;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    job.jobTitle ?? 'اسم الوظيفة غير متوفر',
                    style: const TextStyle(color: Colors.white),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/job_header.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.35),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                ),
                backgroundColor: Colors.blue,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("👤 مرحبًا ${_userData['full_name']}!",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildInfoCard(
                          "الموقع", job.jobLocation ?? "غير متوفر",
                          icon: Icons.location_on),
                    ),

                    if (job.salary != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildInfoCard("الراتب", job.salary!,
                            icon: Icons.monetization_on),
                      ),
                    if (job.qualifications != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildInfoCard("المؤهلات", job.qualifications!,
                            icon: Icons.school),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildInfoCard(
                          "الوصف الوظيفي", job.jobDescription ?? "لا يوجد وصف",
                          icon: Icons.description),
                    ),
                    const SizedBox(height: 12),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: _buildInfoCard(
                    //       "تاريخ المقابلة",
                    //       _selectedDate != null
                    //           ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    //           : "اختر التاريخ",
                    //       icon: Icons.calendar_today),
                    // ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildMapSection(jobGps),
                    ),
                    const SizedBox(
                        height: 100), // extra space for floating button
                  ],
                ),
              ),
            ],
          ),
          // Floating Apply Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _applyForJob,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blue,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'قدّم الآن',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
