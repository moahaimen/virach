import 'package:flutter/material.dart';

import '../../../common_screens/AddOfferForm.dart';
import '../../../common_screens/add_advertise_form.dart';

class ActionButtonsWidget extends StatelessWidget {
  final String userType;
  final String? userId;

  const ActionButtonsWidget({Key? key, required this.userType, this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            // child: ElevatedButton(
            //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => AddOfferForm(userType: userType)),
            //     );
            //   },
            //   child: const Text('اضف عرض او خصم',
            //       style: TextStyle(color: Colors.white)),
            // ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 120),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {}
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => CreateAdvertiseForm(
              //             userType: "doctor",
              //             hspId: 'doctorId'!,
              //           )),
              // );
              // },
              ,
              child: const Text('اضافة اعلان',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
