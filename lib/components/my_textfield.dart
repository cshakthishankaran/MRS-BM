import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:searchfield/searchfield.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final GestureTapCallback? onTap;
  final bool isDropdown;
  final bool isSearchField;
  final List<String>? dropdownItems;
  final String? selectedItem;
  final ValueChanged<String?>? onChanged;
  // final List<SearchFieldListItem<String>>? Function(String)? onSearchTextChange;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final bool readOnly;
  // Function(dynamic query) onSearchTextChange;
  // final List<String> searchFieldSuggestions;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters = const [],
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.isDropdown = false,
    this.dropdownItems,
    this.selectedItem,
    this.onChanged,
    this.suffixIcon,
    this.focusNode,
    this.readOnly = false,
    this.isSearchField = false,
    // this.searchFieldSuggestions =  const [],

  }) : super(key: key);




  @override
  Widget build(BuildContext context) {
    return isDropdown
        ? DropdownButtonFormField<String>(
      decoration: InputDecoration(
          filled: true,
          fillColor:  Colors.white70,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color : Theme.of(context).colorScheme.surface),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black87,
          )
      ),
      items: dropdownItems?.map(
              (String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      value: selectedItem,
      onChanged: onChanged,
    )
        :  TextField(
      controller: controller,
      focusNode : focusNode,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        labelText: hintText,
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: OutlineInputBorder(),
          filled: true,
          fillColor:  Colors.white70,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color : Theme.of(context).colorScheme.surface),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black38,
          ),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
    );
  }
}
