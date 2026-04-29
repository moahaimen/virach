// lib/features/jobseeker/screens/jobseeker_profile_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/home_screen_widgets/appBar_widget.dart';
import '../providers/jobseeker_provider.dart';

class JobSeekerProfileFormPage extends StatefulWidget {
  const JobSeekerProfileFormPage({super.key});

  @override
  State<JobSeekerProfileFormPage> createState() =>
      _JobSeekerProfileFormPageState();
}

class _JobSeekerProfileFormPageState extends State<JobSeekerProfileFormPage> {
  /* ── controllers & formKey ─────────────────────────────────── */
  final _formKey            = GlobalKey<FormState>();
  final _degreeCtrl         = TextEditingController();
  final _specialtyCtrl      = TextEditingController();
  final _addressCtrl        = TextEditingController();
  bool  _submitting         = false;
  String _gender            = 'm';

  /* ── helpers ───────────────────────────────────────────────── */
  InputDecoration _decor(String label, IconData ic) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(ic),
    border: const OutlineInputBorder(),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final prefs   = await SharedPreferences.getInstance();
      final userId  = prefs.getString('user_id');
      final gps     = prefs.getString('gps_location') ?? '37.4219983,-122.084';

      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('⚠️ لا يوجد معرف مستخدم')));
        return;
      }

      final prov = context.read<JobSeekerRetroDisplayGetProvider>();
      final js   = await prov.createJobSeeker(
        userId     : userId,
        specialty  : _specialtyCtrl.text.trim(),
        degree     : _degreeCtrl.text.trim(),
        address    : _addressCtrl.text.trim(),
        gpsLocation: gps,
      );

      if (js == null) throw Exception('failed-to-save');

      // ── quick cache ──
      await prefs.setString('jobseeker_id', js.id ?? '');
      await prefs.setString('degree'      , js.degree ?? '');
      await prefs.setString('specialty'   , js.specialty ?? '');
      await prefs.setString('address'     , js.address ?? '');

      // DEBUG: print what we just saved
      debugPrint('💾 Saved to prefs.jobseeker_id = ${prefs.getString('jobseeker_id')}');
      debugPrint('💾 createJobSeeker returned id = ${js.id}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إنشاء الملف بنجاح')),
      );
      Navigator.pop(context);

    } catch (e) {
      debugPrint('❌ jobseeker save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ حدث خطأ أثناء الحفظ')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /* ── UI ───────────────────────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RacheetaAppBar(title: 'إنشاء ملف الباحث عن عمل'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _degreeCtrl,
                      decoration: _decor('المؤهل العلمي', Icons.school),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _specialtyCtrl,
                      decoration: _decor('التخصص', Icons.work),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: _decor('العنوان', Icons.location_on),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _decor('الجنس', Icons.person),
                      items: const [
                        DropdownMenuItem(value: 'm', child: Text('ذكر')),
                        DropdownMenuItem(value: 'f', child: Text('أنثى')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'm'),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _submitting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.save),
                        label: Text(_submitting ? 'جارٍ الحفظ...' : 'حفظ الملف'),
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
