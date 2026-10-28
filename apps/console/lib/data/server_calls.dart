import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:ui/ui.dart';

import 'exchange.dart';

final class ServerCalls {
  ServerCalls({required this.client, required this.server});

  final http.Client client;
  final Uri server;

  Future<Exchange> get(String path, {Map<String, String>? query, UserId? caller}) => _send(
    'GET',
    server.replace(path: path, queryParameters: query),
    {if (caller != null) ApiHeaders.userId: caller.value},
    null,
  );

  Future<Exchange> post(String path, Map<String, Object?> body, {required UserId caller}) => _send(
    'POST',
    server.replace(path: path),
    {'Content-Type': 'application/json', ApiHeaders.userId: caller.value},
    jsonEncode(body),
  );

  Future<Exchange> _send(String method, Uri url, Map<String, String> headers, String? body) async {
    final request = http.Request(method, url)..headers.addAll(headers);
    if (body != null) request.body = body;
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.Response.fromStream(await client.send(request));
      final contentType = response.headers['content-type'] ?? '';
      return Exchange(
        method: method,
        url: url,
        headers: request.headers,
        body: body == null ? null : _pretty(body),
        answer: Answered(
          status: response.statusCode,
          elapsed: stopwatch.elapsed,
          contentType: contentType,
          body: _pretty(response.body),
          message: _message(contentType, response.body),
        ),
      );
    } on Exception {
      return Exchange(method: method, url: url, headers: request.headers, body: body, answer: const Unreachable());
    }
  }

  String _pretty(String text) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(text));
    } on FormatException {
      return text;
    }
  }

  String? _message(String contentType, String text) {
    if (!contentType.startsWith(ProblemDto.mediaType)) return null;
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, Object?>) return null;
      final problem = ProblemDto.fromJson(json);
      return problem.toDomainError()?.message ?? problem.title;
    } on FormatException {
      return null;
    }
  }
}
