import 'package:domain/domain.dart';

final class ReservationRequest {
  const ReservationRequest({
    required this.guest,
    required this.slot,
    required this.partySize,
    required this.status,
    this.note,
    this.enteredBy,
  });

  final ReservationGuest guest;
  final TimeSlot slot;
  final PartySize partySize;
  final ReservationStatus status;
  final ReservationNote? note;
  final UserId? enteredBy;
}
