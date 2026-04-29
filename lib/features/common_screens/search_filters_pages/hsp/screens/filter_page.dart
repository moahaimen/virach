import 'package:flutter/material.dart';

class HSPFilterPage extends StatefulWidget {
  final String hspType;
  final Map<String, dynamic> currentFilters;
  final void Function(Map<String, dynamic>) onApplyFilters;

  const HSPFilterPage({
    Key? key,
    required this.hspType,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<HSPFilterPage> createState() => _HSPFilterPageState();
}

class _HSPFilterPageState extends State<HSPFilterPage> {
  late Map<String, dynamic> f;

  // All Baghdad districts
  static const _districts = <String>[
    'الأعظمية',
    'الكرخ',
    'الرصافة',
    'المنصور',
    'الطوبجي',
    'الحسينية',
    'الكاظمية',
    'الكرادة',
    'الطارمية',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    // make a mutable copy
    f = Map<String, dynamic>.from(widget.currentFilters);
  }

  void _apply() {
    widget.onApplyFilters(f);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPerson =
        widget.hspType.toLowerCase() == 'nurse' ||
            widget.hspType.toLowerCase() == 'therapist' ||
            widget.hspType.toLowerCase() == 'doctor';

    return Scaffold(
      appBar: AppBar(
        title: Text('تصفية ${widget.hspType}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _apply,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Rating slider ───
          const Text('التقييم الأدنى'),
          Slider(
            value: (f['min_rating'] as double?) ?? 0.0,
            min: 0,
            max: 5,
            divisions: 5,
            label: ((f['min_rating'] as double?) ?? 0.0)
                .toStringAsFixed(1),
            onChanged: (v) => setState(() => f['min_rating'] = v),
          ),
          const SizedBox(height: 16),

          // ─── Address dropdown ───
          const Text('المنطقة'),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: (f['address_kw'] as String?)?.isEmpty ?? true
                ? null
                : (f['address_kw'] as String),
            hint: const Text('اختَر المنطقة'),
            items: _districts
                .map((d) => DropdownMenuItem(
              value: d.toLowerCase(),
              child: Text(d),
            ))
                .toList(),
            onChanged: (sel) => setState(() {
              f['address_kw'] = sel ?? '';
            }),
          ),

          const SizedBox(height: 16),

          // ─── Person‐only gender checkboxes ───
          if (isPerson) ...[
            CheckboxListTile(
              title: const Text('ذكر'),
              value: f['sex_male'] as bool? ?? false,
              onChanged: (v) => setState(() => f['sex_male'] = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('أنثى'),
              value: f['sex_female'] as bool? ?? false,
              onChanged: (v) => setState(() => f['sex_female'] = v ?? false),
            ),
            const SizedBox(height: 16),
          ],

          // ─── Apply button ───
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red,
            ),
            onPressed: _apply,
            child: const Text('تطبيق الفلتر'),
          ),
        ],
      ),
    );
  }
}
