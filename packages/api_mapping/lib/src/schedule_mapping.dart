import 'package:api_contract/api_contract.dart';
import 'package:use_cases/use_cases.dart';

import 'reservation_mapping.dart';
import 'restaurant_mapping.dart';

extension DailyScheduleMapping on DailySchedule {
  ScheduleDto toDto() => ScheduleDto(
    day: dayToJson(day),
    openingHours: openingHours.toDto(),
    tables: [for (final table in tables) table.toDto()],
    reservations: [for (final reservation in reservations) reservation.toDto()],
    guests: [for (final guest in guests.values) guest.toDto()],
    staff: [for (final member in staff.values) member.toDto()],
  );
}

extension ScheduleDtoMapping on ScheduleDto {
  DailySchedule toDomain() => DailySchedule(
    day: dayFromJson(day),
    openingHours: openingHours.toDomain(),
    tables: [for (final table in tables) table.toDomain()],
    reservations: [for (final reservation in reservations) reservation.toDomain()],
    guests: {for (final guest in guests.map((dto) => dto.toDomain())) guest.id: guest},
    staff: {for (final member in staff.map((dto) => dto.toDomain())) member.id: member},
  );
}
