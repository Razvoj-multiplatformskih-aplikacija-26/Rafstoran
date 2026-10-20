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
    TooSoonToBook(:final notice) => 'Termin se rezerviše najkasnije ${hoursLabel(notice.inHours)} unapred.',
    ReservationStarted() => 'Termin je već počeo.',
    ReservationNotStarted() => 'Termin još nije počeo.',
    ArrivalOutsideSlot(:final early) =>
      'Dolazak se beleži najranije ${hoursLabel(early.inHours)} pre termina i najkasnije do njegovog kraja.',
    InvalidTransition() => 'Ova promena rezervacije nije moguća.',
    NoTableAvailable() => 'Nema slobodnog stola za izabrani termin.',
    GuestAlreadyBooked() => 'Gost već ima rezervaciju u to vreme.',
    InvalidGuestName(:final length, :final max) =>
      length == 0 ? 'Ime gosta je obavezno.' : 'Ime gosta može imati najviše $max znakova.',
    InvalidPhoneNumber(:final min, :final max) => 'Broj telefona ima od $min do $max cifara.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    NotFound() => 'Rezervacija nije pronađena.',
  };
}
