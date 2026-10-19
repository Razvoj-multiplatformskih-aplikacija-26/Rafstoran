import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  test('a phone guest needs a name of up to 60 characters and a number of 6 to 15 digits', () {
    expect(ContactGuest.parse(name: '  Ana   Petrović ', phone: '064 123-4567').valueOrNull?.name.text, 'Ana Petrović');
    expect(ContactGuest.parse(name: 'Ana', phone: '+381 64 123 4567').valueOrNull?.phone.value, '+381641234567');
    expect(ContactGuest.parse(name: '   ', phone: '0641234567'), const Failure<ContactGuest>(InvalidGuestName(0)));
    expect(ContactGuest.parse(name: 'A' * 61, phone: '0641234567'), const Failure<ContactGuest>(InvalidGuestName(61)));
    expect(ContactGuest.parse(name: 'Ana', phone: '12345').isSuccess, isFalse);
    expect(ContactGuest.parse(name: 'Ana', phone: '123456').isSuccess, isTrue);
    expect(ContactGuest.parse(name: 'Ana', phone: '1' * 16).isSuccess, isFalse);
    expect(ContactGuest.parse(name: 'Ana', phone: '064 12a 4567'), const Failure<ContactGuest>(InvalidPhoneNumber()));
  });
}
