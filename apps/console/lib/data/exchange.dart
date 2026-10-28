import 'package:equatable/equatable.dart';

final class Exchange extends Equatable {
  const Exchange({
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
    required this.answer,
  });

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final String? body;
  final Answer answer;

  @override
  List<Object?> get props => [method, url, headers, body, answer];
}

sealed class Answer extends Equatable {
  const Answer();
}

final class Answered extends Answer {
  const Answered({
    required this.status,
    required this.elapsed,
    required this.contentType,
    required this.body,
    this.message,
  });

  final int status;
  final Duration elapsed;
  final String contentType;
  final String body;
  final String? message;

  @override
  List<Object?> get props => [status, elapsed, contentType, body, message];
}

final class Unreachable extends Answer {
  const Unreachable();

  @override
  List<Object?> get props => [];
}
