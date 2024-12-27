import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 3})
      : assert(decimalRange > 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final newText = newValue.text;
    if (newText.contains('.') &&
        newText.substring(newText.indexOf('.') + 1).length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}
