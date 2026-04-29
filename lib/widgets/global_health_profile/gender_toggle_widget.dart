import 'package:flutter/material.dart';

class GenderToggleWidget extends StatelessWidget {
  final int selectedGender;
  final ValueChanged<int> onToggle;

  GenderToggleWidget({required this.selectedGender, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ToggleButtons(
          isSelected: [selectedGender == 0, selectedGender == 1],
          onPressed: (int index) {
            onToggle(index);
          },
          borderRadius: BorderRadius.circular(10),
          fillColor: Colors.red, // Background color for the selected state
          selectedColor:
              Colors.grey, // Text and icon color for the selected state
          color: Colors.grey, // Text and icon color for the unselected state
          borderColor: Colors.grey.shade300, // Light grey border for buttons
          selectedBorderColor:
              Colors.blue, // Border color when a button is selected
          splashColor: Colors.transparent, // Remove the splash effect
          highlightColor: Colors.transparent, // Remove highlight on press
          constraints: const BoxConstraints(minHeight: 50, minWidth: 150),
          children: [
            Row(
              children: [
                Icon(
                  Icons.male,
                  color: selectedGender == 0 ? Colors.white : Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  'ذكر',
                  style: TextStyle(
                    color: selectedGender == 0 ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.female,
                  color: selectedGender == 1 ? Colors.white : Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  'أنثى',
                  style: TextStyle(
                    color: selectedGender == 1 ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
