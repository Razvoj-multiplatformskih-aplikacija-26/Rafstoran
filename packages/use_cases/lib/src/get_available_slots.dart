import 'package:domain/domain.dart';

import 'ports/slot_repository.dart';

final class GetAvailableSlots {
  const GetAvailableSlots({required this.slots});

  final SlotRepository slots;

  Future<List<SlotAvailability>> call({required DateTime localDay, required PartySize partySize}) =>
      slots.availableSlots(localDay: localDay, partySize: partySize);
}
