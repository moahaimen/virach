import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../constansts/constants.dart';
import '../../widgets/advertise/custom_drop_down_widget.dart';
import '../../widgets/advertise/custom_text_field_widget.dart';
import '../beauty_centers/providers/beauty_centers_provider.dart';
import '../doctors/providers/doctors_provider.dart';
import '../hospitals/providers/hospital_display_provider.dart';
import '../labrotary/providers/labs_provider.dart';
import '../medical_centre/providers/medical_centers_providers.dart';
import '../nurse/providers/nurse_provider.dart';
import '../pharmacist/providers/pharma_provider.dart';
import '../therapist/providers/therapist_provider.dart';

class CreateAdvertiseForm extends StatefulWidget {
  final String userType;
  final String? userId; // Unique user ID from the user table
  // A generic HSP identifier – fallback value if /me/ isn't available.
  final String hspId;

  const CreateAdvertiseForm({
    Key? key,
    required this.userType,
    this.userId,
    required this.hspId,
  }) : super(key: key);

  @override
  _CreateAdvertiseFormState createState() => _CreateAdvertiseFormState();
}

class _CreateAdvertiseFormState extends State<CreateAdvertiseForm> {
  final TextEditingController advertiseTitleController =
      TextEditingController();
  final TextEditingController advertiseDescriptionController =
      TextEditingController();
  final TextEditingController advertiseCostController = TextEditingController();

  String? selectedDuration;
  final Map<String, int> durationCosts = {
    'شهر ١': 1,
    '٣ اشهر': 3,
    '٦ اشهر': 6,
    'سنة': 12,
  };
  final Map<String, int> costMapping = {
    'شهر ١': 10,
    '٣ اشهر': 25,
    '٦ اشهر': 50,
    'سنة': 75,
  };

  bool isAdvertised = false;
  bool hasActiveAd = false;
  String activeAdDetails = "";
  bool isPaymentCompleted = false;
  late String providerId;

  @override
  void initState() {
    super.initState();
    debugPrint("Passed provider (HSP) ID: ${widget.hspId}");
    _loadProviderId();
  }

  /// Load providerId from the /me/ data if available;
  /// otherwise, fall back to SharedPreferences or the passed widget.hspId.
  Future<void> _loadProviderId() async {
    // Clear previous providerId value if any.
    providerId = "";

    // Determine which provider to use based on userType.
    switch (widget.userType.toLowerCase()) {
      case "doctor":
        {
          final provider = Provider.of<DoctorRetroDisplayGetProvider>(context,
              listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for doctor: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Doctor meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;

      case "nurse":
        {
          final provider =
              Provider.of<NurseRetroDisplayGetProvider>(context, listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for nurse: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Nurse meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;

      case "pharmacist":
        {
          final provider = Provider.of<PharmaRetroDisplayGetProvider>(context,
              listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for pharmacist: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Pharmacist meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;

      case "therapist":
      case "physical-therapist":
        {
          final provider = Provider.of<TherapistRetroDisplayGetProvider>(
              context,
              listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for therapist: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Therapist meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;
      case "lab":
      case "laboratory":
        {
          final provider =
              Provider.of<LabsRetroDisplayGetProvider>(context, listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for laboratory: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Therapist meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;

      case "hospital":
        {
          final provider = Provider.of<HospitalRetroDisplayGetProvider>(context,
              listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for hospital: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Hospital meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;

      case "medical_center":
        {
          final provider = Provider.of<MedicalCentersRetroDisplayGetProvider>(
              context,
              listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for medical_center: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Medical Center meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;

      case "beauty_center":
        {
          final provider = Provider.of<BeautyCentersRetroDisplayGetProvider>(
              context,
              listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ for beauty_center: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Beauty Center meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
        break;

      default:
        {
          // Fallback: use doctor provider as default
          final provider = Provider.of<DoctorRetroDisplayGetProvider>(context,
              listen: false);
          if (provider.meData == null) {
            try {
              await provider.fetchMe();
            } catch (e) {
              debugPrint(
                  '>>> [loadProviderId] Error fetching /me/ in default: $e');
            }
          }
          final meData = provider.meData;
          debugPrint(">>> [loadProviderId] Default meData: $meData");
          if (meData != null) {
            final details = meData['role']?['details'];
            if (details != null && details['id'] != null) {
              providerId = details['id'];
            }
          }
        }
    }

    // Fallback: If providerId is still empty, get it from SharedPreferences or use widget.hspId.
    if (providerId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      providerId = prefs.getString("${widget.userType}_id") ?? widget.hspId;
      debugPrint(
          "📦 [loadProviderId] Retrieved providerId from SharedPreferences: $providerId");
    }

    if (providerId.isEmpty) {
      debugPrint(
          "🚨 [loadProviderId] ERROR: providerId is still empty after all attempts!");
    } else {
      debugPrint("✅ [loadProviderId] Final providerId: $providerId");
    }

    // Check for active advertisement after obtaining providerId.
    await _checkActiveAd();
  }

  /// Check if there's an active advertisement for this provider.
  Future<void> _checkActiveAd() async {
    if (providerId.isEmpty) {
      debugPrint(">>> [checkActiveAd] Provider ID is empty, skipping check.");
      return;
    }

    try {
      debugPrint(
          ">>> [checkActiveAd] Fetching active advertisement for: $providerId");
      Map<String, dynamic>? adInfo;
      switch (widget.userType.toLowerCase()) {
        case "doctor":
          final doctorProvider = Provider.of<DoctorRetroDisplayGetProvider>(
              context,
              listen: false);
          adInfo = await doctorProvider.getActiveAd(providerId);
          break;
        case "nurse":
          final nurseProvider =
              Provider.of<NurseRetroDisplayGetProvider>(context, listen: false);
          adInfo = await nurseProvider.getActiveAd(providerId);
          break;
        case "pharmacist":
          final pharmaProvider = Provider.of<PharmaRetroDisplayGetProvider>(
              context,
              listen: false);
          adInfo = await pharmaProvider.getActiveAd(providerId);
          break;

        case "therapist":
          final therapistProvider =
              Provider.of<TherapistRetroDisplayGetProvider>(context,
                  listen: false);
          adInfo = await therapistProvider.getActiveAd(providerId);
          break;
        case "laboratory":
          final laboratoryProvider =
              Provider.of<LabsRetroDisplayGetProvider>(context, listen: false);
          adInfo = await laboratoryProvider.getActiveAd(providerId);
          break;

        case "hospital":
          final hospitalProvider = Provider.of<HospitalRetroDisplayGetProvider>(
              context,
              listen: false);
          adInfo = await hospitalProvider.getActiveAd(providerId);
          break;
        case "medical_center":
        case "mdeidcal_center":
          final medicalCenterProvider =
          Provider.of<MedicalCentersRetroDisplayGetProvider>(context, listen: false);
          adInfo = await medicalCenterProvider.getActiveAd(providerId);
          break;

        case "beauty_center":
          final beautyCenterProvider =
              Provider.of<BeautyCentersRetroDisplayGetProvider>(context,
                  listen: false);
          adInfo = await beautyCenterProvider.getActiveAd(providerId);
          break;
        default:
          debugPrint("Unsupported provider type: ${widget.userType}");
          return;
      }
      debugPrint(">>> [checkActiveAd] Advertisement Info: $adInfo");
      if (adInfo != null) {
        DateTime startDate = adInfo['start_date'] is DateTime
            ? adInfo['start_date']
            : DateTime.parse(adInfo['start_date'].toString());
        DateTime endDate = adInfo['end_date'] is DateTime
            ? adInfo['end_date']
            : DateTime.parse(adInfo['end_date'].toString());

        final now = DateTime.now();
        final difference = endDate.difference(now);
        int monthsLeft = 0;
        int daysLeft = difference.inDays;
        if (daysLeft > 0) {
          monthsLeft = (daysLeft / 30).floor();
          daysLeft = daysLeft % 30;
        }
        setState(() {
          hasActiveAd = true;
          activeAdDetails = "لديك إعلان نشط لمدة ${adInfo?['duration']} شهر\n"
              "من ${DateFormat('dd/MM/yyyy').format(startDate)} إلى ${DateFormat('dd/MM/yyyy').format(endDate)}\n"
              "تبقى لديك $monthsLeft شهر و $daysLeft يوم";
        });
      } else {
        setState(() {
          hasActiveAd = false;
          activeAdDetails = "";
        });
      }
    } catch (e) {
      debugPrint(">>> [checkActiveAd] Error: $e");
    }
  }

  @override
  void dispose() {
    advertiseTitleController.dispose();
    advertiseDescriptionController.dispose();
    advertiseCostController.dispose();
    super.dispose();
  }

  String _calculateAdDates(int duration) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: duration * 30));
    final formatter = DateFormat('dd/MM/yy');
    return "من ${formatter.format(now)} إلى ${formatter.format(endDate)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اعلانات ${widget.userType}'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (hasActiveAd) _buildActiveAdContainer(),
            Expanded(child: _buildCreateAdForm(disabled: hasActiveAd)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAdContainer() {
    return Container(
      color: Colors.red,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            activeAdDetails,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'لا يمكنك إنشاء اعلان جديد حتى انتهاء الإعلان الحالي. للاستفسار اتصل بنا مباشرةً',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAdForm({bool disabled = false}) {
    return ListView(
      children: [
        const SizedBox(height: 40),
        CustomDropdownField(
          label: 'مدة الاعلان',
          selectedValue: selectedDuration,
          durationCosts: durationCosts,
          onChanged: disabled
              ? (_) {}
              : (newValue) {
                  setState(() {
                    selectedDuration = newValue;
                    advertiseCostController.text =
                        '${costMapping[newValue]} الف';
                  });
                },
        ),
        if (selectedDuration != null)
          Text(
            _calculateAdDates(durationCosts[selectedDuration] ?? 0),
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'كلفة الاعلان',
          controller: advertiseCostController,
          isEnabled: !disabled,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: const Text('تفعيل الاعلان'),
          value: isAdvertised,
          onChanged: disabled
              ? null
              : (value) {
                  setState(() {
                    isAdvertised = value;
                  });
                },
        ),
        const SizedBox(height: 20),
        const Text(
          'الاعلان يسمح لملفك الشخصي\nبالوصول الى اعلى صفحات البحث لدى مستخدمي التطبيق',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: disabled
              ? null
              : () {
                  setState(() {
                    isPaymentCompleted = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم الدفع بنجاح')),
                  );
                },
          child: const Text('ادفع الآن'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: kRedPatientElevatedButtonStyle,
          onPressed:
              disabled || !isPaymentCompleted ? null : _submitAdvertisement,
          child: const Text('ارسل الاعلان', style: kPatientButtonTextStyle),
        ),
      ],
    );
  }

  void _submitAdvertisement() async {
    // 1) Check for existing active ad
    if (hasActiveAd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لديك إعلان نشط بالفعل!')),
      );
      return;
    }

    // 2) Clean up the cost field to digits only
    final cost = advertiseCostController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final duration = durationCosts[selectedDuration] ?? 0;

    try {
      // 3) Call the correct update method for each user type
      switch (widget.userType.toLowerCase()) {
        case "doctor":
          final doctorProvider = Provider.of<DoctorRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          await doctorProvider.updateAdvertisement(
            doctorId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;

        case "nurse":
          final nurseProvider = Provider.of<NurseRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          await nurseProvider.updateAdvertisement(
            nurseId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;

        case "pharmacist":
          final pharmaProvider = Provider.of<PharmaRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          await pharmaProvider.updateAdvertisement(
            pharmaId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;

        case "therapist":
          final therapistProvider =
              Provider.of<TherapistRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          await therapistProvider.updateAdvertisement(
            therapistId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;

        case "lab":
        case "laboratory":
          final laboratoryProvider = Provider.of<LabsRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          // ❗ Here we use providerId directly, instead of calling getLaboratoryId().
          if (providerId.isEmpty) {
            debugPrint("🚨 [Update Advertisement] ERROR: Lab ID is empty.");
            return;
          }
          await laboratoryProvider.updateAdvertisement(
            laboratoryId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;
        case "hospital":
          final hospitalProvider = Provider.of<HospitalRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          await hospitalProvider.updateAdvertisement(
            hospitalId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;
        case "medical_center":
        case "medicalcentre":
          final medicalCenterProvider =
              Provider.of<MedicalCentersRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          await medicalCenterProvider.updateAdvertisement(
            centerId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;

        case "beauty_center":
          final beautyCenterProvider =
              Provider.of<BeautyCentersRetroDisplayGetProvider>(
            context,
            listen: false,
          );
          // If you want to do the same for Beauty Center, remove getBeautyCenterId()
          // and rely on providerId as well:
          if (providerId.isEmpty) {
            debugPrint(
                "🚨 [Update Advertisement] ERROR: Beauty Center ID is empty.");
            return;
          }
          await beautyCenterProvider.updateAdvertisement(
            beautyCenterId: providerId,
            advertise: isAdvertised,
            advertisePrice: cost,
            advertiseDuration: duration.toString(),
          );
          break;

        default:
          throw Exception("Unsupported provider type: ${widget.userType}");
      }

      // 4) If we reached here without errors, show success & pop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم ارسال الاعلان بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint(">>> [Submit Advertisement] Error: $e");
      if (e is DioError) {
        debugPrint(">>> [Submit Advertisement] DioError: ${e.response?.data}");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء ارسال الاعلان')),
      );
    }
  }
}
