import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Faqat raqamlarni olib qolamiz
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Maksimal 16 ta raqam
    if (newText.length > 16) {
      newText = newText.substring(0, 16);
    }

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' '); // Har 4 raqamdan keyin bitta bo'shliq
      }
      buffer.write(newText[i]);
    }

    String formattedText = buffer.toString();

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
