import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _formatter = NumberFormat.decimalPattern('en_IN');

String fmtAmount(int amount) => _formatter.format(amount);

int? tryParseAmount(String text) {
  final clean = text.replaceAll(',', '');
  if (clean.isEmpty) return null;
  return int.tryParse(clean);
}

int parseAmount(String text) {
  final clean = text.replaceAll(',', '');
  return int.parse(clean);
}

class IndianAmountInputFormatter extends TextInputFormatter {
  const IndianAmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final amount = int.tryParse(digitsOnly);
    if (amount == null) return oldValue;

    final formatted = _formatter.format(amount);

    final oldCursorPos = newValue.selection.baseOffset;
    final oldTextUpToCursor = oldCursorPos >= 0 && oldCursorPos <= newValue.text.length
        ? newValue.text.substring(0, oldCursorPos)
        : newValue.text;
    final digitsBeforeCursor =
        oldTextUpToCursor.replaceAll(RegExp(r'[^0-9]'), '').length;

    var newCursorPos = formatted.length;
    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
        digitsSeen++;
      }
      if (digitsSeen == digitsBeforeCursor) {
        newCursorPos = i + 1;
        break;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}
