import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';

@immutable
final class GuestName {
  const GuestName._(this.text);

  static const maxLength = 60;

  final String text;

  static Result<GuestName> parse(String input) {
    final text = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    final length = text.characters.length;
    if (length == 0 || length > maxLength) return Failure(InvalidGuestName(length, max: maxLength));
    return Success(GuestName._(text));
  }

  @override
  bool operator ==(Object other) => other is GuestName && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'GuestName("$text")';
}
