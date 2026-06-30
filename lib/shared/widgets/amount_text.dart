import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';

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
    final prefix = showSymbol ? AppConstants.currencySymbol : '';
    return '$prefix${fmtAmount(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatted, style: style);
  }
}
