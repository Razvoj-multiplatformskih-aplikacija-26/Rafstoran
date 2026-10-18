import 'dart:convert';
import 'dart:io';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> arguments) async {
  final server = Uri.parse(arguments.isEmpty ? 'http://localhost:8080' : arguments.first);
  final day = DateTime.now().add(const Duration(days: 3));
  final slots = await http.get(
    server.replace(path: ApiPaths.slots, queryParameters: {ApiQuery.day: dayToJson(day), ApiQuery.partySize: '10'}),
  );
  final lastTable = [
    for (final slot in jsonDecode(slots.body) as List<Object?>) SlotDto.fromJson(slot! as Map<String, Object?>),
  ].firstWhere((slot) => slot.freeTables == 1);
  stdout.writeln('Two guests reserve the last table for ten at ${lastTable.start.toLocal()}');

  Future<String> reserve(String guest) async {
    final response = await http.post(
      server.replace(path: ApiPaths.reservations),
      headers: {'Content-Type': 'application/json', ApiHeaders.userId: guest},
      body: jsonEncode(NewReservationDto(guestId: guest, start: lastTable.start, partySize: 10).toJson()),
    );
    final body = jsonDecode(response.body) as Map<String, Object?>;
    return '$guest: ${response.statusCode} ${body['code'] ?? 'table ${body['tableId']}'}';
  }

  final answers = await Future.wait([reserve('u-ana'), reserve('u-marko')]);
  answers.forEach(stdout.writeln);
}
