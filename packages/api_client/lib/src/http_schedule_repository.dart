import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpScheduleRepository implements ScheduleRepository {
  const HttpScheduleRepository(this._api);

  final ApiClient _api;

  @override
  Future<DailySchedule> scheduleFor(DateTime localDay) async {
    final answer = await _api.get(ApiPaths.schedule, query: {ApiQuery.day: dayToJson(localDay)});
    return accepted(answer, (json) => ScheduleDto.fromJson(object(json)).toDomain());
  }
}
