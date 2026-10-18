// Ready for copy; adapt User and Role.
import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;

import 'account_store.dart';
import 'http.dart';
import 'passwords.dart';

final class Session {
  const Session({required this.user, required this.expiresAt});

  final User user;
  final DateTime expiresAt;
}

final currentSession = ContextProperty<Session>('session');

const _sessionExpired = ProblemDto(status: 401, code: ErrorCodes.sessionExpired, title: 'Session expired');
const _invalidCredentials = ProblemDto(status: 401, code: ErrorCodes.invalidCredentials, title: 'Invalid credentials');

final class SessionHandlers {
  SessionHandlers({required this.accounts, required String secret, required this.ttl}) : _key = SecretKey(secret);

  final AccountStore accounts;
  final Duration ttl;
  final SecretKey _key;

  Handler signedIn(Handler handler) => (Request request) async {
    final session = switch (_tokenOf(request)) {
      final token? => _verify(token),
      null => null,
    };
    if (session == null) return problemResponse(_sessionExpired);
    currentSession[request] = session;
    return handler(request);
  };

  Handler optionallySignedIn(Handler handler) => (Request request) async {
    final session = switch (_tokenOf(request)) {
      final token? => _verify(token),
      null => null,
    };
    if (session != null) currentSession[request] = session;
    return handler(request);
  };

  Future<Response> logIn(Request request) async {
    final body = LoginDto.fromJson(await readObject(request));
    final account = await accounts.account(body.username);
    if (account == null || !await verifyPassword(body.password, account.passwordHash)) {
      return problemResponse(_invalidCredentials);
    }
    final user = account.user;
    final token = JWT({
      'name': user.username,
      'role': user.role.name,
    }, subject: user.id.value).sign(_key, expiresIn: ttl);
    final session = _verify(token)!;
    final dto = SessionDto(user: user.toDto(), expiresAt: session.expiresAt, token: body.cookie ? null : token);
    final response = json(201, dto.toJson());
    if (!body.cookie) return response;
    return response.copyWith(
      headers: response.headers.transform(
        (headers) => headers.setCookie = SetCookieHeader(
          name: ApiCookies.session,
          value: token,
          path: Uri.parse('/'),
          maxAge: ttl.inSeconds,
          httpOnly: true,
          sameSite: SameSite.lax,
        ),
      ),
    );
  }

  Future<Response> current(Request request) async {
    final session = currentSession.get(request);
    return json(200, SessionDto(user: session.user.toDto(), expiresAt: session.expiresAt).toJson());
  }

  Future<Response> logOut(Request request) async => Response.noContent(
    headers: Headers.build(
      (headers) =>
          headers.setCookie = SetCookieHeader(name: ApiCookies.session, value: 'x', path: Uri.parse('/'), maxAge: 0),
    ),
  );

  Session? _verify(String token) {
    try {
      return switch (JWT.verify(token, _key).payload) {
        {'sub': final String id, 'name': final String name, 'role': final String role, 'exp': final int exp} => Session(
          user: User(id: UserId(id), username: name, role: Role.values.byName(role)),
          expiresAt: DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true),
        ),
        _ => null,
      };
    } on JWTException {
      return null;
    }
  }

  String? _tokenOf(Request request) => switch (request.headers.authorization) {
    BearerAuthorizationHeader(:final token) => token,
    _ => request.headers.cookie?.getCookie(ApiCookies.session)?.value,
  };
}
