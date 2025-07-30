import 'package:flutter/services.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    if (newText.length > 5) {
      return oldValue;
    }

    var newString = newText.replaceAll('/', '');
    if (newString.length > 2) {
      newString = '${newString.substring(0, 2)}/${newString.substring(2)}';
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
