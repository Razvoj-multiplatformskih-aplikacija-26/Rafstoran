part of 'new_reservation_bloc.dart';

sealed class NewReservationState extends Equatable {
  const NewReservationState({required this.accounts, this.account, this.name = '', this.phone = '', this.slot});

  final List<User> accounts;
  final User? account;
  final String name;
  final String phone;
  final TimeSlot? slot;

  @override
  List<Object?> get props => [accounts, account, name, phone, slot];

  @override
  String toString() => '$runtimeType';

  ReservationGuest? get guest => switch (account) {
    final account? => AccountGuest(account.id),
    null => ContactGuest.parse(name: name, phone: phone).valueOrNull,
  };

  DomainError? get nameError => name.trim().isEmpty ? null : GuestName.parse(name).errorOrNull;

  DomainError? get phoneError => phone.trim().isEmpty ? null : PhoneNumber.parse(phone).errorOrNull;

  bool get canContinue => guest != null && slot != null;

  List<User> suggestionsFor(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    return [
      for (final account in accounts)
        if (account.username.toLowerCase().contains(needle)) account,
    ];
  }

  NewReservationEntering entering({
    User? account,
    bool clearAccount = false,
    String? name,
    String? phone,
    TimeSlot? slot,
    bool clearSlot = false,
  }) {
    return NewReservationEntering(
      accounts: accounts,
      account: clearAccount ? null : (account ?? this.account),
      name: name ?? this.name,
      phone: phone ?? this.phone,
      slot: clearSlot ? null : (slot ?? this.slot),
    );
  }
}

final class NewReservationEntering extends NewReservationState {
  const NewReservationEntering({required super.accounts, super.account, super.name, super.phone, super.slot});
}

final class NewReservationConfirming extends NewReservationState {
  const NewReservationConfirming({
    required super.accounts,
    super.account,
    super.name,
    super.phone,
    required TimeSlot super.slot,
  });

  @override
  ReservationGuest get guest => super.guest!;

  @override
  TimeSlot get slot => super.slot!;
}
