import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/slot_repository.dart';

final class GetAvailableSlots {
  const GetAvailableSlots({required this.slots, required this.clock});

  final SlotRepository slots;
  final Clock clock;

  Future<List<SlotAvailability>> call({
    required User by,
    required DateTime localDay,
    required PartySize partySize,
  }) async {
    final all = await slots.availableSlots(localDay: localDay, partySize: partySize);
    final now = clock.now();
    return [
      for (final availability in all)
        if (mayBook(availability.slot, by: by, now: now)) availability,
    ];
  }
}
