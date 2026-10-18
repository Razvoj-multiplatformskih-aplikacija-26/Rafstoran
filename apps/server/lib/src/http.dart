import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;

final _problemMimeType = MimeType.parse(ProblemDto.mediaType);

Response json(int status, Object? body) =>
    Response(status, body: Body.fromString(jsonEncode(body), mimeType: MimeType.json));

Response problem(DomainError error) => problemResponse(error.toProblem());

Response problemResponse(ProblemDto problem) =>
    Response(problem.status, body: Body.fromString(jsonEncode(problem.toJson()), mimeType: _problemMimeType));

Response badRequest(String title) =>
    problemResponse(ProblemDto(status: 400, code: ErrorCodes.badRequest, title: title));

Future<Map<String, Object?>> readObject(Request request) async => switch (jsonDecode(await request.readAsString())) {
  final Map<String, Object?> object => object,
  _ => throw const FormatException('Expected a JSON object'),
};

Response respond(Result<Reservation> result, {int status = 200}) => switch (result) {
  Success(:final value) => json(status, value.toDto().toJson()),
  Failure(:final error) => problem(error),
};

Middleware handleErrors() =>
    (Handler next) => (Request request) async {
      try {
        return await next(request);
      } on FormatException catch (error) {
        return badRequest(error.message);
      }
    };
