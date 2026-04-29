import 'package:flutter/material.dart';
import 'package:racheeta/widgets/offers/category.dart';

class LargeCategoryItem extends StatelessWidget {
  final Category category;
  final TextStyle textStyle;

  LargeCategoryItem({required this.category, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: screenWidth * 0.45,
            height: screenWidth * 0.52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: AssetImage(category.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            category.name,
            style: textStyle.copyWith(color: Colors.black, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
