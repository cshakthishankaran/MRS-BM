import 'package:flutter/material.dart';

class MyTextFieldWithDropdown extends StatefulWidget {
  final List<String> recentItems; // List of recent entries
  final String labelText; // Label text for the TextField
  final TextEditingController controller; // Controller for the TextField

  MyTextFieldWithDropdown({
    required this.recentItems,
    required this.labelText,
    required this.controller,
  });

  @override
  _MyTextFieldWithDropdownState createState() => _MyTextFieldWithDropdownState();
}

class _MyTextFieldWithDropdownState extends State<MyTextFieldWithDropdown> {
  String? selectedRecentItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.labelText,
            ),
          ),
        ),
        DropdownButton<String>(
          value: selectedRecentItem,
          hint: Text('Recent'),
          icon: Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            setState(() {
              selectedRecentItem = newValue;
              widget.controller.text = newValue!; // Update TextField with selected item
            });
          },
          items: widget.recentItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
