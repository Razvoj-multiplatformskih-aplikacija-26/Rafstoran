import 'dart:async';
import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:use_cases/use_cases.dart';

sealed class ApiAnswer {
  const ApiAnswer();
}

final class ApiAccepted extends ApiAnswer {
  const ApiAccepted(this.json);

  final Object? json;
}

final class ApiRejected extends ApiAnswer {
  const ApiRejected(this.error);

  final DomainError error;
}

final class ApiClient {
  ApiClient({
    required this.baseUri,
    required this.userId,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 10),
  }) : _http = httpClient ?? http.Client();

  final Uri baseUri;
  final UserId userId;
  final Duration timeout;
  final http.Client _http;

  Future<ApiAnswer> get(String path, {Map<String, String>? query}) => _send('GET', path, query: query);

  Future<ApiAnswer> post(String path, {Map<String, Object?>? body}) => _send('POST', path, body: body);

  Future<ApiAnswer> _send(String method, String path, {Map<String, String>? query, Map<String, Object?>? body}) async {
    final request = http.Request(method, baseUri.replace(path: path, queryParameters: query))
      ..headers[ApiHeaders.userId] = userId.value
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
    }
    final http.Response response;
    try {
      response = await http.Response.fromStream(await _http.send(request).timeout(timeout));
    } on http.ClientException catch (cause) {
      throw RepositoryException('Server unreachable', failure: RepositoryFailure.unreachable, cause: cause);
    } on TimeoutException catch (cause) {
      throw RepositoryException('Server did not answer', failure: RepositoryFailure.unreachable, cause: cause);
    }
    return _answerOf(response);
  }

  ApiAnswer _answerOf(http.Response response) {
    final status = response.statusCode;
    final json = readJson(() => response.body.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes)));
    if (status >= 200 && status < 300) return ApiAccepted(json);
    if (status >= 400 && status < 500 && json is Map<String, Object?>) {
      final error = readJson(() => ProblemDto.fromJson(json).toDomainError());
      if (error != null) return ApiRejected(error);
    }
    throw RepositoryException('Server answered $status', failure: RepositoryFailure.serverError);
  }
}

T readJson<T>(T Function() read) {
  try {
    return read();
  } on FormatException catch (cause) {
    throw RepositoryException('Unreadable answer', failure: RepositoryFailure.serverError, cause: cause);
  } on ArgumentError catch (cause) {
    throw RepositoryException('Unreadable answer', failure: RepositoryFailure.serverError, cause: cause);
  }
}

T accepted<T>(ApiAnswer answer, T Function(Object? json) read) => switch (answer) {
  ApiAccepted(:final json) => readJson(() => read(json)),
  ApiRejected(:final error) => throw RepositoryException(
    'Unexpected rejection $error',
    failure: RepositoryFailure.serverError,
  ),
};

Result<T> resultOf<T>(ApiAnswer answer, T Function(Object? json) read) => switch (answer) {
  ApiAccepted(:final json) => Success(readJson(() => read(json))),
  ApiRejected(:final error) => Failure(error),
};

Map<String, Object?> object(Object? json) => switch (json) {
  final Map<String, Object?> object => object,
  _ => throw FormatException('Expected a JSON object', json),
};

List<Map<String, Object?>> objects(Object? json) => switch (json) {
  final List<Object?> list => [for (final item in list) object(item)],
  _ => throw FormatException('Expected a JSON list', json),
};
