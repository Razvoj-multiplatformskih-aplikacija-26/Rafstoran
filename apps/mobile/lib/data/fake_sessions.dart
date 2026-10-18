import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final class FakeSessions implements SessionRepository {
  FakeSessions(this._user);

  final User _user;
  User? _current;

  @override
  Future<User?> logIn({required String username, required String password}) async =>
      _current = password.isEmpty ? null : _user;

  @override
  Future<User?> current() async => _current ?? _user;

  @override
  Future<void> logOut() async => _current = null;

  @override
  Stream<void> get expirations => const Stream.empty();
}
