import 'package:flutter_test/flutter_test.dart';
import 'package:ogun_360/number_parser.dart';

void main() {
  test('accepts localized decimal punctuation and digits', () {
    expect(parsePortion('١٢٫٥'), 12.5);
    expect(parsePortion('۱۲,۵'), 12.5);
    expect(parsePortion('12.5'), 12.5);
    expect(parsePortion('  20 '), 20);
  });
  test('rejects ambiguous and malicious numeric inputs', () {
    for (final value in ['-1', '', '1,000.9', '1.2.3', '1e6', 'NaN',
      'Infinity', '٠٬١٠٠', '0', '99999999999999999999999999999999999999999999999']) {
      expect(parsePortion(value), isNull, reason: value);
    }
  });
  test('zero allowed only when explicitly requested', () {
    expect(parsePortion('0', min: 0), 0);
    expect(parsePortion('0'), isNull);
  });
}
