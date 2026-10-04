import 'package:domain/domain.dart';

abstract interface class SlotRepository {
  Future<OpeningHours> openingHours();

  Future<List<SlotAvailability>> availableSlots({required DateTime localDay, required PartySize partySize});
}
