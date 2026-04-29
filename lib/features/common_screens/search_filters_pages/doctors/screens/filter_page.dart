import 'package:flutter/material.dart';
import '../../../../../constansts/constants.dart';

class FilterPage extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;
  const FilterPage({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late Map<String, dynamic> f;                // نسخة قابلة للتعديل
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();

  // كل مناطق بغداد الشائعة
  final List<String> _districts = [
    'الأعظمية','الكرادة','المنصور','الدورة','مدينة الصدر',
    'الشعب','الحرية','بغداد الجديدة','الكاظمية','العامرية','البتاوين',
  ];

  @override
  void initState() {
    super.initState();
    f = Map.from(widget.currentFilters);
    _priceMin.text = f['price_min']?.toString() ?? '';
    _priceMax.text = f['price_max']?.toString() ?? '';
  }

  void _apply() {
    // احفظ السعر إذا كُتِب أرقام صحيحة
    f['price_min'] = double.tryParse(_priceMin.text);
    f['price_max'] = double.tryParse(_priceMax.text);
    widget.onApplyFilters(f);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصفية الأطباء'),
        actions: [ IconButton(icon: const Icon(Icons.check), onPressed: _apply) ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _sectionTitle('الجنس'),
          _checkRow(['دكتور','دكتورة'], ['sex_male','sex_female']),

          _sectionTitle('الدرجة العلمية'),
          _checkRow(['استشاري','اختصاص'], ['degree_consultant','degree_specialist']),

          _sectionTitle('الخدمات'),
          _checkRow(['مكالمة صوتية','مكالمة فيديو'], ['voice_call','video_call']),

          _sectionTitle('الحد الأدنى للتقييم'),
          Slider(
            value : (f['rating_min'] as double),
            min   : 0, max: 5, divisions: 10,
            label : f['rating_min'].toString(),
            onChanged: (v)=> setState(()=> f['rating_min']=v),
          ),

          _sectionTitle('السعر (ألف دينار)'),
          Row(
            children: [
              _numBox(_priceMin, hint: 'من'),
              const SizedBox(width: 12),
              _numBox(_priceMax, hint: 'إلى'),
            ],
          ),

          _sectionTitle('المنطقة'),
          DropdownButton<String>(
            isExpanded: true,
            value: f['address_kw'].toString().isEmpty ? null : f['address_kw'],
            hint : const Text('اختر منطقة فى بغداد'),
            items: _districts.map((d)=> DropdownMenuItem(value:d,child:Text(d))).toList(),
            onChanged: (v)=> setState(()=> f['address_kw']= v ?? ''),
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,padding:const EdgeInsets.symmetric(vertical:18)),
            onPressed: _apply,
            child: const Text('تطبيق الفلاتر',style: kDoctorSearchTextStyle),
          ),

        ],
      ),
    );
  }

  /* ـــــــــــــــــــ Widgets مساعدة ـــــــــــــــــــ */

  Widget _sectionTitle(String t) =>
      Padding(padding: const EdgeInsets.only(top:20,bottom:6),
          child: Text(t,style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _checkRow(List<String> labels, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) => Row(children:[
        Text(labels[i]),
        Checkbox(
          value: f[keys[i]] ?? false,
          onChanged: (v)=> setState(()=> f[keys[i]] = v),
        ),
      ])),
    );
  }

  Widget _numBox(TextEditingController c,{required String hint}) =>
      Expanded(
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
}
