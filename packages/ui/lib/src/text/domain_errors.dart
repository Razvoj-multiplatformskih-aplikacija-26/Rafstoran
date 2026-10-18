import 'package:domain/domain.dart';

import 'serbian.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    NoteTooLong(:final max) => 'Napomena može imati najviše $max znakova.',
    InvalidPartySize(:final min, :final max) => 'Broj osoba je od $min do $max.',
    SlotInPast() => 'Termin je prošao.',
    SlotNotOnHalfHour() => 'Termin počinje na pun sat ili pola sata.',
    OutsideOpeningHours() => 'Termin je van radnog vremena.',
    CancellationTooLate(:final notice) => 'Otkazivanje je moguće najkasnije ${hoursLabel(notice.inHours)} pre termina.',
    TooSoonToBook() => 'Termin se rezerviše najkasnije 2 sata unapred.',
    ReservationStarted() => 'Termin je već počeo.',
    ReservationNotStarted() => 'Termin još nije počeo.',
    ArrivalOutsideSlot() => 'Dolazak se beleži od sat vremena pre termina do njegovog kraja.',
    InvalidTransition() => 'Ova promena rezervacije nije moguća.',
    NoTableAvailable() => 'Nema slobodnog stola za izabrani termin.',
    GuestAlreadyBooked() => 'Gost već ima rezervaciju u to vreme.',
    InvalidGuestName(:final length) =>
      length == 0 ? 'Ime gosta je obavezno.' : 'Ime gosta može imati najviše ${GuestName.maxLength} znakova.',
    InvalidPhoneNumber() => 'Broj telefona ima od ${PhoneNumber.minDigits} do ${PhoneNumber.maxDigits} cifara.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    NotFound() => 'Rezervacija nije pronađena.',
  };
}
