import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final class RememberedSession implements SessionRepository {
  RememberedSession(this.remembered);

  User? remembered;
  final _expirations = StreamController<void>.broadcast();

  void expire() => _expirations.add(null);

  @override
  Future<User?> logIn({required String username, required String password}) async => null;

  @override
  Future<User?> current() async => remembered;

  @override
  Future<void> logOut() async => remembered = null;

  @override
  Stream<void> get expirations => _expirations.stream;
}

void main() {
  const guest = User(id: UserId('u-guest'), username: 'guest1', role: Role.guest);
  late RememberedSession sessions;

  blocTest<SessionBloc, SessionState>(
    'a remembered login survives a restart and ends with a reason when the server says it expired',
    setUp: () => sessions = RememberedSession(guest),
    build: () => SessionBloc(
      restoreSession: RestoreSession(sessions: sessions),
      logOut: LogOut(sessions: sessions),
      expirations: sessions.expirations,
    ),
    act: (bloc) async {
      bloc.add(const SessionRestoreRequested());
      await Future<void>.delayed(Duration.zero);
      sessions.expire();
    },
    expect: () => [const SignedIn(guest), const SignedOut(reason: SignOutReason.expired)],
  );
}
