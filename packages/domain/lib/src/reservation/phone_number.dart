import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';

@immutable
final class PhoneNumber {
  const PhoneNumber._(this.value);

  static const minDigits = 6;
  static const maxDigits = 15;

  final String value;

  static Result<PhoneNumber> parse(String input) {
    final compact = input.replaceAll(RegExp(r'[\s\-/().]'), '');
    final digits = compact.startsWith('+') ? compact.substring(1) : compact;
    final valid = RegExp(r'^\d+$').hasMatch(digits) && digits.length >= minDigits && digits.length <= maxDigits;
    if (!valid) return const Failure(InvalidPhoneNumber());
    return Success(PhoneNumber._(compact));
  }

  @override
  bool operator ==(Object other) => other is PhoneNumber && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PhoneNumber($value)';
}
