import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

void callPharmacist(BuildContext context) async {
  const url = 'tel:009647721837469';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
