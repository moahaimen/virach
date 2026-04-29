/*  ✅  التغييرات باختصار
 *  1) أضفنا keyboardType حيث كان ناقصًا
 *  2) غيّرنا توقيع دوال التحقق ليقبل dynamic
 *  3) ظللنا بدون userType؛ نعتمد على role المحفوظ
 */
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constansts/constants.dart';
import '../../widgets/offers/custom_text_field_widget.dart';
import '../../widgets/offers/date_picker_field_widget.dart';
import '../../widgets/offers/discount_dropdown_widget.dart';
import '../../widgets/offers/large_text_area_widget.dart';
import '../../widgets/offers/offer_image_picker_widget.dart';
import '../offers/providers/offers_provider.dart';

class AddOfferForm extends StatefulWidget {
  const AddOfferForm({super.key, this.userId});
  final String? userId;

  @override
  State<AddOfferForm> createState() => _AddOfferFormState();
}

class _AddOfferFormState extends State<AddOfferForm> {
  /* ---------------- controllers & vars ---------------- */
  final _formKey = GlobalKey<FormState>();
  String _currentRole = 'unknown';

  final offerTitleController       = TextEditingController();
  final offerDescriptionController = TextEditingController();
  final offerPriceController       = TextEditingController();
  final discountedPriceController  = TextEditingController();
  final startDateController        = TextEditingController();
  final endDateController          = TextEditingController();

  String  selectedDiscount = '10%';
  String  selectedDuration = '1 يوم';
  File?   _selectedImage;
  String? selectedOfferType;

  static const List<String> _offerTypes = [
    'أسنان','طب الأسرة','اشعة وسونار','انف واذن وحنجرة','تغذية',
    'أورام','جلدية','مخ واعصاب','علاج طبيعي','تحاليل','أدوية',
    'تجميل','عروض مستشفيات','مختبرات','تمريض','صيدلية',
  ];

  static const Map<String,int> _durationDays = {
    '1 يوم':1,'3 أيام':3,'5 أيام':5,'1 أسبوع':7,'2 أسابيع':14,
    '3 أسابيع':21,'1 شهر':30,
  };

  /* ---------------- init: fetch role ---------------- */
  @override
  void initState() { super.initState(); _loadRole(); }
  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(()=> _currentRole = prefs.getString('role')??'doctor');
  }

  /* ---------------  UI --------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة خصم لـ $_currentRole', style: kAppBarDoctorsTextStyle),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions:[ IconButton(icon: const Icon(Icons.save), onPressed: _submitForm) ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /* ----------- نصوص ----------- */
              CustomTextField(
                label:'اسم العرض',
                controller: offerTitleController,
                keyboardType: TextInputType.text,
                validator: _required,
              ),
              LargeTextAreaField(
                label:'وصف العرض',
                controller: offerDescriptionController,
                validator: _required,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText:'نوع العرض'),
                value: selectedOfferType,
                items: _offerTypes.map((t)=>DropdownMenuItem(value:t,child:Text(t))).toList(),
                onChanged:(v)=>setState(()=>selectedOfferType=v),
                validator:(v)=> v==null ? 'اختر نوع العرض' : null,
              ),
              /* ----------- السعر والخصم ----------- */
              CustomTextField(
                label:'السعر الأصلي',
                controller: offerPriceController,
                keyboardType: TextInputType.number,
                inputFormatters:[ FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')) ],
                validator:(v)=> _validateNumeric(v, 'السعر الأصلي'),
                onChanged: _recalculate,
              ),
              DiscountDropdown(
                selectedValue: selectedDiscount,
                onChanged:(v){ setState(()=>selectedDiscount=v??selectedDiscount); _recalculate(offerPriceController.text); },
              ),
              CustomTextField(
                label:'السعر بعد الخصم',
                controller: discountedPriceController,
                keyboardType: TextInputType.number,
                readOnly:true,
              ),
              /* ----------- المدة والتواريخ ----------- */
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText:'مدة العرض'),
                value: selectedDuration,
                items: _durationDays.keys.map((d)=>DropdownMenuItem(value:d,child:Text(d))).toList(),
                onChanged:(v){ setState(()=>selectedDuration=v??selectedDuration); _calcEndDate(); },
              ),
              DatePickerField(
                label:'تاريخ بداية العرض',
                controller: startDateController,
                keyboardType: TextInputType.datetime,
                validator:(v)=>_validateDate(v,'تاريخ البداية'),
                onTap:_pickStartDate,
              ),
              CustomTextField(
                label:'تاريخ نهاية العرض',
                controller: endDateController,
                keyboardType: TextInputType.datetime,
                readOnly:true,
              ),
              /* ----------- صورة ----------- */
              ImagePickerWidget(onImageSelected:(img)=> _selectedImage=img),
              const SizedBox(height:24),
              ElevatedButton(
                style: kRedPatientElevatedButtonStyle,
                onPressed: _submitForm,
                child: const Text('إرسال العرض',style: TextStyle(color:Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* --------------- helpers --------------- */
  String? _required(dynamic v) =>
      (v==null || (v as String).trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  String? _validateNumeric(dynamic v, String field){
    if(v==null || (v as String).isEmpty) return '$field مطلوب';
    return double.tryParse(v) == null ? '$field رقم غير صالح' : null;
  }

  String? _validateDate(dynamic v,String field){
    if(v==null || (v as String).isEmpty) return '$field مطلوب';
    try{ DateTime.parse(v); }catch(_){ return '$field بصيغة غير صحيحة'; }
    return null;
  }

  void _recalculate(String? price){
    if(price==null || price.isEmpty){ discountedPriceController.clear(); return;}
    final orig = double.tryParse(price)??0;
    final disc = int.parse(selectedDiscount.replaceAll('%',''))/100;
    discountedPriceController.text = (orig-orig*disc).toStringAsFixed(2);
  }

  Future<void> _pickStartDate() async{
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if(d!=null){ startDateController.text=_fmt(d); _calcEndDate(); }
  }
  void _calcEndDate(){
    if(startDateController.text.isEmpty) return;
    final start=DateTime.tryParse(startDateController.text); if(start==null) return;
    endDateController.text = _fmt(start.add(Duration(days:_durationDays[selectedDuration]??1)));
  }
  String _fmt(DateTime d)=> d.toIso8601String().split('T').first;

  /* --------------- submit --------------- */
  void _submitForm(){
    if(_formKey.currentState!.validate()){ _saveOffer(); }
  }

  Future<void> _saveOffer() async{
    MultipartFile? img;
    if(_selectedImage!=null){
      img = await MultipartFile.fromFile(_selectedImage!.path, filename:'offer.jpg');
    }

// ─── التطبيع الوحيد المطلوب ───
    final providerType = (_currentRole == 'medical_center' || _currentRole == 'medical_centre')
        ? 'mdeidcal_center'          // ← الاسم الذي يقبله الخادم
        : _currentRole;

    final data = FormData.fromMap({
      'service_provider_id'  : widget.userId ?? 'unknown',
      'service_provider_type': providerType,          // ← استخدمه هنا
      'offer_title'          : offerTitleController.text.trim(),
      'offer_description'    : offerDescriptionController.text.trim(),
      'offer_type'           : selectedOfferType ?? 'عام',
      'offer_image'          : img,
      'discount_percentage'  : selectedDiscount.replaceAll('%',''),
      'original_price'       : offerPriceController.text.trim(),
      'discounted_price'     : discountedPriceController.text.trim(),
      'period_of_time'       : selectedDuration,
      'start_date'           : _fmt(DateTime.parse(startDateController.text)),
      'end_date'             : _fmt(DateTime.parse(endDateController.text)),
    });


    final provider = context.read<OffersRetroDisplayGetProvider>();
    await provider.createOffer(data);

    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال العرض بنجاح!')),
    );
    Navigator.pop(context);
  }
}
