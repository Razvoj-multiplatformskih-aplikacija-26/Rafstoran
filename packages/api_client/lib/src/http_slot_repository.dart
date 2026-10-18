import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpSlotRepository implements SlotRepository {
  const HttpSlotRepository(this._api);

  final ApiClient _api;

  @override
  Future<OpeningHours> openingHours() async {
    final answer = await _api.get(ApiPaths.openingHours);
    return accepted(answer, (json) => OpeningHoursDto.fromJson(object(json)).toDomain());
  }

  @override
  Future<List<SlotAvailability>> availableSlots({required DateTime localDay, required PartySize partySize}) async {
    final answer = await _api.get(
      ApiPaths.slots,
      query: {ApiQuery.day: dayToJson(localDay), ApiQuery.partySize: '${partySize.value}'},
    );
    return accepted(answer, (json) => [for (final item in objects(json)) SlotDto.fromJson(item).toDomain()]);
  }
}
