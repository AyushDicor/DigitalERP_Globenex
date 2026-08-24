import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Shared quantity-input helpers
//
// ERP stock quantities are fractional (0.5 KG, 12.75 MTR, 1.250 TON), so every
// qty field must accept a decimal point. Use these three helpers instead of
// TextInputType.number + FilteringTextInputFormatter.digitsOnly.
// ═══════════════════════════════════════════════════════════════════════════════

/// Keyboard with a decimal point (iOS shows the "." key, Android the decimal pad).
const TextInputType kQtyKeyboard =
    TextInputType.numberWithOptions(decimal: true);

/// Digits plus one optional decimal point, up to 3 decimal places.
final List<TextInputFormatter> kQtyFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
];

/// Formats a qty for display: keeps real decimals, drops a trailing ".0".
/// 34 -> "34", 34.5 -> "34.5", 12.750 -> "12.75"
String qtyText(num? value, {int decimals = 3}) {
  final v = (value ?? 0).toDouble();
  if (v == v.roundToDouble()) return v.toInt().toString();
  var s = v.toStringAsFixed(decimals);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}
