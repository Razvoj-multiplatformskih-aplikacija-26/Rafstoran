import 'package:domain/domain.dart';

final class ReservationRequest {
  const ReservationRequest({required this.guestId, required this.slot, required this.partySize, this.note});

  final UserId guestId;
  final TimeSlot slot;
  final PartySize partySize;
  final ReservationNote? note;
}
