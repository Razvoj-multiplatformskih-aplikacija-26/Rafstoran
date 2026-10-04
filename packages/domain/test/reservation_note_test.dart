import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('R1 · ReservationNote', () {
    test('accepts a note of exactly 200 characters', () {
      expect(ReservationNote.parse('đ' * 200).valueOrNull?.length, 200);
    });

    test('rejects a note of 201 characters', () {
      expect(ReservationNote.parse('đ' * 201), const Failure<ReservationNote>(NoteTooLong(201)));
    });

    test('counts an emoji family as one character', () {
      expect(ReservationNote.parse('👨‍👩‍👧' * 200).valueOrNull?.length, 200);
    });
  });
}
