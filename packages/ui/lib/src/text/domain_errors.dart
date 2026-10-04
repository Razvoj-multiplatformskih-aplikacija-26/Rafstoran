import 'package:domain/domain.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    NoteTooLong() => 'Napomena može imati najviše ${ReservationNote.maxLength} znakova.',
    InvalidPartySize() => 'Broj osoba je od ${PartySize.min} do ${PartySize.max}.',
    SlotInPast() => 'Termin je prošao.',
    SlotNotOnHalfHour() => 'Termin počinje na pun sat ili pola sata.',
    OutsideOpeningHours() => 'Termin je van radnog vremena.',
    CancellationTooLate() => 'Otkazivanje je moguće najkasnije 2 sata pre termina.',
    InvalidTransition() => 'Ova promena rezervacije nije moguća.',
    NoTableAvailable() => 'Nema slobodnog stola za izabrani termin.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    NotFound() => 'Rezervacija nije pronađena.',
  };
}
