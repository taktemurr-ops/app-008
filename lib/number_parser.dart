/// Parses user-entered numbers using ASCII, Arabic-Indic or Persian digits.
/// Supports decimal comma, dot and Arabic decimal separator, but not ambiguous
/// thousands-grouped values. Length is capped to avoid adversarial input.
double? parsePortion(String source, {double min = 0.01, double max = 100000}) {
  final input = source.trim();
  if (input.isEmpty || input.length > 48) return null;
  final chars = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      chars.writeCharCode(48 + rune - 0x0660);
    } else if (rune >= 0x06f0 && rune <= 0x06f9) {
      chars.writeCharCode(48 + rune - 0x06f0);
    } else if (rune == 0x066b || rune == 44) {
      chars.write('.');
    } else if (rune == 0x066c || rune == 0x200f || rune == 0x200e) {
      // Arabic group separators and Unicode direction controls are rejected.
      return null;
    } else if (rune >= 48 && rune <= 57 || rune == 46) {
      chars.writeCharCode(rune);
    } else {
      return null;
    }
  }
  final normalized = chars.toString();
  if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(normalized)) return null;
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite || value < min || value > max) return null;
  return value;
}
