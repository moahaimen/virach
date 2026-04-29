import 'package:flutter/material.dart';

import '../../../../constansts/constants.dart';
import '../model/filter_manager_model.dart';

class FilterSectionWidget extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> filterKeys;
  final FilterManager filterManager;

  const FilterSectionWidget({
    Key? key,
    required this.title,
    required this.options,
    required this.filterKeys,
    required this.filterManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: kButtonTextStyle),
        ),
        ...List.generate(options.length, (index) {
          return CheckboxListTile(
            title: Text(options[index]),
            value: filterManager.filters[filterKeys[index]] ?? false,
            onChanged: (bool? value) {
              filterManager.updateFilter(filterKeys[index], value);
            },
          );
        }),
        const Divider(),
      ],
    );
  }
}
