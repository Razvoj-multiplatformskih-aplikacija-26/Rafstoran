import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

extension DiningTableMapping on DiningTable {
  TableDto toDto() => TableDto(id: id.value, label: label, capacity: capacity, area: area.name);
}

extension TableDtoMapping on TableDto {
  DiningTable toDomain() =>
      DiningTable(id: DiningTableId(id), label: label, capacity: capacity, area: TableArea.values.byName(area));
}

extension OpeningHoursMapping on OpeningHours {
  OpeningHoursDto toDto() => OpeningHoursDto(
    timeZone: location.name,
    days: [
      for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
        if (forWeekday(weekday) case final hours?)
          DayHoursDto(weekday: weekday, open: hours.open.toString(), close: hours.close.toString()),
    ],
  );
}

extension OpeningHoursDtoMapping on OpeningHoursDto {
  OpeningHours toDomain() => OpeningHours({
    for (final day in days) day.weekday: DayHours(open: _localTime(day.open), close: _localTime(day.close)),
  }, timeZone: timeZone);
}

extension SlotAvailabilityMapping on SlotAvailability {
  SlotDto toDto() => SlotDto(start: slot.start, freeTables: freeTables);
}

extension SlotDtoMapping on SlotDto {
  SlotAvailability toDomain() => SlotAvailability(slot: TimeSlot.existing(start), freeTables: freeTables);
}

extension UserMapping on User {
  UserDto toDto() => UserDto(id: id.value, username: username, role: role.name);
}

extension UserDtoMapping on UserDto {
  User toDomain() => User(id: UserId(id), username: username, role: Role.values.byName(role));
}

String dayToJson(DateTime localDay) =>
    '${localDay.year.toString().padLeft(4, '0')}-${localDay.month.toString().padLeft(2, '0')}-'
    '${localDay.day.toString().padLeft(2, '0')}';

DateTime dayFromJson(String value) {
  final parsed = DateTime.parse(value);
  return DateTime(parsed.year, parsed.month, parsed.day);
}

LocalTime _localTime(String value) => switch (value.split(':')) {
  [final hour, final minute] => LocalTime(int.parse(hour), int.parse(minute)),
  _ => throw FormatException('Expected a time like 12:30', value),
};
