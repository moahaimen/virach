import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import the different profile screens as needed:
import 'package:racheeta/features/nurse/screens/nurse_profile_screen.dart';
import 'package:racheeta/features/pharmacist/screens/pharma_profile_screen.dart';
// (Add additional imports for therapist, hospital, etc. as needed)
import '../../features/beauty_centers/screens/beauty_profile_screen.dart';
import '../../features/common_screens/AddOfferForm.dart';
import '../../features/common_screens/add_advertise_form.dart';
import '../../features/common_screens/add_employee_request_form.dart';
import '../../features/doctors/screens/dr_profile_screeen.dart';
import '../../features/doctors/screens/md_joint_requests_screen.dart';
import '../../features/hospitals/screens/hospitals_profile_screen.dart';
import '../../features/jobposting/screens/current_jobposting_screen.dart';
import '../../features/labrotary/screens/labrotary_profile.dart';
import '../../features/medical_centre/screens/doctors_search_screen.dart';
import '../../features/offers/screens/my_offers_screen.dart';
import '../../features/offers/screens/offers_screent.dart';
import '../../features/therapist/screens/therapist_profile_screen.dart';

class DrawerWidget extends StatefulWidget {
  /// The type of provider (for example: 'doctor', 'nurse', 'pharmacist', etc.)
  final String userType;

  /// The user’s unique ID (from the users table)
  final String? userId;

  /// The provider’s unique ID (doctorId, nurseId, etc.)
  final String? hspId;

  const DrawerWidget({
    Key? key,
    required this.userType,
    this.userId,
    this.hspId,
  }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  // In case the provider ID is stored in SharedPreferences, load it
  String? _providerId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviderId();
  }

  Future<void> _loadProviderId() async {
    final prefs = await SharedPreferences.getInstance();

    switch (widget.userType) {
      case 'doctor':
        _providerId = prefs.getString("doctor_id");
        break;
      case 'nurse':
        _providerId = prefs.getString("nurse_id");
        break;
      case 'pharmacist':
        _providerId = prefs.getString("pharmacy_id");
        break;
      case 'therapist':
        _providerId = prefs.getString("therapist_id");
        break;
      case 'hospital':
        _providerId = prefs.getString("therapist_id");
        break;
      case 'laboratory':
      case 'lab':
        _providerId = prefs.getString("laboratory_id");
        break;
      case 'mdeidcal_center':
      case 'medical_center':
        _providerId = prefs.getString("medical_center_id");
        break;
      case 'beauty_center':
        _providerId = prefs.getString("beautycenter_id");
        break;
      default:
        _providerId = widget.hspId; // Fallback to the passed hspId
    }

    // Ensure `_providerId` is set from either SharedPreferences or `widget.hspId`
    if (_providerId == null || _providerId!.isEmpty) {
      _providerId = widget.hspId;
    }

    setState(() {
      _isLoading = false;
    });

    debugPrint("✔️ Loaded Provider ID: $_providerId");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with dynamic title
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              _getDrawerTitle(widget.userType),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          // Profile ListTile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('الملف الشخصي'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _navigateToProfile();
            },
          ),
          // Notifications
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('الاشعارات'),
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          // Messages
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('الرسائل'),
            onTap: () => Navigator.pushNamed(context, '/messages'),
          ),
          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الاعدادات'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          // Advertisement (appears if both userId and hspId are provided)

          if (widget.userId != null && widget.hspId != null) ...[
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('أضف اعلان'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAdvertiseForm(
                      userType: widget.userType,
                      hspId: widget.hspId!,
                      userId: widget.userId!,
                    ),
                  ),
                );
              },
            ),
          ],

          // Add Offer
          if (widget.userId != null)
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('اضف عرض او خصم'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddOfferForm(
                      userId: widget.userId!,         // ✅ فقط هذا إن احتجت الـ id
                    ),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.local_offer),
            title: const Text('عروضي السابقة'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOffersPage(
                    userType: widget.userType,
                    userId: widget.userId!,
                    //hspId: widget.hspId!,
                  ),
                ),
              );
            },
          ),
          // Employee Request
          if (widget.userId != null)
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('هل تحتاج موظفين؟ اعلن عن وظيفة!'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEmployeeRequestForm(
                      userType: widget.userType,
                      userId: widget.userId!,
                      // hspId: widget.hspId ?? _providerId,
                    ),
                  ),
                );
              },
            ),
          if (widget.userId != null)
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('وظائف معروضة سابقاً'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyJobPostingsPage(
                      userType: widget.userType,
                      userId: widget.userId!,
                      //hspId: widget.hspId!,
                    ),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.person_search),
            title: const Text('هل تبحث عن أطباء؟'),
            onTap: () {
              Navigator.pop(context);            // close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CenterDoctorsScreen(
                   // pass your center id
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.local_offer),
            title: const Text('كل العروضً'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OffersScreen(
                    // userType: widget.userType,
                    // userId: widget.userId!,
                    //hspId: widget.hspId!,
                  ),
                ),
              );
            },
          ),

          // lib/widgets/dashboard_widget/drawer_widget.dart

// … inside your build() where you render the ListTiles …
          if (widget.userType == 'medical_center' ||
              widget.userType == 'mdeidcal_center')
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('طلبات الانضمام المرسلة'),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CenterRequestsScreen()),
                );
              },
            ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  /// Returns a dynamic drawer title based on the provider type.
  String _getDrawerTitle(String userType) {
    switch (userType) {
      case 'doctor':
        return 'لوحة تحكم الطبيب';
      case 'nurse':
        return 'لوحة تحكم الممرض';
      case 'pharmacist':
        return 'لوحة تحكم الصيدلية';
      case 'therapist':
        return 'لوحة تحكم المعالج الطبيعي';
      case 'hospital':
        return 'لوحة تحكم المستشفى';
      case 'medical_center':
        return 'لوحة تحكم المركز الطبي';
      case 'beauty_center':
        return 'لوحة تحكم مركز التجميل';
      default:
        return 'لوحة تحكم مقدم الخدمة';
    }
  }

  /// Navigates to the appropriate profile screen based on the userType.
  void _navigateToProfile() {
    switch (widget.userType.toLowerCase()) {
      case 'doctor':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorSingleProfilePage(), // existing screen
          ),
        );
        break;

      case 'nurse':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NurseSingleProfilePage(), // create screen
          ),
        );
        break;
      case "lab":
      case "laboratory":
        print('this is the laboratory profile');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabrotaryProfile(), // create screen
          ),
        );
        break;

      case 'pharmacist':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacistSingleProfilePage(),
          ),
        );
        break;

      case 'therapist':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TherapistSingleProfilePage(),
          ),
        );
        break;

      case 'hospital':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HospitalSingleProfilePage(),
          ),
        );
        break;
    //
    // case "medical_center":
    // case "medicalcentre":
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => MedicalCenterSingleProfilePage(),
    //     ),
    //   );
    //   break;
    //
      case 'beauty_center':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BeautyCenterProfile(),
          ),
        );
        break;

      default:
      // Fallback if you want a default profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorSingleProfilePage(),
          ),
        );
    }
  }
}

///ToDo build hsp profile page
