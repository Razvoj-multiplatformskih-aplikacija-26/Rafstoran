import 'package:domain/domain.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    NoteTooLong() => 'Napomena može imati najviše ${ReservationNote.maxLength} znakova.',
    InvalidPartySize() => 'Broj osoba je od ${PartySize.min} do ${PartySize.max}.',
    SlotInPast() => 'Termin je prošao.',
    SlotNotOnHalfHour() => 'Termin počinje na pun sat ili pola sata.',
    OutsideOpeningHours() => 'Termin je van radnog vremena.',
    CancellationTooLate() => 'Otkazivanje je moguće najkasnije 2 sata pre termina.',
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
