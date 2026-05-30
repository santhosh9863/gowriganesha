import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';

class AmountText extends StatelessWidget {
  final int amount;
  final TextStyle? style;
  final bool showSymbol;

  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.showSymbol = true,
  });

  String get _formatted {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    final prefix = showSymbol ? AppConstants.currencySymbol : '';
    return '$prefix${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatted, style: style);
  }
}
