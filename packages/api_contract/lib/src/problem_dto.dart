import 'json.dart';
import 'reservation_dto.dart';

final class ProblemDto {
  const ProblemDto({required this.status, required this.code, required this.title, this.value, this.from, this.to});

  static const mediaType = 'application/problem+json';

  final int status;
  final String code;
  final String title;
  final int? value;
  final ReservationStatusDto? from;
  final ReservationStatusDto? to;

  Map<String, Object?> toJson() => {
    'type': 'about:blank',
    'title': title,
    'status': status,
    'code': code,
    'value': ?value,
    if (from case final from?) 'from': from.toJson(),
    if (to case final to?) 'to': to.toJson(),
  };

  factory ProblemDto.fromJson(Map<String, Object?> json) => ProblemDto(
    status: jsonInt(json, 'status'),
    code: jsonString(json, 'code'),
    title: jsonOptionalString(json, 'title') ?? '',
    value: jsonOptionalInt(json, 'value'),
    from: json['from'] == null ? null : ReservationStatusDto.fromJson(jsonObject(json['from'])),
    to: json['to'] == null ? null : ReservationStatusDto.fromJson(jsonObject(json['to'])),
  );
}
