import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'local/local_database.dart';

final class LocalFirstSessions implements SessionRepository {
  LocalFirstSessions({required this.remote, required this.database});

  final SessionRepository remote;
  final LocalDatabase database;

  @override
  Future<User?> logIn({required String username, required String password}) async {
    final user = await remote.logIn(username: username, password: password);
    if (user != null) await _remember(user);
    return user;
  }

  @override
  Future<User?> current() async {
    try {
      final user = await remote.current();
      if (user == null) {
        await database.clear();
        return null;
      }
      await _remember(user);
      return user;
    } on RepositoryException catch (error) {
      if (error.failure case RepositoryFailure.unreachable || RepositoryFailure.serverError) return _remembered();
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await remote.logOut();
    } finally {
      await database.clear();
    }
  }

  @override
  Stream<void> get expirations => remote.expirations.asyncMap((_) => database.clear());

  Future<void> _remember(User user) async {
    final remembered = await _remembered();
    if (remembered != null && remembered.id != user.id) await database.clear();
    await database
        .into(database.signedInUsers)
        .insertOnConflictUpdate(
          SignedInUsersCompanion.insert(id: user.id.value, contract: jsonEncode(user.toDto().toJson())),
        );
  }

  Future<User?> _remembered() async {
    final row = await database.select(database.signedInUsers).getSingleOrNull();
    return row == null ? null : UserDto.fromJson(jsonDecode(row.contract) as Map<String, Object?>).toDomain();
  }
}
