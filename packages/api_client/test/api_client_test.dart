import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

ReservationRequest lastTableFor(String guest) => ReservationRequest(
  guest: AccountGuest(UserId(guest)),
  status: const Pending(),
  slot: TimeSlot.existing(DateTime.utc(2026, 10, 30, 18)),
  partySize: PartySize.parse(10).valueOrNull!,
);

HttpReservationRepository reservationsOver(MockClient server, {TokenStore? tokens}) => HttpReservationRepository(
  ApiClient(
    baseUri: Uri.parse('http://localhost:8080'),
    tokens: tokens,
    httpClient: server,
    keepsSessionInCookie: false,
  ),
);

void main() {
  test('the server taking the last table first reaches the client as NoTableAvailable', () async {
    final tokens = MemoryTokenStore();
    await tokens.write('token-of-ana');
    final server = MockClient((request) async {
      expect(request.url.path, ApiPaths.reservations);
      expect(request.headers['Authorization'], 'Bearer token-of-ana');
      final problem = const ProblemDto(status: 409, code: ErrorCodes.noTableAvailable, title: 'No table available');
      return http.Response(jsonEncode(problem.toJson()), 409, headers: {'content-type': ProblemDto.mediaType});
    });

    final result = await reservationsOver(server, tokens: tokens).create(lastTableFor('u-ana'));

    expect(result, const Failure<Reservation>(NoTableAvailable()));
  });

  test('a server that cannot be reached becomes a RepositoryException the screens can explain', () async {
    final server = MockClient((request) async => throw http.ClientException('Connection refused', request.url));

    expect(
      reservationsOver(server).create(lastTableFor('u-ana')),
      throwsA(isA<RepositoryException>().having((e) => e.failure, 'failure', RepositoryFailure.unreachable)),
    );
  });
}
