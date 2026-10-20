import 'package:api_contract/api_contract.dart';
import 'package:test/test.dart';

void main() {
  test('an older client reads a reservation that carries a field it does not know yet', () {
    final fromNewerServer = {
      'id': 'r-1',
      'guest': {'kind': 'account', 'id': 'u-ana'},
      'start': '2026-10-30T18:00:00.000Z',
      'partySize': 4,
      'status': {'kind': 'pending'},
      'createdAt': '2026-10-28T09:15:00.000Z',
      'highChairs': 2,
    };

    final reservation = ReservationDto.fromJson(fromNewerServer);

    expect(reservation.id, 'r-1');
    expect(reservation.partySize, 4);
    expect(() => ReservationDto.fromJson({...fromNewerServer}..remove('start')), throwsFormatException);
  });
}
