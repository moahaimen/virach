import 'package:flutter/material.dart';

import '../feauted_section_widget.dart';
import '../header_widgets/header_section_widget.dart';
import '../medical_insurance.dart';
import '../offers_item_widget.dart';
import '../service_item_widget.dart';
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeaderSection(),
          FeaturedSection(),
          ServiceItem(),
          Veterian(),
          OffersItem(),
        ],
      ),
    );
  }
}
