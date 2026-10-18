import 'json.dart';

final class ReservationStatusDto {
  const ReservationStatusDto({required this.kind, this.by, this.at, this.reason});

  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const cancelled = 'cancelled';
  static const arrived = 'arrived';

  final String kind;
  final String? by;
  final DateTime? at;
  final String? reason;

  Map<String, Object?> toJson() => {
    'kind': kind,
    'by': ?by,
    if (at case final at?) 'at': instantToJson(at),
    'reason': ?reason,
  };

  factory ReservationStatusDto.fromJson(Map<String, Object?> json) => ReservationStatusDto(
    kind: jsonString(json, 'kind'),
    by: jsonOptionalString(json, 'by'),
    at: jsonOptionalInstant(json, 'at'),
    reason: jsonOptionalString(json, 'reason'),
  );
}

final class ReservationDto {
  const ReservationDto({
    required this.id,
    required this.guestId,
    required this.start,
    required this.partySize,
    required this.status,
    required this.createdAt,
    this.note,
    this.tableId,
    this.enteredBy,
  });

  final String id;
  final String guestId;
  final DateTime start;
  final int partySize;
  final ReservationStatusDto status;
  final DateTime createdAt;
  final String? note;
  final String? tableId;
  final String? enteredBy;

  Map<String, Object?> toJson() => {
    'id': id,
    'guestId': guestId,
    'start': instantToJson(start),
    'partySize': partySize,
    'status': status.toJson(),
    'createdAt': instantToJson(createdAt),
    'note': ?note,
    'tableId': ?tableId,
    'enteredBy': ?enteredBy,
  };

  factory ReservationDto.fromJson(Map<String, Object?> json) => ReservationDto(
    id: jsonString(json, 'id'),
    guestId: jsonString(json, 'guestId'),
    start: jsonInstant(json, 'start'),
    partySize: jsonInt(json, 'partySize'),
    status: ReservationStatusDto.fromJson(jsonObject(json['status'])),
    createdAt: jsonInstant(json, 'createdAt'),
    note: jsonOptionalString(json, 'note'),
    tableId: jsonOptionalString(json, 'tableId'),
    enteredBy: jsonOptionalString(json, 'enteredBy'),
  );
}

final class NewReservationDto {
  const NewReservationDto({required this.guestId, required this.start, required this.partySize, this.note});

  final String guestId;
  final DateTime start;
  final int partySize;
  final String? note;

  Map<String, Object?> toJson() => {
    'guestId': guestId,
    'start': instantToJson(start),
    'partySize': partySize,
    'note': ?note,
  };

  factory NewReservationDto.fromJson(Map<String, Object?> json) => NewReservationDto(
    guestId: jsonString(json, 'guestId'),
    start: jsonInstant(json, 'start'),
    partySize: jsonInt(json, 'partySize'),
    note: jsonOptionalString(json, 'note'),
  );
}

final class CancellationDto {
  const CancellationDto({required this.reason});

  final String reason;

  Map<String, Object?> toJson() => {'reason': reason};

  factory CancellationDto.fromJson(Map<String, Object?> json) => CancellationDto(reason: jsonString(json, 'reason'));
}
