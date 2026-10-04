import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';

@immutable
final class PartySize {
  const PartySize._(this.value);

  static const min = 1;
  static const max = 12;

  final int value;

  static Result<PartySize> parse(int value) {
    if (value < min || value > max) return Failure(InvalidPartySize(value));
    return Success(PartySize._(value));
  }

  @override
  bool operator ==(Object other) => other is PartySize && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PartySize($value)';
}
