import 'json.dart';
import 'reservation_dto.dart';

final class TableDto {
  const TableDto({required this.id, required this.label, required this.capacity, required this.area});

  final String id;
  final String label;
  final int capacity;
  final String area;

  Map<String, Object?> toJson() => {'id': id, 'label': label, 'capacity': capacity, 'area': area};

  factory TableDto.fromJson(Map<String, Object?> json) => TableDto(
    id: jsonString(json, 'id'),
    label: jsonString(json, 'label'),
    capacity: jsonInt(json, 'capacity'),
    area: jsonString(json, 'area'),
  );
}

final class DayHoursDto {
  const DayHoursDto({required this.weekday, required this.open, required this.close});

  final int weekday;
  final String open;
  final String close;

  Map<String, Object?> toJson() => {'weekday': weekday, 'open': open, 'close': close};

  factory DayHoursDto.fromJson(Map<String, Object?> json) =>
      DayHoursDto(weekday: jsonInt(json, 'weekday'), open: jsonString(json, 'open'), close: jsonString(json, 'close'));
}

final class OpeningHoursDto {
  const OpeningHoursDto({required this.timeZone, required this.days});

  final String timeZone;
  final List<DayHoursDto> days;

  Map<String, Object?> toJson() => {
    'timeZone': timeZone,
    'days': [for (final day in days) day.toJson()],
  };

  factory OpeningHoursDto.fromJson(Map<String, Object?> json) => OpeningHoursDto(
    timeZone: jsonString(json, 'timeZone'),
    days: [for (final day in jsonObjects(json, 'days')) DayHoursDto.fromJson(day)],
  );
}

final class SlotDto {
  const SlotDto({required this.start, required this.freeTables});

  final DateTime start;
  final int freeTables;

  Map<String, Object?> toJson() => {'start': instantToJson(start), 'freeTables': freeTables};

  factory SlotDto.fromJson(Map<String, Object?> json) =>
      SlotDto(start: jsonInstant(json, 'start'), freeTables: jsonInt(json, 'freeTables'));
}

final class UserDto {
  const UserDto({required this.id, required this.username, required this.role});

  final String id;
  final String username;
  final String role;

  Map<String, Object?> toJson() => {'id': id, 'username': username, 'role': role};

  factory UserDto.fromJson(Map<String, Object?> json) =>
      UserDto(id: jsonString(json, 'id'), username: jsonString(json, 'username'), role: jsonString(json, 'role'));
}

final class ScheduleDto {
  const ScheduleDto({
    required this.day,
    required this.openingHours,
    required this.tables,
    required this.reservations,
    required this.guests,
    required this.staff,
  });

  final String day;
  final OpeningHoursDto openingHours;
  final List<TableDto> tables;
  final List<ReservationDto> reservations;
  final List<UserDto> guests;
  final List<UserDto> staff;

  Map<String, Object?> toJson() => {
    'day': day,
    'openingHours': openingHours.toJson(),
    'tables': [for (final table in tables) table.toJson()],
    'reservations': [for (final reservation in reservations) reservation.toJson()],
    'guests': [for (final guest in guests) guest.toJson()],
    'staff': [for (final member in staff) member.toJson()],
  };

  factory ScheduleDto.fromJson(Map<String, Object?> json) => ScheduleDto(
    day: jsonString(json, 'day'),
    openingHours: OpeningHoursDto.fromJson(jsonObject(json['openingHours'])),
    tables: [for (final table in jsonObjects(json, 'tables')) TableDto.fromJson(table)],
    reservations: [for (final r in jsonObjects(json, 'reservations')) ReservationDto.fromJson(r)],
    guests: [for (final guest in jsonObjects(json, 'guests')) UserDto.fromJson(guest)],
    staff: [for (final member in jsonObjects(json, 'staff')) UserDto.fromJson(member)],
  );
}
