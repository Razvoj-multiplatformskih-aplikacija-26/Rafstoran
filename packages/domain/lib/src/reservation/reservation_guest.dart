import 'package:meta/meta.dart';

import '../identifiers.dart';
import '../result.dart';
import 'guest_name.dart';
import 'phone_number.dart';

sealed class ReservationGuest {
  const ReservationGuest();

  bool isAccount(UserId id) => switch (this) {
    AccountGuest(:final userId) => userId == id,
    ContactGuest() => false,
  };

  bool isSameGuestAs(ReservationGuest other) => switch ((this, other)) {
    (AccountGuest(userId: final mine), AccountGuest(userId: final theirs)) => mine == theirs,
    (ContactGuest(phone: final mine), ContactGuest(phone: final theirs)) => mine == theirs,
    _ => false,
  };
}

@immutable
final class AccountGuest extends ReservationGuest {
  const AccountGuest(this.userId);

  final UserId userId;

  @override
  bool operator ==(Object other) => other is AccountGuest && other.userId == userId;

  @override
  int get hashCode => Object.hash(AccountGuest, userId);

  @override
  String toString() => 'AccountGuest($userId)';
}

@immutable
final class ContactGuest extends ReservationGuest {
  const ContactGuest({required this.name, required this.phone});

  final GuestName name;
  final PhoneNumber phone;

  static Result<ContactGuest> parse({required String name, required String phone}) =>
      switch ((GuestName.parse(name), PhoneNumber.parse(phone))) {
        (Failure(:final error), _) || (_, Failure(:final error)) => Failure(error),
        (Success(value: final name), Success(value: final phone)) => Success(ContactGuest(name: name, phone: phone)),
      };

  @override
  bool operator ==(Object other) => other is ContactGuest && other.name == name && other.phone == phone;

  @override
  int get hashCode => Object.hash(name, phone);

  @override
  String toString() => 'ContactGuest(${name.text}, ${phone.value})';
}
