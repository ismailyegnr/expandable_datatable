import 'package:flutter/material.dart';

class EditSwitch extends StatefulWidget {
  const EditSwitch({super.key});

  @override
  State<EditSwitch> createState() => _EditSwitchState();
}

class _EditSwitchState extends State<EditSwitch> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: light,
      onChanged: (bool value) {
        setState(() {
          light = value;
        });
      },
    );
  }
}
