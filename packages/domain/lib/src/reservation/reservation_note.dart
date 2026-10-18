import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';

@immutable
final class ReservationNote {
  const ReservationNote._(this.text);

  static const maxLength = 200;

  final String text;

  int get length => text.characters.length;

  bool get isEmpty => text.isEmpty;

  static Result<ReservationNote> parse(String input) {
    final text = input.trim();
    final length = text.characters.length;
    if (length > maxLength) return Failure(NoteTooLong(length, max: maxLength));
    return Success(ReservationNote._(text));
  }

  @override
  bool operator ==(Object other) => other is ReservationNote && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ReservationNote("$text")';
}
