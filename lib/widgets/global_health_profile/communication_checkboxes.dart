import 'package:flutter/material.dart';

class CommunicationCheckboxes extends StatefulWidget {
  final bool acceptAudioCalls;
  final bool acceptVideoCalls;
  final Function(bool, bool)
      onCheckboxChanged; // Function to handle checkbox changes

  const CommunicationCheckboxes({
    required this.acceptAudioCalls,
    required this.acceptVideoCalls,
    required this.onCheckboxChanged,
  });

  @override
  _CommunicationCheckboxesState createState() =>
      _CommunicationCheckboxesState();
}

class _CommunicationCheckboxesState extends State<CommunicationCheckboxes> {
  bool acceptAudioCalls = false;
  bool acceptVideoCalls = false;

  @override
  void initState() {
    super.initState();
    acceptAudioCalls = widget.acceptAudioCalls;
    acceptVideoCalls = widget.acceptVideoCalls;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'هل تقبل بعمل المراجعات عن طريق:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        CheckboxListTile(
          title: const Text('المكالمات الصوتية'),
          value: acceptAudioCalls,
          onChanged: (newValue) {
            setState(() {
              acceptAudioCalls = newValue!;
              widget.onCheckboxChanged(acceptAudioCalls, acceptVideoCalls);
            });
          },
        ),
        CheckboxListTile(
          title: const Text('المكالمات الفيديو'),
          value: acceptVideoCalls,
          onChanged: (newValue) {
            setState(() {
              acceptVideoCalls = newValue!;
              widget.onCheckboxChanged(acceptAudioCalls, acceptVideoCalls);
            });
          },
        ),
      ],
    );
  }
}
