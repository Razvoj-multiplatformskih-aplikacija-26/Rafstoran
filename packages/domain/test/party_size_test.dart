import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('R2 · PartySize', () {
    test('accepts one and twelve people', () {
      expect(PartySize.parse(1).valueOrNull?.value, 1);
      expect(PartySize.parse(12).valueOrNull?.value, 12);
    });

    test('rejects zero and thirteen people', () {
      expect(PartySize.parse(0), const Failure<PartySize>(InvalidPartySize(0)));
      expect(PartySize.parse(13), const Failure<PartySize>(InvalidPartySize(13)));
    });
  });
}
