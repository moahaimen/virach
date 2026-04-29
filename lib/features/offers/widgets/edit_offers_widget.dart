import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../widgets/advertise/large_text_area_field_widget.dart';
import '../../../widgets/offers/custom_text_field_widget.dart';
import '../../../widgets/offers/date_picker_field_widget.dart';
import '../../../widgets/offers/discount_dropdown_widget.dart';
import '../../../widgets/offers/offer_image_picker_widget.dart';
import '../models/offers_model.dart';
import '../providers/offers_provider.dart';

class EditOfferPage extends StatefulWidget {
  final OffersModel offer;
  const EditOfferPage({Key? key, required this.offer}) : super(key: key);

  @override
  State<EditOfferPage> createState() => _EditOfferPageState();
}

class _EditOfferPageState extends State<EditOfferPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController offerTitleController;
  late final TextEditingController offerDescriptionController;
  late final TextEditingController offerPriceController;
  late final TextEditingController discountedPriceController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;

  File? _selectedImage;
  late String selectedDiscount;
  late String selectedDuration;
  late String? selectedOfferType;
  late String currentRole;
  bool _isSaving = false;

  static const List<String> _offerTypes = [
    'أسنان', 'طب الأسرة', 'اشعة وسونار', 'انف واذن وحنجرة', 'تغذية',
    'أورام', 'جلدية', 'مخ واعصاب', 'علاج طبيعي', 'تحاليل', 'أدوية',
    'تجميل', 'عروض مستشفيات', 'مختبرات', 'تمريض', 'صيدلية',
  ];

  static const Map<String, int> _durationDays = {
    '1 يوم': 1, '3 أيام': 3, '5 أيام': 5, '1 أسبوع': 7,
    '2 أسابيع': 14, '3 أسابيع': 21, '1 شهر': 30,
  };

  @override
  void initState() {
    super.initState();

    offerTitleController = TextEditingController(text: widget.offer.offerTitle ?? '');
    offerDescriptionController = TextEditingController(text: widget.offer.offerDescription ?? '');
    offerPriceController = TextEditingController(text: widget.offer.originalPrice ?? '');
    discountedPriceController = TextEditingController(text: widget.offer.discountedPrice ?? '');
    startDateController = TextEditingController(text: widget.offer.startDate ?? '');
    endDateController = TextEditingController(text: widget.offer.endDate ?? '');

    // ✅ Fix for matching dropdown discount
    final parsedDiscount = double.tryParse(widget.offer.discountPercentage ?? '10')?.round() ?? 10;
    selectedDiscount = '${parsedDiscount}%';

    selectedOfferType = widget.offer.offerType;
    selectedDuration = widget.offer.periodOfTime ?? '1 يوم';
    currentRole = widget.offer.serviceProviderType ?? 'doctor';
  }

  @override
  void dispose() {
    offerTitleController.dispose();
    offerDescriptionController.dispose();
    offerPriceController.dispose();
    discountedPriceController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  void _recalculate(String? price) {
    if (price == null || price.isEmpty) {
      discountedPriceController.clear();
      return;
    }
    final orig = double.tryParse(price) ?? 0;
    final disc = int.parse(selectedDiscount.replaceAll('%', '')) / 100;
    discountedPriceController.text = (orig - orig * disc).toStringAsFixed(2);
  }

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(startDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      startDateController.text = _fmt(selected);
      _calcEndDate();
    }
  }

  void _calcEndDate() {
    if (startDateController.text.isEmpty) return;
    final start = DateTime.tryParse(startDateController.text);
    if (start == null) return;
    final days = _durationDays[selectedDuration] ?? 1;
    endDateController.text = _fmt(start.add(Duration(days: days)));
  }

  String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  Future<void> _submitForm() async {
    print(">>> SUBMIT triggered");

    final isValid = _formKey.currentState!.validate();
    print(">>> FORM VALID: $isValid");
    if (!isValid) {
      // ✅ Force form to show all validation errors
      setState(() {});
      return;
    }

    setState(() => _isSaving = true);

    MultipartFile? img;
    if (_selectedImage != null) {
      img = await MultipartFile.fromFile(_selectedImage!.path, filename: 'offer.jpg');
    }

    final formData = FormData.fromMap({
      'offer_title': offerTitleController.text.trim(),
      'offer_description': offerDescriptionController.text.trim(),
      'offer_type': selectedOfferType ?? 'عام',
      'offer_image': img,
      'discount_percentage': selectedDiscount.replaceAll('%', ''),
      'original_price': offerPriceController.text.trim(),
      'discounted_price': discountedPriceController.text.trim(),
      'period_of_time': selectedDuration,
      'start_date': startDateController.text,
      'end_date': endDateController.text,
    });

    print(">>> FormData fields:");
    for (final field in formData.fields) {
      print("    ${field.key}: ${field.value}");
    }
    print(">>> Image attached: ${_selectedImage?.path ?? 'No image'}");

    try {
      final provider = context.read<OffersRetroDisplayGetProvider>();
      final result = await provider.updateOffer(widget.offer.id!, formData);
      print(">>> UPDATE result: ${result?.toJson()}");

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل التحديث. لم يتم حفظ التغييرات.')),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث العرض بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      print(">>> UNHANDLED ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تحديث العرض')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل العرض')),
      body: Form(
        key: _formKey,
        // ✅ Enable live validation feedback
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'اسم العرض',
              controller: offerTitleController,
              keyboardType: TextInputType.text,
              validator: _required, // ✅ Make sure this connects to CustomTextField
            ),
            LargeTextAreaField(
              label: 'وصف العرض',
              controller: offerDescriptionController,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'نوع العرض'),
              value: selectedOfferType,
              items: _offerTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (v) => setState(() => selectedOfferType = v),
              validator: (v) => v == null ? 'اختر نوع العرض' : null, // ✅ Required
            ),
            CustomTextField(
              label: 'السعر الأصلي',
              controller: offerPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              validator: (v) => _validateNumeric(v, 'السعر الأصلي'),
              onChanged: _recalculate,
            ),
            DiscountDropdown(
              selectedValue: selectedDiscount,
              onChanged: (v) {
                setState(() {
                  selectedDiscount = v ?? selectedDiscount;
                  _recalculate(offerPriceController.text);
                });
              },
            ),
            CustomTextField(
              label: 'السعر بعد الخصم',
              controller: discountedPriceController,
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'مدة العرض'),
              value: selectedDuration,
              items: _durationDays.keys.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) {
                setState(() {
                  selectedDuration = v ?? selectedDuration;
                  _calcEndDate();
                });
              },
              validator: (v) => v == null ? 'اختر مدة العرض' : null, // ✅ Required
            ),
            DatePickerField(
              label: 'تاريخ البداية',
              controller: startDateController,
              validator: (v) => _validateDate(v, 'تاريخ البداية'),
              onTap: _pickStartDate,
            ),
            CustomTextField(
              label: 'تاريخ النهاية',
              controller: endDateController,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              validator: _required, // ✅ Enforce end date presence
            ),
            ImagePickerWidget(onImageSelected: (file) => _selectedImage = file),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _submitForm,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تحديث العرض'),
            )
          ],
        ),
      ),
    );
  }

  String? _required(dynamic v) =>
      (v == null || (v as String).trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  String? _validateNumeric(dynamic v, String field) =>
      (v == null || v.isEmpty) ? '$field مطلوب' :
      double.tryParse(v) == null ? '$field غير صالح' : null;

  String? _validateDate(dynamic v, String field) {
    if (v == null || v.isEmpty) return '$field مطلوب';
    try {
      DateTime.parse(v);
      return null;
    } catch (_) {
      return '$field غير صالح';
    }
  }
}
